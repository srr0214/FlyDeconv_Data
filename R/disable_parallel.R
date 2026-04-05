## 强制所有方法单线程（benchmark 推荐设置）

if (requireNamespace("BiocParallel", quietly = TRUE)) {
  BiocParallel::register(BiocParallel::SerialParam())
}

if (requireNamespace("future", quietly = TRUE)) {
  future::plan("sequential")
}

options(mc.cores = 1)
