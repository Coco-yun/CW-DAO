<template>
  <div id="app">
    <!-- 导航栏组件，全局可见 -->
    <NavigationBar />
    
    <!-- 路由视图，内容随当前路由改变 -->
    <router-view />
  </div>
</template>

<script setup>
import NavigationBar from './components/NavigationBar.vue';
// 这里也可以添加全局逻辑
</script>

<style>
/* 全局缩放 */
html {
  font-size: 80%; /* 将整体UI缩小至80% */
}

/* 全局样式 */
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  color: var(--text-primary);
  background-color: var(--background-color);
}

html,
body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  background-color: var(--background-color);
  color: var(--text-primary);
}

/* 全局按钮样式 */
button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  cursor: pointer;
  transition: background-color 0.2s, transform 0.1s;
}

button:hover {
  background-color: var(--primary-dark);
}

button:active {
  transform: scale(0.98);
}

/* 常用容器样式 */
.card {
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 0.5rem;
  padding: 1rem;
  box-shadow: 0 0.125rem 0.5rem rgba(0, 0, 0, 0.05);
}

/* 添加全局变量，基于80%缩放 */
:root {
  --primary-color: #1e90ff;
  --primary-light: #4da6ff;
  --primary-dark: #0066cc;
  --background-color: #ffffff;
  --background-secondary: #f5f7fa;
  --text-primary: #333333;
  --text-secondary: #666666;
  --text-light: #999999;
  --border-color: #e0e0e0;
  
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
  
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-md: 1rem;
  --font-size-lg: 1.25rem;
  --font-size-xl: 1.5rem;
  --font-size-xxl: 2rem;
}
</style>
