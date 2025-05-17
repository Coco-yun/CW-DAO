<template>
  <div class="asset-detail-item">
    <div class="asset-info">
      <div class="asset-title">{{ title }}</div>
      <div class="asset-amount" :class="{ negative: amount < 0 }">
        {{ amount > 0 ? "+" : "" }}{{ amount }} 代币
      </div>
    </div>
    <button class="details-button" @click="onDetailsClick">详情</button>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(["details"]);

const onDetailsClick = () => {
  emit("details");
};
</script>

<style scoped>
.asset-detail-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
  padding: 1rem;
  border-radius: 8px;
  background-color: var(--background-secondary);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.asset-info {
  display: flex;
  flex-direction: column;
}

.asset-title {
  color: var(--primary-color);
  font-size: 1.1rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
}

.asset-amount {
  color: var(--text-primary);
  font-weight: bold;
  font-size: 1.1rem;
}

.asset-amount.negative {
  color: var(--error-color);
}

.details-button {
  background-color: transparent;
  color: var(--primary-color);
  border: 1px solid var(--primary-color);
  border-radius: 20px;
  padding: 0.2rem 0.8rem;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.details-button:hover {
  background-color: var(--primary-light);
  color: white;
}
</style>
