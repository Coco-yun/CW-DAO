import Web3 from "web3";
import AuthorManagerJSON from "../json/AuthorManager.json";

const useAuthorManager = () => {
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
  let AuthorManagerContract;
  const contractAddress = "0x3c168c2DA2cC0d0c8E0602caC654d15a339fC548";

  try {
    web3 = new Web3(getProvider());
    console.log("Web3 instance:", web3);

    // 验证合约地址
    if (!web3.utils.isAddress(contractAddress)) {
      throw new Error("Invalid contract address");
    }

    // 实例化合约
    AuthorManagerContract = new web3.eth.Contract(
      AuthorManagerJSON.abi,
      contractAddress
    );
    console.log("AuthorManager contract instance:", AuthorManagerContract);

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

    // 核心交互方法

    // 注册作者
    const registerAuthor = async (authorName) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .registerAuthor(authorName)
          .send({ from: account });
      } catch (error) {
        console.error("注册失败:", error);
        throw new Error(
          error.message.includes("already registered")
            ? "该地址已注册"
            : "注册请求被拒绝"
        );
      }
    };

    // 添加文章
    const addArticleForAuthor = async (articleId, authorAddress) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .addArticleForAuthor(articleId, authorAddress)
          .send({ from: account });
      } catch (error) {
        console.error("添加文章失败:", error);
        throw new Error(
          error.message.includes("not registered")
            ? "目标地址未注册"
            : "交易执行失败"
        );
      }
    };

    // 查询作者所有文章 id 列表
    const getArticlesForAuthor = async (authorAddress) => {
      try {
        return AuthorManagerContract.methods
          .getArticlesForAuthor(authorAddress)
          .call();
      } catch (error) {
        console.error("查询失败:", error);
        throw new Error("无效地址或未注册作者");
      }
    };

    // 辅助查询方法，通过映射获取作者基本信息
    const getAuthorInfo = async (authorAddress) => {
      try {
        const authorId = await AuthorManagerContract.methods
          .authorIdMapping(authorAddress)
          .call();
        return {
          id: authorId,
          name: await AuthorManagerContract.methods
            .authorStringMapping(authorId)
            .call(),
          articleCount: (
            await AuthorManagerContract.methods
              .getArticlesForAuthor(authorAddress)
              .call()
          ).length,
        };
      } catch (error) {
        console.error("作者信息查询失败:", error);
        throw error;
      }
    };

    // —— 以下为新增加的交互函数 —— //

    // 通过作者ID查询注册地址
    const getAddressByAuthorId = async (authorId) => {
      try {
        return await AuthorManagerContract.methods
          .authorAddressMapping(authorId)
          .call();
      } catch (error) {
        console.error("获取地址失败:", error);
        throw new Error("查询作者地址失败");
      }
    };

    // 通过作者ID查询作者名称
    const getNameByAuthorId = async (authorId) => {
      try {
        return await AuthorManagerContract.methods
          .authorStringMapping(authorId)
          .call();
      } catch (error) {
        console.error("获取作者名称失败:", error);
        throw new Error("查询作者名称失败");
      }
    };

    // 查询某个地址是否已注册
    const isAddressRegistered = async (address) => {
      try {
        return await AuthorManagerContract.methods.isRegistered(address).call();
      } catch (error) {
        console.error("查询注册状态失败:", error);
        throw new Error("查询注册状态失败");
      }
    };

    // 通过地址查询对应的作者ID
    const getAuthorIdByAddress = async (address) => {
      try {
        return await AuthorManagerContract.methods
          .authorIdMapping(address)
          .call();
      } catch (error) {
        console.error("获取作者ID失败:", error);
        throw new Error("查询作者ID失败");
      }
    };

    // 通过 authors 数组直接查询作者完整数据（注意数组下标从 0 开始，所以需要传入的 authorId 减 1）
    const getAuthorFromArray = async (authorId) => {
      try {
        const index = authorId - 1;
        return await AuthorManagerContract.methods.authors(index).call();
      } catch (error) {
        console.error("查询作者数据失败:", error);
        throw new Error("查询作者数据失败");
      }
    };

    // 调用新增函数：添加粉丝
    const addFollower = async (userAddress, followerAddress) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .addFollower(userAddress, followerAddress)
          .send({ from: account });
      } catch (error) {
        console.error("添加粉丝失败:", error);
        throw new Error("添加粉丝失败:" + error.message);
      }
    };

    // 调用新增函数：移除粉丝
    const removeFollower = async (userAddress, followerAddress) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .removeFollower(userAddress, followerAddress)
          .send({ from: account });
      } catch (error) {
        console.error("移除粉丝失败:", error);
        throw new Error("移除粉丝失败:" + error.message);
      }
    };

    // 调用新增函数：添加关注（调用者关注目标地址）
    const addFollowing = async (targetAddress) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .addFollowing(targetAddress)
          .send({ from: account });
      } catch (error) {
        console.error("添加关注失败:", error);
        throw new Error("添加关注失败:" + error.message);
      }
    };

    // 调用新增函数：取消关注（调用者取消关注目标地址）
    const removeFollowing = async (targetAddress) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .removeFollowing(targetAddress)
          .send({ from: account });
      } catch (error) {
        console.error("取消关注失败:", error);
        throw new Error("取消关注失败:" + error.message);
      }
    };

    // 调用新增函数：通过地址查询完整的作者信息（包含名称、ID、关注/粉丝列表及文章列表）
    const getAuthorInformationByAddress = async (authorAddress) => {
      try {
        return await AuthorManagerContract.methods
          .getAuthorInformationByAddress(authorAddress)
          .call();
      } catch (error) {
        console.error("获取作者详细信息失败:", error);
        throw new Error("获取作者详细信息失败:" + error.message);
      }
    };

    // —— 新增与 setCollectArticleId 交互的函数 —— //
    // 设置/更新收藏的文章ID，调用合约中的 setCollectArticleId 函数
    const setCollectArticleId = async (collectArticleId) => {
      try {
        const account = await getAccount();
        return AuthorManagerContract.methods
          .setCollectArticleId(account, collectArticleId)
          .send({ from: account });
      } catch (error) {
        console.error("设置收藏帖子失败:", error);
        throw new Error("设置收藏帖子失败:" + error.message);
      }
    };

    return {
      web3,
      AuthorManagerContract,
      contractAddress,
      getAccount,
      registerAuthor,
      addArticleForAuthor,
      getArticlesForAuthor,
      getAuthorInfo,
      // 已有的查询函数
      getAddressByAuthorId,
      getNameByAuthorId,
      isAddressRegistered,
      getAuthorIdByAddress,
      getAuthorFromArray,
      // 新增加的交互函数
      addFollower,
      removeFollower,
      addFollowing,
      removeFollowing,
      getAuthorInformationByAddress,
      // 新增的和 setCollectArticleId 交互的函数
      setCollectArticleId,
    };
  } catch (error) {
    console.error("Web3 initialization failed:", error);
    return null;
  }
};

export default useAuthorManager;
