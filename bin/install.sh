#!/usr/bin/env bash
# Rust 安装目录
RUST_HOME=$(rustup show home)

PrintError() {
    echo -e "\033[31m [ERROR] \033[0m $1"
}

PrintInfo() {
    echo -e "\033[32m [INFO] \033[0m $1"
}

PrintWarn (){
    echo -e "\033[33m [WARN] \033[0m $1"
}
RequestDoc (){
    filename=$1
    rust_path=$2
    
    Repositories='https://github.com/wtklbm/rust-library-i18n.git'
    tmpdir='/tmp/rust-library-chinese'
    
    rm -rf $tmpdir
    mkdir $tmpdir
    PrintInfo "正在从远程下载中文文档... (可能会很长时间，请耐心等待)"
    git clone --depth 1 $Repositories $tmpdir
    
    libraryfile="$tmpdir/dist/$filename"
    
    if [ -f "$tmpdir/dist/$filename" ];then
        cp $libraryfile $rust_path
        rm -rf $tmpdir
        return 1
    fi
    return 0
}

Install(){
    PrintInfo "Rust 中文文档安装脚本：<https://github.com/wtklbm/rust-library-i18n/blob/main/bin/install.sh>"
    if ! command -v unzip &> /dev/null
    then
        PrintError '请先安装 unzip，然后重新执行安装'
        exit
    fi
    
    if ! command -v git &> /dev/null
    then
        PrintError '请先安装 git，然后重新执行安装'
        exit
    fi
    PrintInfo '正在获取Rust安装信息..'
    
    version=$(rustc --version | awk '{print $2}' )
    
    PrintInfo "当前 Rust 版本是：$version"
    
    PrintWarn "您确定安装 Rust 中文文档吗?,安装中文文档时会切换到 stable 分支，并且会安装 rust-src 组件如果继续请输入 y 或 n (默认: y) "
    read is_install
    
    if [ "$is_install" == "n" ];
    then
        PrintInfo "安装取消"
        exit
    fi
    
    rustup default stable>/dev/null 2>&1
    rustup component add rust-src>/dev/null 2>&1
    
    filename="v$version.zip"
    # Rust library的位置
    # mac下大概是这样：.//toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust
    rust_path=$(find $RUST_HOME -path '*rustlib/src/rust')
    library_path="$rust_path/library"
    
    if [ -d "$rust_path" ];then
        PrintInfo "rustlib路径：$rust_path"
    else
        PrintError "没有获取到library路径"
        exit
    fi
    
    RequestDoc $filename $rust_path
    hasDoc=$?
    if [ $hasDoc == 0 ];
    then
        PrintWarn "没有找到当前 Rust 版本所对应的中文文档"
        exit
    fi
    
    PrintWarn "您需要备份源文件吗？如果继续请输入 y 或 n (默认: y)"
    read is_backup
    if [ "$is_backup" != "n" ];
    then
        backup_dir="$rust_path/library_backup"
        cp -rf $library_path $backup_dir
        PrintInfo "备份libray:$backup_dir"
    fi
    
    PrintInfo "正在尝试解压中文文档"
    cd $rust_path
    unzip -oq $filename
    rm $filename
    
    PrintInfo "安装中文文档成功后，您还应该确保在 IDE 中安装了 Rust 相关插件，比如在 vscode 中需要安装 rust-analyzer。
    安装好插件后，重新启动你的 IDE 看看吧。祝您编码愉快。"
}


Install
