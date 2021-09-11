# 构建离线 HTML 文档

本文档仅提供构建的基本操作，有关更多详细信息，请参见 [Rust 官方仓库](https://github.com/rust-lang/rust)。



## 第一步：克隆和替换

```bash
# 在终端中执行

# 克隆 Rust 官方仓库
git clone https://github.com.cnpmjs.org/rust-lang/rust.git rust

# NOTE: 后续操作将在这个目录下完成
cd rust

# 切换版本号
git checkout 1.55.0

# 删除 `rust/library` 目录
rm -rf ./library

# 克隆子仓库
git clone https://github.com.cnpmjs.org/rust-lang/rust-installer.git src/tools/rust-installer
git clone https://github.com.cnpmjs.org/rust-lang/cargo.git src/tools/cargo
git clone https://github.com.cnpmjs.org/rust-lang/rls.git src/tools/rls
git clone https://github.com.cnpmjs.org/rust-lang/miri.git src/tools/miri
git clone https://github.com.cnpmjs.org/rust-lang/stdarch.git library/stdarch
git clone https://github.com.cnpmjs.org/rust-lang/backtrace-rs.git library/backtrace
git clone https://github.com.cnpmjs.org/rust-lang/libbacktrace library/backtrace/crates/backtrace-sys/src/libbacktrace

# 替换中文文档
# 将中文文档复制到 `rust/library` 目录下，已经存在的，直接选择替换

# 本地提交一次
git add -A
git commit -m none
```



## 第二步：添加配置

```bash
# Linux/macOS Bash
echo -e "changelog-seen = 2\n[llvm]\nninja = false" >> config.toml

# Windows PowerShell
Write-Output "changelog-seen = 2`n[llvm]`nninja = false" >> config.toml
```



## 第三步：构建离线文档


```bash
# 构建 HTML 离线静态文档
python x.py doc library/std

# 构建的结果将自动保存在 `rust/build/x86_64-pc-windows-msvc/doc` 目录下
# 构建完成后，请通过浏览器打开 `rust/build/x86_64-pc-windows-msvc/doc/std/index.html` 文件
```

