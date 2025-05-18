<template>
  <div class="voter-item">
    <div class="voter-info">
      <div class="voter-avatar">
        <img src="avatar" :alt="id" />
      </div>
      <div class="voter-id">{{ id }}</div>
    </div>

    <div class="voter-tokens">{{ tokens }} Tokens</div>

    <div class="voter-info-link">
      <button class="homepage-button" @click="visitInfo">Homepage</button>
    </div>

    <div class="voter-options">
      <button
        class="approve-button"
        :class="{ active: isApproved === true }"
        @click="handleVote(true)"
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
        :class="{ active: isApproved === false }"
        @click="handleVote(false)"
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
</template>

<script setup>
import { ref } from "vue";
import useContentReviewDAO from "../../composables/useContentReviewDAO";

const props = defineProps({
  avatar: {
    type: String,
    required: true,
  },
  id: {
    type: String,
    required: true,
  },
  tokens: {
    type: Number,
    required: true,
  },
  infoLink: {
    type: String,
    required: true,
  },
  isApproved: {
    type: Boolean,
    default: null,
  },
});

const emit = defineEmits(["vote", "visit-info"]);
const dao = useContentReviewDAO();
const account = dao.getAccount();

const handleVote = (approved) => {
  if (approved) {
    trueVote(); // Call the function if true
  } else {
    ttt(); // Call the function if false
  }
  emit("vote", approved);
};

// Define your functions here
const trueVote = () => {};

const ttt = () => {
  console.log("Function ttt executed.");
  // Add your logic here
};

const visitInfo = () => {
  emit("visit-info", props.infoLink);
};
</script>

<style scoped>
.voter-item {
  display: flex;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid rgba(180, 41, 255, 0.3);
}

.voter-info {
  flex: 1;
  display: flex;
  align-items: center;
}

.voter-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 1rem;
}

.voter-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.voter-id {
  font-weight: bold;
}

.voter-tokens {
  flex: 1;
  text-align: center;
  font-weight: bold;
}

.voter-info-link {
  flex: 1;
  text-align: center;
}

.homepage-button {
  background-color: #b429ff;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 0.3rem 1rem;
  font-size: 0.8rem;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.homepage-button:hover {
  background-color: #9b00e8;
}

.voter-options {
  flex: 1;
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.approve-button,
.reject-button {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

.approve-button {
  background-color: rgba(0, 255, 0, 0.2);
  color: #00ff00;
}

.approve-button:hover,
.approve-button.active {
  background-color: rgba(0, 255, 0, 0.5);
}

.reject-button {
  background-color: rgba(255, 0, 0, 0.2);
  color: #ff6b6b;
}

.reject-button:hover,
.reject-button.active {
  background-color: rgba(255, 0, 0, 0.5);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .voter-item {
    flex-direction: column;
    gap: 0.5rem;
    padding: 1rem;
  }

  .voter-info,
  .voter-tokens,
  .voter-info-link,
  .voter-options {
    width: 100%;
    text-align: left;
  }

  .voter-options {
    justify-content: flex-start;
  }
}
</style>
