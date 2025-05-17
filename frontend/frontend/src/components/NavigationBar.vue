<template>
  <header class="header">
    <nav class="main-nav">
      <div class="nav-left">
        <router-link to="/Home" class="logo">
          <img src="../assets/image/loge.png" alt="Logo" class="logo-image">
        </router-link>
      </div>

      <div class="nav-center">
        <router-link to="/Home" class="nav-item">首页</router-link>
        <router-link to="/post" class="nav-item">发布</router-link>
        <router-link to="/profile" class="nav-item">个人中心</router-link>
        <a class="nav-item" @click="handleModerationClick">审核</a>
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

    <div class="sub-nav">
      <router-link to="/accessibility" class="sub-nav-item">无障碍</router-link>
      <router-link to="/ux" class="sub-nav-item">用户体验</router-link>
      <router-link to="/css" class="sub-nav-item">CSS</router-link>
      <router-link to="/javascript" class="sub-nav-item">JavaScript</router-link>
      <router-link to="/performance" class="sub-nav-item">性能</router-link>
      <router-link to="/design" class="sub-nav-item">设计</router-link>
      <router-link to="/guides" class="sub-nav-item">指南</router-link>
    </div>
  </header>
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
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.main-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: var(--header-height);
  padding: 0 2rem;
  background-color: var(--primary-color);
}

.nav-left, .nav-center, .nav-right {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.logo {
  display: flex;
  align-items: center;
}

.logo-image {
  height: 2.5rem;
}

.nav-item {
  color: white;
  text-decoration: none;
  font-size: 1rem;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.2s ease;
}

.nav-item:hover {
  background-color: var(--primary-hover);
  color: white;
}

.search-box {
  display: flex;
  align-items: center;
  background-color: white;
  border-radius: 4px;
  overflow: hidden;
}

.search-input {
  padding: 0.5rem 1rem;
  border: none;
  outline: none;
  font-size: 0.9rem;
  width: 200px;
}

.search-button {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  color: var(--text-light);
}

.search-icon {
  font-size: 1.2rem;
}

.connect-button {
  background-color: white;
  color: var(--primary-color);
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.connect-button:hover {
  background-color: var(--primary-hover);
  color: white;
}

.connect-button.connected {
  background-color: var(--primary-hover);
  color: white;
}

.sub-nav {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 2rem;
  background-color: white;
  border-bottom: 1px solid var(--border-color);
}

.sub-nav-item {
  color: var(--text-color);
  text-decoration: none;
  font-size: 0.9rem;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.sub-nav-item:hover {
  color: var(--primary-color);
  background-color: rgba(211, 58, 44, 0.1);
}
</style>
