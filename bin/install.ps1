# 感谢 [tch1121](https://github.com/tch1121)

function PrintError {
    Write-Host "[ERROR] " -NoNewline -ForegroundColor Red
    Write-Host @args -ForegroundColor White
}

function PrintInfo {
    Write-Host "[INFO] " -NoNewline -ForegroundColor Green
    Write-Host @args -ForegroundColor White
}

function PrintWarn {
    Write-Host "[WARN] " -NoNewline -ForegroundColor Yellow
    Write-Host @args -ForegroundColor White
}

function IsDir {
    param($path)

    return $path -and (Test-Path $path -PathType Container)
}

function IsFile {
    param($path)

    return $path -and (Test-Path $path -PathType Leaf)
}

function GetRustHome {
    rustup show home
}

function GetRustVersion {
    $curr_version = (rustc --version) -match ' (?<version>[\d\.]*?) '

    if ($curr_version) {
        $curr_version = $Matches.version
        return $curr_version
    }

    PrintError '获取rustc版本号失败'
}

function GetLibraryPath {
    [System.IO.Path]::GetFullPath(
        "$(GetRustHome)\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\src\rust"
    )
}

function ExistsCommand {
    param($command)

    !($null -eq (Get-Command -Name $command -ErrorAction Ignore))
}

function ExtractZip {
    param($filename, $dirname)

    $filename = $("" + $filename).TrimEnd("\")
    & 7z.exe x $filename -aoa $("-o" + $dirname) | Out-Null
}

function SelectStable {
    rustup default stable
}

function InstallRustSrcComponent {
    rustup component add rust-src
}

function RequestDoc {
    param ($filename)

    if ($(is_file $filename)) {
        return $True
    }

    PrintInfo "正在从远程下载中文文档... (可能会很长时间，请耐心等待)"

    $tempdir = Join-Path $env:TEMP "rust-library-chinese"

    if ($(IsDir $tempdir)) {
        Remove-Item $tempdir -Recurse -Force
    }

    git clone --depth 1 https://gitee.com/wtklbm/rust-library-chinese.git $tempdir

    $filepath = Join-Path $tempdir "dist/$filename"

    if (!$(IsFile $filepath)) {
        return $False
    }

    Copy-Item $filepath .
    Remove-Item $tempdir -Recurse -Force

    return $True
}

function Install {
    PrintInfo "Rust 中文文档安装脚本：<https://github.com/wtklbm/rust-library-i18n/blob/main/bin/install.ps1>`n"

    if (!$(ExistsCommand 7z)) {
        PrintError "请先安装 7z，然后重新执行安装"
        return
    }

    if (!$(ExistsCommand git)) {
        PrintError "请先安装 git，然后重新执行安装"
        return
    }

    $version = "$(GetRustVersion)"
    PrintWarn "当前 Rust 版本是：$version`n"

    $is_install = $(Read-Host '您确定安装 Rust 中文文档吗？如果继续请输入 y').ToLower()

    if ($is_install -ne 'y') {
        return
    }

    $filename = "v$version.zip"

    if (!$(RequestDoc $filename)) {
        PrintError "没有找到当前 Rust 版本所对应的中文文档"
        return
    }

    $is_install = $(Read-Host '安装中文文档时会切换到 stable 分支，并且会安装 rust-src 组件，如果继续请输入 y').ToLower()

    if ($is_install -ne 'y') {
        return
    }

    SelectStable
    InstallRustSrcComponent

    $cwdpath = "$(GetLibraryPath)"
    $library = Join-Path $cwdpath 'library'

    if (!$(IsDir $library)) {
        PrintError "请检查该目录是否存在：$library"
        return
    }

    $backup = Join-Path $cwdpath 'library_backup'

    PrintInfo "正在将源文件备份到：$backup"
    Copy-Item -Recurse -Force "$library" "$backup"

    PrintInfo "正在尝试解压中文文档"
    ExtractZip $filename $cwdpath

    if ($LASTEXITCODE -eq 0) {
        Remove-Item $filename
    }

    PrintInfo "
    安装中文文档成功后，您还应该确保在 IDE 中安装了 Rust 相关插件，比如在 vscode 中需要安装 rust-analyzer。
    安装好插件后，重新启动你的 IDE 看看吧。祝您编码愉快。`n"
}

Install
