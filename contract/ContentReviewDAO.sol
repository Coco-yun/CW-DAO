// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ContentManager.sol";
import "./KLT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContentReviewDAO {
    address public owner;
    address public contentManagerAddress;
    ContentManager public contentManagerContract;
    KLT public KLTContract;

    // 治理参数
    uint256 public eliminationRatio = 1000; // 万分比淘汰比例（例如 1000 表示 10%）
    uint256 public minimumVotingPeriod = 1 days; // 最小投票持续时间

    // 质押相关状态变量
    mapping(address => uint256) public reviewerStakes; // 审核者质押量
    uint256 public totalStakedKLT; // 总质押量
    uint256 public constant REVIEWER_STAKE = 10 * 1e18; // 申请审核者需质押的 KLT 数量
    uint256 public constant MIN_VOTE_STAKE = 5 * 1e18; // 最小投票质押量

    // 审核者数据结构
    struct Reviewer {
        uint256 joinTime;
        uint256 reviewerId;
        address reviewerAddress;
        uint256 totalReviews;
        uint256 reputationScore; // 初始及动态声誉评分
    }

    // 申请提案结构（申请成为 reviewer）
    struct Application {
        address applicant;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 startTime;
        mapping(address => bool) hasVoted;
        bool resolved;
    }

    // 核心存储结构
    address[] public reviewersList;
    mapping(address => Reviewer) public reviewers;
    mapping(address => bool) public isReviewer;
    mapping(address => uint256) public reviewerIndex;
    mapping(address => Application) public pendingApplications;
    address[] public applicationQueue;

    // 针对文章投票相关状态
    mapping(uint256 => mapping(address => bool)) public articleVotes; // 针对文章的投票记录
    mapping(uint256 => uint256) public articleVoteCount; // 针对文章的投票总数

    uint256 public reviewerCount;

    // 事件声明
    event ReviewerAdded(
        uint256 reviewerId,
        address reviewerAddress,
        uint256 joinTime
    );
    event ReviewerRemoved(address reviewerAddress);
    event ApplicationSubmitted(address applicant);
    event ApplicationVoted(address applicant, address voter, bool support);
    event ApplicationApproved(address applicant);
    event ApplicationRejected(address applicant);
    event ArticleVote(
        address reviewer,
        uint256 articleId,
        uint256 newVoteCount
    );
    event ArticleUpdated(uint256 articleId, bytes32 newContentHash);

    constructor(address _KLTAddress, address _ContentManagerAddress) {
        owner = msg.sender;
        KLTContract = KLT(_KLTAddress);
        contentManagerAddress = _ContentManagerAddress;
        contentManagerContract = ContentManager(_ContentManagerAddress);
        // 构造函数将合约创建者自动设为第一个 reviewer
        _addReviewer(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // =============================
    // 申请成为审核者（需质押保证金）
    // =============================
    function applyForReviewer() external {
        require(!isReviewer[msg.sender], "Already reviewer");
        require(!pendingApplications[msg.sender].resolved, "Already applied");

        // 申请时需转移 REVIEWER_STAKE 数量的 KLT 到合约（申请前请先调用 KLT 的 approve）
        require(
            KLTContract.transferFrom(msg.sender, address(this), REVIEWER_STAKE),
            "Token transfer failed"
        );

        Application storage app = pendingApplications[msg.sender];
        app.applicant = msg.sender;
        app.startTime = block.timestamp;
        applicationQueue.push(msg.sender);

        emit ApplicationSubmitted(msg.sender);
    }

    // ============================================================
    // 针对申请成为 reviewer 的投票（支持声誉加权及质押）
    // ============================================================
    /**
     * @notice 当前已注册的 reviewer 使用质押投票方式，对申请者进行表决
     * @param _applicant 申请者地址
     * @param _support 投票立场，true 表示赞成，false 表示反对
     * @param stakeAmount 投票时质押的 KLT 数量（必须 >= MIN_VOTE_STAKE）
     */
    function voteForApplicant(
        address _applicant,
        bool _support,
        uint256 stakeAmount
    ) external {
        require(isReviewer[msg.sender], "Only reviewers can vote");
        Application storage app = pendingApplications[_applicant];
        require(!app.resolved, "Application already resolved");
        require(!app.hasVoted[msg.sender], "Already voted");
        require(stakeAmount >= MIN_VOTE_STAKE, "Stake amount too low");

        // 转移质押代币（投票人需先调用 approve）
        require(
            KLTContract.transferFrom(msg.sender, address(this), stakeAmount),
            "Token transfer failed"
        );

        // 更新投票人质押记录
        reviewerStakes[msg.sender] += stakeAmount;
        totalStakedKLT += stakeAmount;

        // 声誉更新：基础 +10 分，加上每质押 1 KLT 加 1 分
        uint256 reputationBoost = 10 + (stakeAmount / 1e18);
        reviewers[msg.sender].reputationScore += reputationBoost;

        // 声誉加权投票：基础 1 票 + 每 100 声誉加 1 票
        uint256 votingPower = 1 + (reviewers[msg.sender].reputationScore / 100);

        app.hasVoted[msg.sender] = true;
        if (_support) {
            app.yesVotes += votingPower;
        } else {
            app.noVotes += votingPower;
        }
        emit ApplicationVoted(_applicant, msg.sender, _support);

        // 动态阈值计算：全体 reviewer 投票权总和的 50%
        uint256 totalVotingPower = 0;
        for (uint256 i = 0; i < reviewersList.length; i++) {
            totalVotingPower +=
                1 +
                (reviewers[reviewersList[i]].reputationScore / 100);
        }
        uint256 threshold = (totalVotingPower * 5000) / 10000; // 50% 阈值

        // 根据投票结果判断：如果赞成票达到阈值则审批，否则在投票期后反对票超过阈值一半则拒绝
        if (app.yesVotes >= threshold) {
            _approveApplication(_applicant);
        } else if (
            block.timestamp > app.startTime + minimumVotingPeriod &&
            app.noVotes > (threshold / 2)
        ) {
            _rejectApplication(_applicant);
        }
    }

    function voteForArticleUpdate(
        uint256 _articleId,
        uint256 stakeAmount
    ) external {
        (bool isExist, bool isRelease) = contentManagerContract
            .checkArticleStatus(_articleId);

        require(isExist, "Article does not exist");
        require(!isRelease, "Article already released");

        require(isReviewer[msg.sender], "Only reviewers can vote");
        require(
            !articleVotes[_articleId][msg.sender],
            "Already voted on this article"
        );
        require(stakeAmount >= MIN_VOTE_STAKE, "Stake amount too low");

        // 转移质押代币
        require(
            KLTContract.transferFrom(msg.sender, address(this), stakeAmount),
            "Token transfer failed"
        );

        // 记录投票行为
        articleVotes[_articleId][msg.sender] = true;
        articleVoteCount[_articleId] += 1;

        // 更新投票人质押记录
        reviewerStakes[msg.sender] += stakeAmount;
        totalStakedKLT += stakeAmount;
        emit ArticleVote(msg.sender, _articleId, articleVoteCount[_articleId]);

        // 判断票数是否超过审核者总数一半（即多数票）后进行更新
        uint256 totalReviewers = reviewersList.length;
        if (articleVoteCount[_articleId] > totalReviewers / 2) {
            contentManagerContract.updataArticleRelease(_articleId);

            KLTContract.approve(contentManagerAddress, 1e18);

            (
                uint256 id,
                string memory content,
                bytes32 contentHash,
                uint256 likes,
                uint256 reward,
                bool release,
                address author
            ) = contentManagerContract.articles(_articleId);

            KLTContract.transfer(author, 1e18);
        }
    }

    // =====================================================
    // 优化后的淘汰机制（带声誉衰减及综合评分）
    // =====================================================
    /**
     * @notice 由合约拥有者调用，根据声誉（按月衰减）和综合评分淘汰表现不佳的审核者
     */
    function eliminateUnderperformingReviewers() external onlyOwner {
        uint256 total = reviewersList.length;
        require(total > 0, "No reviewers");

        // 计算需淘汰的审核者数量
        uint256 eliminateCount = (total * eliminationRatio) / 10000;
        eliminateCount = eliminateCount > 0 ? eliminateCount : 1;

        // 生成临时数组，记录每个审核者（包含声誉衰减后的数值）
        Reviewer[] memory reviewersTemp = new Reviewer[](total);
        for (uint256 i = 0; i < total; i++) {
            Reviewer storage r = reviewers[reviewersList[i]];
            // 声誉衰减：每 30 天衰减 5%
            uint256 monthsActive = (block.timestamp - r.joinTime) / 30 days;
            // 使用指数运算（注意：对于较大的 monthsActive 可能存在溢出风险，实际使用时需注意）
            reviewersTemp[i] = Reviewer({
                joinTime: r.joinTime,
                reviewerId: r.reviewerId,
                reviewerAddress: r.reviewerAddress,
                totalReviews: r.totalReviews,
                reputationScore: (r.reputationScore * (95 ** monthsActive)) /
                    (100 ** monthsActive)
            });
        }

        // 冒泡排序：按综合评分降序排列（综合评分 = totalReviews * 2 + reputationScore）
        for (uint256 i = 0; i < total - 1; i++) {
            for (uint256 j = 0; j < total - i - 1; j++) {
                if (
                    _calculateScore(reviewersTemp[j]) <
                    _calculateScore(reviewersTemp[j + 1])
                ) {
                    Reviewer memory temp = reviewersTemp[j];
                    reviewersTemp[j] = reviewersTemp[j + 1];
                    reviewersTemp[j + 1] = temp;
                }
            }
        }

        // 淘汰最低分的 eliminateCount 名审核者
        for (uint256 i = total - eliminateCount; i < total; i++) {
            address removeAddr = reviewersTemp[i].reviewerAddress;
            _removeReviewer(removeAddr);
        }
    }

    // 综合评分算法（这里简单地使用：总评论数×2 + 声誉）
    function _calculateScore(Reviewer memory r) private pure returns (uint256) {
        return r.totalReviews * 2 + r.reputationScore;
    }

    // =====================================================
    // 内部辅助函数
    // =====================================================
    function _approveApplication(address _applicant) private {
        Application storage app = pendingApplications[_applicant];
        app.resolved = true;
        // 为申请者累加审核者质押（申请时已扣除）
        reviewerStakes[_applicant] += REVIEWER_STAKE;
        totalStakedKLT += REVIEWER_STAKE;
        _addReviewer(_applicant);
        _removeFromQueue(_applicant);
        emit ApplicationApproved(_applicant);
    }

    function _rejectApplication(address _applicant) private {
        Application storage app = pendingApplications[_applicant];
        app.resolved = true;
        // 退还申请时质押的 KLT
        require(
            KLTContract.transfer(_applicant, REVIEWER_STAKE),
            "Refund failed"
        );
        _removeFromQueue(_applicant);
        emit ApplicationRejected(_applicant);
    }

    function _addReviewer(address _reviewer) private {
        reviewersList.push(_reviewer);
        reviewerIndex[_reviewer] = reviewersList.length - 1;
        isReviewer[_reviewer] = true;
        reviewerCount++;

        reviewers[_reviewer] = Reviewer({
            joinTime: block.timestamp,
            reviewerId: reviewerCount,
            reviewerAddress: _reviewer,
            totalReviews: 0,
            reputationScore: 100 // 初始声誉值
        });
        emit ReviewerAdded(reviewerCount, _reviewer, block.timestamp);
    }

    function _removeReviewer(address _reviewer) private {
        uint256 index = reviewerIndex[_reviewer];
        address lastAddress = reviewersList[reviewersList.length - 1];
        reviewersList[index] = lastAddress;
        reviewerIndex[lastAddress] = index;
        reviewersList.pop();

        // 计算退款：按用户质押占比退还合约余额的 90%
        uint256 contractBalance = KLTContract.balanceOf(address(this));
        uint256 userRatio = (reviewerStakes[_reviewer] * 1e18) / totalStakedKLT;
        uint256 refundAmount = (contractBalance * userRatio * 9) / (1e18 * 10);

        totalStakedKLT -= reviewerStakes[_reviewer];
        delete reviewerStakes[_reviewer];

        if (refundAmount > 0) {
            KLTContract.transfer(_reviewer, refundAmount);
        }

        delete reviewerIndex[_reviewer];
        isReviewer[_reviewer] = false;
        delete reviewers[_reviewer];
        reviewerCount--;

        emit ReviewerRemoved(_reviewer);
    }

    function _removeFromQueue(address _applicant) private {
        for (uint256 i = 0; i < applicationQueue.length; i++) {
            if (applicationQueue[i] == _applicant) {
                applicationQueue[i] = applicationQueue[
                    applicationQueue.length - 1
                ];
                applicationQueue.pop();
                break;
            }
        }
    }

    /**
     * @notice 获取申请的投票详情
     * @param _applicant 申请者地址
     * @return yes 赞成票数
     * @return no 反对票数
     * @return threshold 当前动态票数阈值
     */
    function getApplicationDetails(
        address _applicant
    ) external view returns (uint256 yes, uint256 no, uint256 threshold) {
        Application storage app = pendingApplications[_applicant];
        yes = app.yesVotes;
        no = app.noVotes;
        uint256 totalVotingPower = 0;
        for (uint256 i = 0; i < reviewersList.length; i++) {
            totalVotingPower +=
                1 +
                (reviewers[reviewersList[i]].reputationScore / 100);
        }
        threshold = (totalVotingPower * 5000) / 10000;
    }

    // =====================
    // Setter 函数
    // =====================
    function setContentManager(address _addr) external onlyOwner {
        contentManagerContract = ContentManager(_addr);
    }

    function setKLTContract(address _addr) external onlyOwner {
        KLTContract = KLT(_addr);
    }

    function getStakeOf(address _addr) external view returns (uint256) {
        return reviewerStakes[_addr];
    }

    // 获取所有申请成为审核者的详细信息
    function getAllApplications()
        external
        view
        returns (
            address[] memory applicants,
            uint256[] memory yesVotes,
            uint256[] memory noVotes,
            uint256[] memory startTimes,
            bool[] memory resolvedStatuses
        )
    {
        uint256 length = applicationQueue.length;
        applicants = new address[](length);
        yesVotes = new uint256[](length);
        noVotes = new uint256[](length);
        startTimes = new uint256[](length);
        resolvedStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            address applicant = applicationQueue[i];
            Application storage app = pendingApplications[applicant];
            applicants[i] = applicant;
            yesVotes[i] = app.yesVotes;
            noVotes[i] = app.noVotes;
            startTimes[i] = app.startTime;
            resolvedStatuses[i] = app.resolved;
        }
    }
}

// 0x4FA88b6B204906046126EE4813034d876E2eAffe
