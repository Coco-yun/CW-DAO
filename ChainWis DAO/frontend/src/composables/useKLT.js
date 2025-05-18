import Web3 from "web3";
import KLTJSON from "../json/KLT.json";

const useKLT = () => {
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
  let KLTContract;
  const contractAddress = "0x1D54D22fb8D85b13bbEb9E8648A618c4B69B5A6f";

  try {
    web3 = new Web3(getProvider());
    console.log("Web3 instance:", web3);

    // 验证合约地址
    if (!web3.utils.isAddress(contractAddress)) {
      throw new Error("Invalid contract address");
    }

    // 实例化合约
    KLTContract = new web3.eth.Contract(KLTJSON.abi, contractAddress);
    console.log("KLT contract instance:", KLTContract);

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

    // approve 交互方法
    const approve = async (spenderAddress, amount) => {
      try {
        const account = await getAccount();
        const amountWei = web3.utils.toWei(amount.toString(), "ether");

        return KLTContract.methods
          .approve(spenderAddress, amountWei)
          .send({ from: account });
      } catch (error) {
        console.error("Approve error:", error);
        throw error;
      }
    };

    // transfer 交互方法
    const transfer = async (toAddress, amount) => {
      try {
        const account = await getAccount();
        const amountWei = web3.utils.toWei(amount.toString(), "ether");

        return KLTContract.methods
          .transfer(toAddress, amountWei)
          .send({ from: account });
      } catch (error) {
        console.error("Transfer error:", error);
        throw error;
      }
    };

    // transferFrom 交互方法
    const transferFrom = async (fromAddress, toAddress, amount) => {
      try {
        const account = await getAccount();
        const amountWei = web3.utils.toWei(amount.toString(), "ether");

        return KLTContract.methods
          .transferFrom(fromAddress, toAddress, amountWei)
          .send({ from: account });
      } catch (error) {
        console.error("TransferFrom error:", error);
        throw error;
      }
    };

    // 获取总发行量
    const getTotalSupply = async () => {
      try {
        const supply = await KLTContract.methods.totalSupply().call();
        return web3.utils.fromWei(supply, "ether");
      } catch (error) {
        console.error("TotalSupply error:", error);
        throw error;
      }
    };

    // ****** 新增交互方法 ******

    // 获取指定地址的代币余额
    const balanceOf = async (address) => {
      try {
        const balance = await KLTContract.methods.balanceOf(address).call();
        return web3.utils.fromWei(balance, "ether");
      } catch (error) {
        console.error("获取余额失败:", error);
        throw error;
      }
    };

    return {
      web3,
      KLTContract,
      contractAddress,
      getAccount,
      approve,
      transfer,
      transferFrom,
      getTotalSupply,
      balanceOf,
    };
  } catch (error) {
    console.error("Web3 initialization failed:", error);
    return null;
  }
};

export default useKLT;
