<template>
  <NavigationBar />
  <HomepageComponent
    authorName="John Doe"
    :level="2"
    :totalPosts="5"
    :followers="100"
    :posts="[
      {
        title: 'Topic 1',
        author: 'John Doe',
        date: '2025-04-12 10:56',
        content: 'Lorem ipsum dolor sit amet...',
        tag: 'tag1',
      },
      {
        title: 'Topic 2',
        author: 'John Doe',
        date: '2025-04-13 12:30',
        content: 'Consectetur adipiscing elit...',
        tag: 'tag2',
      },
    ]"
  />
</template>

<script setup>
import HomepageComponent from "../components/HomeComponents/HomepageComponent.vue";
import NavigationBar from "../components/NavigationBar.vue";
</script>
