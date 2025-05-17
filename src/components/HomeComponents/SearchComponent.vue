<template>
  <div class="search-page">
    <!-- Navigation Bar -->
    <NavigationBar />

    <!-- Search Content -->
    <div class="search-content">
      <!-- Back Button and Search Bar -->
      <div class="search-header">
        <button class="back-button" @click="goBack">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="back-icon"
          >
            <polyline points="15 18 9 12 15 6"></polyline>
          </svg>
        </button>
        <div class="search-bar">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="search-icon"
          >
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <!-- 使用 v-model 实现双向绑定 -->
          <input
            type="text"
            class="search-input"
            :value="searchQuery"
            placeholder="Search..."
            @input="handleInput"
            @keyup.enter="performSearch"
          />
        </div>
      </div>

      <!-- Results Count -->
      <div class="results-count">Total: {{ searchResults.length }}</div>

      <!-- Search Results List -->
      <div class="results-container">
        <div class="results-list">
          <div
            v-for="(result, index) in searchResults"
            :key="index"
            class="result-item"
          >
            <h3 class="result-title">{{ result.title }}</h3>
            <div class="result-author">
              {{ result.author }} {{ result.date }}
            </div>
            <div class="result-content">{{ result.content }}</div>
            <div class="result-tag"># {{ result.tag }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineEmits, defineProps, onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import NavigationBar from "../NavigationBar.vue";
import useContentManager from "../../composables/useContentManager";

// 定义 props 和 emits
const props = defineProps({
  searchQuery: {
    type: String,
    required: true,
  },
  searchResults: {
    type: Array,
    required: true,
  },
});

const posts = ref([]);

onMounted(async () => {
  const content = useContentManager();

  if (!content) {
    console.error("Web3 初始化失败");
    return;
  }

  try {
    const account = await content.getAccount();
    if (!account) {
      console.error("未连接钱包");
      return;
    }

    const postIDs = await content.getAllArticleId();
    // console.log(postIDs + "我在这里");

    posts.value = [];
    for (let i = 0; i < postIDs.length; i++) {
      // 调用 content 合约中的 getArticleDetails，传入对应的 ID
      const articleDetail = await content.getArticleDetails(postIDs[i]);
      console.log(articleDetail.content + "我在这里");
      // 构造用于显示的文章对象
      posts.value.push({
        title: "Topic", // 固定值
        time: "2025-4-12 10:56", // 固定值
        content: articleDetail.content, // 从合约返回的内容字段
      });
    }
  } catch (error) {
    console.error("获取作者信息失败:", error);
  }

  // DAO
});

const emit = defineEmits(["update:searchQuery"]);

const router = useRouter();

// 返回上一页
const goBack = () => {
  router.go(-1);
};

// 输入框事件：通过 emit 传递更新
const handleInput = (event) => {
  emit("update:searchQuery", event.target.value);
};

// 模拟搜索功能（实际场景中可调用 API 获取数据）
const performSearch = () => {
  console.log("Searching for:", props.searchQuery);
};
</script>

<style scoped>
.search-page {
  min-height: 100vh;
  background-color: #0a0118;
  color: white;
  font-family: Arial, sans-serif;
}

/* Navigation Bar */
.nav-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  border-bottom: 1px solid rgba(180, 41, 255, 0.3);
}

.logo-container {
  display: flex;
  align-items: center;
}

.logo {
  width: 40px;
  height: 40px;
}

.logo-text {
  color: #b429ff;
  font-weight: bold;
  font-size: 1.5rem;
  margin-left: 0.5rem;
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  transition: color 0.2s;
}

.nav-link:hover {
  color: #b429ff;
}

.connect-button {
  background-color: #b429ff;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 0.5rem 1.5rem;
  font-weight: bold;
  cursor: pointer;
}

/* Search Content */
.search-content {
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem 2rem;
}

.search-header {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

.back-button {
  background: none;
  border: none;
  color: #b429ff;
  cursor: pointer;
  padding: 0.5rem;
  margin-right: 1rem;
}

.search-bar {
  flex: 1;
  display: flex;
  align-items: center;
  background-color: transparent;
  border: 2px solid #b429ff;
  border-radius: 25px;
  padding: 0.5rem 1rem;
}

.search-icon {
  color: #b429ff;
  margin-right: 0.5rem;
}

.search-input {
  flex: 1;
  background: transparent;
  border: none;
  color: white;
  font-size: 1rem;
  outline: none;
}

.results-count {
  text-align: center;
  color: #b429ff;
  margin-bottom: 1.5rem;
}

.results-container {
  border: 1px solid rgba(180, 41, 255, 0.3);
  border-radius: 10px;
  padding: 0;
  overflow: hidden;
}

.results-list {
  max-height: 70vh;
  overflow-y: auto;
}

.result-item {
  padding: 1.5rem;
  border-bottom: 1px solid rgba(180, 41, 255, 0.3);
}

.result-item:last-child {
  border-bottom: none;
}

.result-title {
  font-size: 1.5rem;
  margin: 0 0 0.5rem 0;
}

.result-author {
  color: #cccccc;
  margin-bottom: 1rem;
}

.result-content {
  line-height: 1.6;
  margin-bottom: 1rem;
}

.result-tag {
  color: #b429ff;
}

/* Custom scrollbar styling */
.results-list::-webkit-scrollbar {
  width: 6px;
}

.results-list::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}

.results-list::-webkit-scrollbar-thumb {
  background: #b429ff;
  border-radius: 3px;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .nav-bar {
    padding: 1rem;
  }

  .nav-links {
    gap: 1rem;
  }

  .search-content {
    padding: 1rem;
  }
}
</style>
