<template>
  <div class="moderation-page">
    <!-- 导航栏 -->
    <NavigationBar />

    <div class="main-content">
      <div class="restriction-container">
        <div class="warning-icon">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="48"
            height="48"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
        </div>
        <div class="restriction-message">
          您不是审核员，无法访问此页面
        </div>
        <p class="restriction-description">
          成为审核员需要质押平台代币并填写申请表单。审核员可以参与投票，决定哪些内容可以发布，并获得奖励。成为审核员至少需要10枚代币。
        </p>
        <div class="action-buttons">
          <button class="apply-button" @click="handleApply">
            申请成为审核员
          </button>
          <router-link to="/" class="return-button">返回首页</router-link>
        </div>
      </div>
    </div>

    <!-- 申请模态框 -->
    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal reviewer-application-modal">
        <div class="modal-header">
          <h2>评审员申请</h2>
          <button class="close-button" @click="showModal = false">×</button>
        </div>
        <div class="modal-content">
          <div class="application-form">
            <div class="form-group">
              <div class="form-label">您为什么想要成为一名评审员呢?</div>
              <textarea 
                v-model="applicationReason" 
                placeholder="请解释一下您为何想要担任评审员这一职位......" 
                class="textarea-field"
              ></textarea>
            </div>
            
            <div class="form-group">
              <div class="form-label">相关经历：</div>
              <textarea 
                v-model="applicationExperience" 
                placeholder="请描述任何相关的经历......" 
                class="textarea-field"
              ></textarea>
            </div>
            
            <div class="token-requirement">
              <div class="token-requirement-title">用于质押的代币：</div>
              <div class="token-requirement-text">成为审核员至少需要 10 个代币</div>
            </div>

            <p class="token-info">
              您当前的代币余额: <span>{{ userTokens }}</span>
            </p>
          </div>
        </div>
        <div class="modal-footer">
          <button 
            class="confirm-button submit-button" 
            @click="confirmApply"
            :disabled="!applicationReason || !applicationExperience"
          >
            提交申请
          </button>
          <button class="cancel-button" @click="showModal = false">取消</button>
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
        <div class="success-icon">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="48"
            height="48"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
        </div>
        <h2>申请成功</h2>
        <p>您的审核员申请已提交成功！系统将质押您的10枚代币。请等待管理员审核，审核通过后您将获得审核员权限。</p>
        <button class="ok-button" @click="handleSuccessClose">
          确定
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import NavigationBar from "../../components/NavigationBar.vue";
import useContentReviewDAO from "../../composables/useContentReviewDAO";

const router = useRouter();
const showModal = ref(false);
const showSuccessModal = ref(false);
const userTokens = ref(200); // 假设用户有200代币
const applicationReason = ref('');
const applicationExperience = ref('');

// 处理申请按钮点击
const handleApply = () => {
  showModal.value = true;
};

// 确认申请
const confirmApply = async () => {
  try {
    if (!applicationReason.value.trim() || !applicationExperience.value.trim()) {
      alert("请填写所有必填字段");
      return;
    }
    
    const dao = useContentReviewDAO();
    if (dao) {
      // 这里可以添加将applicationReason和applicationExperience提交到链上的逻辑
      await dao.applyForMembership({
        reason: applicationReason.value,
        experience: applicationExperience.value
      });
      
      // 重置表单
      applicationReason.value = "";
      applicationExperience.value = "";
      
      showModal.value = false;
      showSuccessModal.value = true;
    } else {
      alert("DAO合约未初始化");
    }
  } catch (error) {
    console.error("申请审核员出错:", error);
    alert("申请失败，请重试");
    showModal.value = false;
  }
};

// 处理成功模态框关闭
const handleSuccessClose = () => {
  showSuccessModal.value = false;
  // 可以在这里添加逻辑，例如刷新页面或跳转
};
</script>

<style scoped>
.moderation-page {
  min-height: 100vh;
  background-color: var(--background-color);
  color: var(--text-primary);
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem;
}

.restriction-container {
  max-width: 600px;
  width: 100%;
  text-align: center;
  padding: 3rem 2rem;
  border-radius: 10px;
  border: 1px solid var(--border-color);
  background-color: var(--background-color);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.warning-icon {
  margin-bottom: 1.5rem;
  color: var(--primary-color);
}

.restriction-message {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--primary-color);
  margin-bottom: 1.5rem;
  letter-spacing: 0.5px;
}

.restriction-description {
  color: var(--text-secondary);
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 2rem;
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
  max-width: 300px;
  margin: 0 auto;
}

.apply-button,
.return-button {
  padding: 0.8rem 1.5rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
}

.apply-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

.return-button {
  background-color: transparent;
  color: var(--primary-color);
  border: 1px solid var(--primary-color);
  text-decoration: none;
}

.apply-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(30, 144, 255, 0.3);
}

.return-button:hover {
  background-color: rgba(30, 144, 255, 0.05);
  transform: translateY(-2px);
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
  border-radius: 10px;
  padding: 2rem;
  width: 90%;
  max-width: 480px;
  position: relative;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.modal-header h2 {
  font-size: 1.5rem;
  color: var(--primary-color);
  margin: 0;
}

.close-button {
  background: none;
  border: none;
  color: var(--text-light);
  cursor: pointer;
  transition: color 0.2s;
}

.close-button:hover {
  color: var(--text-primary);
}

.modal-content {
  margin-bottom: 2rem;
}

.modal-text {
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 1rem;
  color: var(--text-primary);
}

.token-info {
  background-color: var(--background-secondary);
  padding: 1rem;
  border-radius: 8px;
  font-size: 1rem;
  color: var(--text-secondary);
}

.token-info span {
  font-weight: bold;
  color: var(--primary-color);
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.cancel-button,
.confirm-button {
  padding: 0.7rem 1.5rem;
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

.confirm-button {
  background-color: var(--primary-color);
  color: white;
  border: none;
}

.cancel-button:hover {
  background-color: var(--border-light);
}

.confirm-button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(30, 144, 255, 0.2);
}

/* 成功模态框样式 */
.success-modal {
  text-align: center;
  background: linear-gradient(to bottom, #fafafa, #f5fff5);
  border: 1px solid rgba(76, 175, 80, 0.2);
  box-shadow: 0 10px 25px rgba(76, 175, 80, 0.1);
}

.success-icon {
  color: var(--success-color);
  margin-bottom: 1rem;
}

.success-modal h2 {
  color: var(--success-color);
  margin-bottom: 1rem;
}

.success-modal p {
  margin-bottom: 2rem;
  color: var(--text-secondary);
  line-height: 1.6;
}

.ok-button {
  background-color: var(--success-color);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.8rem 2rem;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  margin: 0 auto;
  display: block;
  width: 50%;
}

.ok-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }
  
  .restriction-container {
    padding: 2rem 1.5rem;
  }
  
  .restriction-message {
    font-size: 1.3rem;
  }
  
  .restriction-description {
    font-size: 1rem;
  }
  
  .modal {
    padding: 1.5rem;
    width: 95%;
  }
  
  .reviewer-application-modal {
    max-width: 95%;
  }
  
  .modal-header h2 {
    font-size: 1.4rem;
  }
  
  .form-label {
    font-size: 1rem;
  }
  
  .textarea-field {
    min-height: 90px;
  }
  
  .token-requirement {
    padding: 1rem;
  }
  
  .cancel-button,
  .confirm-button {
    padding: 0.7rem 1.5rem;
    font-size: 0.95rem;
    min-width: 100px;
  }
}

.reviewer-application-modal {
  max-width: 500px;
  display: flex;
  flex-direction: column;
  border: 1px solid rgba(124, 77, 255, 0.2);
  box-shadow: 0 10px 25px rgba(124, 77, 255, 0.1);
  background: linear-gradient(to bottom, #fafafa, #f5f5ff);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid rgba(124, 77, 255, 0.2);
}

.modal-header h2 {
  font-size: 1.6rem;
  color: #6c2fb8;
  margin: 0;
  text-align: center;
  width: 100%;
  position: relative;
  left: 12px; /* 补偿关闭按钮的宽度，使标题视觉上居中 */
}

.application-form {
  margin: 0 auto;
  width: 90%;
}

.form-group {
  margin-bottom: 1.8rem;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.form-label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.8rem;
  color: #444;
  text-align: center;
  width: 100%;
  font-size: 1.05rem;
}

.textarea-field {
  width: 100%;
  min-height: 110px;
  border: 1px solid rgba(124, 77, 255, 0.3);
  border-radius: 10px;
  padding: 1rem;
  font-size: 1rem;
  background-color: rgba(255, 255, 255, 0.8);
  color: #333;
  resize: vertical;
  transition: all 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
}

.textarea-field:focus {
  outline: none;
  border-color: #8338ec;
  box-shadow: 0 0 0 3px rgba(131, 56, 236, 0.15);
  background-color: white;
}

.textarea-field::placeholder {
  color: #aaa;
  opacity: 0.8;
}

.token-requirement {
  background-color: #f8f4ff;
  border-left: 3px solid #8338ec;
  padding: 1.2rem;
  border-radius: 10px;
  margin: 1.5rem 0;
  text-align: center;
  box-shadow: 0 3px 10px rgba(131, 56, 236, 0.08);
}

.token-requirement-title {
  font-weight: 600;
  color: #6c2fb8;
  margin-bottom: 0.5rem;
  font-size: 1.1rem;
}

.token-requirement-text {
  color: #6c2fb8;
  font-size: 1rem;
}

.token-info {
  text-align: center;
  background-color: rgba(255, 255, 255, 0.8);
  padding: 1rem;
  border-radius: 10px;
  font-size: 1rem;
  color: #555;
  border: 1px dashed rgba(124, 77, 255, 0.3);
}

.token-info span {
  font-weight: bold;
  color: #8338ec;
  font-size: 1.1rem;
}

.modal-footer {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(124, 77, 255, 0.1);
}

.cancel-button,
.confirm-button {
  padding: 0.8rem 1.8rem;
  border-radius: 30px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 120px;
  text-align: center;
}

.cancel-button {
  background-color: transparent;
  color: #777;
  border: 1px solid #ccc;
}

.submit-button {
  background: linear-gradient(135deg, #8338ec, #6c2fb8);
  color: white;
  border: none;
  box-shadow: 0 4px 10px rgba(124, 77, 255, 0.3);
}

.submit-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(124, 77, 255, 0.4);
}

.submit-button:disabled {
  background: linear-gradient(135deg, #bba3e9, #a28cd0);
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.cancel-button:hover {
  background-color: #f5f5f5;
  border-color: #999;
  color: #555;
}

.close-button {
  background: none;
  border: none;
  color: #999;
  font-size: 1.8rem;
  line-height: 1;
  cursor: pointer;
  transition: all 0.2s ease;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-button:hover {
  color: #6c2fb8;
  transform: rotate(90deg);
}
</style>
