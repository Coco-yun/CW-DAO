<template>
  <div>
    <SearchPage
      v-model:searchQuery="searchQuery"
      :searchResults="searchResults"
    />
  </div>
</template>

<script setup>
import { ref } from "vue";
import SearchPage from "../components/HomeComponents/SearchComponent.vue";

// 定义搜索关键字和搜索结果数据
const searchQuery = ref("btc");

const searchResults = ref([
  {
    id: 1,
    title: "Topic 1",
    author: "Author",
    date: "2025-04-12 10:56",
    content: "Brief introduction Brief introduction Brief introduction...",
    tag: "tag1",
  },
  {
    id: 2,
    title: "Topic 2",
    author: "Author",
    date: "2025-04-12 10:56",
    content: "Brief introduction Brief introduction Brief introduction...",
    tag: "tag2",
  },
  {
    id: 3,
    title: "Topic 3",
    author: "Author",
    date: "2025-04-12 10:56",
    content: "Brief introduction Brief introduction Brief introduction...",
    tag: "tag3",
  },
]);
</script>
