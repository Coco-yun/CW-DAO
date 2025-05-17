<template>
  <div class="posts-list-container">
    <!-- 列表区：当没有选择文章时显示所有文章简略信息 -->
    <div v-if="!selectedPost.postID" class="posts-list">
      <div
        v-for="(post, index) in posts"
        :key="index"
        class="post-item"
        @click="openPostDetail(post)"
      >
        <h3 class="post-title">{{ post.title }}</h3>
        <div class="post-author">{{ post.author }} - {{ post.time }}</div>
        <div class="post-content">
          {{
            post.content.length > 100
              ? post.content.substring(0, 100) + "..."
              : post.content
          }}
        </div>
      </div>
    </div>

    <!-- 文章详情区：直接在页面显示选中的文章 -->
    <div v-else class="post-detail">
      <!-- 标题居中显示 -->
      <div class="center-title">
        <h2 class="detail-title">{{ selectedPost.title }}</h2>
      </div>

      <!-- 返回按钮和作者信息 -->
      <div class="detail-meta">
        <button class="back-button" @click="closePostDetail">
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
          >
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
          </svg>
          返回列表
        </button>
        <div class="detail-author">
          {{ selectedPost.author }} - {{ selectedPost.time }}
        </div>
      </div>
      
      <div class="detail-content">
        {{ selectedPost.content }}
      </div>
      
      <div class="detail-actions">
        <button @click="likePost" class="action-button like-button">
          <svg class="action-icon" viewBox="0 0 24 24" width="18" height="18">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
          </svg>
          点赞
        </button>
        <button @click="collectPost" class="action-button collect-button">
          <svg class="action-icon" viewBox="0 0 24 24" width="18" height="18">
            <path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z" />
          </svg>
          收藏
        </button>
        <button @click="openCommentModal" class="action-button comment-button">
          <svg class="action-icon" viewBox="0 0 24 24" width="18" height="18">
            <path d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z" />
          </svg>
          评论
        </button>
        <button @click="openRewardModal" class="action-button reward-button">
          <svg class="action-icon" viewBox="0 0 24 24" width="18" height="18">
            <path d="M20 6h-2.18c.11-.31.18-.65.18-1 0-1.66-1.34-3-3-3-1.05 0-1.96.54-2.5 1.35l-.5.67-.5-.68C10.96 2.54 10.05 2 9 2 7.34 2 6 3.34 6 5c0 .35.07.69.18 1H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2zm-5-2c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zM9 4c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm11 15H4v-2h16v2zm0-5H4V8h5.08L7 10.83 8.62 12 12 7.4l3.38 4.6L17 10.83 14.92 8H20v6z" />
          </svg>
          打赏
        </button>
      </div>
    </div>

    <!-- 评论输入弹窗 -->
    <div
      class="modal-overlay"
      v-if="showCommentModal"
      @click.self="closeCommentModal"
    >
      <div class="post-modal comment-modal">
        <button class="close-button" @click="closeCommentModal">×</button>
        <h2 class="modal-title">添加评论</h2>
        <textarea
          v-model="commentText"
          id="comment-text"
          name="comment-text"
          placeholder="写下你的想法..."
          class="comment-textarea"
        ></textarea>
        <div class="modal-buttons">
          <button @click="closeCommentModal" class="cancel-button">取消</button>
          <button @click="submitComment" class="submit-button">提交评论</button>
        </div>
      </div>
    </div>

    <!-- 打赏输入弹窗 -->
    <div
      class="modal-overlay"
      v-if="showRewardModal"
      @click.self="closeRewardModal"
    >
      <div class="post-modal reward-modal">
        <button class="close-button" @click="closeRewardModal">×</button>
        <h2 class="modal-title">打赏作者</h2>
        <p class="reward-description">支持作者创作更多优质内容</p>
        <div class="reward-input-container">
          <input
            type="number"
            id="reward-amount"
            name="reward-amount"
            v-model="rewardAmount"
            placeholder="输入打赏金额..."
            class="reward-input"
          />
          <span class="reward-currency">代币</span>
        </div>
        <div class="modal-buttons">
          <button @click="closeRewardModal" class="cancel-button">取消</button>
          <button @click="submitReward" class="submit-button">确认打赏</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, defineProps } from "vue";
import useContentManager from "../../composables/useContentManager";
import useAuthorManager from "../../composables/useAuthorManager";

// 接收 posts 数据
const props = defineProps({
  posts: {
    type: Array,
    required: true,
  },
});

const selectedPost = ref({});
const showCommentModal = ref(false);
const showRewardModal = ref(false);
const commentText = ref("");
const rewardAmount = ref(0);

// 点击某个 post 时直接在页面显示详情
const openPostDetail = (post) => {
  selectedPost.value = post;
  window.scrollTo({ top: 0, behavior: 'smooth' });
};

// 关闭详情，返回列表
const closePostDetail = () => {
  selectedPost.value = {};
};

// 打开评论输入弹窗
const openCommentModal = () => {
  showCommentModal.value = true;
};

// 关闭评论输入弹窗
const closeCommentModal = () => {
  showCommentModal.value = false;
  commentText.value = ""; // 清空输入
};

// 提交评论
const submitComment = async () => {
  try {
    const contentManager = useContentManager();
    const id = selectedPost.value.postID; // 文章 ID
    const comment = commentText.value; // 评论内容
    await contentManager.addComment(id, comment); // 传递评论内容
  } catch (error) {
    console.error("评论操作失败:", error);
  }
  closeCommentModal();
};

// 打开打赏输入弹窗
const openRewardModal = () => {
  showRewardModal.value = true;
};

// 关闭打赏输入弹窗
const closeRewardModal = () => {
  showRewardModal.value = false;
  rewardAmount.value = 0; // 清空输入
};

// 提交打赏
const submitReward = async () => {
  try {
    const content = useContentManager();
    const id = selectedPost.value.postID;

    // 确保 rewardAmount 是一个有效的数字
    const amount = parseFloat(rewardAmount.value);
    if (isNaN(amount) || amount <= 0) {
      throw new Error("请输入有效的打赏金额");
    }

    // 调用 rewardArticle 方法，转换为 Wei
    await content.rewardArticle(id, amount.toString()); // 这里假设合约需要字符串形式的金额

    console.log("打赏金额:", amount);
  } catch (error) {
    console.error("打赏操作失败:", error);
  }
  closeRewardModal();
};

// 以下为各操作的占位函数，具体功能由你来实现
const likePost = async () => {
  try {
    const content = useContentManager();
    const id = selectedPost.value.postID;
    await content.likeArticle(id);
  } catch (error) {
    console.error("点赞操作失败:", error);
  }
};

const collectPost = () => {
  const author = useAuthorManager();
  const account = author.getAccount();
  const id = selectedPost.value.postID;
  author.setCollectArticleId(id, account);
};
</script>

<style scoped>
.posts-list-container {
  padding: var(--spacing-md);
}

/* 文章列表样式 */
.posts-list {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.post-item {
  background-color: var(--background-color);
  padding: 1.5rem;
  border: 1px solid var(--border-color);
  border-radius: 0.75rem;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 0.1875rem 0.625rem rgba(0, 0, 0, 0.06);
}

.post-item:hover {
  border-color: var(--primary-color);
  box-shadow: 0 0.375rem 0.9375rem rgba(30, 144, 255, 0.15);
  transform: translateY(-0.1875rem);
}

.post-title {
  font-size: var(--font-size-xl);
  margin: 0 0 0.7rem 0;
  color: var(--primary-color);
}

.post-author {
  font-size: 0.95rem;
  color: var(--text-light);
  margin-bottom: 1rem;
}

.post-content {
  font-size: var(--font-size-md);
  line-height: 1.5;
  color: var(--text-primary);
}

/* 文章详情样式 */
.post-detail {
  background-color: var(--background-color);
  padding: 2rem;
  border-radius: 0.75rem;
  box-shadow: 0 0.25rem 1rem rgba(0, 0, 0, 0.1);
  animation: fadeIn 0.3s ease;
  position: relative;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.center-title {
  text-align: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.detail-title {
  font-size: 1.8rem;
  font-weight: bold;
  color: var(--primary-color);
  margin: 0;
  text-align: center;
}

.detail-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: none;
  border: none;
  color: var(--primary-color);
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  padding: 0.5rem 0.8rem;
  border-radius: 0.5rem;
  transition: all 0.3s ease;
}

.back-button:hover {
  background-color: rgba(30, 144, 255, 0.1);
  transform: translateX(-3px);
}

.detail-author {
  font-size: 1rem;
  color: var(--text-light);
}

.detail-content {
  font-size: 1.1rem;
  line-height: 1.8;
  color: var(--text-primary);
  margin-bottom: 2.5rem;
  padding: 0 1rem;
  white-space: pre-line;
}

.detail-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  justify-content: center;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border-color);
}

/* 模态窗样式 */
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

.post-modal {
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 15px;
  padding: 2.5rem;
  width: 90%;
  max-width: 650px;
  color: var(--text-primary);
  position: relative;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
}

.close-button {
  position: absolute;
  top: 1.2rem;
  right: 1.2rem;
  background: none;
  border: none;
  font-size: 1.8rem;
  color: var(--primary-color);
  cursor: pointer;
  transition: all 0.2s;
}

.close-button:hover {
  transform: rotate(90deg);
  color: var(--primary-dark);
}

.modal-title {
  font-size: 2rem;
  margin-bottom: 0.8rem;
  color: var(--primary-color);
}

.action-button {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  border: none;
  border-radius: 10px;
  padding: 0.8rem 0.5rem;
  color: white;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  min-width: 80px;
}

.action-icon {
  fill: currentColor;
}

.like-button {
  background-color: #ff6b6b;
}

.collect-button {
  background-color: #feca57;
}

.comment-button {
  background-color: #54a0ff;
}

.reward-button {
  background-color: #5f27cd;
}

.action-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}

/* 评论和打赏模态框 */
.comment-modal, .reward-modal {
  max-width: 500px;
}

.comment-textarea {
  width: 100%;
  height: 150px;
  border-radius: 10px;
  border: 1px solid var(--border-color);
  background-color: var(--background-color);
  color: var(--text-primary);
  padding: 1rem;
  margin-bottom: 1.5rem;
  font-size: 1.05rem;
  resize: none;
  transition: all 0.3s;
}

.comment-textarea:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.2);
  outline: none;
}

.reward-description {
  text-align: center;
  color: var(--text-secondary);
  margin-bottom: 1.5rem;
  font-size: 1.1rem;
}

.reward-input-container {
  display: flex;
  align-items: center;
  border: 1px solid var(--border-color);
  border-radius: 10px;
  padding: 0 1rem;
  margin-bottom: 1.5rem;
  transition: all 0.3s;
}

.reward-input-container:focus-within {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.2);
}

.reward-input {
  flex: 1;
  border: none;
  background: transparent;
  padding: 1rem 0;
  font-size: 1.1rem;
  color: var(--text-primary);
  outline: none;
}

.reward-currency {
  color: var(--primary-color);
  font-weight: bold;
  font-size: 1.1rem;
}

.modal-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.cancel-button, .submit-button {
  padding: 0.8rem 1.5rem;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
}

.cancel-button {
  background-color: var(--background-secondary);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
}

.submit-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
}

.cancel-button:hover, .submit-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.submit-button:hover {
  background-color: var(--primary-dark);
}

/* 响应式样式 */
@media (max-width: 768px) {
  .post-item {
    padding: 1.2rem;
  }
  
  .post-detail {
    padding: 1.5rem 1rem;
  }
  
  .detail-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .detail-title {
    font-size: 1.5rem;
  }
  
  .detail-content {
    padding: 0;
    font-size: 1rem;
  }
  
  .detail-actions {
    flex-direction: column;
  }
  
  .action-button {
    width: 100%;
  }
}
</style>
