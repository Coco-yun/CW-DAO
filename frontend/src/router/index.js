import { createRouter, createWebHistory } from "vue-router";

import noReviewerView from "../views/Moderation/noReviewerView.vue";
import ReviewerView from "../views/Moderation/ReviewerView.vue";

import HomeView from "../views/Home/HomeView.vue";

import PostView from "../views/Post/PostView.vue";

import ProfileView from "../views/Profile/ProfileView.vue";

import HomepageComponent from "../components/HomeComponents/HomepageComponent.vue";

import test from "../views/test.vue";
import test1 from "../views/test1.vue";

// 定义路由规则
const routes = [
  {
    path: "/",
    name: "root",
    redirect: "/Home"
  },
  {
    path: "/Post",
    name: "Post",
    component: PostView,
  },
  {
    path: "/Profile",
    name: "Profile",
    component: ProfileView,
  },
  {
    path: "/Home",
    name: "Home",
    component: HomeView,
  },
  {
    path: "/Reviewer",
    name: "Reviewer",
    component: ReviewerView,
  },
  {
    path: "/noReviewer",
    name: "noReviewerView",
    component: noReviewerView,
  },
  {
    path: "/test",
    name: "test",
    component: test,
  },
  {
    path: "/test1",
    name: "test1",
    component: test1,
  },
  {
    path: "/Homepage",
    name: "Homepage",
    component: HomepageComponent,
  },
  {
    path: "/moderation",
    name: "Moderation",
    redirect: "/noReviewer"
  },
];

// 创建路由实例，并指定路由模式（这里使用 HTML5 History 模式）
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;
