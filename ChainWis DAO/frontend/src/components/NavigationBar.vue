<template>
  <header class="header">
    <nav class="main-nav">
      <div class="nav-left">
        <router-link to="/Home" class="logo">
          <img src="../assets/image/loge.png" alt="Logo" class="logo-image">
        </router-link>
      </div>

      <div class="nav-center">
        <router-link to="/Home" class="nav-item" :class="{ 'router-link-active': $route.path === '/Home' }">首页</router-link>
        <router-link to="/post" class="nav-item" :class="{ 'router-link-active': $route.path === '/post' }">发布</router-link>
        <router-link to="/profile" class="nav-item" :class="{ 'router-link-active': $route.path === '/profile' }">个人中心</router-link>
        <a class="nav-item" 
           @click="handleModerationClick"
           :class="{ 'active': isReviewerPage }">
          审核
        </a>
      </div>

      <div class="nav-right">
        <div class="search-box">
          <input type="text" placeholder="搜索文章..." class="search-input">
          <button class="search-button">
            <span class="search-icon">🔍</span>
          </button>
        </div>
        <button 
          @click="handleConnection" 
          class="connect-button"
          :class="{ 'connected': connected }"
        >
          {{ connected ? accountDisplay : "连接钱包" }}
        </button>
      </div>
    </nav>
  </header>
</template>

<script setup>
import { ethers } from "ethers";
import { ref, onMounted, computed } from "vue";
import { useRouter, useRoute } from "vue-router";
import useContentReviewDAO from "../composables/useContentReviewDAO";

const router = useRouter();
const route = useRoute();
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

// 计算属性：判断是否在审核页面
const isReviewerPage = computed(() => {
  return route.path === '/Reviewer' || route.path === '/noReviewer';
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
      // 如果已连接，用户点击按钮则断开连接
      connected.value = false;
      account.value = "";
      isReviewer.value = false;
      console.log("钱包已断开连接");
      router.push("/Home");
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
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background-color: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.main-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: var(--header-height);
  padding: 0 2.5rem;
  background: var(--primary-gradient);
}

.nav-left, .nav-center, .nav-right {
  display: flex;
  align-items: center;
  gap: 2rem;
  height: 100%;
}

.logo {
  display: flex;
  align-items: center;
  height: 100%;
  padding: 0.75rem 0;
}

.logo-image {
  height: 4rem;
  filter: brightness(0) invert(1);
}

.nav-item {
  color: white;
  text-decoration: none;
  font-size: 1.25rem;
  font-weight: 600;
  padding: 0.875rem 1.5rem;
  border-radius: 6px;
  transition: all 0.2s ease;
  letter-spacing: 0.5px;
  height: 3.5rem;
  display: flex;
  align-items: center;
  position: relative;
}

.nav-item:hover {
  background-color: rgba(255, 255, 255, 0.15);
  transform: translateY(-1px);
}

.nav-item.router-link-active {
  background-color: rgba(255, 255, 255, 0.2);
  font-weight: 700;
}

.nav-item.router-link-active::after {
  content: '';
  position: absolute;
  bottom: 0.5rem;
  left: 1.5rem;
  right: 1.5rem;
  height: 3px;
  background-color: white;
  border-radius: 2px;
  box-shadow: 0 0 8px rgba(255, 255, 255, 0.4);
}

/* 为审核按钮添加激活状态 */
.nav-item.active {
  background-color: rgba(255, 255, 255, 0.2);
  font-weight: 700;
}

.nav-item.active::after {
  content: '';
  position: absolute;
  bottom: 0.5rem;
  left: 1.5rem;
  right: 1.5rem;
  height: 3px;
  background-color: white;
  border-radius: 2px;
  box-shadow: 0 0 8px rgba(255, 255, 255, 0.4);
}

.search-box {
  display: flex;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.15);
  border-radius: 6px;
  overflow: hidden;
  transition: all 0.2s ease;
  min-width: 280px;
  height: 3.5rem;
}

.search-box:focus-within {
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.search-input {
  padding: 0.875rem 1.5rem;
  border: none;
  outline: none;
  font-size: 1.125rem;
  width: 100%;
  background: transparent;
  color: white;
  height: 100%;
}

.search-input::placeholder {
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
}

.search-input:focus {
  color: var(--text-color);
}

.search-input:focus::placeholder {
  color: var(--text-light);
}

.search-button {
  background: none;
  border: none;
  padding: 0.875rem 1.25rem;
  cursor: pointer;
  color: white;
  transition: all 0.2s ease;
  height: 100%;
  display: flex;
  align-items: center;
}

.search-button:hover {
  background: none;
  transform: scale(1.1);
  box-shadow: none;
}

.search-icon {
  font-size: 1.5rem;
}

.connect-button {
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
  padding: 0.875rem 1.75rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 1.25rem;
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
  height: 3.5rem;
  display: flex;
  align-items: center;
  border: 2px solid rgba(255, 255, 255, 0.9);
  position: relative;
  overflow: hidden;
  backdrop-filter: blur(5px);
}

.connect-button:hover {
  background-color: rgba(255, 255, 255, 0.3);
  color: white;
  transform: translateY(-2px);
  border-color: white;
}

.connect-button.connected {
  background-color: rgba(255, 255, 255, 0.25);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.9);
}

.connect-button.connected:hover {
  background-color: rgba(255, 255, 255, 0.35);
  color: white;
  border-color: white;
}
</style>
