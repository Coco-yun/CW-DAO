<template>
  <header>
    <div class="container">
      <div class="header-content">
        <router-link to="/" class="logo">
          <div class="logo-icon">
            <i class="fas fa-feather-alt"></i>
          </div>
          <span>Dandelion</span>
        </router-link>
        <button class="mobile-menu-btn" @click="toggleMobileMenu">
          <i class="fas fa-bars"></i>
        </button>
        <nav>
          <ul :class="{ 'open': mobileMenuOpen }">
            <li><router-link to="/" exact-active-class="active"><i class="fas fa-home"></i> 首页</router-link></li>
            <li><router-link to="/tasks" exact-active-class="active"><i class="fas fa-tasks"></i> 任务看板</router-link></li>
            <li><router-link to="/publish" exact-active-class="active"><i class="fas fa-plus-circle"></i> 发布任务</router-link></li>
            <li><router-link to="/profile" exact-active-class="active"><i class="fas fa-user"></i> 个人中心</router-link></li>
            <li><router-link to="/dispute" exact-active-class="active"><i class="fas fa-gavel"></i> 仲裁中心</router-link></li>
          </ul>
        </nav>
        <div class="wallet-section">
          <div v-if="error" class="error-message">
            {{ error }}
          </div>
          <button
            v-if="!isConnected"
            class="btn btn-primary"
            @click="walletStore.connectWallet()"
            :disabled="connecting"
          >
            <i class="fas fa-wallet"></i>
            <span v-if="!connecting">连接钱包</span>
            <span v-else>连接中...</span>
          </button>
          <div v-else class="user-info">
            <div class="user-dropdown">
              <div class="user-avatar" @click="dropdownOpen = !dropdownOpen">
                {{ shortAccount }}
              </div>
              <div v-if="dropdownOpen" class="dropdown-menu">
                <div class="dropdown-account">
                  <i class="fas fa-wallet"></i>
                  <span>{{ account }}</span>
                </div>
                <div class="dropdown-divider"></div>
                <button class="dropdown-item" @click="walletStore.disconnectWallet">
                  <i class="fas fa-sign-out-alt"></i> 断开连接
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useWalletStore } from '../../composables/useWallet'
import { storeToRefs } from 'pinia'
const mobileMenuOpen = ref(false)
const dropdownOpen = ref(false)

const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

// 使用钱包store
const walletStore = useWalletStore()
const { isConnected, account, connecting, shortAccount, error } = storeToRefs(walletStore)

// 初始化钱包
onMounted(() => {
  walletStore.initWallet()
})

// 点击外部关闭下拉菜单
const handleClickOutside = (event) => {
  if (!event.target.closest('.user-dropdown')) {
    dropdownOpen.value = false;
  }
};

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});
</script>

<style scoped>
header {
  background-color: var(--card-bg);
  box-shadow: var(--shadow-sm);
  position: fixed;
  top: 0;
  left: 0;
  z-index: 100;
  border-bottom: 1px solid var(--border);
  width: 100vw;
  min-width: 100vw;
  margin-left: 50%;
  transform: translateX(-50%);
  max-width: 100vw;
  padding: 0;
  height: 75px;
  display: flex;
  align-items: center;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  width: 100vw;
  min-width: 100vw;
  box-sizing: border-box;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  position: relative;
  min-height: 60px;
  height: 76px;
  font-size: 1.15rem;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 700;
  font-size: 2rem;
  color: var(--primary);
  text-decoration: none;
  transition: var(--transition);
  margin-left: 60px;
}

.logo:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

.logo-icon {
  width: 44px;
  height: 44px;
  font-size: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--purple-gradient);
  border-radius: var(--radius-md);
  color: white;
}

nav ul {
  display: flex;
  gap: 24px;
  list-style: none;
}

nav a {
  text-decoration: none;
  color: var(--text-secondary);
  font-weight: 500;
  transition: var(--transition);
  position: relative;
  padding: 12px 0;
  font-size: 1.15rem;
  display: flex;
  align-items: center;
  gap: 6px;
}

nav a:hover, nav a.active {
  color: var(--primary);
}

nav a.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 3px;
  background-color: var(--primary);
  border-radius: 2px;
}

.mobile-menu-btn {
  display: none;
  background: none;
  border: none;
  font-size: 2rem;
  color: var(--text-primary);
  cursor: pointer;
}

.wallet-section {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 1.1rem;
  position: relative;
}

.btn {
  margin-right: 60px;
  padding: 14px 28px;
  border-radius: var(--radius-md);
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  border: none;
  font-size: 1.15rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  white-space: nowrap;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn:active {
  transform: translateY(0);
}

.btn-primary {
  background: var(--purple-gradient);
  color: white;
  box-shadow: 0 4px 6px rgba(108, 99, 255, 0.15);
}

.btn-primary:hover {
  box-shadow: 0 6px 8px rgba(108, 99, 255, 0.25);
}

.user-info {
  margin-right: 60px;
}

.user-avatar {
  width: 44px;
  height: 44px;
  font-size: 1.2rem;
  border-radius: var(--radius-full);
  background: var(--teal-gradient);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  cursor: pointer;
  font-size: 0.9rem;
  transition: transform 0.3s ease;
}

.user-avatar:hover {
  transform: scale(1.05);
}

/* 下拉菜单样式 */
.user-dropdown {
  position: relative;
}

.dropdown-menu {
  position: absolute;
  right: 0;
  top: 100%;
  margin-top: 8px;
  background: var(--card-bg);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);
  min-width: 240px;
  overflow: hidden;
  z-index: 110;
  animation: fadeIn 0.2s ease-out;
  border: 1px solid var(--border);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.dropdown-account {
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 0.9rem;
  color: var(--text-secondary);
  overflow-wrap: break-word;
  background: rgba(0, 0, 0, 0.03);
  border-bottom: 1px solid var(--border);
}

.dropdown-divider {
  height: 1px;
  background: var(--border);
  margin: 4px 0;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 12px 16px;
  background: none;
  border: none;
  text-align: left;
  font-size: 1rem;
  color: var(--text-primary);
  cursor: pointer;
  transition: background 0.2s;
}

.dropdown-item:hover {
  background: var(--bg-secondary);
}

.dropdown-item i {
  width: 20px;
  text-align: center;
  color: var(--primary);
}

/* 错误提示 */
.error-message {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  padding: 8px 16px;
  background: var(--error);
  color: white;
  border-radius: var(--radius-md);
  font-size: 0.9rem;
  z-index: 200;
  animation: fadeIn 0.3s ease;
}
</style>