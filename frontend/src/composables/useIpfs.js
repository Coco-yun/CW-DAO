import { useState } from "react";
import { create } from "ipfs-http-client";

// 请将下面的 'YourProjectID' 与 'YourProjectSecret' 替换为你在 Infura 的凭据
const projectId = "YourProjectID";
const projectSecret = "YourProjectSecret";
// 通过 Base64 编码生成授权信息
const auth =
  "Basic " + Buffer.from(`${projectId}:${projectSecret}`).toString("base64");

// 创建 IPFS 客户端实例，连接到 Infura 的 IPFS 节点
const ipfs = create({
  host: "ipfs.infura.io",
  port: 5001,
  protocol: "https",
  headers: {
    authorization: auth,
  },
});

/**
 * 自定义 React Hook：useIpfsUpload
 * 此 Hook 提供上传文件到 IPFS 的方法，并在上传成功后返回文件的哈希值（CID）。
 */
export function useIpfsUpload() {
  const [hash, setHash] = useState(null); // 上传成功返回的文件哈希值
  const [loading, setLoading] = useState(false); // 上传状态标识
  const [error, setError] = useState(null); // 错误信息

  // uploadFile 为异步函数，接收文件内容，可为字符串、Buffer、Blob 或 File（浏览器环境）
  const uploadFile = async (file) => {
    setLoading(true);
    setError(null);
    try {
      // 调用 ipfs.add 方法上传文件
      const result = await ipfs.add(file);
      // 上传成功后 result 对象包含 cid、path、size 等字段，这里使用 cid 的字符串形式
      setHash(result.cid.toString());
    } catch (err) {
      setError(err);
    }
    setLoading(false);
  };

  return { hash, loading, error, uploadFile };
}
