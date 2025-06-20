<template>
  <section class="task-detail">
    <div class="container">
      <div class="task-detail-container">
        <!-- 任务状态时间线 -->
        <div class="task-timeline">
          <div class="timeline-step" :class="{active: task.status === 'bidding' || task.status === 'developing' || task.status === 'reviewing' || task.status === 'completed'}">
            <div class="timeline-icon">
              <i class="fas fa-gavel"></i>
            </div>
            <div class="timeline-label">竞标中</div>
          </div>
          
          <div class="timeline-step" :class="{active: task.status === 'developing' || task.status === 'reviewing' || task.status === 'completed'}">
            <div class="timeline-icon">
              <i class="fas fa-code"></i>
            </div>
            <div class="timeline-label">开发中</div>
          </div>
          
          <div class="timeline-step" :class="{active: task.status === 'reviewing' || task.status === 'completed'}">
            <div class="timeline-icon">
              <i class="fas fa-check-circle"></i>
            </div>
            <div class="timeline-label">评审中</div>
          </div>
          
          <div class="timeline-step" :class="{active: task.status === 'completed'}">
            <div class="timeline-icon">
              <i class="fas fa-flag-checkered"></i>
            </div>
            <div class="timeline-label">已完成</div>
          </div>
        </div>

        <div class="task-detail-header">
          <div class="detail-title">
            <span>{{ task.title }}</span>
            <!-- Web3任务特殊标签 -->
            <span v-if="task.isWeb3" class="web3-tag">
              <i class="fab fa-ethereum"></i> Web3任务
            </span>
            <span class="task-status-badge" :class="'status-' + task.status">{{ task.statusText || statusTextMap[task.status] }}</span>
          </div>
          <div class="detail-subtitle">
            {{ task.description }}
          </div>
          
          <!-- 竞标统计信息 -->
          <div class="bidding-stats">
            <div class="stats-item">
              <i class="fas fa-users"></i>
              <span>当前竞标人数: {{ task.currentBidders || 0 }}/{{ task.maxParticipants || '无限' }}</span>
            </div>
            <div class="stats-item">
              <i class="fas fa-coins"></i>
              <span>参与竞标需质押: 50 USDT</span>
            </div>
            <div class="stats-item">
              <i class="fas fa-percentage"></i>
              <span>平台手续费: 0.5%</span>
            </div>
          </div>
          
          <div class="detail-meta-grid">
            <div class="meta-item">
              <div class="meta-label">
                <i class="fas fa-coins"></i> 任务赏金
              </div>
              <div class="meta-value">{{ task.reward }} USDT</div>
            </div>
            
            <!-- 雇主信息 -->
            <div class="meta-item" v-if="task.employer">
              <div class="meta-label">
                <i class="fas fa-user-tie"></i> 雇主
              </div>
              <div class="meta-value">
                <div class="employer-info">
                  <div class="employer-avatar">
                    {{ employerInitials }}
                  </div>
                  <div class="employer-name">
                    {{ employerName }}
                    <div class="employer-rating">
                      <i class="fas fa-star"></i> 4.8 (32次合作)
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="meta-item" v-if="task.duration">
              <div class="meta-label">
                <i class="fas fa-hourglass-half"></i> 开发周期
              </div>
              <div class="meta-value">{{ task.duration }} 天</div>
            </div>
            
            <div class="meta-item">
              <div class="meta-label">
                <i class="fas fa-calendar"></i> 截止日期
              </div>
              <div class="meta-value">{{ task.deadline }}</div>
            </div>
            
            <!-- Web3任务专属信息 -->
            <div class="meta-item" v-if="task.isWeb3 && task.githubRepo">
              <div class="meta-label">
                <i class="fab fa-github"></i> GitHub仓库
              </div>
              <div class="meta-value">
                <a :href="task.githubRepo" class="github-link" target="_blank">{{ formatGithubUrl(task.githubRepo) }}</a>
              </div>
            </div>
            
            <div class="meta-item" v-if="task.isWeb3 && task.targetBranch">
              <div class="meta-label">
                <i class="fas fa-code-branch"></i> 目标分支
              </div>
              <div class="meta-value">{{ task.targetBranch }}</div>
            </div>
            
            <div class="meta-item">
              <div class="meta-label">
                <i class="fas fa-layer-group"></i> 任务类型
              </div>
              <div class="meta-value">{{ task.category || task.type }}</div>
            </div>
            
            <!-- 质押金额 -->
            <div class="meta-item">
              <div class="meta-label">
                <i class="fas fa-lock"></i> 质押金额
              </div>
              <div class="meta-value">50 USDT</div>
            </div>
          </div>
          
          <div class="task-skills" v-if="task.skills && task.skills.length">
            <span class="skill-tag" v-for="(skill, i) in task.skills" :key="i">{{ skill }}</span>
          </div>
          
          <!-- 竞标按钮区域 -->
          <div class="task-actions" v-if="task.status === 'bidding'">
            <!-- 钱包未连接提示 -->
            <template v-if="!isConnected">
              <div class="wallet-disconnected-container">
                <i class="fas fa-wallet"></i>
                <span class="wallet-disconnected-tip">请连接钱包参与竞标</span>
              </div>
            </template>
            
            <template v-else-if="isTaskOwner">
              <div class="employer-container">
                <i class="fas fa-user-tie"></i>
                <span class="employer-tip">您是该任务的雇主，不能参与竞标</span>
              </div>
            </template>
            
            <template v-else-if="biddingFull">
              <div class="bidding-full-container">
                <i class="fas fa-exclamation-circle"></i>
                <span class="bidding-full-tip">当前任务竞标人数已满</span>
              </div>
            </template>
            
            <template v-else-if="alreadyJoined">
              <div class="already-joined-container">
                <i class="fas fa-check-circle"></i>
                <span class="already-joined-tip">您已参与该任务</span>
                <button class="btn btn-outline" @click="viewBidDetails">
                  <i class="fas fa-eye"></i> 查看竞标详情
                </button>
              </div>
            </template>
            
            <template v-else>
              <div class="bid-instruction">
                <i class="fas fa-info-circle"></i>
                <p>参与竞标需质押<strong>50 USDT</strong>，任务完成后质押金将退还至您的账户</p>
              </div>
              <div class="bid-actions">
                <button class="btn btn-outline" @click="showStakeInfo = true">
                  <i class="fas fa-question-circle"></i> 了解质押规则
                </button>
                <button class="btn btn-primary" @click="handleBid" :disabled="biddingInProgress">
                  <i class="fas fa-hand-paper"></i> 
                  {{ biddingInProgress ? '处理中...' : '质押并参与竞标' }}
                </button>
              </div>
            </template>
          </div>
        </div>
        
        <div class="task-description-content">
          <h3>
            <i class="fas fa-file-alt"></i> 任务详情
          </h3>
          <div class="description-box">
            <p>{{ task.fullDescription || task.description }}</p>
          </div>
          
          <!-- 技术要求 -->
          <h3 v-if="task.technologies">
            <i class="fas fa-tools"></i> 技术要求
          </h3>
          <ul v-if="task.technologies" class="tech-list">
            <li v-for="(tech, i) in task.technologies" :key="i">{{ tech }}</li>
          </ul>
          
          <!-- 交付要求 -->
          <h3 v-if="task.deliverables">
            <i class="fas fa-clipboard-check"></i> 交付要求
          </h3>
          <ul v-if="task.deliverables" class="deliverables-list">
            <li v-for="(item, i) in task.deliverables" :key="i">{{ item }}</li>
          </ul>
          
          <!-- 里程碑展示 -->
          <div v-if="task.milestoneEnabled && task.milestones && task.milestones.length" class="milestones-section">
            <h3>
              <i class="fas fa-road"></i> 里程碑计划
            </h3>
            <div class="milestones-container">
              <div class="milestone-card" v-for="(milestone, index) in task.milestones" :key="index">
                <div class="milestone-header">
                  <div class="milestone-number">里程碑 #{{ index + 1 }}</div>
                  <div class="milestone-reward">{{ milestone.rewardPercent }}% 赏金</div>
                </div>
                <h4 class="milestone-title">{{ milestone.name }}</h4>
                <div class="milestone-content">
                  <p>{{ milestone.criteria }}</p>
                </div>
                <div class="milestone-status" v-if="task.status !== 'bidding'">
                  <i class="fas fa-circle" :class="{'status-pending': index > 0, 'status-completed': index === 0}"></i>
                  {{ index === 0 ? '已完成' : '待完成' }}
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Web3任务特殊提示 -->
        <div v-if="task.isWeb3" class="web3-notice">
          <i class="fab fa-ethereum"></i>
          <div class="web3-notice-content">
            <h4>Web3任务说明</h4>
            <p>此任务使用区块链技术管理，所有代码提交将通过GitHub仓库进行，赏金将通过智能合约支付。</p>
            <ul>
              <li><i class="fas fa-code-branch"></i> GitHub仓库: <a :href="task.githubRepo" target="_blank">{{ formatGithubUrl(task.githubRepo) }}</a></li>
              <!-- <li><i class="fas fa-lock"></i> 智能合约托管赏金</li> -->
              <!-- <li><i class="fas fa-shield-alt"></i> 代码提交需通过Pull Request审核</li> -->
            </ul>
          </div>
        </div>
        
        <!-- 在任务描述后添加文件查看区域 -->
        <div v-if="task.files && task.files.length" class="files-section">
          <h3><i class="fas fa-paperclip"></i> 相关文件</h3>
          <div class="files-container">
            <div v-for="(file, index) in task.files" :key="index" class="file-card">
              <div class="file-icon">
                <i :class="getFileIcon(file)"></i>
              </div>
              <div class="file-info">
                <div class="file-name">{{ file.name }}</div>
                <div class="file-size">{{ formatFileSize(file.size) }}</div>
                <div class="file-type">{{ getFileTypeName(file) }}</div>
              </div>
              <a 
                :href="getIpfsUrl(file.cid)" 
                target="_blank" 
                class="file-download"
              >
                <i class="fas fa-download"></i> 下载
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 质押规则弹窗 -->
    <div v-if="showStakeInfo" class="stake-modal">
      <div class="modal-backdrop" @click="showStakeInfo = false"></div>
      <div class="modal-content">
        <div class="modal-header">
          <h3>质押规则说明</h3>
          <button class="modal-close" @click="showStakeInfo = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="stake-card">
            <div class="stake-card-header">
              <i class="fas fa-shield-alt"></i>
              <h4>质押机制保障公平性</h4>
            </div>
            <div class="stake-card-content">
              <ul>
                <li><strong>质押金额：</strong>每个任务参与竞标需质押50 USDT</li>
                <li><strong>资金安全：</strong>质押资金由智能合约托管，安全可靠</li>
                <li><strong>退还机制：</strong>任务完成后质押金自动退还至您的钱包</li>
                <li><strong>违规扣除：</strong>恶意竞标或未完成任务将扣除质押金</li>
                <li><strong>信用影响：</strong>违规行为将影响您的平台信用评分</li>
                <li><strong>争议解决：</strong>争议发生时，质押金将用于仲裁流程</li>
                <li><strong>激励机制：</strong>按时完成任务可获得额外信用奖励</li>
              </ul>
            </div>
            <div class="stake-card-footer">
              <div class="stake-example">
                <div class="example-title">示例：</div>
                <div class="example-content">
                  <p>任务赏金: <strong>200 USDT</strong></p>
                  <p>质押金额: <strong>50 USDT</strong></p>
                  <p>平台手续费 (0.5%): <strong>1 USDT</strong></p>
                  <p class="example-total">总计支付: <strong>251 USDT</strong></p>
                  <p class="example-note">* 任务完成后，质押的50 USDT将退还至您的账户</p>
                </div>
              </div>
              <button class="btn btn-primary" @click="showStakeInfo = false">
                <i class="fas fa-check"></i> 我明白了
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useWallet } from '../../composables/useWallet.js'; // 引入钱包功能

const props = defineProps({
  task: {
    type: Object,
    required: true,
    default: () => ({
      currentBidders: 0,
      maxParticipants: 0,
      employer: "0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
    })
  }
});

const emit = defineEmits(['bid']);

// 引入钱包状态
const { walletAddress, isConnected } = useWallet();

const statusTextMap = {
  bidding: '竞标中',
  developing: '开发中',
  reviewing: '评审中',
  completed: '已完成',
  disputed: '争议中'
};

const biddingInProgress = ref(false);
const showStakeInfo = ref(false);

// 计算当前用户是否已参与任务
const alreadyJoined = computed(() => {
  if (!isConnected.value || !walletAddress.value) return false;
  // 从本地存储获取当前钱包参与的任务
  const myTasks = JSON.parse(localStorage.getItem('myTasks') || '[]');
  return myTasks.some(
    t => t.id === props.task.id && t.wallet === walletAddress.value
  );
});

// 计算竞标是否已满
const biddingFull = computed(() => {
  if (props.task.maxParticipants === 0) return false;
  return props.task.currentBidders >= props.task.maxParticipants;
});

// 雇主信息
const employerName = computed(() => {
  return props.task.employerName || "区块链开发者";
});

const employerInitials = computed(() => {
  if (!employerName.value) return "?";
  const names = employerName.value.split(' ');
  if (names.length > 1) {
    return names[0].charAt(0) + names[1].charAt(0);
  }
  return employerName.value.substring(0, 2);
});

// 判断当前用户是否为雇主
const isTaskOwner = computed(() => {
  return isConnected.value && props.task.employer === walletAddress.value;
});

function handleBid() {
  if (!isConnected.value || !walletAddress.value) {
    alert('请先连接钱包');
    return;
  }
  biddingInProgress.value = true;
  
  // 模拟质押和竞标过程
  setTimeout(() => {
    emit('bid', {
      ...props.task,
      stakeAmount: 50,
      stakeCurrency: 'USDT',
      wallet: walletAddress.value // 记录钱包地址
    });
    biddingInProgress.value = false;
  }, 1500);
}

function viewBidDetails() {
  alert('查看竞标详情功能正在开发中...');
}

function formatGithubUrl(url) {
  if (!url) return "";
  return url.replace("https://github.com/", "");
}

// 添加获取IPFS文件URL的方法
function getIpfsUrl(cid) {
  return `https://ipfs.io/ipfs/${cid}`
}

// 添加文件类型图标映射
function getFileIcon(file) {
  const type = file.type || file.name.split('.').pop().toLowerCase();
  
  if (type.includes('pdf')) return 'fas fa-file-pdf';
  if (type.includes('word') || type.includes('doc')) return 'fas fa-file-word';
  if (type.includes('image')) return 'fas fa-file-image';
  if (type.includes('zip') || type.includes('rar')) return 'fas fa-file-archive';
  return 'fas fa-file';
}

// 获取文件类型名称
function getFileTypeName(file) {
  const type = file.type || file.name.split('.').pop().toLowerCase();
  
  if (type.includes('pdf')) return 'PDF文档';
  if (type.includes('word') || type.includes('doc')) return 'Word文档';
  if (type.includes('image')) return '图片文件';
  if (type.includes('zip') || type.includes('rar')) return '压缩文件';
  return '文件';
}

// 添加文件大小格式化方法
function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}
</script>

<style scoped>
.task-detail {
  padding: 40px 0 60px;
  background: linear-gradient(to bottom, rgba(108, 99, 255, 0.05) 0%, rgba(255, 255, 255, 0) 300px);
}

.task-detail-container {
  max-width: 900px;
  margin: 0 auto;
}

/* 任务时间线样式 */
.task-timeline {
  display: flex;
  justify-content: space-between;
  margin-bottom: 30px;
  position: relative;
}

.task-timeline::before {
  content: '';
  position: absolute;
  top: 20px;
  left: 0;
  right: 0;
  height: 3px;
  background-color: var(--border);
  z-index: 1;
}

.timeline-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 2;
  flex: 1;
}

.timeline-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--background);
  border: 3px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  color: var(--text-secondary);
  margin-bottom: 10px;
  transition: all 0.3s ease;
}

.timeline-step.active .timeline-icon {
  background: var(--primary);
  border-color: var(--primary);
  color: white;
  box-shadow: 0 4px 10px rgba(108, 99, 255, 0.3);
}

.timeline-label {
  font-size: 0.9rem;
  color: var(--text-secondary);
  text-align: center;
}

.timeline-step.active .timeline-label {
  color: var(--primary);
  font-weight: 500;
}

.task-detail-header {
  background-color: var(--card-bg);
  border-radius: var(--radius-lg);
  padding: 30px;
  box-shadow: var(--shadow-md);
  margin-bottom: 30px;
  position: relative;
  overflow: hidden;
}

.detail-title {
  font-size: 1.8rem;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 15px;
  flex-wrap: wrap;
}

.detail-subtitle {
  color: var(--text-secondary);
  margin-bottom: 25px;
  font-size: 1.1rem;
  line-height: 1.6;
}

/* 竞标统计信息 */
.bidding-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 15px;
  background: rgba(108, 99, 255, 0.05);
  border-radius: var(--radius-md);
  border-left: 3px solid var(--primary);
  flex-wrap: wrap;
}

.stats-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 500;
  color: var(--primary);
}

.stats-item i {
  font-size: 1.2rem;
}

.detail-meta-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.meta-item {
  background-color: var(--background);
  border-radius: var(--radius-md);
  padding: 15px;
  transition: var(--transition);
}

.meta-item:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-sm);
}

.meta-label {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 5px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.meta-value {
  font-weight: 600;
  font-size: 1.1rem;
}

/* 雇主信息样式 */
.employer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.employer-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--purple-gradient);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.9rem;
}

.employer-name {
  font-size: 0.95rem;
  font-weight: 500;
}

.employer-rating {
  font-size: 0.8rem;
  color: var(--warning);
  margin-top: 3px;
}

.task-skills {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 20px 0;
}

.skill-tag {
  background-color: rgba(108, 99, 255, 0.1);
  color: var(--primary);
  padding: 6px 15px;
  border-radius: var(--radius-full);
  font-size: 0.85rem;
  font-weight: 500;
  transition: var(--transition);
}

.skill-tag:hover {
  background-color: rgba(108, 99, 255, 0.2);
  transform: translateY(-2px);
}

.task-actions {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid var(--border);
}

.bidding-full-container, .already-joined-container {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 15px;
  border-radius: var(--radius-md);
}

.bidding-full-container {
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--error);
}

.already-joined-container {
  background-color: rgba(16, 185, 129, 0.1);
  color: var(--success);
  justify-content: space-between;
}

.bidding-full-container i, .already-joined-container i {
  font-size: 1.2rem;
}

.bid-instruction {
  display: flex;
  gap: 10px;
  background-color: rgba(59, 130, 246, 0.1);
  padding: 15px;
  border-radius: var(--radius-md);
  color: var(--info);
}

.bid-instruction i {
  font-size: 1.2rem;
  margin-top: 3px;
}

.bid-actions {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.btn {
  padding: 10px 20px;
  border-radius: var(--radius-md);
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  border: none;
  font-size: 0.95rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  white-space: nowrap;
}

.btn:hover {
  transform: translateY(-2px);
}

.btn:active {
  transform: translateY(0);
}

.btn-primary {
  background: var(--purple-gradient);
  color: white;
  box-shadow: 0 4px 6px rgba(108, 99, 255, 0.15);
}

.btn-primary:hover {
  box-shadow: 0 6px 8px rgba(108, 99, 255, 0.25);
}

.btn-primary:disabled {
  background: var(--text-tertiary);
  cursor: not-allowed;
  opacity: 0.7;
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--border);
  color: var(--text-primary);
}

.btn-outline:hover {
  border-color: var(--primary);
  color: var(--primary);
  background-color: rgba(108, 99, 255, 0.05);
}

/* 任务详情内容 */
.task-description-content {
  background-color: var(--card-bg);
  border-radius: var(--radius-lg);
  padding: 30px;
  box-shadow: var(--shadow-md);
  margin-bottom: 30px;
  line-height: 1.7;
}

.task-description-content h3 {
  margin-bottom: 15px;
  font-size: 1.3rem;
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--primary);
}

.description-box {
  background: var(--background);
  padding: 20px;
  border-radius: var(--radius-md);
  margin-bottom: 25px;
  border-left: 3px solid var(--primary);
}

.tech-list, .deliverables-list {
  background: var(--background);
  padding: 20px;
  border-radius: var(--radius-md);
  margin-bottom: 25px;
}

.tech-list li, .deliverables-list li {
  margin-bottom: 10px;
  padding-left: 20px;
  position: relative;
}

.tech-list li::before, .deliverables-list li::before {
  content: "•";
  color: var(--primary);
  font-weight: bold;
  position: absolute;
  left: 0;
}

.github-link {
  color: var(--primary);
  text-decoration: underline;
}

.github-link:hover {
  color: var(--primary-dark);
  text-decoration: underline;
}

/* 里程碑样式 */
.milestones-section {
  margin-top: 30px;
}

.milestones-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 15px;
}

.milestone-card {
  background: white;
  border-radius: var(--radius-md);
  padding: 20px;
  border: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
}

.milestone-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-md);
}

.milestone-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--border);
}

.milestone-number {
  font-weight: 600;
  color: var(--primary);
}

.milestone-reward {
  background: rgba(16, 185, 129, 0.1);
  color: var(--success);
  padding: 4px 10px;
  border-radius: var(--radius-full);
  font-size: 0.85rem;
}

.milestone-title {
  font-size: 1.1rem;
  margin-bottom: 10px;
}

.milestone-status {
  margin-top: 15px;
  padding-top: 10px;
  border-top: 1px dashed var(--border);
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-pending {
  color: var(--warning);
}

.status-completed {
  color: var(--success);
}

/* 质押规则弹窗 */
.stake-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
}

.modal-content {
  position: relative;
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  z-index: 1001;
  animation: modalIn 0.3s ease;
}

@keyframes modalIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid var(--border);
}

.modal-header h3 {
  margin: 0;
  font-size: 1.3rem;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.2rem;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 5px;
}

.modal-body {
  padding: 20px;
}

.stake-card {
  background: var(--card-bg);
  border-radius: var(--radius-lg);
  overflow: hidden;
  margin-top: 20px;
  border: 1px solid var(--border);
}

.stake-card-header {
  background: linear-gradient(135deg, #6c63ff, #8b5cf6);
  color: white;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.stake-card-header i {
  font-size: 1.8rem;
}

.stake-card-header h4 {
  font-size: 1.3rem;
  margin: 0;
}

.stake-card-content {
  padding: 25px;
}

.stake-card-content ul {
  list-style-type: none;
  padding: 0;
}

.stake-card-content li {
  padding: 12px 0;
  border-bottom: 1px solid var(--border);
  display: flex;
  gap: 10px;
}

.stake-card-content li:last-child {
  border-bottom: none;
}

.stake-card-content li::before {
  content: "•";
  color: var(--primary);
  font-weight: bold;
  display: inline-block;
  width: 1em;
}

.stake-card-footer {
  padding: 15px 25px;
  text-align: center;
  border-top: 1px solid var(--border);
}

.stake-example {
  background: rgba(108, 99, 255, 0.05);
  padding: 15px;
  border-radius: var(--radius-md);
  margin-bottom: 20px;
  text-align: left;
}

.example-title {
  font-weight: 600;
  margin-bottom: 10px;
  color: var(--primary);
}

.example-content p {
  margin: 8px 0;
}

.example-total {
  margin-top: 15px;
  padding-top: 10px;
  border-top: 1px dashed var(--border);
  font-weight: 600;
  font-size: 1.1rem;
}

.example-note {
  font-size: 0.85rem;
  color: var(--text-secondary);
  margin-top: 10px;
}

/* Web3任务标签样式 */
.web3-tag {
  background: linear-gradient(135deg, #8a2be2, #4b0082);
  color: white;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 0.8rem;
  margin-left: 10px;
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

/* Web3任务特殊提示 */
.web3-notice {
  display: flex;
  gap: 15px;
  background: rgba(138, 43, 226, 0.1);
  border-radius: var(--radius-md);
  padding: 20px;
  margin-bottom: 25px;
  border-left: 3px solid #8a2be2;
}

.web3-notice i {
  font-size: 2rem;
  color: #8a2be2;
  margin-top: 5px;
}

.web3-notice-content h4 {
  color: #8a2be2;
  margin-top: 0;
  margin-bottom: 10px;
}

.web3-notice-content ul {
  padding-left: 20px;
  margin: 10px 0 0;
}

.web3-notice-content li {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.web3-notice-content li i {
  font-size: 1rem;
  color: #8a2be2;
}

/* 文件区域样式 */
.files-section {
  margin-top: 30px;
  padding: 20px;
  background: var(--background);
  border-radius: var(--radius-md);
  border: 1px solid var(--border);
}

.files-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 15px;
  margin-top: 15px;
}

.file-card {
  display: flex;
  align-items: center;
  padding: 15px;
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  transition: var(--transition);
  background: white;
}

.file-card:hover {
  border-color: var(--primary);
  transform: translateY(-3px);
  box-shadow: var(--shadow-sm);
}

.file-icon {
  font-size: 2rem;
  width: 50px;
  text-align: center;
}

.file-icon .fa-file-pdf { color: #e74c3c; }
.file-icon .fa-file-word { color: #2b579a; }
.file-icon .fa-file-image { color: #27ae60; }
.file-icon .fa-file-archive { color: #f39c12; }
.file-icon .fa-file { color: #7f8c8d; }

.file-info {
  flex: 1;
  padding: 0 15px;
}

.file-name {
  font-weight: 500;
  margin-bottom: 3px;
  word-break: break-all;
}

.file-size, .file-type {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.file-download {
  background: var(--primary);
  color: white;
  padding: 8px 15px;
  border-radius: var(--radius-md);
  font-size: 0.9rem;
  text-decoration: none;
  transition: var(--transition);
  white-space: nowrap;
}

.file-download:hover {
  background: var(--primary-dark);
}

/* 新增钱包未连接提示样式 */
.wallet-disconnected-container {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px;
  background: rgba(251, 191, 36, 0.1);
  border-radius: var(--radius-md);
  border-left: 3px solid var(--warning);
  color: var(--warning);
}

.wallet-disconnected-tip {
  font-weight: 500;
}

/* 雇主提示样式 */
.employer-container {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px;
  background: rgba(251, 191, 36, 0.1);
  border-radius: var(--radius-md);
  border-left: 3px solid var(--warning);
  color: var(--warning);
}

.employer-tip {
  font-weight: 500;
}

/* 其他样式保持不变 */
</style>