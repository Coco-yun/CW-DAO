// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuthorManager {
    // 定义作者结构体，新增 articleIds 数组，用于存储该作者所有文章的 id
    struct Author {
        string authorName;
        uint256 authorId;
        address[] following; // 记录该作者关注的其它用户
        address[] follower; // 记录关注该作者的粉丝（用户）
        uint256[] articleIds;
        bytes32 photoHash;
        uint256[] collectArticleIds;
    }

    // 记录已注册的作者总数（作者ID自增）
    uint256 public authorCount;

    // 存放所有作者信息的数组
    Author[] public authors;

    // 映射：作者ID 到 注册者的地址
    mapping(uint256 => address) public authorAddressMapping;
    // 映射：作者ID 到 作者名称
    mapping(uint256 => string) public authorStringMapping;
    // 映射：判断某个地址是否已经注册，避免重复注册
    mapping(address => bool) public isRegistered;
    // 映射：用户地址 到 作者ID，便于快速查询作者在数组中的索引（注意：作者ID从1开始）
    mapping(address => uint256) public authorIdMapping;

    // 事件：用户注册成功后触发
    event AuthorRegistered(
        uint256 indexed authorId,
        address indexed authorAddress,
        string authorName
    );

    /**
     * @dev 用户注册函数
     * @param _authorName 用户要注册的名称
     *
     * 要求每个地址只能注册一次。
     */
    function registerAuthor(string memory _authorName) public {
        // 检查 msg.sender 是否已注册
        require(!isRegistered[msg.sender], "Address already registered.");

        // 更新计数器，生成新的作者ID
        authorCount++;
        uint256 newAuthorId = authorCount;

        // 将新用户信息存储到数组中，同时 follower 和 following 数组会自动初始化为空
        authors.push(
            Author({
                authorName: _authorName,
                authorId: newAuthorId,
                following: new address[](0), // 修正动态数组初始化
                follower: new address[](0), // 修正动态数组初始化
                articleIds: new uint256[](0), // 修正动态数组初始化
                photoHash: bytes32(0), // 初始化 photoHash
                collectArticleIds: new uint256[](0) // 初始化 collectArticleIds
            })
        );

        // 更新映射信息
        authorAddressMapping[newAuthorId] = msg.sender;
        authorStringMapping[newAuthorId] = _authorName;
        isRegistered[msg.sender] = true;
        authorIdMapping[msg.sender] = newAuthorId;

        // 触发用户注册事件
        emit AuthorRegistered(newAuthorId, msg.sender, _authorName);
    }

    /**
     * @dev 给已注册的作者添加一篇文章的id
     * @param _articleId 要添加的文章id
     */
    function addArticleForAuthor(
        uint256 _articleId,
        address _authorAddress
    ) public {
        // 检查该地址是否已注册
        require(isRegistered[_authorAddress], "Address not registered.");

        // 获取注册时映射的作者 ID，并转换为数组的正确索引
        uint256 authorIndex = authorIdMapping[_authorAddress] - 1;

        // 在正确的作者记录中添加文章 id
        authors[authorIndex].articleIds.push(_articleId);
    }

    /**
     * @dev 查询某个用户的所有文章id
     * @param _authorAddress 用户的地址
     * @return 返回该作者的所有文章 id 数组
     */
    function getArticlesForAuthor(
        address _authorAddress
    ) public view returns (uint256[] memory) {
        // 检查传入地址是否已注册
        require(isRegistered[_authorAddress], "Address not registered.");
        uint256 authorId = authorIdMapping[_authorAddress];
        return authors[authorId - 1].articleIds;
    }

    /**
     * @dev 增加用户粉丝：
     *      通过传入目标用户地址 _userAddress 和粉丝地址 _followerAddress，
     *      将 _followerAddress 添加到目标用户的 follower 数组中。
     */
    function addFollower(
        address _userAddress,
        address _followerAddress
    ) public {
        require(isRegistered[_userAddress], "Target user not registered.");
        require(isRegistered[_followerAddress], "Follower not registered.");
        uint256 authorIndex = authorIdMapping[_userAddress] - 1;

        // 检查该粉丝是否已存在
        for (uint256 i = 0; i < authors[authorIndex].follower.length; i++) {
            require(
                authors[authorIndex].follower[i] != _followerAddress,
                "Follower already added."
            );
        }

        authors[authorIndex].follower.push(_followerAddress);
    }

    /**
     * @dev 减少用户粉丝：
     *      通过传入目标用户地址 _userAddress 和粉丝地址 _followerAddress，
     *      将 _followerAddress 从目标用户的 follower 数组中移除。
     */
    function removeFollower(
        address _userAddress,
        address _followerAddress
    ) public {
        require(isRegistered[_userAddress], "User not registered.");
        uint256 authorIndex = authorIdMapping[_userAddress] - 1;
        uint256 length = authors[authorIndex].follower.length;
        bool found = false;
        uint256 indexToRemove;

        for (uint256 i = 0; i < length; i++) {
            if (authors[authorIndex].follower[i] == _followerAddress) {
                found = true;
                indexToRemove = i;
                break;
            }
        }
        require(found, "Follower not found.");

        // 使用 swap and pop 移除元素
        authors[authorIndex].follower[indexToRemove] = authors[authorIndex]
            .follower[length - 1];
        authors[authorIndex].follower.pop();
    }

    /**
     * @dev 增加用户关注：
     *      允许 msg.sender 关注其他用户，传入目标用户地址 _targetAddress
     */
    function addFollowing(address _targetAddress) public {
        require(isRegistered[msg.sender], "Caller not registered.");
        require(isRegistered[_targetAddress], "Target not registered.");
        uint256 authorIndex = authorIdMapping[msg.sender] - 1;

        // 检查是否已关注该目标
        for (uint256 i = 0; i < authors[authorIndex].following.length; i++) {
            require(
                authors[authorIndex].following[i] != _targetAddress,
                "Already following the target."
            );
        }

        authors[authorIndex].following.push(_targetAddress);
    }

    /**
     * @dev 减少用户关注：
     *      允许 msg.sender 取消关注目标用户，传入目标用户地址 _targetAddress
     */
    function removeFollowing(address _targetAddress) public {
        require(isRegistered[msg.sender], "Caller not registered.");
        uint256 authorIndex = authorIdMapping[msg.sender] - 1;
        uint256 length = authors[authorIndex].following.length;
        bool found = false;
        uint256 indexToRemove;

        for (uint256 i = 0; i < length; i++) {
            if (authors[authorIndex].following[i] == _targetAddress) {
                found = true;
                indexToRemove = i;
                break;
            }
        }
        require(found, "Not following the target.");

        authors[authorIndex].following[indexToRemove] = authors[authorIndex]
            .following[length - 1];
        authors[authorIndex].following.pop();
    }

    /**
     * @dev 通过用户地址查询详细的作者信息，包括作者名称、作者ID、关注/粉丝列表、文章列表等
     * @param _authorAddress 用户地址
     * @return 返回对应的 Author 结构体数据
     */
    function getAuthorInformationByAddress(
        address _authorAddress
    ) public view returns (Author memory) {
        require(isRegistered[_authorAddress], "Address not registered.");
        uint256 authorIndex = authorIdMapping[_authorAddress] - 1;
        return authors[authorIndex];
    }

    /**
     * @dev 设置/修改头像
     * @param _authorAddress 用户地址
     * @param _photoHash 头像hash
     */
    function setAuthorPhotoHashByAddress(
        address _authorAddress,
        bytes32 _photoHash
    ) public {
        uint256 authorIndex = authorIdMapping[_authorAddress] - 1;
        authors[authorIndex].photoHash = _photoHash;
    }

    /**
     * @dev 设置收藏的帖子
     * @param _authorAddress 用户地址
     * @param _collectArticleId 收集的文章Id
     */
    function setCollectArticleId(
        address _authorAddress,
        uint256 _collectArticleId
    ) public {
        require(authorIdMapping[_authorAddress] != 0, "Author not registered");
        uint256 authorIndex = authorIdMapping[_authorAddress] - 1;
        authors[authorIndex].collectArticleIds.push(_collectArticleId);
    }

    /**
     * @dev 查询收藏的帖子ID
     * @param _authorAddress 用户地址
     */
    function getCollectArticleId(
        address _authorAddress
    ) public view returns (uint256[] memory) {
        require(authorIdMapping[_authorAddress] != 0, "Author not registered");
        uint256 authorIndex = authorIdMapping[_authorAddress] - 1;
        return authors[authorIndex].collectArticleIds;
    }
}
//0x1664cb3230D0CE06A7825dE3F28075F2eCccAf91
