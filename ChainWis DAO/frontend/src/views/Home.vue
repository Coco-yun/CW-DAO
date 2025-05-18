<template>
  <div class="home">
    <main class="main-content">
      <div class="container">
        <div class="articles-grid">
          <ArticleCard
            v-for="article in articles"
            :key="article.id"
            :article="article"
          />
        </div>

        <SidebarLayout>
          <div class="sidebar-card">
            <h3 class="sidebar-title">精选博客</h3>
            <div class="sidebar-links">
              <router-link to="/featured" class="sidebar-link">
                <span class="sidebar-icon">📝</span>
                <span class="sidebar-text">精选博客</span>
              </router-link>
              <router-link to="/knowledge" class="sidebar-link">
                <span class="sidebar-icon">🧠</span>
                <span class="sidebar-text">知识图谱</span>
              </router-link>
            </div>
          </div>

          <div class="sidebar-card">
            <h3 class="sidebar-title">订阅更新</h3>
            <form class="newsletter-form" @submit.prevent="handleSubscribe">
              <input
                type="email"
                placeholder="您的邮箱地址"
                class="newsletter-input"
                v-model="email"
              >
              <button type="submit" class="newsletter-button">订阅！</button>
            </form>
            <p class="sidebar-tip-item">
              <span class="sidebar-tip-icon">✨</span>
              已有超过 30,000+ 专业人士订阅
            </p>
          </div>

          <div class="sidebar-card">
            <h3 class="sidebar-title">热门主题</h3>
            <div class="topics-list">
              <router-link
                v-for="topic in popularTopics"
                :key="topic.id"
                :to="topic.path"
                class="sidebar-link"
              >
                <span class="sidebar-text">{{ topic.name }}</span>
              </router-link>
            </div>
          </div>
        </SidebarLayout>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import ArticleCard from '../components/ArticleCard.vue';
import SidebarLayout from '../components/SidebarLayout.vue';

const email = ref('');

// 模拟文章数据
const articles = ref([
  {
    id: 1,
    title: '如何使用 LCP Subpart Analysis 修复最大内容绘制问题',
    author: '张三',
    authorAvatar: 'https://placekitten.com/100/100',
    date: '2024-03-08',
    categories: ['性能优化', '用户体验'],
    excerpt: '了解如何使用 Google 新推出的 LCP subparts 来定位页面加载延迟的来源。现在，在 Chrome UX Report 中，这些数据提供了真实的访问者洞察，以加快您的网站速度并提升排名。',
    likes: 42,
    comments: 12
  },
  {
    id: 2,
    title: 'WordPress 主题框架的极简设置：一个反传统的观点',
    author: '李四',
    authorAvatar: 'https://placekitten.com/101/101',
    date: '2024-03-07',
    categories: ['WordPress', '开发框架'],
    excerpt: '探索为什么在某些情况下，最小化的 WordPress 设置可能比使用复杂的主题框架更有优势。我们将深入研究性能、维护性和开发效率的权衡。',
    likes: 38,
    comments: 15
  }
]);

// 热门主题数据
const popularTopics = ref([
  { id: 1, name: 'JavaScript', path: '/javascript' },
  { id: 2, name: 'CSS 技巧', path: '/css' },
  { id: 3, name: '响应式设计', path: '/responsive' },
  { id: 4, name: 'Web 性能', path: '/performance' },
  { id: 5, name: '可访问性', path: '/accessibility' }
]);

const handleSubscribe = () => {
  // 处理订阅逻辑
  console.log('订阅邮箱:', email.value);
  email.value = '';
};
</script>

<style scoped>
.home {
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

.articles-grid {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.sidebar {
  position: sticky;
  top: calc(var(--header-height) + 2rem);
  height: fit-content;
}

.newsletter-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--border-color);
}

.newsletter-title {
  font-size: var(--font-size-sidebar);
  font-weight: 600;
  margin-bottom: 1rem;
  color: var(--text-color);
}

.newsletter-description {
  color: var(--text-light);
  margin-bottom: 1.5rem;
  line-height: 1.5;
  font-size: var(--font-size-sidebar);
}

.newsletter-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1rem;
}

.newsletter-input {
  padding: 0.75rem 1rem;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  font-size: var(--font-size-sidebar);
  transition: all 0.2s ease;
}

.newsletter-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.1);
}

.newsletter-button {
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 4px;
  padding: 0.75rem;
  font-size: var(--font-size-sidebar);
  cursor: pointer;
  transition: all 0.2s ease;
}

.newsletter-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(41, 128, 185, 0.2);
}

.newsletter-note {
  font-size: var(--font-size-sidebar);
  color: var(--text-light);
  text-align: center;
}

.popular-topics {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--border-color);
}

.sidebar-title {
  font-size: var(--font-size-sidebar);
  font-weight: 600;
  margin-bottom: 1rem;
  color: var(--text-color);
}

.topics-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.topic-link {
  color: var(--text-color);
  text-decoration: none;
  padding: 0.5rem;
  border-radius: 4px;
  transition: all 0.2s ease;
  font-size: var(--font-size-sidebar);
}

.topic-link:hover {
  color: var(--primary-color);
  background-color: rgba(52, 152, 219, 0.1);
}

@media (max-width: 1024px) {
  .container {
    grid-template-columns: 1fr;
  }

  .sidebar {
    position: static;
    margin-top: 2rem;
  }
}

@media (max-width: 768px) {
  .container {
    padding: 0 1rem;
  }

  .home {
    padding-top: calc(var(--header-height) + 24px);
  }
}
</style> 