<template>
  <div class="notification-item">
    <div class="notification-header">
      <div class="notification-icon" :class="type">
        <!-- 图标使用文字代替 -->
        <span v-if="type === 'comment'" class="icon-text">评论</span>
        <span v-if="type === 'like'" class="icon-text">点赞</span>
        <span v-if="type === 'collect'" class="icon-text">收藏</span>
        <span v-if="type === 'reward'" class="icon-text">奖励</span>
      </div>

      <div class="notification-avatar">
        <img :src="avatar" alt="用户头像" />
      </div>
    </div>

    <div class="notification-content">
      <div class="notification-text">{{ content }}</div>
      <div v-if="comment" class="notification-comment">{{ comment }}</div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  type: {
    type: String,
    required: true,
    validator: (value) =>
      ["comment", "like", "collect", "reward"].includes(value),
  },
  avatar: {
    type: String,
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  comment: {
    type: String,
    default: "",
  },
});
</script>

<style scoped>
.notification-item {
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  border-radius: 10px;
  border: 1px solid var(--border-color);
  background-color: var(--background-color);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  margin-bottom: 1rem;
}

.notification-header {
  display: flex;
  align-items: center;
  margin-bottom: 0.75rem;
}

.notification-icon {
  min-width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 0.75rem;
  color: var(--primary-color);
  font-weight: bold;
}

.icon-text {
  font-size: 0.9rem;
}

.notification-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid var(--primary-light);
}

.notification-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.notification-content {
  margin-left: 0.5rem;
}

.notification-text {
  margin-bottom: 0.5rem;
  color: var(--text-primary);
}

.notification-comment {
  color: var(--text-secondary);
  line-height: 1.4;
  padding: 0.5rem;
  background-color: var(--background-secondary);
  border-radius: 5px;
}
</style>
