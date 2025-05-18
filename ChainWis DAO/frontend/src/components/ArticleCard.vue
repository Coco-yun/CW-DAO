<template>
  <article class="article-card">
    <div class="article-meta">
      <div class="author-info">
        <img :src="article.authorAvatar" :alt="article.author" class="author-avatar">
        <span class="author-name">{{ article.author }}</span>
        <span class="article-date">{{ formatDate(article.date) }}</span>
      </div>
      <div class="article-categories">
        <span v-for="category in article.categories" :key="category" class="category-tag">
          {{ category }}
        </span>
      </div>
    </div>

    <h2 class="article-title">
      <router-link :to="{ name: 'article', params: { id: article.id }}" class="title-link">
        {{ article.title }}
      </router-link>
    </h2>

    <p class="article-excerpt">{{ article.excerpt }}</p>

    <div class="article-footer">
      <router-link :to="{ name: 'article', params: { id: article.id }}" class="read-more">
        继续阅读 →
      </router-link>
      <div class="article-stats">
        <span class="stat-item">
          <span class="stat-icon">👍</span>
          {{ article.likes }}
        </span>
        <span class="stat-item">
          <span class="stat-icon">💬</span>
          {{ article.comments }}
        </span>
      </div>
    </div>
  </article>
</template>

<script setup>
import { defineProps } from 'vue';

const props = defineProps({
  article: {
    type: Object,
    required: true
  }
});

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
};
</script>

<style scoped>
.article-card {
  padding: 2rem;
  margin-bottom: 2rem;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
  border: 1px solid var(--border-color);
}

.article-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.1);
  border-color: var(--primary-color);
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.author-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.author-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.author-name {
  font-weight: 500;
  color: var(--text-color);
}

.article-date {
  color: var(--text-light);
  font-size: 0.9rem;
}

.article-categories {
  display: flex;
  gap: 0.5rem;
}

.category-tag {
  padding: 0.25rem 0.75rem;
  background-color: rgba(52, 152, 219, 0.1);
  color: var(--primary-color);
  border-radius: 16px;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.category-tag:hover {
  background-color: rgba(52, 152, 219, 0.2);
}

.article-title {
  margin: 0 0 1rem 0;
  font-size: 1.75rem;
  line-height: 1.3;
}

.title-link {
  color: var(--text-color);
  text-decoration: none;
  transition: color 0.2s ease;
}

.title-link:hover {
  color: var(--primary-color);
}

.article-excerpt {
  color: var(--text-light);
  line-height: 1.6;
  margin-bottom: 1.5rem;
}

.article-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid var(--border-color);
}

.read-more {
  color: var(--primary-color);
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.read-more:hover {
  color: var(--primary-hover);
  gap: 0.75rem;
}

.article-stats {
  display: flex;
  gap: 1rem;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  color: var(--text-light);
  font-size: 0.9rem;
}

.stat-icon {
  font-size: 1.1rem;
}
</style> 