<template>
  <div class="post-page">
    <main class="main-content">
      <div class="container">
        <div class="content-area">
          <router-view />
        </div>

        <SidebarLayout>
          <div class="sidebar-card">
            <h3 class="sidebar-title">发布中心</h3>
            <div class="sidebar-links">
              <router-link to="/post/write" class="sidebar-link">
                <span class="sidebar-icon">✍️</span>
                <span class="sidebar-text">写文章</span>
              </router-link>
              <router-link to="/post/drafts" class="sidebar-link">
                <span class="sidebar-icon">📋</span>
                <span class="sidebar-text">我的草稿</span>
              </router-link>
              <router-link to="/post/published" class="sidebar-link">
                <span class="sidebar-icon">📚</span>
                <span class="sidebar-text">发布记录</span>
              </router-link>
            </div>
          </div>

          <div class="sidebar-card">
            <h3 class="sidebar-title">发布小贴士</h3>
            <div class="sidebar-tips">
              <div class="sidebar-tip-item">
                <span class="sidebar-tip-icon">🖼️</span>
                <span>添加图片可以让文章更加生动</span>
              </div>
              <div class="sidebar-tip-item">
                <span class="sidebar-tip-icon">💡</span>
                <span>撰写原创内容有机会获得更多奖励</span>
              </div>
              <div class="sidebar-tip-item">
                <span class="sidebar-tip-icon">🏷️</span>
                <span>选择合适的标签可以让更多人看到</span>
              </div>
              <div class="sidebar-tip-item">
                <span class="sidebar-tip-icon">📱</span>
                <span>分享到社交媒体可以获得更多曝光</span>
              </div>
            </div>
          </div>
        </SidebarLayout>
      </div>
    </main>
  </div>
</template>

<script setup>
import SidebarLayout from '../components/SidebarLayout.vue';
</script>

<style scoped>
.post-page {
  padding-top: calc(var(--header-height) + 48px);
  background-color: var(--background-color);
  min-height: 100vh;
}

.main-content {
  padding: 2rem 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  display: grid;
  grid-template-columns: 1fr 280px;
  gap: 2rem;
}

.content-area {
  background: white;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--border-color);
}

@media (max-width: 1024px) {
  .container {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .container {
    padding: 0 1rem;
  }

  .post-page {
    padding-top: calc(var(--header-height) + 24px);
  }
}
</style> 