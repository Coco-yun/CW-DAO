<template>
  <div class="post-page">
    <!-- 导航栏 -->
    <NavigationBar />

    <div class="main-layout">
      <!-- 左侧边栏 -->
      <div class="sidebar">
        <!-- 标题区域 -->
        <div class="platform-info">
          <h1 class="platform-title">发布中心</h1>
          <p class="platform-subtitle">分享您的观点和见解</p>
        </div>
        
        <!-- 左侧导航菜单 -->
        <div class="sidebar-nav">
          <button
            class="sidebar-item"
            :class="{ active: activeTab === 'write' }"
            @click="setActiveTab('write')"
          >
            <span class="item-icon">📝</span>
            <span class="item-name">写文章</span>
          </button>
          <button
            class="sidebar-item"
            :class="{ active: activeTab === 'drafts' }"
            @click="setActiveTab('drafts')"
          >
            <span class="item-icon">📊</span>
            <span class="item-name">我的草稿</span>
          </button>
          <button
            class="sidebar-item"
            :class="{ active: activeTab === 'history' }"
            @click="setActiveTab('history')"
          >
            <span class="item-icon">📚</span>
            <span class="item-name">发布记录</span>
          </button>
          
          <div class="tips-container">
            <h3 class="tips-title">发布小贴士</h3>
            <ul class="tips-list">
              <li>添加图片可以让文章更加生动</li>
              <li>撰写原创内容有机会获得更多奖励</li>
              <li>选择合适的标签可以让更多人看到</li>
              <li>分享到社交媒体可以获得更多曝光</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- 主内容区域 -->
      <div class="content-area">
        <!-- 写文章页面 -->
        <div v-if="activeTab === 'write'" class="post-form">
          <div class="form-group">
            <textarea
              v-model="postContent"
              id="post-content"
              name="post-content"
              class="post-textarea"
              placeholder="在此撰写您的帖子内容..."
            ></textarea>
          </div>
          
          <div class="action-buttons">
            <button class="save-draft-button" @click="saveDraft">保存草稿</button>
            <button
              class="post-button"
              @click="handleSubmit"
              :disabled="isPublishing || !postContent"
            >
              {{ isPublishing ? "发布中..." : "发布文章" }}
            </button>
          </div>
        </div>
        
        <!-- 草稿列表页面 -->
        <div v-else-if="activeTab === 'drafts'" class="list-container">
          <div class="section-header">
            <h2 class="section-title">我的草稿</h2>
            <p class="section-subtitle">这里保存了您尚未发布的文章</p>
          </div>
          
          <div v-if="drafts.length > 0" class="items-list">
            <div v-for="(draft, index) in drafts" :key="index" class="list-item">
              <div class="item-content">
                <h3 class="item-title">{{ draft.title || '无标题草稿' }}</h3>
                <p class="item-preview">{{ getDraftPreview(draft.content) }}</p>
                <div class="item-meta">
                  <span class="item-date">最后编辑于 {{ formatDate(draft.timestamp) }}</span>
                  <span class="item-tags">
                    <span v-for="(tag, tagIndex) in draft.tags" :key="tagIndex" class="item-tag">{{ tag }}</span>
                  </span>
                </div>
              </div>
              <div class="item-actions">
                <button class="action-button edit-button" @click="editDraft(index)">编辑</button>
                <button class="action-button delete-button" @click="deleteDraft(index)">删除</button>
              </div>
            </div>
          </div>
          
          <div v-else class="empty-state">
            <div class="empty-icon">📝</div>
            <h3 class="empty-title">还没有草稿</h3>
            <p class="empty-desc">您的草稿将会显示在这里</p>
            <button class="create-button" @click="setActiveTab('write')">开始创作</button>
          </div>
        </div>
        
        <!-- 发布记录页面 -->
        <div v-else-if="activeTab === 'history'" class="list-container">
          <div class="section-header">
            <h2 class="section-title">发布记录</h2>
            <p class="section-subtitle">查看您已发布的所有文章</p>
          </div>
          
          <div v-if="publishedArticles.length > 0" class="items-list">
            <div v-for="(article, index) in publishedArticles" :key="index" class="list-item">
              <div class="item-content">
                <h3 class="item-title">{{ article.title || '无标题文章' }}</h3>
                <p class="item-preview">{{ getArticlePreview(article.content) }}</p>
                <div class="item-meta">
                  <span class="item-date">发布于 {{ formatDate(article.timestamp) }}</span>
                  <span class="item-info">
                    <span class="info-item"><i class="info-icon">👁️</i> {{ article.views || 0 }}</span>
                    <span class="info-item"><i class="info-icon">👍</i> {{ article.likes || 0 }}</span>
                    <span class="info-item"><i class="info-icon">💰</i> {{ article.rewards || 0 }}</span>
                  </span>
                </div>
              </div>
              <div class="item-actions">
                <button class="action-button view-button" @click="viewArticle(article.id)">查看</button>
              </div>
            </div>
          </div>
          
          <div v-else class="empty-state">
            <div class="empty-icon">📚</div>
            <h3 class="empty-title">还没有发布文章</h3>
            <p class="empty-desc">您的已发布文章将会显示在这里</p>
            <button class="create-button" @click="setActiveTab('write')">开始创作</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import NavigationBar from "../../components/NavigationBar.vue";
import useContentManager from "../../composables/useContentManager";
import { useRouter } from "vue-router";

const router = useRouter();
const { writeArticle } = useContentManager();

const isPublishing = ref(false);
const postContent = ref("");
const activeTab = ref("write"); // 默认显示写文章页面

// 草稿和发布文章数据
const drafts = ref([]);
const publishedArticles = ref([]);

// 设置活跃标签
const setActiveTab = (tab) => {
  activeTab.value = tab;
};

// 从localStorage加载草稿
const loadDrafts = () => {
  try {
    const savedDrafts = localStorage.getItem('post-drafts');
    if (savedDrafts) {
      drafts.value = JSON.parse(savedDrafts);
    }
  } catch (error) {
    console.error('加载草稿失败:', error);
  }
};

// 保存草稿到localStorage
const saveDraftToStorage = () => {
  try {
    localStorage.setItem('post-drafts', JSON.stringify(drafts.value));
  } catch (error) {
    console.error('保存草稿失败:', error);
  }
};

// 保存当前编辑的内容为草稿
const saveDraft = () => {
  if (!postContent.value) {
    alert('草稿内容为空，无需保存');
    return;
  }
  
  const newDraft = {
    content: postContent.value,
    timestamp: new Date().toISOString()
  };
  
  drafts.value.unshift(newDraft);
  saveDraftToStorage();
  
  alert('草稿保存成功！');
  
  // 清空当前编辑区
  postContent.value = '';
};

// 编辑已保存的草稿
const editDraft = (index) => {
  const draft = drafts.value[index];
  postContent.value = draft.content || '';
  
  // 删除这个草稿
  drafts.value.splice(index, 1);
  saveDraftToStorage();
  
  // 切换到编辑页面
  setActiveTab('write');
};

// 删除草稿
const deleteDraft = (index) => {
  if (confirm('确定要删除这个草稿吗？此操作不可撤销')) {
    drafts.value.splice(index, 1);
    saveDraftToStorage();
  }
};

// 获取草稿预览
const getDraftPreview = (content) => {
  if (!content) return '空白草稿';
  return content.length > 100 ? content.substring(0, 100) + '...' : content;
};

// 获取文章预览
const getArticlePreview = (content) => {
  if (!content) return '暂无内容';
  return content.length > 100 ? content.substring(0, 100) + '...' : content;
};

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '未知时间';
  const date = new Date(dateString);
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()} ${date.getHours()}:${date.getMinutes()}`;
};

// 查看已发布文章
const viewArticle = (id) => {
  // 跳转到文章详情页
  router.push(`/article/${id}`);
};

// 加载已发布文章
const loadPublishedArticles = async () => {
  try {
    const contentManager = useContentManager();
    if (!contentManager) return;

    const account = await contentManager.getAccount();
    if (!account) return;

    const postIDs = await contentManager.getAllArticleId();
    const articles = [];

    for (let i = 0; i < postIDs.length; i++) {
      const articleDetail = await contentManager.getArticleDetails(postIDs[i]);
      articles.push({
        id: articleDetail.id,
        content: articleDetail.content,
        timestamp: new Date().toISOString(),
        views: Math.floor(Math.random() * 100), // 模拟数据
        likes: Math.floor(Math.random() * 50),  // 模拟数据
        rewards: Math.floor(Math.random() * 10) // 模拟数据
      });
    }

    publishedArticles.value = articles;
  } catch (error) {
    console.error('加载已发布文章失败:', error);
  }
};

const handleSubmit = async () => {
  if (!postContent.value.trim()) {
    alert("请输入文章内容");
    return;
  }
  
  try {
    isPublishing.value = true;

    // 直接调用智能合约的 writeArticle 方法
    await writeArticle(postContent.value);

    // 重置表单
    postContent.value = '';
    
    alert("发布成功！");
  } catch (error) {
    console.error("发布失败:", error);
    alert(error.message || "发布失败");
  } finally {
    isPublishing.value = false;
  }
};

// 初始化
onMounted(() => {
  loadDrafts();
  loadPublishedArticles();
});
</script>

<style scoped>
.post-page {
  min-height: 100vh;
  background-color: var(--background-color);
  color: var(--text-primary);
  display: flex;
  flex-direction: column;
  padding-top: 5rem; /* 为顶部导航栏留出空间 */
}

.main-layout {
  display: flex;
  flex: 1;
  height: calc(100vh - 5rem);
}

/* 侧边栏样式 */
.sidebar {
  min-width: 16rem;
  width: 16rem;
  border-right: 1px solid var(--border-color);
  padding: 1.5rem 1rem;
  display: flex;
  flex-direction: column;
  background-color: var(--background-color);
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.05);
}

.platform-info {
  padding: 0.8rem;
  margin-bottom: 1.5rem;
  text-align: center;
  border-bottom: 2px solid var(--primary-light);
  padding-bottom: 1.5rem;
}

.platform-title {
  font-size: 1.8rem;
  font-weight: bold;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
}

.platform-subtitle {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.sidebar-item {
  display: flex;
  align-items: center;
  padding: 0.8rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  text-align: left;
  background: none;
  border: none;
  color: var(--text-primary);
  font-size: 1rem;
  transition: all 0.3s ease;
  font-weight: 500;
}

.sidebar-item .item-icon {
  margin-right: 0.8rem;
  font-size: 1.2rem;
}

.sidebar-item:hover {
  background-color: var(--background-secondary);
  color: var(--primary-color);
}

.sidebar-item.active {
  background-color: var(--primary-light);
  color: white;
  font-weight: 600;
  border-left: 3px solid var(--primary-color);
  box-shadow: 0 2px 8px rgba(30, 144, 255, 0.15);
}

.tips-container {
  margin-top: 2rem;
  padding: 1.2rem;
  background-color: #f8f9fa;
  border-radius: 0.5rem;
  border-left: 3px solid var(--primary-color);
}

.tips-title {
  font-size: 1.1rem;
  color: var(--primary-color);
  margin-bottom: 0.8rem;
}

.tips-list {
  padding-left: 1.2rem;
  margin: 0;
}

.tips-list li {
  margin-bottom: 0.6rem;
  font-size: 0.9rem;
  color: var(--text-secondary);
}

/* 内容区样式 */
.content-area {
  flex: 1;
  padding: 2rem;
  overflow-y: auto;
}

.post-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  width: 100%;
}

.post-textarea {
  width: 100%;
  min-height: 300px;
  resize: vertical;
  padding: 1rem;
  font-size: 1.1rem;
  line-height: 1.6;
  border: 1px solid var(--border-color);
  border-radius: 0.5rem;
  outline: none;
  transition: all 0.3s;
  background-color: var(--background-color);
  color: var(--text-primary);
}

.post-textarea:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.1);
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}

.save-draft-button, .post-button {
  padding: 0.8rem 1.5rem;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.save-draft-button {
  background-color: var(--background-secondary);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}

.save-draft-button:hover {
  background-color: var(--background-color);
  color: var(--primary-color);
  border-color: var(--primary-color);
}

.post-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.post-button:hover:not(:disabled) {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.3);
}

.post-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 响应式样式 */
@media (max-width: 768px) {
  .main-layout {
    flex-direction: column;
    height: auto;
  }
  
  .sidebar {
    width: 100%;
    min-width: 100%;
    border-right: none;
    border-bottom: 1px solid var(--border-color);
    padding: 1rem;
  }
  
  .content-area {
    padding: 1rem;
  }
  
  .post-textarea {
    min-height: 200px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .save-draft-button, .post-button {
    width: 100%;
  }
}

/* 新添加的样式 */
.list-container {
  width: 100%;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--primary-light);
}

.section-title {
  font-size: 1.8rem;
  font-weight: bold;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
}

.section-subtitle {
  color: var(--text-secondary);
  font-size: 1rem;
}

.items-list {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.list-item {
  display: flex;
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 0.75rem;
  padding: 1.2rem;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.list-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
  border-color: var(--primary-light);
}

.item-content {
  flex: 1;
}

.item-title {
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-top: 0;
  margin-bottom: 0.6rem;
}

.item-preview {
  font-size: 0.95rem;
  color: var(--text-secondary);
  margin-bottom: 1rem;
  line-height: 1.5;
}

.item-meta {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
  color: var(--text-light);
}

.item-date {
  color: var(--text-light);
}

.item-tags {
  display: flex;
  gap: 0.5rem;
}

.item-tag {
  background-color: var(--background-secondary);
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
  font-size: 0.75rem;
}

.item-info {
  display: flex;
  gap: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.3rem;
}

.info-icon {
  font-style: normal;
}

.item-actions {
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
  margin-left: 1rem;
}

.action-button {
  background-color: var(--background-secondary);
  border: none;
  color: var(--text-primary);
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 0.9rem;
  font-weight: 500;
}

.edit-button:hover, .view-button:hover {
  background-color: var(--primary-color);
  color: white;
}

.delete-button:hover {
  background-color: #e53935;
  color: white;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.6;
}

.empty-title {
  font-size: 1.4rem;
  color: var(--text-primary);
  margin-bottom: 0.6rem;
}

.empty-desc {
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.create-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  padding: 0.8rem 1.5rem;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.create-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(30, 144, 255, 0.3);
}
</style>
