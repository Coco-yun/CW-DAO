<template>
  <div class="task-modal">
    <div class="modal-overlay" @click.self="$emit('close')"></div>
    
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title">{{ task.title }}</h3>
        <span class="close-btn" @click="$emit('close')">
          <i class="fas fa-times"></i>
        </span>
      </div>
      
      <div class="modal-body">
        <!-- 任务状态指示器 -->
        <div class="status-indicator">
          <span class="status-badge" :class="'status-' + task.status">
            {{ task.statusText }}
          </span>
          <span class="deadline">
            <i class="far fa-clock"></i> 截止: {{ task.deadline }}
          </span>
        </div>
        
        <!-- 任务描述 -->
        <div class="task-description">
          <p>{{ task.description }}</p>
        </div>
        
        <!-- 动态内容区 -->
        <div class="dynamic-content">
          <!-- 竞标中状态 -->
          <div v-if="task.status === 'bidding'" class="bidding-section">
            <h4>竞标管理</h4>
            <div class="bid-info">
              <div class="bid-count">
                <i class="fas fa-users"></i>
                <span>当前竞标者: {{ task.bidders || 0 }}人</span>
              </div>
              <button class="btn btn-primary" @click="viewBidders">
                <i class="fas fa-list"></i> 查看竞标者
              </button>
            </div>
            
            <div class="action-buttons">
              <button class="btn btn-outline" @click="closeBidding">
                <i class="fas fa-lock"></i> 关闭竞标
              </button>
            </div>
          </div>
          
          <!-- 开发中状态 -->
          <div v-else-if="task.status === 'developing'" class="development-section">
            <h4>开发进度管理</h4>
            
            <div class="progress-update">
              <label for="progress-update-textarea">进度更新:</label>
              <textarea
                v-model="progressUpdate"
                class="progress-textarea"
                id="progress-update-textarea"
                name="progress-update"
                placeholder="描述当前进度..."></textarea>
            </div>
            
            <div class="action-buttons">
              <button v-if="!isCreator" class="btn btn-primary" @click="submitProgress">
                <i class="fas fa-paper-plane"></i> 提交进度
              </button>
              <button v-if="isCreator" class="btn btn-outline" @click="requestUpdate">
                <i class="fas fa-sync-alt"></i> 要求更新
              </button>
              <button class="btn btn-primary" @click="submitForReview">
                <i class="fas fa-check-circle"></i> 提交评审
              </button>
            </div>
          </div>
          
          <!-- 评审中状态 -->
          <div v-else-if="task.status === 'reviewing'" class="review-section">
            <h4>任务评审</h4>
            
            <div v-if="isCreator" class="creator-actions">
              <button class="btn btn-success" @click="approveTask">
                <i class="fas fa-check"></i> 审核通过
              </button>
              <button class="btn btn-warning" @click="requestRevision">
                <i class="fas fa-edit"></i> 要求修改
              </button>
              <button class="btn btn-danger" @click="initiateArbitration">
                <i class="fas fa-gavel"></i> 发起仲裁
              </button>
            </div>
            
            <div v-else class="executor-waiting">
              <div class="waiting-message">
                <i class="fas fa-hourglass-half"></i>
                <p>等待任务创建者审核中...</p>
              </div>
              <button class="btn btn-outline" @click="withdrawSubmission">
                <i class="fas fa-undo"></i> 撤回提交
              </button>
            </div>
          </div>
          
          <!-- 争议中状态 -->
          <div v-else-if="task.status === 'disputed'" class="arbitration-section">
            <h4>仲裁管理</h4>
            
            <div class="arbitration-status">
              <i class="fas fa-balance-scale"></i>
              <span>当前状态: {{ task.arbitrationStatus || '处理中' }}</span>
            </div>
            
            <div class="action-buttons">
              <button class="btn btn-outline" @click="viewArbitrationDetails">
                <i class="fas fa-info-circle"></i> 查看详情
              </button>
              <button class="btn btn-primary" @click="submitEvidence">
                <i class="fas fa-file-upload"></i> 提交证据
              </button>
            </div>
          </div>
        </div>
        
        <!-- 任务元信息 -->
        <div class="task-meta">
          <div class="meta-item">
            <i class="fas fa-coins"></i>
            <span>奖励: {{ task.reward }} ETH</span>
          </div>
          <div class="meta-item">
            <i class="fas fa-users"></i>
            <span>参与者: {{ task.participants }}</span>
          </div>
          <div v-if="task.progress" class="meta-item">
            <i class="fas fa-tasks"></i>
            <span>最新进度: {{ task.progress }}</span>
          </div>
        </div>
        
        <!-- 在动态内容区添加文件上传/查看区域 -->
        <div class="file-section" v-if="(task.status === 'developing' && !isCreator) || 
                                 (task.status === 'reviewing' && isCreator)">
          <h4>{{ isCreator ? '任务成果' : '提交任务' }}</h4>
          
          <!-- 雇佣兵提交区域 -->
          <div v-if="!isCreator && task.status === 'developing'">
            <div class="file-upload-area" @dragover.prevent @drop="handleDrop">
              <div v-if="!uploadedFile" class="upload-placeholder">
                <i class="fas fa-cloud-upload-alt"></i>
                <p>拖放文件到此处或 <span class="link" @click="triggerFileInput">选择文件</span></p>
                <p class="hint">支持 ZIP, RAR, 7Z 等压缩格式 (最大 100MB)</p>
              </div>
              <div v-else class="file-preview">
                <i class="fas fa-file-archive"></i>
                <div class="file-info">
                  <p class="filename">{{ uploadedFile.name }}</p>
                  <p class="filesize">{{ formatFileSize(uploadedFile.size) }}</p>
                </div>
                <button class="btn-icon" @click="removeFile">
                  <i class="fas fa-times"></i>
                </button>
              </div>
              <input 
                type="file" 
                ref="fileInput"
                @change="handleFileSelect"
                style="display: none"
                accept=".zip,.rar,.7z,.tar,.gz">
            </div>
            
            <div class="upload-progress" v-if="uploadProgress > 0">
              <div class="progress-bar" :style="{ width: uploadProgress + '%' }"></div>
              <span>{{ uploadProgress }}%</span>
            </div>
            
            <div class="action-buttons">
              <button 
                class="btn btn-primary" 
                :disabled="!uploadedFile || isUploading"
                @click="uploadToIPFS">
                <i class="fas fa-upload"></i> 提交任务
              </button>
              <button 
                class="btn btn-outline"
                @click="cancelTask">
                <i class="fas fa-ban"></i> 取消任务
              </button>
            </div>
          </div>
          
          <!-- 雇主查看区域 -->
          <div v-if="isCreator && task.status === 'reviewing'">
            <div v-if="task.submissionCid" class="submission-info">
              <div class="submission-card">
                <i class="fas fa-file-archive"></i>
                <div class="submission-details">
                  <h5>任务成果提交</h5>
                  <p>提交时间: {{ task.submissionTime }}</p>
                  <p>文件哈希: {{ task.submissionCid }}</p>
                  <p>文件大小: {{ task.submissionSize }}</p>
                </div>
              </div>
              
              <div class="action-buttons">
                <button class="btn btn-primary" @click="downloadSubmission">
                  <i class="fas fa-download"></i> 下载文件
                </button>
                <button class="btn btn-outline" @click="cancelTask">
                  <i class="fas fa-ban"></i> 取消任务
                </button>
              </div>
            </div>
            <div v-else class="no-submission">
              <i class="fas fa-exclamation-circle"></i>
              <p>尚未收到任务成果提交</p>
            </div>
          </div>
        </div>
        
        <!-- 在模态框底部添加取消任务按钮（其他状态） -->
        <div v-if="showCancelButton" class="cancel-task-section">
          <button class="btn btn-cancel" @click="cancelTask">
            <i class="fas fa-ban"></i> 取消任务
          </button>
          <div class="penalty-info">
            将扣除 <span class="penalty-amount">{{ penaltyPercentage }}%</span> 的质押金作为违约金
          </div>
        </div>
      </div>
      
      <div class="modal-footer">
        <button class="btn btn-outline" @click="$emit('close')">
          <i class="fas fa-times"></i> 关闭
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import IPFSService from '../../composables/ipfs';
import { useWallet } from '../../composables/useWallet';

const props = defineProps({
  task: {
    type: Object,
    required: true
  },
  isCreator: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'updateTask'])

const progressUpdate = ref(props.task.progress || '')

// 新增响应式变量
const fileInput = ref(null);
const uploadedFile = ref(null);
const isUploading = ref(false);
const uploadProgress = ref(0);
const submissionContent = ref(null);

// 计算属性：显示取消按钮的条件
const showCancelButton = computed(() => {
  // 雇佣兵：竞标中或开发中
  if (!isCreator.value && (task.value.status === 'bidding' || task.value.status === 'developing')) {
    return true;
  }
  // 雇主：所有状态
  if (isCreator.value && task.value.status !== 'completed' && task.value.status !== 'disputed') {
    return true;
  }
  return false;
});

// 计算属性：违约金百分比
const penaltyPercentage = computed(() => {
  if (!isCreator.value) {
    // 雇佣兵
    return task.value.status === 'bidding' ? 60 : 100;
  } else {
    // 雇主
    switch (task.value.status) {
      case 'bidding': return 35;
      case 'developing': return 70;
      case 'reviewing': return 100;
      default: return 0;
    }
  }
});

// 观察任务变化
watch(() => props.task, (newTask) => {
  progressUpdate.value = newTask.progress || ''
})

// 任务管理方法
const viewBidders = () => {
  console.log('查看竞标者:', props.task.id)
  // 实际实现中这里会调用API获取竞标者列表
}

const closeBidding = () => {
  const updatedTask = {...props.task, status: 'developing', statusText: '开发中'}
  emit('updateTask', updatedTask)
}

const submitProgress = () => {
  const updatedTask = {...props.task, progress: progressUpdate.value}
  emit('updateTask', updatedTask)
}

const submitForReview = () => {
  const updatedTask = {...props.task, status: 'reviewing', statusText: '评审中'}
  emit('updateTask', updatedTask)
}

const approveTask = () => {
  const updatedTask = {...props.task, status: 'completed', statusText: '已完成'}
  emit('updateTask', updatedTask)
}

const requestRevision = () => {
  const updatedTask = {...props.task, status: 'developing', statusText: '开发中'}
  emit('updateTask', updatedTask)
}

const initiateArbitration = () => {
  const updatedTask = {...props.task, status: 'disputed', statusText: '争议中'}
  emit('updateTask', updatedTask)
}

const withdrawSubmission = () => {
  const updatedTask = {...props.task, status: 'developing', statusText: '开发中'}
  emit('updateTask', updatedTask)
}

const viewArbitrationDetails = () => {
  console.log('查看仲裁详情:', props.task.id)
  // 实际实现中这里会打开仲裁详情页面
}

const submitEvidence = () => {
  console.log('提交证据:', props.task.id)
  // 实际实现中这里会打开证据提交表单
}

const requestUpdate = () => {
  console.log('要求更新:', props.task.id)
  // 实际实现中这里会发送通知给任务执行者
}

// 触发文件选择
const triggerFileInput = () => {
  fileInput.value.click();
};

// 处理文件选择
const handleFileSelect = (e) => {
  const file = e.target.files[0];
  if (file) {
    // 检查文件大小 (100MB限制)
    if (file.size > 100 * 1024 * 1024) {
      alert('文件大小不能超过100MB');
      return;
    }
    uploadedFile.value = file;
  }
};

// 处理拖放文件
const handleDrop = (e) => {
  e.preventDefault();
  const file = e.dataTransfer.files[0];
  if (file) {
    // 检查文件类型
    const validTypes = ['.zip', '.rar', '.7z', '.tar', '.gz'];
    const extension = file.name.slice(file.name.lastIndexOf('.')).toLowerCase();
    
    if (!validTypes.includes(extension)) {
      alert('只支持压缩文件格式: ZIP, RAR, 7Z, TAR, GZ');
      return;
    }
    
    // 检查文件大小
    if (file.size > 100 * 1024 * 1024) {
      alert('文件大小不能超过100MB');
      return;
    }
    
    uploadedFile.value = file;
  }
};

// 移除文件
const removeFile = () => {
  uploadedFile.value = null;
};

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// 上传到IPFS
const uploadToIPFS = async () => {
  if (!uploadedFile.value) return;
  
  try {
    isUploading.value = true;
    uploadProgress.value = 10;
    
    // 创建FormData
    const formData = new FormData();
    formData.append('file', uploadedFile.value);
    
    // 模拟上传进度
    const interval = setInterval(() => {
      if (uploadProgress.value < 90) {
        uploadProgress.value += 10;
      }
    }, 500);
    
    // 实际调用IPFS服务
    const cid = await IPFSService.uploadFile(uploadedFile.value);
    
    // 完成上传
    clearInterval(interval);
    uploadProgress.value = 100;
    
    // 更新任务状态
    const updatedTask = {
      ...props.task,
      status: 'reviewing',
      statusText: '评审中',
      submissionCid: cid,
      submissionTime: new Date().toLocaleString(),
      submissionSize: formatFileSize(uploadedFile.value.size)
    };
    
    emit('updateTask', updatedTask);
    
    // 重置状态
    setTimeout(() => {
      isUploading.value = false;
      uploadProgress.value = 0;
      uploadedFile.value = null;
    }, 1000);
    
  } catch (error) {
    console.error('IPFS上传失败:', error);
    isUploading.value = false;
    uploadProgress.value = 0;
    alert(`上传失败: ${error.message}`);
  }
};

// 下载提交内容
const downloadSubmission = async () => {
  if (!task.value.submissionCid) return;
  
  try {
    // 实际项目中应直接从网关下载文件
    // 这里模拟下载过程
    alert(`开始下载任务成果: ${task.value.submissionCid}`);
    
    // 实际实现：
    // const fileUrl = `${IPFSService.gateway}/${task.value.submissionCid}`;
    // window.open(fileUrl, '_blank');
    
  } catch (error) {
    console.error('下载失败:', error);
    alert(`下载失败: ${error.message}`);
  }
};

// 取消任务
const cancelTask = async () => {
  const confirmMessage = isCreator.value 
    ? `您确定要取消此任务吗？将扣除${penaltyPercentage.value}%的质押金。` 
    : `取消任务将扣除${penaltyPercentage.value}%的质押金，确定继续吗？`;
  
  if (!confirm(confirmMessage)) return;
  
  try {
    // 实际应调用智能合约取消任务
    // 这里模拟取消操作
    
    // 根据状态更新任务
    let updatedTask = { ...props.task };
    
    if (isCreator.value && task.value.status === 'reviewing') {
      // 雇主在评审中取消需进入仲裁
      updatedTask.status = 'disputed';
      updatedTask.statusText = '争议中';
      updatedTask.arbitrationStatus = '等待仲裁';
    } else {
      // 其他情况直接取消
      updatedTask.status = 'canceled';
      updatedTask.statusText = '已取消';
    }
    
    emit('updateTask', updatedTask);
    emit('close');
    
    alert(`任务已取消，${penaltyPercentage.value}%的质押金已扣除。`);
    
  } catch (error) {
    console.error('取消任务失败:', error);
    alert(`取消任务失败: ${error.message}`);
  }
};
</script>

<style scoped>
.task-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(2px);
}

.modal-content {
  position: relative;
  background: white;
  border-radius: 16px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 
              0 10px 10px -5px rgba(0, 0, 0, 0.04);
  z-index: 1001;
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1e293b;
}

.close-btn {
  cursor: pointer;
  font-size: 1.25rem;
  color: #64748b;
  transition: color 0.3s;
}

.close-btn:hover {
  color: #475569;
}

.modal-body {
  padding: 20px;
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 9999px;
  font-size: 0.85rem;
  font-weight: 500;
}

.status-bidding {
  background-color: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
}

.status-developing {
  background-color: rgba(245, 158, 11, 0.1);
  color: #f59e0b;
}

.status-reviewing {
  background-color: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.status-disputed {
  background-color: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.deadline {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #64748b;
  font-size: 0.9rem;
}

.task-description {
  margin-bottom: 25px;
  color: #475569;
  line-height: 1.6;
}

.dynamic-content {
  margin-bottom: 25px;
  padding-bottom: 25px;
  border-bottom: 1px solid #e2e8f0;
}

.dynamic-content h4 {
  margin-bottom: 15px;
  font-size: 1.1rem;
  color: #334155;
}

.bid-info, .action-buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.bid-count {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #475569;
}

.progress-update {
  margin-bottom: 20px;
}

.progress-update label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #334155;
}

.progress-textarea {
  width: 100%;
  min-height: 100px;
  padding: 12px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  resize: vertical;
  font-family: inherit;
  transition: border-color 0.3s;
}

.progress-textarea:focus {
  outline: none;
  border-color: #8b5cf6;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.creator-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.executor-waiting {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.waiting-message {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  color: #64748b;
  margin-bottom: 15px;
}

.waiting-message i {
  font-size: 2rem;
  color: #94a3b8;
}

.arbitration-status {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  font-size: 1.1rem;
  color: #475569;
}

.task-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #64748b;
  font-size: 0.9rem;
}

.modal-footer {
  padding: 15px 20px;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: flex-end;
}

.btn {
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.btn:active {
  transform: translateY(0);
}

.btn-primary {
  background: linear-gradient(135deg, #6c63ff, #8b5cf6);
  color: white;
}

.btn-outline {
  background: transparent;
  border: 1px solid #cbd5e1;
  color: #334155;
}

.btn-outline:hover {
  border-color: #8b5cf6;
  color: #6c63ff;
  background-color: rgba(108, 99, 255, 0.05);
}

.btn-success {
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
}

.btn-warning {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: white;
}

.btn-danger {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  color: white;
}

/* 新增样式 */
.file-section {
  margin-bottom: 25px;
  padding: 20px;
  background-color: #f8fafc;
  border-radius: 12px;
  border: 1px dashed #cbd5e1;
}

.file-upload-area {
  height: 180px;
  border: 2px dashed #94a3b8;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
  background-color: white;
  margin-bottom: 15px;
}

.file-upload-area:hover {
  border-color: #6366f1;
  background-color: #f0f9ff;
}

.upload-placeholder {
  text-align: center;
  color: #64748b;
}

.upload-placeholder i {
  font-size: 48px;
  color: #94a3b8;
  margin-bottom: 10px;
}

.link {
  color: #6366f1;
  text-decoration: underline;
  cursor: pointer;
}

.hint {
  font-size: 0.85rem;
  margin-top: 8px;
  color: #94a3b8;
}

.file-preview {
  display: flex;
  align-items: center;
  padding: 15px;
  width: 100%;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.file-preview i {
  font-size: 32px;
  color: #f59e0b;
  margin-right: 15px;
}

.file-info {
  flex-grow: 1;
}

.filename {
  font-weight: 500;
  margin-bottom: 5px;
}

.filesize {
  font-size: 0.9rem;
  color: #64748b;
}

.btn-icon {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 1.2rem;
  cursor: pointer;
  transition: color 0.3s;
}

.btn-icon:hover {
  color: #ef4444;
}

.upload-progress {
  height: 28px;
  background: #e2e8f0;
  border-radius: 9999px;
  margin-bottom: 15px;
  position: relative;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #6366f1, #8b5cf6);
  border-radius: 9999px;
  transition: width 0.3s;
}

.upload-progress span {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-weight: 500;
  font-size: 0.85rem;
}

.submission-info {
  padding: 15px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.submission-card {
  display: flex;
  align-items: center;
  padding: 15px;
  background: #f0fdfa;
  border-radius: 8px;
  border: 1px solid #ccfbf1;
}

.submission-card i {
  font-size: 40px;
  color: #0d9488;
  margin-right: 15px;
}

.submission-details h5 {
  margin-bottom: 8px;
  color: #0f766e;
}

.submission-details p {
  font-size: 0.9rem;
  color: #64748b;
  margin-bottom: 4px;
}

.no-submission {
  text-align: center;
  padding: 30px;
  color: #64748b;
}

.no-submission i {
  font-size: 48px;
  color: #f59e0b;
  margin-bottom: 15px;
}

.cancel-task-section {
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
  text-align: center;
}

.btn-cancel {
  background: linear-gradient(135deg, #fef3c7, #fde68a);
  color: #92400e;
  font-weight: 600;
}

.btn-cancel:hover {
  background: linear-gradient(135deg, #fde68a, #fcd34d);
}

.penalty-info {
  margin-top: 10px;
  font-size: 0.9rem;
  color: #b45309;
}

.penalty-amount {
  font-weight: 700;
  color: #b45309;
}
</style>