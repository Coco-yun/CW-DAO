import Web3 from "web3";
import ContentReviewDAOJSON from "../json/ContentReviewDAO.json";

const useContentReviewDAO = () => {
  // 初始化 Web3（增强版）
  const getProvider = () => {
    if (typeof window !== "undefined" && window.ethereum) {
      return window.ethereum;
    }
    // 验证 Infura 项目 ID
    const projectId = "b5ec59d9451e4bdeaf5b81d6e87277ee";
    if (!projectId) throw new Error("Missing Infura project ID");
    return `wss://sepolia.infura.io/ws/v3/${projectId}`;
  };

  let web3;
  let ContentReviewDAOContract;
  const contractAddress = "0x4FA88b6B204906046126EE4813034d876E2eAffe";

  try {
    web3 = new Web3(getProvider());
    console.log("Web3 instance:", web3);

    // 验证合约地址
    if (!web3.utils.isAddress(contractAddress)) {
      throw new Error("Invalid contract address");
    }

    // 实例化合约
    ContentReviewDAOContract = new web3.eth.Contract(
      ContentReviewDAOJSON.abi,
      contractAddress
    );
    console.log("ContentReviewDAOContract instance:", ContentReviewDAOContract);

    // 获取账户（增强错误处理）
    const getAccount = async () => {
      try {
        const accounts = await web3.eth.requestAccounts();
        if (accounts.length === 0) throw new Error("No accounts available");
        return accounts[0];
      } catch (error) {
        console.error("Account error:", error.message);
        return null;
      }
    };

    // ===========================
    // 核心交互方法（申请/投票/管理）
    // ===========================
    const applyForReviewer = async () => {
      try {
        const account = await getAccount();
        return ContentReviewDAOContract.methods
          .applyForReviewer()
          .send({ from: account });
      } catch (error) {
        console.error("申请失败:", error);
        throw new Error(
          error.message.includes("transfer") ? "代币授权不足" : "申请被拒绝"
        );
      }
    };

    const voteForApplicant = async (applicant, support, stakeAmount) => {
      try {
        const account = await getAccount();
        // 添加单位转换逻辑
        const weiAmount = web3.utils.toWei(stakeAmount.toString(), "ether");

        return ContentReviewDAOContract.methods
          .voteForApplicant(applicant, support, weiAmount)
          .send({ from: account });
      } catch (error) {
        console.error("投票失败:", error);
        throw new Error(
          error.message.includes("reviewer")
            ? "非审核者无权投票"
            : error.message.includes("invalid BigNumber string")
            ? "无效的数值格式"
            : "质押金额不足"
        );
      }
    };

    const voteForArticleUpdate = async (articleId, stakeAmount) => {
      try {
        const account = await getAccount();
        const weiAmount = web3.utils.toWei(stakeAmount.toString(), "ether");
        return ContentReviewDAOContract.methods
          .voteForArticleUpdate(articleId, weiAmount)
          .send({ from: account });
      } catch (error) {
        console.error("文章投票失败:", error);
        throw new Error(
          error.message.includes("release") ? "文章已发布" : "投票条件未满足"
        );
      }
    };

    const eliminateReviewers = async () => {
      try {
        return ContentReviewDAOContract.methods
          .eliminateUnderperformingReviewers()
          .send({ from: await getAccount() });
      } catch (error) {
        console.error("淘汰失败:", error);
        throw new Error("仅合约所有者可执行此操作");
      }
    };

    // ===========================
    // 查询方法
    // ===========================
    const getApplicationDetails = async (applicant) => {
      try {
        const result = await ContentReviewDAOContract.methods
          .getApplicationDetails(applicant)
          .call();
        return {
          yesVotes: result[0],
          noVotes: result[1],
          threshold: result[2],
        };
      } catch (error) {
        console.error("申请详情获取失败:", error);
        throw new Error("无效的申请人地址");
      }
    };

    const getReviewerInfo = async (address) => {
      try {
        return await ContentReviewDAOContract.methods.reviewers(address).call();
      } catch (error) {
        console.error("审核者信息获取失败:", error);
        throw new Error("地址未注册为审核者");
      }
    };

    // 管理功能
    const setContentManager = async (newAddress) => {
      try {
        return ContentReviewDAOContract.methods
          .setContentManager(newAddress)
          .send({ from: await getAccount() });
      } catch (error) {
        console.error("合约地址更新失败:", error);
        throw new Error("仅所有者可修改合约地址");
      }
    };

    // ===========================
    // 新增交互函数（mapping 与全局变量）
    // ===========================
    // 通过 applicationQueue 获取当前申请队列
    const getApplicationQueue = async () => {
      try {
        if (ContentReviewDAOContract.methods.getApplicationQueue) {
          return await ContentReviewDAOContract.methods
            .getApplicationQueue()
            .call();
        }
        let queue = [];
        let i = 0;
        while (true) {
          try {
            let applicant = await ContentReviewDAOContract.methods
              .applicationQueue(i)
              .call();
            queue.push(applicant);
            i++;
          } catch (e) {
            break;
          }
        }
        return queue;
      } catch (error) {
        console.error("获取申请队列失败:", error);
        throw new Error("无法获取申请队列");
      }
    };

    // 查询全局变量
    const getEliminationRatio = async () => {
      try {
        return await ContentReviewDAOContract.methods.eliminationRatio().call();
      } catch (error) {
        console.error("获取 eliminationRatio 失败:", error);
        throw new Error("无法获取 eliminationRatio");
      }
    };

    const getMinimumVotingPeriod = async () => {
      try {
        return await ContentReviewDAOContract.methods
          .minimumVotingPeriod()
          .call();
      } catch (error) {
        console.error("获取 minimumVotingPeriod 失败:", error);
        throw new Error("无法获取 minimumVotingPeriod");
      }
    };

    const getTotalStakedKLT = async () => {
      try {
        return await ContentReviewDAOContract.methods.totalStakedKLT().call();
      } catch (error) {
        console.error("获取 totalStakedKLT 失败:", error);
        throw new Error("无法获取 totalStakedKLT");
      }
    };

    const getMinVoteStake = async () => {
      try {
        return await ContentReviewDAOContract.methods.MIN_VOTE_STAKE().call();
      } catch (error) {
        console.error("获取 MIN_VOTE_STAKE 失败:", error);
        throw new Error("无法获取 MIN_VOTE_STAKE");
      }
    };

    const getReviewerStakeAmount = async () => {
      try {
        return await ContentReviewDAOContract.methods.REVIEWER_STAKE().call();
      } catch (error) {
        console.error("获取 REVIEWER_STAKE 失败:", error);
        throw new Error("无法获取 REVIEWER_STAKE");
      }
    };

    // 新增查询函数：检查某个地址是否为审核者
    const isAddressReviewer = async (addr) => {
      try {
        return await ContentReviewDAOContract.methods.isReviewer(addr).call();
      } catch (error) {
        console.error("审核者状态查询失败:", error);
        throw new Error("无法查询审核者状态");
      }
    };

    // 新增查询函数：与合约中的 getAllApplications 进行交互
    const getAllApplications = async () => {
      try {
        const result = await ContentReviewDAOContract.methods
          .getAllApplications()
          .call();
        // result 是一个数组：[applicants, yesVotes, noVotes, startTimes, resolvedStatuses]
        return {
          applicants: result[0],
          yesVotes: result[1],
          noVotes: result[2],
          startTimes: result[3],
          resolvedStatuses: result[4],
        };
      } catch (error) {
        console.error("获取所有申请者信息失败:", error);
        throw new Error("无法获取所有申请者信息");
      }
    };

    // 新增查询函数：获取指定地址的质押金额（mapping reviewerStakes）
    const getStakeOf = async (addr) => {
      try {
        return await ContentReviewDAOContract.methods.getStakeOf(addr).call();
      } catch (error) {
        console.error("获取审核者质押失败:", error);
        throw new Error("无法获取该地址的质押金额");
      }
    };

    return {
      web3,
      ContentReviewDAOContract,
      contractAddress,
      getAccount,
      applyForReviewer,
      voteForApplicant,
      voteForArticleUpdate,
      eliminateReviewers,
      getApplicationDetails,
      getReviewerInfo,
      setContentManager,
      // 新增查询函数
      getApplicationQueue,
      getEliminationRatio,
      getMinimumVotingPeriod,
      getTotalStakedKLT,
      getMinVoteStake,
      getReviewerStakeAmount,
      isAddressReviewer,
      getAllApplications,
      getStakeOf, // 新增：通过 mapping 获取审核者质押金额
    };
  } catch (error) {
    console.error("Web3 initialization failed:", error);
    return null;
  }
};

export default useContentReviewDAO;
