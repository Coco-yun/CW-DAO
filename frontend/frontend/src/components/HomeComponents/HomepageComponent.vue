<template>
  <div class="profile-page">
    <!-- Profile Content -->
    <div class="profile-content">
      <!-- Logo and Avatar -->
      <div class="profile-header">
        <div class="logo-background">
          <img
            src="../../assets/image/image 2@2x.png"
            alt="DSCN Logo Background"
            class="logo-bg"
          />
          <div class="avatar-container">
            <img
              src="../../assets/image/author1.png"
              alt="User Avatar"
              class="avatar"
            />
          </div>
        </div>

        <!-- Author Info -->
        <div class="author-info">
          <h2 class="author-name">{{ authorName }}</h2>
          <button class="follow-button">Follow</button>
        </div>

        <!-- Stats -->
        <div class="stats-container">
          <div class="stat-item">
            <div class="stat-label">Level</div>
            <div class="stat-value">{{ level }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">Total Posts</div>
            <div class="stat-value">{{ totalPosts }}</div>
          </div>
          <div class="stat-item">
            <div class="stat-label">Followers</div>
            <div class="stat-value">{{ followers }}</div>
          </div>
        </div>

        <!-- Tags -->
        <div class="tags-container">
          <span class="tag-item">Bitcoin enthusiast</span>
          <span class="separator">|</span>
          <span class="tag-item">Full stack technology developer</span>
          <span class="separator">|</span>
          <span class="tag-item">Daily technology sharing</span>
        </div>

        <!-- Posts - Now with scrollable container -->
        <div class="posts-container">
          <div class="posts-scrollable">
            <div v-for="(post, index) in posts" :key="index" class="post-item">
              <h3 class="post-title">{{ post.title }}</h3>
              <div class="post-author">{{ post.author }} {{ post.date }}</div>
              <p class="post-content">{{ post.content }}</p>
              <div class="post-tag"># {{ post.tag }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  authorName: {
    type: String,
    required: true,
  },
  level: {
    type: Number,
    required: true,
  },
  totalPosts: {
    type: Number,
    required: true,
  },
  followers: {
    type: Number,
    required: true,
  },
  posts: {
    type: Array,
    required: true,
  },
});

// 直接通过解构 props，方便模板中直接使用变量名称
const { authorName, level, totalPosts, followers, posts } = props;
</script>

<style scoped>
.profile-page {
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
  padding: 0.5rem 0;
  transition: color 0.2s;
}

.nav-link:hover,
.nav-link.active {
  color: #b429ff;
  border-bottom: 2px solid #b429ff;
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

/* Profile Content */
.profile-content {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo-background {
  position: relative;
  width: 100%;
  display: flex;
  justify-content: center;
  margin-bottom: 3rem;
}

.logo-bg {
  width: 100%;
  max-width: 400px;
}

.avatar-container {
  position: absolute;
  bottom: -40px;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid white;
  background-color: white;
}

.avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.author-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2rem;
}

.author-name {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}

.follow-button {
  background-color: transparent;
  color: #b429ff;
  border: 1px solid #b429ff;
  border-radius: 20px;
  padding: 0.3rem 1.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.follow-button:hover {
  background-color: #b429ff;
  color: white;
}

/* Stats */
.stats-container {
  display: flex;
  justify-content: space-around;
  width: 100%;
  max-width: 500px;
  border: 1px solid rgba(180, 41, 255, 0.3);
  border-radius: 10px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-label {
  color: #b429ff;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: bold;
}

/* Tags */
.tags-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  width: 100%;
  max-width: 500px;
  border: 1px solid rgba(180, 41, 255, 0.3);
  border-radius: 10px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  gap: 0.5rem;
}

.tag-item {
  color: white;
}

.separator {
  color: rgba(255, 255, 255, 0.5);
}

/* Posts - Modified for scrollable container */
.posts-container {
  width: 100%;
  max-width: 500px;
  border: 1px solid rgba(180, 41, 255, 0.3);
  border-radius: 10px;
  padding: 1.5rem;
  /* Fixed height container */
  height: 400px; /* You can adjust this value as needed */
}

/* New scrollable container for posts */
.posts-scrollable {
  height: 100%;
  overflow-y: auto;
  /* Add some padding to prevent content from touching scrollbar */
  padding-right: 5px;
}

.post-item {
  padding: 1.5rem 0;
  border-bottom: 1px solid rgba(180, 41, 255, 0.3);
}

.post-item:last-child {
  border-bottom: none;
}

.post-title {
  font-size: 1.5rem;
  margin: 0 0 0.5rem 0;
}

.post-author {
  color: #cccccc;
  margin-bottom: 1rem;
}

.post-content {
  line-height: 1.6;
  margin-bottom: 1rem;
}

.post-tag {
  color: #b429ff;
}

/* Custom scrollbar styling */
.posts-scrollable::-webkit-scrollbar {
  width: 6px;
}

.posts-scrollable::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}

.posts-scrollable::-webkit-scrollbar-thumb {
  background: #b429ff;
  border-radius: 3px;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .profile-content {
    padding: 1rem;
  }

  .stats-container,
  .tags-container,
  .posts-container {
    padding: 1rem;
  }

  /* Adjust height for smaller screens */
  .posts-container {
    height: 350px;
  }
}
</style>
