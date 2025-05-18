<template>
  <div id="app">
    <!-- 导航栏组件，全局可见 -->
    <NavigationBar />
    
    <!-- 添加过渡效果的路由视图 -->
    <router-view v-slot="{ Component }">
      <transition name="slide-fade" mode="out-in">
        <component :is="Component" />
      </transition>
    </router-view>
  </div>
</template>

<script setup>
import NavigationBar from './components/NavigationBar.vue';
// 这里也可以添加全局逻辑
</script>

<style>
/* Reset default styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Global styles */
:root {
  --primary-color: #3498db;
  --primary-gradient: linear-gradient(135deg, #3498db, #2980b9);
  --primary-hover: #2980b9;
  --text-color: #333333;
  --text-light: #666666;
  --background-color: #f8fafc;
  --border-color: #e6e6e6;
  --header-height: 88px;
  
  /* Typography */
  --font-primary: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --font-size-base: 16px;
  --line-height-base: 1.5;
  --font-size-sidebar: 14px;
}

html {
  font-size: var(--font-size-base);
}

body {
  font-family: var(--font-primary);
  line-height: var(--line-height-base);
  color: var(--text-color);
  background: linear-gradient(135deg, var(--background-color) 0%, var(--background-secondary) 100%);
  min-height: 100vh;
}

#app {
  min-height: 100vh;
}

/* Global button styles */
button {
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

button:hover {
  background: var(--primary-hover);
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(41, 128, 185, 0.2);
}

/* Global link styles */
a {
  color: var(--primary-color);
  text-decoration: none;
  transition: all 0.2s ease;
}

a:hover {
  color: var(--primary-hover);
}

/* Container styles */
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

/* Global scrollbar styles */
::-webkit-scrollbar {
  width: 10px;
  height: 10px;
}

::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 5px;
}

::-webkit-scrollbar-thumb {
  background: var(--primary-color);
  border-radius: 5px;
  border: 2px solid var(--background-color);
  transition: all 0.2s ease;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--primary-hover);
}

/* Page transition animations */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.3s ease;
}

.slide-fade-enter-from {
  transform: translateX(20px);
  opacity: 0;
}

.slide-fade-leave-to {
  transform: translateX(-20px);
  opacity: 0;
}

/* Card styles */
.card {
  background-color: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 
    0 4px 6px rgba(0, 0, 0, 0.05),
    0 1px 3px rgba(0, 0, 0, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 
    0 6px 12px rgba(0, 0, 0, 0.08),
    0 3px 6px rgba(0, 0, 0, 0.12),
    inset 0 1px 0 rgba(255, 255, 255, 0.15);
}
</style>
