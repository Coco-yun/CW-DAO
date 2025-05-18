<template>
  <div class="profile-page">
    <!-- Main Content Area -->
    <div class="main-content">
      <!-- Left Sidebar -->
      <div class="sidebar">
        <!-- User Profile Section -->
        <div class="user-profile">
          <div class="avatar-container">
            <img :src="userProfile.avatar" alt="用户头像" class="avatar" />
          </div>
          <div class="username">{{ userProfile.username }}</div>
          <button class="edit-button" @click="openEditModal">编辑</button>
        </div>

        <!-- Sidebar Navigation -->
        <div class="sidebar-nav">
          <button
            v-for="(item, index) in sidebarItems"
            :key="index"
            class="sidebar-item"
            :class="{ active: activeSection === item.id }"
            @click="setActiveSection(item.id)"
          >
            <span class="item-icon" v-if="item.icon">
              <component :is="item.icon" />
            </span>
            <span class="item-name">{{ item.name }}</span>
            <!-- 包裹文字 -->
          </button>
        </div>
      </div>

      <!-- Content Area -->
      <div class="content-area">
        <!-- My Posts Section -->
        <ScrollableContainer
          v-if="activeSection === 'mypost'"
          :totalItems="posts.length"
        >
          <template #icon>
            <img src="../../assets/image/文章.png" alt="文章" style="width: 10%;" />
          </template>

          <template #title>
            <span class="section-title">我的文章</span>
          </template>

          <PostItem
            v-for="(post, index) in posts"
            :key="index"
            :title="post.title"
            :content="post.content"
            :time="post.time"
            @delete="deletePost(index)"
          />
        </ScrollableContainer>

        <!-- Assets Section -->
        <ScrollableContainer
          v-if="activeSection === 'assets'"
          :showTotal="false"
        >
          <template #icon>
            <img src="../../assets/image/资产.png" alt="资产" style="width: 10%;" />
          </template>

          <template #title>
            <span class="section-title">我的资产</span>
          </template>

          <div class="assets-content">
            <div class="assets-total">
              <h3>DAO总资产</h3>
              <div class="assets-amount">
                {{ stakingTotalAssets }} <span>KLT 代币</span>
              </div>
            </div>

            <div class="assets-staking">
              <h3>质押资产</h3>
              <div class="assets-amount">
                {{ stakingAssets }} <span>KLT 代币</span>
              </div>
            </div>

            <div class="assets-divider"></div>

            <div class="assets-detail-header">
              <h3>资产明细</h3>
            </div>

            <div class="assets-detail-list">
              <AssetDetailItem
                v-for="(asset, index) in assetDetails"
                :key="index"
                :title="asset.title"
                :amount="asset.amount"
                @details="showAssetDetails(asset)"
              />
            </div>
          </div>
        </ScrollableContainer>

        <!-- Collection Section -->
        <ScrollableContainer
          v-if="activeSection === 'collection'"
          :totalItems="collections.length"
        >
          <template #icon>
            <img src="../../assets/image/收藏.png" alt="收藏" style="width: 8%;" />
          </template>

          <template #title>
            <span class="section-title">我的收藏</span>
          </template>

          <div
            v-for="(collection, index) in collections"
            :key="index"
            class="collection-item"
          >
            <h3 class="collection-title">{{ collection.title }}</h3>
            <div class="collection-author">
              {{ collection.author }} {{ collection.time }}
            </div>
            <p class="collection-content">{{ collection.content }}</p>
            <p class="collection-tag"># 标签</p>
            <div class="divider" v-if="index !== collections.length - 1"></div>
          </div>
        </ScrollableContainer>

        <!-- Notification Section -->
        <ScrollableContainer
          v-if="activeSection === 'notification'"
          :totalItems="notifications.length"
        >
          <template #icon>
            <img src="../../assets/image/通知.png" alt="通知" style="width: 8%;" />
          </template>

          <template #title>
            <span class="section-title">我的通知</span>
          </template>

          <notificateComponent
            v-for="(notification, index) in notifications"
            :key="index"
            :type="notification.type"
            :avatar="notification.avatar"
            :content="notification.content"
            :comment="notification.comment"
          />
        </ScrollableContainer>

        <!-- Followers Section -->
        <ScrollableContainer
          v-if="activeSection === 'followers'"
          :totalItems="followers.length"
        >
          <template #icon>
            <img src="../../assets/image/粉丝.png" alt="粉丝" style="width: 8%;" />
          </template>

          <template #title>
            <span class="section-title">我的粉丝</span>
          </template>

          <followerComponent
            v-for="(follower, index) in followers"
            :key="index"
            :avatar="follower.avatar"
            :name="follower.name"
            @visit-homepage="visitHomepage(follower.id)"
          />
        </ScrollableContainer>

        <!-- Following Section -->
        <ScrollableContainer
          v-if="activeSection === 'following'"
          :totalItems="following.length"
        >
          <template #icon>
            <img src="../../assets/image/关注.png" alt="关注" style="width: 8%;" />
          </template>

          <template #title>
            <span class="section-title">我的关注</span>
          </template>

          <followerComponent
            v-for="(user, index) in following"
            :key="index"
            :avatar="user.avatar"
            :name="user.name"
            @visit-homepage="visitHomepage(user.id)"
          />
        </ScrollableContainer>
      </div>
    </div>

    <!-- Edit Profile Modal -->
    <div
      class="modal-overlay"
      v-if="showEditModal"
    >
      <div class="edit-modal">
        <!-- Close Button -->
        <button class="close-button" @click="closeEditModal">
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
          >
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>

        <!-- Avatar Upload -->
        <div class="modal-avatar-container">
          <img
            :src="editFormData.avatar"
            alt="User Avatar"
            class="modal-avatar"
          />
          <button class="upload-button" @click="triggerFileUpload">
            Upload
          </button>
          <input
            type="file"
            id="avatar-upload"
            ref="fileInput"
            @change="handleFileUpload"
            accept="image/*"
            style="display: none"
          />
        </div>

        <!-- Form Fields -->
        <div class="form-group">
          <label for="username">用户名:</label>
          <input
            type="text"
            id="username"
            v-model="editFormData.username"
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="self-intro">自我介绍:</label>
          <textarea
            id="self-intro"
            v-model="editFormData.selfIntro"
            class="form-textarea"
          ></textarea>
        </div>

        <!-- Buttons Container -->
        <div class="buttons-container">
          <!-- Cancel Button -->
          <button class="cancel-button" @click="closeEditModal">取消</button>
          <!-- Save Button -->
          <button class="save-button" @click="saveProfile">保存</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import PostItem from "../../components/ProfileComponents/myPostComponent.vue";
import AssetDetailItem from "../../components/ProfileComponents/assetComponent.vue";
import ScrollableContainer from "../../components/ProfileComponents/scrollableContainer.vue";
import notificateComponent from "../../components/ProfileComponents/notificateComponent.vue";
import followerComponent from "../../components/ProfileComponents/followerComponent.vue";
import HomepageComponent from "../../components/HomeComponents/HomepageComponent.vue";

import useKLT from "../../composables/useKLT";
import useAuthorManager from "../../composables/useAuthorManager";
import useContentManager from "../../composables/useContentManager";
import useContentReviewDAO from "../../composables/useContentReviewDAO";

import authorAvatar from "../../assets/image/author1.png";
import authorAvatar1 from "../../assets/image/author2.png";
import authorAvatar2 from "../../assets/image/author3.png";
import authorAvatar3 from "../../assets/image/jiaxu.png";

const authorInfo = ref(null);
// 用户所有的资产
const userTotalAssets = ref(0);
// 用户质押的资产
const stakingAssets = ref(0);
// 池子中所有的资产
const stakingTotalAssets = ref(0);
// 文章的奖励总和
const contentRewards = ref(0);

const AuthorRewards = ref(0);

const posts = ref([]);
const collections = ref([]);
const followers = ref([]);
const following = ref([]);

onMounted(async () => {
  const klt = useKLT();

  const author = useAuthorManager();

  const content = useContentManager();

  const dao = useContentReviewDAO();

  if (!author && !content) {
    console.error("Web3 初始化失败");
    return;
  }

  try {
    const account = await author.getAccount();
    if (!account) {
      console.error("未连接钱包");
      return;
    }
    // author
    const authorInfo = await author.getAuthorInformationByAddress(account);

    userProfile.username = authorInfo[0];

    //作者的收藏
    collections.value = [];
    const collectionIDs = authorInfo[6];
    for (let index = 0; index < collectionIDs.length; index++) {
      const element = await content.getArticleDetails(collectionIDs[index]);
      console.log(element[1] + "我在这里呀");
      collections.value.push({
        title: "Topic",
        author: "author",
        time: "2025-4-12 10:56",
        content: element[1],
      });
    }

    //作者的关注
    following.value = [];
    const followingAddresses = authorInfo[2];
    console.log(followingAddresses);
    for (let index = 0; index < followingAddresses.length; index++) {
      const followingDetail = await author.getAuthorInformationByAddress(
        followingAddresses[index]
      );
      following.value.push({
        id: followingDetail[1],
        name: followingDetail[0],
        avatar: "/avatar-placeholder.png",
      });
    }

    // // 作者的粉丝
    followers.value = [];
    const followersAddresses = authorInfo[3];
    for (let index = 0; index < followersAddresses.length; index++) {
      const followerDetail = await author.getAuthorInformationByAddress(
        followersAddresses[index]
      );
      followers.value.push({
        id: followerDetail[1],
        name: followerDetail[0],
        avatar: "/avatar-placeholder.png",
      });
    }

    // content
    const contensIDs = await author.getArticlesForAuthor(account);
    posts.value = [];
    for (let i = 0; i < contensIDs.length; i++) {
      try {
        // 调用 content 合约中的 getArticleDetails，传入对应的 ID
        const articleDetail = await content.getArticleDetails(contensIDs[i]);
        
        // 安全处理数据，确保reward是数字类型
        let reward = 0;
        try {
          reward = Number(articleDetail.reward || 0);
        } catch (e) {
          console.warn("转换奖励值失败:", e);
        }
        contentRewards.value += reward;

        // 根据是否是最后一条信息来设置时间
        const time =
          i === contensIDs.length - 1 ? "2025-4-14 22:48" : "2025-4-12 10:56";

        // 构造用于显示的文章对象，确保内容字段存在
        posts.value.push({
          title: "Topic", // 固定值
          time: time, // 根据条件设置时间
          content: articleDetail.content || articleDetail[1] || "内容加载失败", // 尝试不同方式获取内容
        });
      } catch (error) {
        console.error(`获取文章ID ${contensIDs[i]} 详情失败:`, error);
        // 添加一个占位文章，表明加载失败
        posts.value.push({
          title: "加载失败",
          time: new Date().toLocaleString(),
          content: `文章ID ${contensIDs[i]} 加载失败，可能是合约数据格式不匹配`,
        });
      }
    }

    // dao And KLT
    stakingTotalAssets.value = await klt.balanceOf(
      "0x4FA88b6B204906046126EE4813034d876E2eAffe"
    );
    // 用户所有的资产
    userTotalAssets.value = await klt.balanceOf(account);
    // 用户质押的资产
    try {
      stakingAssets.value = await dao.getStakeOf(account);
      const rawStakeAmount = stakingAssets.value;
      stakingAssets.value = (Number(rawStakeAmount) / 1e18).toFixed(2);
    } catch (error) {
      console.error("获取质押资产失败:", error);
      stakingAssets.value = "0.00";
    }

    try {
      const amount = contentRewards.value;
      contentRewards.value = (Number(amount) / 1e18).toFixed(2);
    } catch (error) {
      console.error("计算内容奖励失败:", error);
      contentRewards.value = "0.00";
    }
  } catch (error) {
    console.error("获取作者信息失败:", error);
  }

  // DAO
});

// Active section state
const activeSection = ref("mypost");

// 查询名称功能

/////////////////////////////////////////////
// User profile data
const userProfile = reactive({
  username: "Autor",
  avatar: authorAvatar1,
  selfIntro: "This is my self introduction.",
});

// Edit modal state
const showEditModal = ref(false);
const fileInput = ref(null);
const editFormData = reactive({
  username: "",
  avatar: "",
  selfIntro: "",
});

// Sidebar items
const sidebarItems = [
  { id: "mypost", name: "我的文章", icon: null },
  { id: "assets", name: "资产", icon: null },
  { id: "collection", name: "收藏", icon: null },
  { id: "notification", name: "通知", icon: null },
  { id: "following", name: "关注", icon: null },
  { id: "followers", name: "粉丝", icon: null },
];

// Asset details data

const assetDetails = ref([
  { title: "审核员总资产", amount: userTotalAssets },
  { title: "审核奖励", amount: contentRewards },
  { title: "审核扣减", amount: 0 },
  { title: "读者举报奖励", amount: contentRewards.value * 0.9 },
  { title: "来自读者的作者奖励", amount: AuthorRewards },
]);

// Notification data
const notifications = ref([
  {
    type: "comment",
    avatar: authorAvatar,
    content: "dusko 评论了你的文章",
    comment: "评论内容",
  },
  {
    type: "like",
    avatar: authorAvatar1,
    content: "pzqy 赞了你的文章",
  },
  {
    type: "collect",
    avatar: authorAvatar2,
    content: "d50 收藏了你的文章",
  },
  {
    type: "reward",
    avatar: authorAvatar3,
    content: "jiaxu 给了你1个代币作为文章奖励",
  },
]);

// Function to set active section
const setActiveSection = (sectionId) => {
  activeSection.value = sectionId;
};

// Function to open edit modal
const openEditModal = () => {
  // Copy current profile data to form
  editFormData.username = userProfile.username;
  editFormData.avatar = userProfile.avatar;
  editFormData.selfIntro = userProfile.selfIntro;
  showEditModal.value = true;
};

// Function to close edit modal
const closeEditModal = () => {
  showEditModal.value = false;
};

// Function to trigger file upload dialog
const triggerFileUpload = () => {
  fileInput.value.click();
};

// Function to handle file upload
const handleFileUpload = (event) => {
  const file = event.target.files[0];
  if (file) {
    // Create a URL for the file
    const fileURL = URL.createObjectURL(file);
    editFormData.avatar = fileURL;
  }
};

// Function to save profile changes
const saveProfile = () => {
  // Update user profile with form data
  userProfile.username = editFormData.username;
  userProfile.avatar = editFormData.avatar;
  userProfile.selfIntro = editFormData.selfIntro;

  // Close the modal
  closeEditModal();

  console.log("Profile updated:", userProfile);
};

// Function to visit user's homepage
const visitHomepage = (userId) => {
  console.log(`Visit homepage of user ${userId}`);
};

// Function to delete post
const deletePost = (index) => {
  posts.value.splice(index, 1);
};

// Function to show asset details
const showAssetDetails = (asset) => {
  console.log("Show details for:", asset.title);
  // Implement your details logic here
};
</script>

<style scoped>
/* Profile Page Styles */
.profile-page {
  background-color: var(--background-color);
  color: var(--text-primary);
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  padding-top: 5rem; /* 为顶部导航栏留出空间 */
  padding-bottom: 2rem;
}

/* Icon Text Styles */
.icon-text {
  font-size: var(--font-size-md);
  font-weight: bold;
  color: var(--primary-color);
}

.section-title {
  font-size: var(--font-size-xl);
  font-weight: bold;
  color: var(--primary-color);
  margin-left: 0.5rem;
}

/* Main Content Area Styles */
.main-content {
  display: flex;
  flex: 1;
  padding: 1.5rem 3rem 2.5rem;
  background-color: var(--background-secondary);
}

/* Sidebar Styles */
.sidebar {
  min-width: 16.25rem;
  width: 16.25rem;
  border-right: 1px solid var(--border-color);
  padding: 1.8rem 1.2rem 1.2rem;
  display: flex;
  flex-direction: column;
  background-color: var(--background-color);
  border-radius: 0.9375rem 0 0 0.9375rem;
  box-shadow: -0.3125rem 0 0.9375rem rgba(0, 0, 0, 0.05);
  margin-right: 0.125rem;
}

/* User Profile Section */
.user-profile {
  text-align: center;
  margin-bottom: 2.5rem;
  padding-bottom: 1.8rem;
  border-bottom: 2px solid var(--primary-light);
  position: relative;
}

.avatar-container {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  margin: 0 auto 1.2rem;
  border: 4px solid var(--primary-light);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  position: relative;
  z-index: 1;
}

.avatar-container::after {
  content: '';
  position: absolute;
  top: -5px;
  left: -5px;
  right: -5px;
  bottom: -5px;
  border-radius: 50%;
  background: linear-gradient(45deg, var(--primary-color), var(--primary-light));
  z-index: -1;
  opacity: 0.2;
}

.avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.username {
  font-weight: bold;
  font-size: 1.4rem;
  margin-bottom: 0.8rem;
  color: var(--text-primary);
}

.edit-button {
  border: 1px solid var(--primary-color);
  border-radius: 20px;
  padding: 0.5rem 1.5rem;
  cursor: pointer;
  color: var(--primary-color);
  background-color: var(--background-color);
  transition: all 0.3s ease;
  font-size: 1rem;
  font-weight: 500;
  box-shadow: 0 3px 8px rgba(30, 144, 255, 0.1);
}

.edit-button:hover {
  background-color: var(--primary-light);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(30, 144, 255, 0.2);
}

/* Sidebar Navigation */
.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.sidebar-item {
  display: flex;
  align-items: center;
  padding: 1rem 1.2rem;
  margin-bottom: 0.3rem;
  border-radius: 10px;
  cursor: pointer;
  text-align: left;
  background: none;
  border: none;
  color: var(--text-primary);
  font-size: 1.1rem;
  transition: all 0.3s ease;
  font-weight: 500;
  letter-spacing: 0.5px;
}

.sidebar-item:hover {
  background-color: var(--background-secondary);
  color: var(--primary-color);
  transform: translateX(5px);
}

.sidebar-item.active {
  background-color: var(--primary-light);
  color: white;
  font-weight: 600;
  border-left: 3px solid var(--primary-color);
  box-shadow: 0 4px 10px rgba(30, 144, 255, 0.15);
}

.item-icon {
  margin-right: 0.8rem;
}

/* Content Area Styles */
.content-area {
  flex: 1;
  padding: 2rem;
  overflow: hidden;
  background-color: var(--background-color);
  border-radius: 0 15px 15px 0;
  box-shadow: 5px 0 15px rgba(0, 0, 0, 0.05);
  border-left: 1px solid var(--border-color);
}

/* Assets specific styles */
.assets-content {
  padding: 1.5rem;
  background-color: var(--background-secondary);
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.assets-total,
.assets-staking {
  margin-bottom: 2rem;
  background-color: var(--background-color);
  padding: 1.5rem;
  border-radius: 10px;
  border: 1px solid var(--border-color);
  transition: all 0.3s;
}

.assets-total:hover,
.assets-staking:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: var(--primary-light);
}

.assets-total h3,
.assets-staking h3,
.assets-detail-header h3 {
  color: var(--primary-color);
  font-size: 1.3rem;
  margin-bottom: 0.8rem;
  letter-spacing: 0.5px;
}

.assets-amount {
  font-size: 2.2rem;
  font-weight: bold;
  color: var(--primary-dark);
}

.assets-amount span {
  font-size: 1.2rem;
  margin-left: 0.5rem;
  color: var(--text-secondary);
}

.assets-divider {
  height: 2px;
  background-color: var(--border-color);
  margin: 2rem 0;
}

.assets-detail-header {
  margin-bottom: 1.5rem;
}

.assets-detail-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* Collection specific styles */
.collection-item {
  padding: 1.5rem;
  background-color: var(--background-secondary);
  border-radius: 12px;
  margin-bottom: 1.5rem;
  transition: all 0.3s;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--border-color);
}

.collection-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: var(--primary-light);
}

.collection-title {
  font-size: 1.3rem;
  margin: 0 0 0.8rem 0;
  color: var(--primary-color);
}

.collection-author {
  color: var(--text-light);
  font-size: 0.95rem;
  margin-bottom: 0.8rem;
}

.collection-content {
  margin: 0.8rem 0;
  line-height: 1.6;
  color: var(--text-primary);
}

.collection-tag {
  color: var(--primary-color);
  margin: 0.8rem 0 0;
  font-weight: 500;
}

.divider {
  height: 1px;
  background-color: var(--border-color);
  margin: 1.5rem 0;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
}

.edit-modal {
  width: 90%;
  max-width: 550px;
  padding: 2.5rem;
  border-radius: 15px;
  border: 2px solid var(--primary-light);
  position: relative;
  background-color: var(--background-color);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.close-button {
  position: absolute;
  top: 1.5rem;
  right: 1.5rem;
  background: none;
  border: none;
  color: var(--primary-color);
  cursor: pointer;
  padding: 0;
  transition: all 0.3s;
}

.close-button:hover {
  transform: rotate(90deg);
}

.modal-avatar-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2.5rem;
}

.modal-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid var(--primary-color);
  margin-bottom: 1.5rem;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
}

.upload-button {
  border: 1px solid var(--primary-color);
  border-radius: 25px;
  padding: 0.7rem 2rem;
  cursor: pointer;
  color: var(--primary-color);
  background-color: var(--background-color);
  transition: all 0.3s ease;
  font-size: 1.1rem;
  letter-spacing: 1px;
  font-weight: 500;
  box-shadow: 0 4px 10px rgba(30, 144, 255, 0.1);
}

.upload-button:hover {
  background-color: var(--primary-light);
  color: white;
  transform: translateY(-3px);
  box-shadow: 0 8px 15px rgba(30, 144, 255, 0.2);
}

.upload-button:active {
  transform: translateY(2px);
  box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.1);
}

.form-group {
  margin-bottom: 2rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.8rem;
  font-weight: 600;
  color: var(--text-primary);
  font-size: 1.1rem;
}

.form-input,
.form-textarea {
  width: 100%;
  padding: 1rem;
  border: 1px solid var(--border-color);
  border-radius: 10px;
  background-color: var(--background-color);
  color: var(--text-primary);
  font-size: 1.05rem;
  transition: all 0.3s;
}

.form-input:focus,
.form-textarea:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.1);
  outline: none;
}

.form-textarea {
  min-height: 180px;
  resize: vertical;
}

/* Buttons container */
.buttons-container {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  margin-top: 2rem;
}

.cancel-button {
  width: 40%;
  border: 1px solid var(--border-color);
  border-radius: 25px;
  padding: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 2px;
  color: var(--text-primary);
  background-color: var(--background-color);
  transition: all 0.3s ease;
}

.cancel-button:hover {
  background-color: var(--background-secondary);
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.cancel-button:active {
  transform: translateY(2px);
  box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.1);
}

.save-button {
  width: 40%;
  border: 1px solid var(--primary-color);
  border-radius: 25px;
  padding: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 2px;
  color: white;
  background-color: var(--primary-color);
  transition: all 0.3s ease;
}

.save-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(30, 144, 255, 0.3);
}

.save-button:active {
  transform: translateY(2px);
  box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.2);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .main-content {
    flex-direction: column;
    padding: 1rem;
  }
  
  .sidebar {
    width: 100%;
    min-width: 100%;
    border-right: none;
    border-radius: 15px 15px 0 0;
    border-bottom: 1px solid var(--border-color);
    padding: 1.5rem;
    margin-right: 0;
    margin-bottom: 2px;
  }
  
  .content-area {
    border-radius: 0 0 15px 15px;
    border-left: none;
    border-top: 1px solid var(--border-color);
  }
  
  .user-profile {
    margin-bottom: 1.5rem;
  }
  
  .avatar-container {
    width: 100px;
    height: 100px;
  }
  
  .buttons-container {
    flex-direction: column;
    gap: 1rem;
  }
  
  .cancel-button,
  .save-button {
    width: 100%;
  }
}
</style>
