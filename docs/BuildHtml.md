# 构建离线 HTML 文档

您可以构建离线的 HTML 文档供自己阅读。在构建离线 HTML 文档之前，您需要了解一些 Git 操作知识以及 Rust 构建流程。在这里，仅提供 HTML 离线文档的构建命令，有关更多详细信息，请参见 [Rust 官方仓库](https://github.com/rust-lang/rust)。

下面所提供的构建 HTML 文档的脚本并不总是有效的。如果您从来没有通过源代码构建过 Rust 文档。那么请避免随意尝试，会出现各种各样的问题。如果您想通过源码构建文档，最快最直接的方式是跳转到 Rust 官方仓库，了解 Rust 构建流程，通过自身的学习，以此探索更好的构建 HTML 文档的操作。

之前，[cxping](https://github.com/cxping) 同学构建过一份儿离线中英文对照文档，但长时间无人更新此文档，它显得已经有些老旧，故已将其删除。目前还没有人愿意长期更新本地文档的 HTML 版本，所以即便您构建出 HTML 文档，也请不要向该仓库提交 PR。




## 第一步：克隆和替换

```bash
# 在终端中执行

# 克隆 Rust 官方仓库
git clone https://github.com/rust-lang/rust.git rust

# NOTE: 后续操作将在这个目录下完成
cd rust

# 切换版本号
# 注意：这里的版本号应该与要构建的中文文档的版本号保持一致
# 特别注意：下面这一行不能直接拷贝，版本号 `1.55.0` 一定要记得改
git checkout 1.55.0

# 删除 `rust/library` 目录
rm -rf ./library

# 克隆子仓库
git clone https://github.com/rust-lang/rust-installer.git src/tools/rust-installer
git clone https://github.com/rust-lang/cargo.git src/tools/cargo
git clone https://github.com/rust-lang/rls.git src/tools/rls
git clone https://github.com/rust-lang/miri.git src/tools/miri
git clone https://github.com/rust-lang/stdarch.git library/stdarch
git clone https://github.com/rust-lang/backtrace-rs.git library/backtrace
git clone https://github.com/rust-lang/libbacktrace library/backtrace/crates/backtrace-sys/src/libbacktrace

# 替换中文文档
# 文档下载地址：https://github.com/wtklbm/rust-library-i18n/tree/main/dist
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
# 关于为什么执行下面的命令能构建文档，请跳转到 Rust 官方仓库
# 有关任何关于该命令的问题，也请到相关仓库进行提问
python x.py doc library/std

# 构建的结果将自动保存在 `rust/build/x86_64-pc-windows-msvc/doc` 目录下
# 构建完成后，请通过浏览器打开 `rust/build/x86_64-pc-windows-msvc/doc/std/index.html` 文件
```
