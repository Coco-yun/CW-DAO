<template>
  <div class="user-item">
    <div class="user-avatar">
      <img
        src="../../assets/image/author3.png"
        :alt="name"
      />
    </div>
    <div class="user-name">{{ name }}</div>
    <button class="homepage-button" @click="$emit('visit-homepage')">
      主页
    </button>
  </div>
</template>

<script setup>
defineProps({
  avatar: {
    type: String,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
});

defineEmits(["visit-homepage"]);
</script>

<style scoped>
.user-item {
  display: flex;
  align-items: center;
  padding: 0.8rem 0;
  border-bottom: 1px solid var(--border-color);
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 1rem;
  border: 2px solid var(--primary-light);
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.user-name {
  flex: 1;
  font-weight: bold;
  color: var(--text-primary);
}

.homepage-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 0.3rem 1rem;
  font-size: 0.8rem;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.homepage-button:hover {
  background-color: var(--primary-dark);
}
</style>
