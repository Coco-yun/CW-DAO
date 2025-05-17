<template>
  <div class="reviewer-dashboard">
    <!-- 导航栏组件 -->
    <NavigationBar />

    <!-- 主仪表盘视图 -->
    <div v-if="activeView === 'dashboard'" class="main-content">
      <!-- 欢迎信息 -->
      <div class="welcome-section">
        <h1 class="welcome-text">欢迎回来，审核员！</h1>
      </div>

      <!-- 质押代币部分 -->
      <div class="action-section">
        <button class="stake-button" @click="showStakeModal = true">
          质押代币
        </button>
      </div>

      <!-- 审核帖子部分 -->
      <div class="review-section">
        <h2 class="review-heading">
          有 <span class="post-count">{{ pendingPostsCount }}</span> 篇帖子等待您审核!
        </h2>
        <button class="review-button" @click="activeView = 'reviewPosts'">
          审核帖子
        </button>
      </div>

      <!-- 投票部分 -->
      <div class="voting-section">
        <h2 class="voting-heading">
          审核员选举正在进行中！您已获得投票权 — 不要错过投票机会！
        </h2>
        <button class="voting-button" @click="activeView = 'voting'">
          参与投票
        </button>
      </div>
    </div>

    <!-- 审核帖子视图 -->
    <div v-if="activeView === 'reviewPosts'" class="content-container">
      <!-- 返回按钮 -->
      <button class="back-button" @click="activeView = 'dashboard'">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="40"
          height="40"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="m15 18-6-6 6-6" />
        </svg>
      </button>

      <div class="posts-container">
        <div class="posts-list">
          <PostItem
            v-for="(post, index) in noreleaseContens"
            :key="index"
            :title="post.title"
            :content="post.content"
            :time="post.time"
            @delete="reviewPost(post, index)"
          />
        </div>
      </div>
    </div>

    <!-- 帖子详情审核视图 -->
    <div
      v-if="activeView === 'postDetail'"
      class="content-container post-review-view"
    >
      <!-- 返回按钮 -->
      <button class="back-button" @click="activeView = 'reviewPosts'">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="40"
          height="40"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="m15 18-6-6 6-6" />
        </svg>
      </button>

      <div class="post-detail-wrapper">
        <div class="post-detail-container">
          <div class="post-detail-content">
            <div class="post-content-inner">
              <div
                v-if="currentPost.content"
                v-html="formatPostContent(currentPost.content)"
              ></div>
              <div v-else class="sample-content">
                <p class="post-heading">
                  ### **比特币产品适应机构需求**
                </p>
                <p>
                  Rochard解释说，公司的目标客户包括**寻求波动保护的信贷分配者**和**追求比特币不对称上行空间的股权风险承担者**。如果市场条件允许，其长期愿景包括在未来21年内确保1万亿美元的BTC。
                </p>

                <p>
                  当被问及发布的时机和动机时，Rochard透露，比特币支持的证券化公司的概念自他早期从事比特币以来就引起了他的兴趣，与他的资产支持融资背景相符。
                </p>

                <p>
                  他指出，唐纳德·特朗普最近的总统选举胜利促成了计划的实施，表明了监管转变：
                </p>
                <p>
                  > "展望未来，SEC将中立运作，不受政治影响，确保对比特币金融产品进行平衡监督，以保障美国资本市场。这种明确性给予了成熟机构信心，能够与比特币进行建设性互动。"
                </p>

                <p>
                  Rochard强调，他的愿景是通过将比特币包装成**结构化金融工具**来扩展比特币的实用性，这些工具满足机构对透明度、监管和风险管理的标准。这种方法与机构加密原生产品的更广泛趋势一致，包括交易所交易产品（ETP）和资产支持票据。
                </p>

                <p>
                  根据公司的公告，其使命是"在信贷分配者和风险承担者之间建立持久的伙伴关系，通过比特币支持的结构化融资为资本市场创造价值，为全球战略储备资产提供透明、受监管和高效的风险转移。"
                </p>

                <p>---</p>

                <p class="post-heading">
                  ### **比特币ETF成功的验证**
                </p>
                <p>
                  Rochard强调比特币ETF的爆炸性成功证明了市场需求，称其为"金融行业历史上最成功的产品发布"。他认为，虽然机构投资者受波动性限制，但风险寻求者渴望杠杆——他的公司旨在弥合这一差距：
                </p>
                <p>
                  > "比特币债券公司的存在是为了通过比特币支持的产品负责任地连接这两个群体，为双方创造长期价值。"
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="post-actions">
          <div class="button-group">
            <button class="pass-button" @click="passFunction">
              <span>通过</span>
            </button>
            <button class="reject-button" @click="rejectFunction">
              <span>拒绝</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 投票视图 -->
    <div v-if="activeView === 'voting'" class="content-container">
      <!-- 返回按钮 -->
      <button class="back-button" @click="activeView = 'dashboard'">
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
          <path d="m15 18-6-6 6-6" />
        </svg>
      </button>

      <div class="voting-container">
        <div class="voting-header">
          <div class="participant-header">参与者</div>
          <div class="staked-header">质押代币数量</div>
          <div class="info-header">信息</div>
          <div class="option-header">选项</div>
        </div>

        <div class="voting-list">
          <div v-for="(voter, index) in voters" :key="index" class="voter-item">
            <div class="voter-info">
              <div class="voter-id">{{ voter.id }}</div>
            </div>

            <div class="voter-tokens">{{ voter.tokens }} 代币</div>

            <div class="voter-info-link">
              <button class="homepage-button" @click="visitHomepage(voter.id)">
                主页
              </button>
            </div>

            <div class="voter-options">
              <button
                class="approve-button"
                :class="{ active: voter.isApproved === true }"
                @click="approveVoter(index)"
              >
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
                  <path d="M20 6L9 17l-5-5" />
                </svg>
              </button>

              <button
                class="reject-button"
                :class="{ active: voter.isApproved === false }"
                @click="rejectVoter(index)"
              >
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
                  <circle cx="12" cy="12" r="10" />
                  <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 质押模态框 -->
    <div
      class="modal-overlay"
      v-if="showStakeModal"
      @click.self="showStakeModal = false"
    >
      <div class="modal">
        <div class="modal-header">
          <h2>质押代币</h2>
          <button class="close-modal-button" @click="showStakeModal = false">
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
        </div>

        <div class="modal-content">
          <div class="form-group">
            <label for="stakeAmount">质押数量:</label>
            <input
              type="number"
              id="stakeAmount"
              v-model="stakeAmount"
              class="form-input"
              min="100"
              placeholder="输入数量"
            />
            <p class="form-help">最低需要100代币</p>
          </div>

          <div class="token-balance">
            <p>
              您当前的余额: <span>{{ userTokens }}</span> 代币
            </p>
          </div>
        </div>

        <div class="modal-footer">
          <button class="cancel-button" @click="showStakeModal = false">
            取消
          </button>
          <button class="submit-button" @click="stakeTokens">质押</button>
        </div>
      </div>
    </div>

    <!-- 通过模态框 -->
    <div
      class="modal-overlay"
      v-if="showPassModal"
      @click.self="showPassModal = false"
    >
      <div class="modal">
        <div class="modal-header">
          <h2>通过帖子</h2>
          <button class="close-modal-button" @click="showPassModal = false">
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
        </div>

        <div class="modal-content">
          <div class="form-group">
            <label for="passAmount">用于批准的代币数量:</label>
            <input
              type="number"
              id="passAmount"
              v-model="passAmount"
              class="form-input"
              min="1"
              placeholder="输入代币数量"
            />
            <p class="form-help">
              输入用于批准的代币数量
            </p>
          </div>

          <div class="token-balance">
            <p>
              您当前的余额: <span>{{ userTokens }}</span> 代币
            </p>
          </div>
        </div>

        <div class="modal-footer">
          <button class="cancel-button" @click="showPassModal = false">
            取消
          </button>
          <button class="submit-button" @click="confirmPass(currentPostIndex)">
            确认
          </button>
        </div>
      </div>
    </div>

    <!-- 成功模态框 -->
    <div
      class="modal-overlay"
      v-if="showSuccessModal"
      @click.self="showSuccessModal = false"
    >
      <div class="modal success-modal">
        <h2>代币质押成功</h2>
        <p>您已成功质押 {{ stakeAmount }} 代币。</p>
        <div class="modal-footer centered">
          <button class="submit-button" @click="showSuccessModal = false">
            确定
          </button>
        </div>
      </div>
    </div>

    <!-- 通过成功模态框 -->
    <div
      class="modal-overlay"
      v-if="showPassSuccessModal"
      @click.self="showPassSuccessModal = false"
    >
      <div class="modal success-modal">
        <h2>帖子审核通过</h2>
        <p>您已使用 {{ passAmount }} 代币批准了该帖子。</p>
        <div class="modal-footer centered">
          <button class="submit-button" @click="showPassSuccessModal = false">
            确定
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import NavigationBar from "../../components/NavigationBar.vue";
import PostItem from "../../components/ModerationComponents/detailComponent.vue";
import useContentReviewDAO from "../../composables/useContentReviewDAO";
import useContentManager from "../../composables/useContentManager";
import useAuthorManager from "../../composables/useAuthorManager";

// 视图状态
const activeView = ref("dashboard"); // 'dashboard', 'reviewPosts', 'postDetail', 'voting'

// 模态框状态
const showStakeModal = ref(false);
const showSuccessModal = ref(false);
const showPassModal = ref(false);
const showPassSuccessModal = ref(false);

// 用户数据
const userTokens = ref(1000);
const stakeAmount = ref(100);
const passAmount = ref(10); // 通过帖子的默认代币数量
const pendingPostsCount = ref(3);

// 当前正在审核的帖子
const currentPost = ref({});
const currentPostIndex = ref(null);

const releaseContens = ref([]);
const noreleaseContens = ref([]);
const pendingApplications = ref([]);
const allPendingApplicationDetail = ref([]);

// 投票者数据
const voters = ref([]);

onMounted(async () => {
  const dao = useContentReviewDAO();
  const author = useAuthorManager();
  const content = useContentManager();

  if (!dao && !content && !author) {
    console.error("Web3 初始化失败");
    return;
  }

  try {
    const account = await author.getAccount();
    if (!account) {
      console.error("未连接钱包");
      return;
    }

    // 获取内容
    const releaseContenIDs = await content.getReleasedArticleIds();
    const noreleaseContenIDS = await content.getUnreleasedArticleIds();
    releaseContens.value = [];
    noreleaseContens.value = [];

    for (let i = 0; i < releaseContenIDs.length; i++) {
      const articleDetail = await content.getArticleDetails(
        releaseContenIDs[i]
      );
      releaseContens.value.push({
        title: "话题",
        time: "2025-4-12 10:56",
        content: articleDetail[1],
      });
    }

    for (let i = 0; i < noreleaseContenIDS.length; i++) {
      const articleDetail = await content.getArticleDetails(
        noreleaseContenIDS[i]
      );
      noreleaseContens.value.push({
        title: "话题",
        time: "2025-4-12 10:56",
        content: articleDetail[1],
        id: noreleaseContenIDS[i], // 确保添加 id 字段
      });
    }

    // 更新待审核帖子数量
    pendingPostsCount.value = noreleaseContens.value.length;

    // 获取 DAO 申请
    const pendingApplicationIDsRaw = await dao.getApplicationQueue();
    const pendingApplicationIDs = [...new Set(pendingApplicationIDsRaw)];
    console.log("唯一申请地址:", pendingApplicationIDs);
    voters.value = []; // 清空已有 voters

    for (let i = 0; i < pendingApplicationIDs.length; i++) {
      const pendingApplicationDetail = await dao.getApplicationDetails(
        pendingApplicationIDs[i]
      );
      const pendingApplicationID = await author.getAuthorIdByAddress(
        pendingApplicationIDs[i]
      );
      voters.value.push({
        address: pendingApplicationIDs[i],
        id: pendingApplicationID,
        tokens: 10, // 示例 token 数量
        isApproved: null,
      });
    }
  } catch (error) {
    console.error("获取作者信息失败:", error);
  }
});

// 格式化帖子内容，正确显示类似markdown的语法
const formatPostContent = (content) => {
  if (!content) return "";

  // 替换类似markdown的语法为HTML
  let formattedContent = content
    .replace(/###\s+\*\*(.*?)\*\*/g, '<p class="post-heading">$1</p>')
    .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
    .replace(/>\s+"(.*?)"/g, '<blockquote>"$1"</blockquote>')
    .replace(/\n\n/g, "</p><p>")
    .replace(/\n/g, "<br>");

  // 如果尚未包含段落标签，则添加
  if (!formattedContent.startsWith("<p>")) {
    formattedContent = "<p>" + formattedContent;
  }
  if (!formattedContent.endsWith("</p>")) {
    formattedContent = formattedContent + "</p>";
  }

  return formattedContent;
};

// 功能函数
const stakeTokens = () => {
  if (stakeAmount.value <= 0) {
    alert("请输入有效的数量");
    return;
  }

  if (stakeAmount.value > userTokens.value) {
    alert("您的代币不足");
    return;
  }

  userTokens.value -= stakeAmount.value;
  showStakeModal.value = false;
  showSuccessModal.value = true;
};

const reviewPost = (post, index) => {
  console.log("正在审核帖子:", post);
  currentPost.value = post;
  currentPostIndex.value = index;
  activeView.value = "postDetail";
};

// 修改为显示通过模态框而不是直接处理
const passFunction = async (index) => {
  showPassModal.value = true;
  console.log("准备通过帖子");
};

const confirmPass = async (index) => {
  try {
    // 检查数组中对应的文章是否存在
    const article = noreleaseContens.value[index];
    if (!article || !article.id) {
      throw new Error(`索引 ${index} 处的文章不存在或缺少ID`);
    }

    // 获取 DAO 实例和账户
    const DAO = useContentReviewDAO();
    const account = await DAO.getAccount();
    if (!account) {
      throw new Error("未连接钱包");
    }

    // 调用投票函数，传入文章 id 和代币数量
    await DAO.voteForArticleUpdate(article.id, passAmount.value);
    console.log(
      `通过索引 ${index} 处的帖子，使用 ${passAmount.value} 代币`
    );

    // 更新用户代币数量
    userTokens.value -= passAmount.value;

    // 关闭模态框
    showPassModal.value = false;

    // 显示成功消息，并从未发布内容中删除已审核的文章
    showPassSuccessModal.value = true;
    noreleaseContens.value.splice(index, 1);
    pendingPostsCount.value = noreleaseContens.value.length;

    // 显示成功消息后返回审核帖子列表
    setTimeout(() => {
      showPassSuccessModal.value = false;
      activeView.value = "reviewPosts";
    }, 2000);
  } catch (error) {
    console.error("通过帖子时出错:", error);
    showPassModal.value = false;
  }
};

const rejectFunction = async (index) => {
  try {
    console.log("拒绝索引处的帖子:", index);
    activeView.value = "reviewPosts";
    noreleaseContens.value.splice(index, 1);
    pendingPostsCount.value = noreleaseContens.value.length;
  } catch (error) {
    console.error("拒绝帖子时出错:", error);
  }
};

const approveVoter = (index) => {
  voters.value[index].isApproved = true;
  const dao = useContentReviewDAO();
  dao.voteForApplicant(voters.value[index].address, true, 10);
};

const rejectVoter = (index) => {
  voters.value[index].isApproved = false;
  const dao = useContentReviewDAO();
  dao.voteForApplicant(voters.value[index].address, false, 10);
};

const visitHomepage = (id) => {
  console.log("访问用户主页:", id);
  // 实现导航到用户主页的功能
};
</script>

<style scoped>
.reviewer-dashboard {
  min-height: 100vh;
  background-color: var(--background-color);
  color: var(--text-primary);
  display: flex;
  flex-direction: column;
}

.main-content {
  display: flex;
  flex-direction: column;
  padding: 2rem;
  gap: 2rem;
  max-width: 1000px;
  margin: 0 auto;
  width: 100%;
}

/* 欢迎部分 */
.welcome-section {
  text-align: center;
  margin-bottom: 1rem;
}

.welcome-text {
  font-size: 2rem;
  color: var(--primary-color);
  font-weight: bold;
  margin: 0;
}

/* 操作部分 */
.action-section {
  display: flex;
  justify-content: center;
  margin-bottom: 1rem;
}

.stake-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.8rem 2rem;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.stake-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.3);
}

/* 审核部分 */
.review-section {
  background-color: var(--background-secondary);
  border-radius: 10px;
  padding: 2rem;
  text-align: center;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.review-section:hover {
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.1);
  transform: translateY(-2px);
}

.review-heading {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin-bottom: 1.5rem;
}

.post-count {
  color: var(--primary-color);
  font-weight: bold;
}

.review-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.8rem 2rem;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.review-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.3);
}

/* 投票部分 */
.voting-section {
  background-color: var(--background-secondary);
  border-radius: 10px;
  padding: 2rem;
  text-align: center;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.voting-section:hover {
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.1);
  transform: translateY(-2px);
}

.voting-heading {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin-bottom: 1.5rem;
}

.voting-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.8rem 2rem;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.voting-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.3);
}

/* 内容容器 */
.content-container {
  max-width: 1000px;
  margin: 2rem auto;
  padding: 2rem;
  position: relative;
  background-color: var(--background-color);
  border-radius: 10px;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  width: 90%;
}

.back-button {
  position: absolute;
  top: 1rem;
  left: 1rem;
  background: none;
  border: none;
  color: var(--primary-color);
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  transition: all 0.2s ease;
}

.back-button:hover {
  background-color: rgba(30, 144, 255, 0.1);
  transform: translateX(-2px);
}

/* 帖子容器 */
.posts-container {
  margin-top: 2rem;
}

.posts-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

/* 帖子详情样式 */
.post-detail-wrapper {
  margin-top: 2rem;
}

.post-detail-container {
  background-color: white;
  border-radius: 8px;
  border: 1px solid var(--border-color);
  overflow: hidden;
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.post-detail-content {
  padding: 2rem;
}

.post-content-inner {
  line-height: 1.6;
  font-size: 1rem;
  color: var(--text-primary);
}

.post-heading {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--primary-color);
  margin-bottom: 1rem;
}

.post-actions {
  display: flex;
  justify-content: center;
  margin-top: 2rem;
}

.button-group {
  display: flex;
  gap: 2rem;
}

.pass-button,
.reject-button {
  width: 150px;
  height: 48px;
  border-radius: 8px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.pass-button {
  background-color: var(--success-color);
  color: white;
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.2);
}

.reject-button {
  background-color: var(--error-color);
  color: white;
  box-shadow: 0 4px 12px rgba(244, 67, 54, 0.2);
}

.pass-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(76, 175, 80, 0.3);
}

.reject-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(244, 67, 54, 0.3);
}

/* 投票容器 */
.voting-container {
  margin-top: 2rem;
}

.voting-header {
  display: flex;
  padding: 1rem 0;
  font-weight: bold;
  font-size: 1.1rem;
  border-bottom: 2px solid var(--primary-light);
  margin-bottom: 1rem;
}

.participant-header,
.staked-header,
.info-header,
.option-header {
  flex: 1;
  text-align: center;
}

.voting-list {
  max-height: 70vh;
  overflow-y: auto;
  padding-right: 1rem;
}

.voter-item {
  display: flex;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border-light);
}

.voter-info,
.voter-tokens,
.voter-info-link,
.voter-options {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.voter-id {
  font-weight: bold;
  color: var(--text-primary);
}

.voter-tokens {
  font-weight: bold;
  color: var(--primary-dark);
}

.homepage-button {
  background-color: var(--primary-light);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 0.3rem 1rem;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.homepage-button:hover {
  background-color: var(--primary-color);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.voter-options {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.approve-button,
.reject-button {
  min-width: 100px;
  height: 38px;
  padding: 0 1.5rem;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  font-weight: bold;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

/* 模态框样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 10px;
  padding: 2rem;
  width: 90%;
  max-width: 500px;
  position: relative;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  color: var(--text-primary);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.modal-header h2 {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--primary-color);
  margin: 0;
}

.close-modal-button {
  background: none;
  border: none;
  color: var(--primary-color);
  cursor: pointer;
  transition: transform 0.2s;
}

.close-modal-button:hover {
  transform: scale(1.1);
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: var(--text-primary);
}

.form-input {
  width: 100%;
  padding: 0.8rem;
  border: 1px solid var(--border-color);
  border-radius: 5px;
  background-color: var(--background-color);
  color: var(--text-primary);
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.1);
  outline: none;
}

.form-help {
  font-size: 0.9rem;
  color: var(--text-light);
  margin-top: 0.5rem;
}

.token-balance {
  padding: 1rem;
  background-color: var(--background-secondary);
  border-radius: 5px;
  margin-bottom: 1.5rem;
}

.token-balance p {
  margin: 0;
  color: var(--text-secondary);
}

.token-balance span {
  font-weight: bold;
  color: var(--primary-color);
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.modal-footer.centered {
  justify-content: center;
}

.cancel-button,
.submit-button {
  padding: 0.8rem 1.5rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cancel-button {
  background-color: transparent;
  color: var(--text-primary);
  border: 1px solid var(--border-color);
}

.submit-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
}

.cancel-button:hover {
  background-color: var(--border-light);
}

.submit-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.success-modal {
  text-align: center;
}

.success-modal h2 {
  color: var(--primary-color);
  margin-bottom: 1rem;
}

.success-modal p {
  margin-bottom: 2rem;
  color: var(--text-secondary);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }
  
  .review-section,
  .voting-section {
    padding: 1.5rem;
  }
  
  .content-container {
    padding: 1.5rem;
    margin: 1rem auto;
  }
  
  .button-group {
    flex-direction: column;
    gap: 1rem;
  }
  
  .pass-button,
  .reject-button {
    width: 100%;
  }
  
  .voter-item {
    flex-direction: column;
    gap: 1rem;
  }
  
  .voter-info,
  .voter-tokens,
  .voter-info-link,
  .voter-options {
    width: 100%;
  }
}
</style>
