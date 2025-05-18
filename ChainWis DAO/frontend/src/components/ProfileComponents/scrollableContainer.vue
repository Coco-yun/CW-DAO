<template>
  <div class="section-container">
    <div class="section-header">
      <div class="header-icon">
        <slot name="icon"></slot>
        <slot name="title"></slot>
      </div>
    </div>

    <div v-if="showTotal" class="total-count">总数:{{ totalItems }}</div>

    <div class="scrollable-content">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  totalItems: {
    type: Number,
    default: 0,
  },
  showTotal: {
    type: Boolean,
    default: true,
  },
});
</script>

<style scoped>
@font-face {
  font-family: "SFProDisplayBold";
  src: url("/src/assets/font/SFPRODISPLAYMEDIUM.OTF") format("opentype");
  font-weight: bold;
  font-style: normal;
}

.section-container {
  width: 100%;
  height: 100%;
  border-radius: 10px;
  border: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: var(--background-color);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

.section-header {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--border-light);
}

.header-icon {
  display: flex;
  align-items: center;
  color: var(--primary-color);
}

.section-title {
  color: var(--primary-color);
  font-size: 1.5rem;
  font-weight: bold;
  letter-spacing: 1px;
  text-transform: uppercase;
  margin-left: 1rem;
}

.total-count {
  color: var(--primary-color);
  padding: 0 1.5rem;
  margin-bottom: 1rem;
  font-size: 1.2rem;
  font-weight: bold;
  font-family: "SFProDisplayBold", sans-serif;
  letter-spacing: 1px;
}

.scrollable-content {
  flex: 1;
  overflow-y: auto;
  padding: 0 1.5rem 1.5rem;
}

/* Scrollbar styling */
.scrollable-content::-webkit-scrollbar {
  width: 6px;
}

.scrollable-content::-webkit-scrollbar-track {
  background: var(--background-secondary);
  border-radius: 3px;
}

.scrollable-content::-webkit-scrollbar-thumb {
  background: var(--primary-color);
  border-radius: 3px;
}
</style>
