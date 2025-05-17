import { ref } from "vue";

export function useGet(url) {
  const data = ref(null);
  const error = ref(null);
  const loading = ref(false);

  const getData = async () => {
    loading.value = true;
    error.value = null;
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`请求错误：${response.statusText}`);
      }
      // 假设返回的是 JSON 数据
      data.value = await response.json();
    } catch (err) {
      error.value = err;
    } finally {
      loading.value = false;
    }
  };

  return { data, error, loading, getData };
}
