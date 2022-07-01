#!/usr/bin/env bash

# 感谢 [Tarhyru](https://github.com/Tarhyru)

print_error() {
    echo -e "\033[31m [ERROR]\033[0m $*"
}

print_info() {
    echo -e "\033[32m [INFO]\033[0m $*"
}

print_warn() {
    echo -e "\033[33m [WARN]\033[0m $*"
}

request_doc() {
    filename=$1
    rust_path=$2

    repositories_list=(
        'https://github.com/wtklbm/rust-library-i18n.git'
        'https://gitee.com/wtklbm/rust-library-chinese.git'
    )

    print_warn "请选择仓库源 (输入数字。默认: 1)"
    echo -e "   \033[32m[0]\033[0m: github"
    echo -e "   \033[32m[1]\033[0m: gitee"

    read -r repository

    if [ "$repository" = 0 ]; then
        repository=${repositories_list[0]}
    else
        repository=${repositories_list[1]}
    fi

    tmpdir='/tmp/rust-library-chinese'

    rm -rf $tmpdir
    mkdir $tmpdir

    print_info "正在从远程下载中文文档... (可能会很长时间，请耐心等待)"

    git clone --depth 1 "$repository" $tmpdir >/dev/null 2>&1 || {
        print_error "克隆仓库失败，请重试"
        return 0
    }

    print_warn "请选择文档样式 (输入数字。默认: 0)"
    echo -e "   \033[32m[0]\033[0m: 纯中文文档。阅读方便，有看不懂的地方直接看官网原文和源码"
    echo -e "   \033[32m[1]\033[0m: 对照文档。阅读起来比较慢，中文翻译只作为参考"

    read -r style

    if [ "$style" = 1 ]; then
        filename=${filename/".zip"/"_contrast.zip"}
    fi

    distpath="$tmpdir/dist"
    filepath="$distpath/$filename"

    if [ -f "$filepath" ]; then
        cp "$filepath" "$rust_path"
        rm -rf $tmpdir
        return 1
    fi

    basename=$(basename "$(find "$distpath" -path "*/v*")" .zip)

    print_error "没有找到当前通道的 Rust 版本所对应的中文文档。找到了 $basename 版本的中文文档。"

    return 0
}

install() {
    print_info "Rust 中文文档安装脚本：<https://github.com/wtklbm/rust-library-i18n/blob/main/bin/install.sh>\n"

    if ! (command -v unzip &>/dev/null || command -v 7z &>/dev/null); then
        print_error '请先安装 unzip 或 p7zip，然后重新执行安装'
        return
    fi

    if ! command -v git &>/dev/null; then
        print_error '请先安装 git，然后重新执行安装'
        return
    fi

    if ! command -v rustup &>/dev/null; then
        print_info '正在安装 Rust ...'

        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh || {
            print_error "安装 Rust 失败，请重新尝试"
            return
        }

        source "$HOME"/.cargo/env
    fi

    print_warn "您确定安装 Rust 中文文档吗？安装中文文档时会切换到 stable 通道，并且会安装 rust-src 组件。如果继续请输入 y 或 n (默认: y)"

    read -r is_install

    if [ "$is_install" == "n" ]; then
        return
    fi

    rustup default stable >/dev/null 2>&1
    rustup component add rust-src >/dev/null 2>&1

    version=$(rustc --version | awk '{print $2}')
    filename="v$version.zip"
    rust_home=$(rustup show home)

    #  路径格式为：`$rust_home/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust`
    rust_path=$(find "$rust_home" -path "*stable-*rustlib/src/rust")

    library_path="$rust_path/library"

    print_info "当前 Rust 版本是：$version"

    if [ ! -d "$library_path" ]; then
        print_error "没有获取到 library 路径: $library_path"
        return
    fi

    request_doc "$filename" "$rust_path"
    has_doc=$?

    if [ $has_doc == 0 ]; then
        return
    fi

    print_warn "您需要备份 rust-src 组件中附带的源文件吗？如果继续请输入 y 或 n (默认: n)"

    read -r is_backup

    if [ "$is_backup" = "y" ]; then
        backup_dir="$rust_path/library_backup"
        cp -rf "$library_path" "$backup_dir"
        print_info "源文件已备份到 $backup_dir"
    fi

    cd "$rust_path" || {
        print_error "请检查目录是否存在：$rust_path"
        return
    }

    unzip -oq "$filename" &>/dev/null || 7z x -aoa "$filename" &>/dev/null || {
        print_error "尝试解压 $filename 失败"
        return
    }

    rm "$filename"

    print_info "安装完成！\n"
    print_warn "请确保在 IDE 中安装了 Rust 相关插件："
    echo -e "   - Visual Studio Code 需要安装 [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer)"
    echo -e "   - JetBrains 系列需要安装 [Rust](https://plugins.jetbrains.com/plugin/8182-rust)"
    echo ''
    print_info "安装好插件后，重新启动你的 IDE 看看吧。祝您编码愉快！"
}

install
