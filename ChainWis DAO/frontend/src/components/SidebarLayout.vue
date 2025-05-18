<template>
  <aside class="sidebar">
    <slot></slot>
  </aside>
</template>

<script setup>
</script>

<style scoped>
.sidebar {
  position: sticky;
  top: calc(var(--header-height) + 2rem);
  height: fit-content;
  width: 280px;
}

.sidebar-card {
  background: white;
  border-radius: 8px;
  padding: 1.25rem;
  margin-bottom: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--border-color);
  min-height: 120px;
}

.sidebar-title {
  font-size: var(--font-size-sidebar);
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: var(--text-color);
  height: 20px;
  line-height: 20px;
}

.sidebar-links {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.625rem 0.75rem;
  color: var(--text-color);
  text-decoration: none;
  border-radius: 6px;
  transition: all 0.2s ease;
  font-size: var(--font-size-sidebar);
  height: 36px;
}

.sidebar-link:hover {
  color: var(--primary-color);
  background-color: rgba(52, 152, 219, 0.1);
}

.sidebar-link.active {
  color: var(--primary-color);
  background-color: rgba(52, 152, 219, 0.1);
  font-weight: 500;
}

.sidebar-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-light);
  flex-shrink: 0;
}

.sidebar-text {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sidebar-divider {
  height: 1px;
  background-color: var(--border-color);
  margin: 0.75rem 0;
}

.sidebar-tips {
  padding: 1rem;
  background-color: rgba(52, 152, 219, 0.1);
  border-radius: 6px;
  margin-top: 0.75rem;
}

.sidebar-tip-item {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding: 0.5rem 0;
  font-size: var(--font-size-sidebar);
  color: var(--text-color);
  min-height: 32px;
}

.sidebar-tip-item:last-child {
  padding-bottom: 0;
}

.sidebar-tip-icon {
  color: var(--primary-color);
  font-size: 1.1em;
  flex-shrink: 0;
}

.user-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  margin-bottom: 0.75rem;
  object-fit: cover;
}

.user-name {
  font-size: calc(var(--font-size-sidebar) + 2px);
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: var(--text-color);
  line-height: 1.2;
}

.user-bio {
  font-size: var(--font-size-sidebar);
  color: var(--text-light);
  margin-bottom: 0.75rem;
  line-height: 1.4;
  height: 40px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.sidebar-button {
  width: 100%;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 6px;
  font-size: var(--font-size-sidebar);
  cursor: pointer;
  transition: all 0.2s ease;
}

.sidebar-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(41, 128, 185, 0.2);
}
</style> 