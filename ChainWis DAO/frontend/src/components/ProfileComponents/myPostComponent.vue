<template>
  <div class="post-item">
    <div class="post-header">
      <h3 class="post-title">{{ title }}</h3>
      <button class="delete-button" @click="onDelete">删除</button>
    </div>
    <div class="post-date">{{ time }}</div>
    <p class="post-content">{{ content }}</p>
    <p class="post-tag"># 标签</p>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
});

const emit = defineEmits(["delete"]);

const onDelete = () => {
  emit("delete");
};
</script>

<style scoped>
.post-item {
  padding: 1rem 0;
  border-bottom: 1px solid var(--border-color);
}

.post-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.post-title {
  font-size: 1.2rem;
  font-weight: bold;
  color: var(--text-primary);
  margin: 0;
}

.delete-button {
  background-color: #E0FFFF;
  color: var(--text-primary);
  border: none;
  border-radius: 20px;
  padding: 0.2rem 0.8rem;
  font-size: 0.8rem;
  cursor: pointer;
}

.delete-button:hover {
  background-color: #E0FFFF;
}

.post-date {
  color: var(--text-light);
  font-size: 0.9rem;
  margin: 0.5rem 0;
}

.post-content {
  margin: 0.5rem 0;
  line-height: 1.6;
  color: var(--text-primary);
}

.post-tag {
  color: var(--primary-color);
  margin: 0.5rem 0 0;
}
</style>
