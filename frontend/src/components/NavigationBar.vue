<template>
  <nav class="navbar">
    <div class="logo-container">
      <router-link to="/Home" class="logo-link">
        <img src="../assets/image/loge.png" alt="logo" class="logo-image" >
        
      </router-link>
      
    </div>

    <div class="nav-links">
      <router-link class="nav-link" to="/Home">首页</router-link>
      <router-link class="nav-link" to="/post">发布</router-link>
      <router-link class="nav-link" to="/profile">个人中心</router-link>
      <a class="nav-link" @click="handleModerationClick">审核</a>
    </div>

    <div class="connect-wallet">
      <button 
        @click="handleConnection" 
        class="connect-button"
        :class="{ 'connected': connected }"
        :title="connected ? '点击按钮取消连接' : '连接钱包'"
      >
        {{ connected ? accountDisplay : "连接钱包" }}
      </button>
    </div>
  </nav>
</template>

<script setup>
import { ethers } from "ethers";
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import useContentReviewDAO from "../composables/useContentReviewDAO";

const router = useRouter();
// 用户是否已连接钱包
const connected = ref(false);
// 连接的账户地址
const account = ref("");
// 是否是审核员
const isReviewer = ref(false);

// 计算属性：显示账户地址的缩略形式
const accountDisplay = computed(() => {
  if (!account.value) return "";
  return `${account.value.substring(0, 6)}...${account.value.substring(38)}`;
});

// 处理钱包连接
const handleConnection = async () => {
  try {
    if (!connected.value) {
      if (window.ethereum) {
        // 使用ethers v5或v6版本的方式创建provider
        let provider;
        try {
          // 尝试ethers v6的方式
          provider = new ethers.BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          account.value = await signer.getAddress();
          connected.value = true;
        } catch (e) {
          // 回退到ethers v5的方式
          provider = new ethers.providers.Web3Provider(window.ethereum);
          const accounts = await provider.send("eth_requestAccounts", []);
          account.value = accounts[0];
          connected.value = true;
        }
        console.log("钱包连接成功:", account.value);
        // 连接成功后检查是否是审核员
        checkReviewerStatus();
      } else {
        alert("请安装MetaMask钱包!");
      }
    } else {
      // 如果已连接，用户点击按钮则断开连接（仅UI层面）
      connected.value = false;
      account.value = "";
      isReviewer.value = false;
      console.log("钱包已断开连接");
    }
  } catch (error) {
    console.error("连接钱包时出错:", error);
    alert("连接钱包失败，请重试!");
  }
};

// 组件挂载时检查钱包是否已连接
onMounted(async () => {
  try {
    if (window.ethereum) {
      let provider;
      try {
        // 尝试ethers v6的方式
        provider = new ethers.BrowserProvider(window.ethereum);
        const accounts = await provider.listAccounts();
        if (accounts.length > 0) {
          account.value = accounts[0].address; // v6中账户是对象，需要获取address属性
          connected.value = true;
          console.log("已检测到连接的钱包:", account.value);
          // 检查是否是审核员
          checkReviewerStatus();
        }
      } catch (e) {
        // 回退到ethers v5的方式
        provider = new ethers.providers.Web3Provider(window.ethereum);
        const accounts = await provider.listAccounts();
        if (accounts.length > 0) {
          account.value = accounts[0];
          connected.value = true;
          console.log("已检测到连接的钱包:", account.value);
          // 检查是否是审核员
          checkReviewerStatus();
        }
      }

      // 监听账户变化
      window.ethereum.on("accountsChanged", (accounts) => {
        if (accounts.length > 0) {
          account.value = accounts[0];
          connected.value = true;
          console.log("钱包账户已切换:", account.value);
          // 账户变化时重新检查是否是审核员
          checkReviewerStatus();
        } else {
          account.value = "";
          connected.value = false;
          isReviewer.value = false;
          console.log("钱包已断开连接");
        }
      });
    }
  } catch (error) {
    console.error("检查钱包连接状态时出错:", error);
  }
});

// 检查用户是否是审核员
const checkReviewerStatus = async () => {
  try {
    if (connected.value && account.value) {
      const dao = useContentReviewDAO();
      if (dao) {
        isReviewer.value = await dao.isAddressReviewer(account.value);
        console.log("当前用户是否为审核员:", isReviewer.value);
      }
    }
  } catch (error) {
    console.error("检查审核员状态时出错:", error);
  }
};

// 处理审核链接点击事件
const handleModerationClick = () => {
  if (!connected.value) {
    alert("请先连接钱包");
    return;
  }
  
  if (isReviewer.value) {
    router.push("/Reviewer");
  } else {
    router.push("/noReviewer");
  }
};
</script>

<style scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 2.5rem;
  background-color: #70b7d8;
  border-bottom: 3px solid var(--primary-light);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

.logo-container {
  display: flex;
  align-items: center;
  padding: 0;
}

.logo-link {
  text-decoration: none;
  display: flex;
  align-items: center;
}

.logo-image {
  height: 5rem;
  margin-right: 0.8rem;
  object-fit: contain;
  vertical-align: middle;
}

.logo-text {
  font-size: 1.5rem;
  font-weight: bold;
  color: white;
  letter-spacing: 1px;
}

.nav-links {
  display: flex;
  gap: 1.5rem;
  background-color: var(--background-secondary);
  padding: 0.7rem 1.5rem;
  border-radius: 30px;
  box-shadow: inset 0 2px 5px rgba(0, 0, 0, 0.1), 0 3px 10px rgba(0, 0, 0, 0.1);
}

.nav-link {
  color: var(--text-primary);
  text-decoration: none;
  font-size: 1.3rem;
  font-weight: 600;
  padding: 0.6rem 1.2rem;
  position: relative;
  transition: all 0.3s ease;
  border-radius: 20px;
}

.nav-link:hover {
  color: var(--primary-color);
  background-color: rgba(30, 144, 255, 0.1);
}

.nav-link::after {
  content: '';
  position: absolute;
  width: 0;
  height: 2px;
  bottom: 0;
  left: 50%;
  background-color: var(--primary-color);
  transition: all 0.3s ease;
  transform: translateX(-50%);
}

.nav-link:hover::after,
.nav-link.router-link-active::after {
  width: 70%;
}

.nav-link.router-link-active {
  color: var(--primary-color);
  font-weight: 600;
  background-color: rgba(30, 144, 255, 0.1);
}

.connect-wallet {
  display: flex;
  align-items: center;
}

.connect-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 0.7rem 1.5rem;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 10px rgba(30, 144, 255, 0.3);
  position: relative;
  overflow: hidden;
}

.connect-button::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(255, 255, 255, 0.1);
  transform: translateX(-100%);
  transition: transform 0.3s ease;
}

.connect-button:hover::before {
  transform: translateX(0);
}

.connect-button.connected {
  background-color: #4caf50; /* 连接状态下使用绿色 */
  display: flex;
  align-items: center;
  justify-content: center;
}

.connect-button.connected:hover {
  background-color: #e53935; /* 连接状态下悬停时改为红色，暗示断开连接 */
  position: relative;
}

.connect-button.connected:hover::after {
  content: "断开";
  position: absolute;
  font-size: 0.75rem;
  bottom: 1px;
  opacity: 0.8;
}

.connect-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(30, 144, 255, 0.4);
}

.connect-button:active {
  transform: translateY(1px);
  box-shadow: 0 2px 4px rgba(30, 144, 255, 0.2);
}

.connect-button.connected:active {
  transform: translateY(1px);
  box-shadow: 0 2px 4px rgba(76, 175, 80, 0.2);
}

/* 响应式样式 */
@media (max-width: 768px) {
  .navbar {
    padding: 0.4rem 1rem;
    flex-wrap: wrap;
  }
  
  .nav-links {
    gap: 0.5rem;
    margin: 0.5rem 0;
    width: 100%;
    justify-content: center;
    order: 3;
    flex-wrap: wrap;
  }
  
  .logo-container,
  .connect-wallet {
    flex: 1;
  }
  
  .logo-image {
    height: 3.5rem;
    margin-right: 0.4rem;
  }
  
  .logo-text {
    font-size: 1.2rem;
  }
  
  .connect-wallet {
    justify-content: flex-end;
  }
  
  .nav-link {
    font-size: 1rem;
    padding: 0.4rem 0.8rem;
  }
  
  .connect-button {
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
  }
  
  .connect-button.connected:hover::after {
    font-size: 0.7rem;
    bottom: 0;
  }
}
</style>
