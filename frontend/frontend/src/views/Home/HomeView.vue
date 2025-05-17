<template>
  <div class="home-page">
    <!-- 主内容区域 -->
    <div class="main-layout">
      <!-- 左侧边栏 -->
      <div class="sidebar">
        <!-- 标题区域 -->
        <div class="platform-info">
          <h1 class="platform-title">ChainWis DAO</h1>
          <p class="platform-subtitle">一个高质量的去中心化知识平台</p>
        </div>
        
        <!-- 左侧导航菜单 -->
        <div class="sidebar-nav">
          <button
            class="sidebar-item"
            :class="{ active: activeTab === 'featured' }"
            @click="setActiveTab('featured')"
          >
            <span class="item-icon">📚</span>
            <span class="item-name">精选博客</span>
          </button>
          <button
            class="sidebar-item"
            :class="{ active: activeTab === 'knowledge' }"
            @click="setActiveTab('knowledge')"
          >
            <span class="item-icon">🧠</span>
            <span class="item-name">知识图谱</span>
          </button>
        </div>
      </div>

      <!-- 右侧内容区域 -->
      <div class="content-area">
        <!-- 搜索栏 -->
        <div class="search-container">
          <div class="search-bar">
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
              class="search-icon"
            >
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input
              type="text"
              class="search-input"
              placeholder="开始搜索..."
              v-model="searchQuery"
              @keyup.enter="handleSearch"
            />
          </div>
        </div>
        
        <!-- 精选博客内容 -->
        <div v-if="activeTab === 'featured'" class="content-section">
          <div class="section-header">
            <h2 class="section-title">精选博客</h2>
            <p class="section-subtitle">发现高质量内容</p>
          </div>
          <!-- 文章列表组件 -->
          <PostsList :posts="posts" />
        </div>

        <!-- 知识图谱内容 -->
        <div v-if="activeTab === 'knowledge'" class="content-section">
          <div class="section-header">
            <h2 class="section-title">知识图谱</h2>
            <p class="section-subtitle">探索区块链知识</p>
          </div>

          <!-- 知识图谱布局 - 当未选择具体项目时显示 -->
          <div v-if="!selectedItem.name" class="graph-items">
            <div
              v-for="(item, index) in knowledgeItems"
              :key="index"
              class="graph-item"
              :style="{ borderColor: item.color, boxShadow: `0 4px 12px ${item.color}30` }"
              @click="showKnowledgeDetail(item)"
            >
              <div class="item-icon-container" :style="{ backgroundColor: `${item.color}20` }">
                <span class="item-icon">{{ item.icon }}</span>
              </div>
              <div class="item-content">
                <div class="item-name">{{ item.name }}</div>
                <div class="item-description">{{ item.description }}</div>
              </div>
            </div>
          </div>

          <!-- 知识详情 - 当选择了具体项目时显示 -->
          <div v-else class="knowledge-detail">
            <div class="detail-header" :style="{ borderColor: selectedItem.color }">
              <button class="back-button" @click="closeKnowledgeDetail">
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
              <div class="detail-title-container">
                <span class="detail-icon">{{ selectedItem.icon }}</span>
                <h3 class="detail-title" :style="{ color: selectedItem.color }">{{ selectedItem.name }}</h3>
              </div>
            </div>
            <div class="detail-content">
              <p class="detail-text">{{ selectedItem.description }}</p>
              
              <!-- 这里可以根据选中的项目展示不同的内容 -->
              <div class="detail-section" :style="{ borderLeft: `4px solid ${selectedItem.color}` }">
                <h4 class="detail-subtitle" :style="{ color: selectedItem.color }">主要概念</h4>
                <p>{{ selectedItem.name }}是区块链领域的重要技术，以下是关键知识点：</p>
                <ul class="detail-list">
                  <li 
                    v-for="(concept, index) in getMainConcepts(selectedItem.name)" 
                    :key="index"
                    :style="{ '--i': index }"
                  >
                    {{ concept }}
                  </li>
                </ul>
              </div>
              
              <div class="detail-section" :style="{ borderLeft: `4px solid ${selectedItem.color}` }">
                <h4 class="detail-subtitle" :style="{ color: selectedItem.color }">相关技术</h4>
                <div class="related-items">
                  <div 
                    v-for="(relatedItem, index) in getRelatedItems(selectedItem.name)" 
                    :key="index"
                    class="related-item"
                    @click="showKnowledgeDetail(findKnowledgeItem(relatedItem.name))"
                  >
                    <span class="related-item-icon">{{ relatedItem.icon }}</span>
                    {{ relatedItem.name }}
                  </div>
                </div>
              </div>

              <div class="detail-section" :style="{ borderLeft: `4px solid ${selectedItem.color}` }">
                <h4 class="detail-subtitle" :style="{ color: selectedItem.color }">技术应用案例</h4>
                <div class="application-cases">
                  <div 
                    v-for="(caseItem, index) in getApplicationCases(selectedItem.name)" 
                    :key="index"
                    class="case-item"
                    :style="{ '--i': index }"
                  >
                    <h5 class="case-title">{{ caseItem.title }}</h5>
                    <p class="case-description">{{ caseItem.description }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Coze 聊天组件容器 -->
    <div id="coze-chat-container"></div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import PostsList from "../../components/HomeComponents/PostsListComponent.vue";
import useContentManager from "../../composables/useContentManager";
import useAuthorManager from "../../composables/useAuthorManager";

const router = useRouter();
const activeTab = ref("featured");
const searchQuery = ref("");
const showModal = ref(false);
const selectedItem = reactive({
  name: "",
  icon: "",
  description: "",
  color: "",
});

// 博客文章数据
const posts = ref([]);

// 知识图谱数据
const knowledgeItems = ref([
  { 
    name: "比特币", 
    icon: "🪙", 
    description: "第一个去中心化加密货币，由中本聪于2009年创建",
    color: "#f7931a"
  },
  { 
    name: "以太坊", 
    icon: "💎", 
    description: "支持智能合约的区块链平台，由Vitalik Buterin创建",
    color: "#627eea"
  },
  { 
    name: "Sui 区块链", 
    icon: "🌊", 
    description: "高性能第一层区块链，专注于资产所有权和可组合性",
    color: "#6fbcf0"
  },
  { 
    name: "Aptos 网络", 
    icon: "⭐", 
    description: "专注于安全性和可扩展性的Layer 1区块链解决方案",
    color: "#277da1"
  },
  { 
    name: "智能合约", 
    icon: "📝", 
    description: "在区块链上自动执行的程序，无需第三方介入",
    color: "#ff9e00"
  },
  { 
    name: "DeFi", 
    icon: "💰", 
    description: "去中心化金融，基于区块链的金融应用生态系统",
    color: "#2bb673"
  },
  { 
    name: "NFT", 
    icon: "🖼️", 
    description: "非同质化代币，代表独特的数字资产所有权",
    color: "#e84393"
  },
  { 
    name: "DAO", 
    icon: "👥", 
    description: "去中心化自治组织，由智能合约管理的社区治理模式",
    color: "#6c5ce7"
  }
]);

// 设置 Tab 切换
const setActiveTab = (tab) => {
  activeTab.value = tab;
  // 当切换到其他标签时，清除选中的知识项
  if (tab !== 'knowledge') {
    selectedItem.name = "";
    selectedItem.icon = "";
    selectedItem.description = "";
    selectedItem.color = "";
  }
};

// 处理搜索
const handleSearch = () => {
  if (searchQuery.value.trim()) {
    router.push({ name: "search", query: { q: searchQuery.value } });
  }
};

// 显示知识详情
const showKnowledgeDetail = (item) => {
  selectedItem.name = item.name;
  selectedItem.icon = item.icon;
  selectedItem.description = item.description;
  selectedItem.color = item.color;
};

// 关闭知识详情，返回列表
const closeKnowledgeDetail = () => {
  selectedItem.name = "";
  selectedItem.icon = "";
  selectedItem.description = "";
  selectedItem.color = "";
};

// 根据名称查找知识项
const findKnowledgeItem = (name) => {
  return knowledgeItems.value.find(item => item.name === name) || {
    name: name,
    icon: "🔍",
    description: `关于${name}的详细信息`,
    color: "#6c5ce7"
  };
};

// 获取相关项目
const getRelatedItems = (itemName) => {
  // 根据当前选中的项目返回相关的其他项目
  const relatedMap = {
    '比特币': [
      { name: '以太坊', icon: '💎' },
      { name: '区块链基础', icon: '🔗' },
      { name: '挖矿', icon: '⛏️' },
      { name: '加密货币', icon: '💱' }
    ],
    '以太坊': [
      { name: '比特币', icon: '🪙' },
      { name: '智能合约', icon: '📝' },
      { name: 'ERC标准', icon: '📋' },
      { name: 'DeFi', icon: '💰' }
    ],
    'Sui 区块链': [
      { name: 'Move语言', icon: '🔄' },
      { name: 'Web3应用', icon: '🌐' },
      { name: '对象模型', icon: '📦' }
    ],
    'Aptos 网络': [
      { name: 'Move语言', icon: '🔄' },
      { name: 'Layer 1解决方案', icon: '🏗️' },
      { name: '并行执行', icon: '⚡' }
    ],
    '智能合约': [
      { name: '以太坊', icon: '💎' },
      { name: 'Solidity', icon: '📊' },
      { name: 'DApp开发', icon: '👨‍💻' }
    ],
    'DeFi': [
      { name: '去中心化交易所', icon: '🔄' },
      { name: '借贷协议', icon: '🏦' },
      { name: '流动性挖矿', icon: '💧' }
    ],
    'NFT': [
      { name: '数字艺术', icon: '🎨' },
      { name: '元宇宙', icon: '🌌' },
      { name: '游戏资产', icon: '🎮' }
    ],
    'DAO': [
      { name: '社区治理', icon: '🗳️' },
      { name: '代币经济', icon: '💹' },
      { name: '去中心化决策', icon: '🤝' }
    ]
  };
  
  return relatedMap[itemName] || [];
};

// 获取主要概念
const getMainConcepts = (itemName) => {
  const conceptsMap = {
    '比特币': [
      '区块链技术：分布式账本，通过密码学确保交易安全',
      '工作量证明（PoW）：挖矿机制，确保网络安全',
      '去中心化：无需中央机构管理的点对点网络',
      '有限供应：总量固定在2100万枚，通缩特性',
      '比特币钱包与私钥：资产存储与安全管理'
    ],
    '以太坊': [
      '智能合约：自动执行的代码，实现无需信任的交易',
      '以太坊虚拟机（EVM）：执行智能合约的运行环境',
      'Gas费用：执行交易和合约的计算成本',
      '权益证明（PoS）：节能环保的共识机制',
      'DApp生态系统：去中心化应用程序平台'
    ],
    'Sui 区块链': [
      '对象中心模型：资产作为对象直接管理',
      '平行交易处理：高吞吐量架构',
      'Move语言：安全的智能合约编程语言',
      '所有权模型：明确的数字资产所有权',
      '低延迟终局性：快速交易确认'
    ],
    'Aptos 网络': [
      'Move VM：安全的智能合约执行环境',
      'BFT共识机制：高效的区块确认',
      '并行执行引擎：提高交易处理速度',
      '模块化设计：灵活的系统架构',
      '账户抽象：改进的用户体验'
    ],
    '智能合约': [
      '自动执行：预设条件满足时自动触发',
      '不可篡改：部署后代码无法更改',
      '透明性：公开可验证的执行逻辑',
      '编程语言：Solidity、Move、Rust等',
      '应用场景：金融、供应链、游戏等领域'
    ],
    'DeFi': [
      '去中心化交易所（DEX）：无需中介的资产交换',
      '借贷协议：点对点的资金借贷市场',
      '流动性挖矿：为提供流动性获得奖励',
      '稳定币：价值稳定的加密货币',
      '收益聚合器：优化投资回报的策略'
    ],
    'NFT': [
      '独特性：每个代币都是唯一的',
      '不可分割：无法部分交易',
      '所有权证明：数字资产的确权',
      '元数据：与代币关联的额外信息',
      '版税机制：创作者持续获得二次销售收益'
    ],
    'DAO': [
      '去中心化治理：社区投票决策',
      '代币经济：通过代币分配治理权',
      '提案系统：成员提交改进建议',
      '自动执行：通过智能合约实现决策',
      '透明运营：公开透明的财务与决策'
    ]
  };
  
  return conceptsMap[itemName] || [
    '起源与发展历史',
    '技术原理与架构',
    '应用场景与案例',
    '未来发展趋势',
    '关键挑战与机遇'
  ];
};

// 获取应用案例
const getApplicationCases = (itemName) => {
  const casesMap = {
    '比特币': [
      {
        title: '跨境支付',
        description: '比特币作为全球性支付网络，实现了低成本、快速的国际转账，绕过传统银行系统的限制和高额手续费。'
      },
      {
        title: '资产保值',
        description: '在通货膨胀严重的国家，比特币被用作对冲通胀的工具，保护资产价值不被本国货币贬值侵蚀。'
      },
      {
        title: '金融普惠',
        description: '为无银行账户的人群提供金融服务，使全球约17亿无银行账户的人能够参与到金融体系中。'
      }
    ],
    '以太坊': [
      {
        title: 'Uniswap去中心化交易所',
        description: '基于以太坊的自动做市商协议，允许用户无需中介直接交换加密货币，每日交易量超过10亿美元。'
      },
      {
        title: 'Aave借贷平台',
        description: '去中心化借贷协议，用户可存入资产赚取利息或借入资产，总锁仓价值超过50亿美元。'
      },
      {
        title: 'ENS域名服务',
        description: '以太坊域名服务，将复杂的钱包地址映射为易读的域名，如"alice.eth"，简化用户体验。'
      }
    ],
    'Sui 区块链': [
      {
        title: 'Sui Move生态系统',
        description: '支持高性能NFT市场和游戏应用，交易处理速度可达到每秒数万笔。'
      },
      {
        title: 'Sui钱包与DApp集成',
        description: '提供无缝的用户体验，实现一键登录和资产管理，降低Web3应用的使用门槛。'
      },
      {
        title: '链上游戏',
        description: '利用Sui的高吞吐量和低延迟特性，开发实时链上游戏，如链上棋牌游戏和策略游戏。'
      }
    ],
    'Aptos 网络': [
      {
        title: 'Aptos NFT生态',
        description: '基于Aptos的NFT市场，提供高性能、低成本的NFT铸造和交易服务。'
      },
      {
        title: '去中心化社交网络',
        description: '利用Aptos的高吞吐量特性，构建去中心化社交媒体平台，保护用户数据隐私。'
      },
      {
        title: '跨链资产桥',
        description: '连接Aptos与其他区块链的桥接服务，实现不同链之间的资产无缝转移。'
      }
    ],
    '智能合约': [
      {
        title: '保险自动理赔',
        description: '基于智能合约的参数保险，如航班延误保险，一旦条件满足（航班延误确认），自动执行赔付。'
      },
      {
        title: '供应链追踪',
        description: '使用智能合约记录和验证供应链各环节，确保产品真实性和可追溯性，如IBM Food Trust平台。'
      },
      {
        title: '版权管理',
        description: '音乐人通过智能合约直接向粉丝销售作品，自动分配版税，如Audius音乐平台。'
      }
    ],
    'DeFi': [
      {
        title: 'MakerDAO',
        description: '去中心化稳定币DAI的发行平台，用户可抵押加密资产生成稳定币，市值超过50亿美元。'
      },
      {
        title: 'Compound',
        description: '算法利率协议，根据市场供需自动调整借贷利率，重新定义了金融市场的运作方式。'
      },
      {
        title: 'Yearn Finance',
        description: '收益聚合器，自动将用户资金分配到最优收益策略，简化DeFi投资流程。'
      }
    ],
    'NFT': [
      {
        title: 'Bored Ape Yacht Club',
        description: '知名NFT系列，不仅是数字艺术品，还授予持有者独特的社区会员权益和商业使用权。'
      },
      {
        title: 'Axie Infinity',
        description: 'NFT游戏，玩家拥有游戏内资产的真正所有权，创造了"边玩边赚"的新型游戏经济模式。'
      },
      {
        title: '数字房地产',
        description: '如Decentraland平台中的虚拟土地，用户可购买、开发和出租虚拟空间，建立元宇宙资产。'
      }
    ],
    'DAO': [
      {
        title: 'MakerDAO',
        description: '管理DAI稳定币系统的去中心化组织，持有MKR代币的成员可对关键参数进行投票决策。'
      },
      {
        title: 'Uniswap治理',
        description: 'UNI代币持有者可提出和投票决定协议升级、费用分配等重要决策，实现社区自治。'
      },
      {
        title: 'Gitcoin',
        description: '通过二次方资助机制支持开源项目，社区成员共同决定资金分配，促进公共产品的发展。'
      }
    ]
  };
  
  return casesMap[itemName] || [
    {
      title: '应用案例示例',
      description: '这里将展示相关的实际应用案例和使用场景。'
    }
  ];
};

onMounted(async () => {
  // 获取文章数据
  const content = useContentManager();
  const author = useAuthorManager();
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
    posts.value = [];
    for (let i = 0; i < postIDs.length; i++) {
      const articleDetail = await content.getArticleDetails(postIDs[i]);
      const authorAddress = articleDetail.author;
      const authorInfo = await author.getAuthorInformationByAddress(
        authorAddress
      );
      const authorName = authorInfo.authorName || "未知作者";
      posts.value.push({
        title: articleDetail.title || "话题",
        author: authorName,
        time: "2025-4-12 10:56",
        content: articleDetail.content,
        postID: articleDetail.id,
      });
    }
  } catch (error) {
    console.error("获取文章信息失败:", error);
  }

  // Coze 聊天组件集成
  const script = document.createElement("script");
  script.src =
    "https://lf-cdn.coze.cn/obj/unpkg/flow-platform/chat-app-sdk/1.2.0-beta.6/libs/cn/index.js";
  script.onload = () => {
    new window.CozeWebSDK.WebChatClient({
      config: { bot_id: "7493140079997632547" },
      componentProps: { title: "知识助手" },
      auth: {
        type: "token",
        token:
          "pat_plkUl7cURBsOMzutTbURAzT4QZlwtsxqXOltw4NeHNnmzh1BoBNFbAUft2GPiQYP",
        onRefreshToken: function () {
          return "pat_plkUl7cURBsOMzutTbURAzT4QZlwtsxqXOltw4NeHNnmzh1BoBNFbAUft2GPiQYP";
        },
      },
      container: "#coze-chat-container",
    });
  };
  document.body.appendChild(script);
});
</script>

<style scoped>
/* 页面布局 */
.home-page {
  min-height: 100vh;
  background-color: var(--background-color);
  color: var(--text-primary);
  display: flex;
  flex-direction: column;
  padding-top: 5rem; /* 为顶部导航栏留出空间 */
  padding-bottom: 2rem;
}

.main-layout {
  display: flex;
  flex: 1;
  padding: 1.5rem 2rem;
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
  border-radius: 0.75rem 0 0 0.75rem;
  box-shadow: -3px 0 15px rgba(0, 0, 0, 0.03);
  margin-right: 2px;
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

/* 搜索栏 */
.search-container {
  width: 100%;
  max-width: 800px;
  margin: 0 auto 2rem;
}

.search-bar {
  display: flex;
  align-items: center;
  width: 100%;
  background-color: var(--background-secondary);
  border: 2px solid var(--primary-light);
  border-radius: 2rem;
  padding: 1rem 1.5rem;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.search-bar:focus-within {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 4px rgba(30, 144, 255, 0.1), 0 6px 15px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.search-icon {
  color: var(--primary-color);
  margin-right: 1rem;
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 1.2rem;
  color: var(--text-primary);
  outline: none;
}

.search-input::placeholder {
  color: var(--text-light);
}

/* 侧边栏导航 */
.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-top: 0.5rem;
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
  transform: translateX(3px);
}

.sidebar-item.active {
  background-color: var(--primary-light);
  color: white;
  font-weight: 600;
  border-left: 3px solid var(--primary-color);
  box-shadow: 0 2px 8px rgba(30, 144, 255, 0.15);
}

/* 内容区域 */
.content-area {
  flex: 1;
  padding: 1.5rem;
  background-color: var(--background-color);
  border-radius: 0 0.75rem 0.75rem 0;
  box-shadow: 5px 0 15px rgba(0, 0, 0, 0.03);
  overflow-y: auto;
}

/* 内容区域样式 */
.content-section {
  width: 100%;
  margin-bottom: 2rem;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--primary-light);
}

.section-title {
  font-size: 2rem;
  font-weight: bold;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
}

.section-subtitle {
  color: var(--text-secondary);
  font-size: 1.1rem;
}

/* 知识图谱样式 */
.graph-items {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
  padding: 0.5rem;
}

.graph-item {
  display: flex;
  align-items: flex-start;
  padding: 1.5rem;
  border-radius: 1rem;
  border: 2px solid var(--border-color);
  background-color: var(--background-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  position: relative;
  overflow: hidden;
}

.graph-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 100%);
  z-index: 1;
  pointer-events: none;
}

.graph-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.graph-item:hover .item-icon {
  transform: scale(1.2);
  transition: transform 0.3s ease;
}

.item-icon-container {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 50%;
  margin-right: 1rem;
  background-color: rgba(30, 144, 255, 0.1);
}

.item-icon {
  font-size: 1.8rem;
}

.item-content {
  flex: 1;
}

.item-name {
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.item-description {
  font-size: 0.95rem;
  color: var(--text-secondary);
  line-height: 1.5;
}

/* 知识详情样式 */
.knowledge-detail {
  padding: 1.5rem;
  background-color: var(--background-color);
  border-radius: 1rem;
  animation: fadeIn 0.3s ease;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.detail-header {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
  padding-bottom: 1.2rem;
  border-bottom: 2px solid var(--border-color);
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

.detail-title-container {
  display: flex;
  align-items: center;
  margin: 0 auto;
}

.detail-icon {
  font-size: 2.2rem;
  margin-right: 1rem;
}

.detail-title {
  font-size: 2rem;
  font-weight: bold;
  margin: 0;
}

.detail-content {
  padding: 0.5rem;
}

.detail-text {
  font-size: 1.2rem;
  line-height: 1.7;
  color: var(--text-secondary);
  margin-bottom: 2.5rem;
  padding: 0 1rem;
}

.detail-section {
  margin-bottom: 2.5rem;
  padding: 1.8rem;
  background-color: var(--background-secondary);
  border-radius: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  border-left: 4px solid var(--primary-color);
  position: relative;
  overflow: hidden;
}

.detail-section::before {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 100px;
  height: 100px;
  background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 70%);
  z-index: 0;
  pointer-events: none;
}

.detail-subtitle {
  font-size: 1.4rem;
  color: var(--primary-color);
  margin-top: 0;
  margin-bottom: 1rem;
  font-weight: 600;
}

.detail-list {
  margin: 1.2rem 0;
  padding-left: 0;
  list-style-type: none;
}

.detail-list li {
  margin-bottom: 1rem;
  color: var(--text-primary);
  font-size: 1.05rem;
  position: relative;
  padding-left: 2rem;
  padding-bottom: 0.8rem;
  border-bottom: 1px dashed rgba(0,0,0,0.1);
  transition: all 0.3s ease;
}

.detail-list li:last-child {
  border-bottom: none;
}

.detail-list li:before {
  content: '';
  position: absolute;
  left: 0;
  top: 0.5rem;
  width: 0.8rem;
  height: 0.8rem;
  background-color: var(--primary-light);
  border-radius: 50%;
  box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.2);
}

.detail-list li:hover {
  transform: translateX(5px);
  background-color: rgba(255,255,255,0.1);
  border-radius: 4px;
}

/* 添加动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.detail-list li {
  animation: fadeInUp 0.3s ease forwards;
  animation-delay: calc(0.1s * var(--i, 0));
  opacity: 0;
}

.related-items {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 1.2rem;
}

.related-item {
  display: flex;
  align-items: center;
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 2rem;
  padding: 0.7rem 1.5rem;
  font-size: 1rem;
  color: var(--primary-color);
  cursor: pointer;
  transition: all 0.3s ease;
}

.related-item-icon {
  margin-right: 0.5rem;
  font-size: 1.2rem;
}

.related-item:hover {
  background-color: var(--primary-light);
  color: white;
  border-color: var(--primary-color);
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(30, 144, 255, 0.2);
}

/* 响应式样式 */
@media (max-width: 768px) {
  .main-layout {
    flex-direction: column;
    padding: 1rem;
  }
  
  .sidebar {
    width: 100%;
    min-width: 100%;
    margin-right: 0;
    margin-bottom: 1rem;
    border-radius: 0.75rem 0.75rem 0 0;
    border-right: none;
    border-bottom: 1px solid var(--border-color);
    padding: 1rem;
  }
  
  .content-area {
    border-radius: 0 0 0.75rem 0.75rem;
    padding: 1rem;
  }
  
  .search-bar {
    padding: 0.8rem 1.2rem;
  }
  
  .search-input {
    font-size: 1rem;
  }
  
  .platform-title {
    font-size: 1.5rem;
  }
  
  .sidebar-item {
    padding: 0.6rem 0.8rem;
  }
  
  .section-title {
    font-size: 1.6rem;
  }
  
  .detail-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .back-button {
    align-self: flex-start;
  }
  
  .detail-title {
    align-self: center;
  }
}

@media (prefers-reduced-motion: no-preference) {
  .graph-item {
    transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
  }
  
  .related-item {
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }
}

.application-cases {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-top: 1.5rem;
}

.case-item {
  background-color: var(--background-color);
  border-radius: 0.8rem;
  padding: 1.5rem;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid var(--border-color);
  animation: fadeInUp 0.4s ease forwards;
  animation-delay: calc(0.15s * var(--i, 0));
  opacity: 0;
}

.case-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: var(--primary-light);
}

.case-title {
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--primary-color);
  margin-top: 0;
  margin-bottom: 1rem;
}

.case-description {
  color: var(--text-secondary);
  font-size: 0.95rem;
  line-height: 1.6;
  margin: 0;
}
</style>
