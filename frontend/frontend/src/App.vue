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
/* Reset default styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Global styles */
:root {
  --primary-color: #d33a2c;
  --primary-hover: #b33024;
  --text-color: #333333;
  --text-light: #666666;
  --background-color: #ffffff;
  --border-color: #e6e6e6;
  --header-height: 60px;
  
  /* Typography */
  --font-primary: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --font-size-base: 16px;
  --line-height-base: 1.5;
}

html {
  font-size: var(--font-size-base);
}

body {
  font-family: var(--font-primary);
  line-height: var(--line-height-base);
  color: var(--text-color);
  background-color: var(--background-color);
}

#app {
  min-height: 100vh;
}

/* Global button styles */
button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

button:hover {
  background-color: var(--primary-hover);
}

/* Global link styles */
a {
  color: var(--primary-color);
  text-decoration: none;
  transition: color 0.2s ease;
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

/* Card styles */
.card {
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}
</style>
