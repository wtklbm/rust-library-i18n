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

# function ExtractZip {
#     param($filename, $dirname)

#     $filename = $("" + $filename).TrimEnd("\")
#     & 7z.exe x $filename -aoa $("-o" + $dirname) | Out-Null
# }

# bate
function ExtractZip {
    param($filename, $dirname, $remove)
    $filename = $("" + $filename).TrimEnd("\")
    
    try {
        Expand-Archive -Path "$filename" -DestinationPath "$dirname" -Force

        if ($remove) {
            Remove-Item $filename
        }
    }
    catch {
    
    }
}

function SelectStable {
    rustup default stable
}

function InstallRustSrcComponent {
    rustup component add rust-src
}

function RequestDoc {
    param ($filename)

    if ($(IsFile $filename)) {
        return $True
    }

    
    $tempdir = Join-Path $env:TEMP "rust-library-chinese"
    
    if ($(IsDir $tempdir)) {
        Remove-Item $tempdir -Recurse -Force
    }
    
    $RepositoriesList = @{
        'github' = 'https://github.com/wtklbm/rust-library-i18n.git'
        'gitee'  = 'https://gitee.com/wtklbm/rust-library-chinese.git'
    }

    PrintInfo "选择仓库源"

    $Repositories = $(Read-Host " [0]: github`n [1]: gitee`n 选择").ToLower()
    $Repositories -match '^\[?(?<target>[0-1])\]?$' | Out-Null
    $Repositories = if ($Matches.target -eq 0) { $RepositoriesList.github } else { $RepositoriesList.gitee }

    PrintInfo "正在从远程下载中文文档... (可能会很长时间，请耐心等待)"
    git clone --depth 1 $Repositories $tempdir
    # git clone --depth 1 https://gitee.com/wtklbm/rust-library-chinese.git $tempdir

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

    $is_install = $(Read-Host '您确定安装 Rust 中文文档吗？如果继续请输入 y 或 n (默认: y) ').ToLower()

    if ($is_install -eq 'n') {
        return
    }

    $filename = "v$version.zip"

    if (!$(RequestDoc $filename)) {
        PrintError "没有找到当前 Rust 版本所对应的中文文档"
        return
    }

    $is_install = $(Read-Host '安装中文文档时会切换到 stable 分支，并且会安装 rust-src 组件，如果继续请输入 y 或 n (默认: y) ').ToLower()

    if ($is_install -eq 'n') {
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

    $is_install = $(Read-Host '您需要备份源文件吗？如果继续请输入 y 或 n (默认: y) ').ToLower()

    if ($is_install -eq '' -or $is_install -eq 'y') {
        PrintInfo "正在将源文件备份到：$backup"
        Copy-Item -Recurse -Force "$library" "$backup"
    }

    PrintInfo "正在尝试解压中文文档"
    $CompleteRemove = $true

    # 7z
    # ExtractZip $filename $cwdpath

    # Expand-Archive
    ExtractZip $filename $cwdpath $CompleteRemove

    # 对内部对象无效
    # if ($LASTEXITCODE -eq 0) {
    #     Remove-Item $filename
    # }

    PrintInfo "
    安装中文文档成功后，您还应该确保在 IDE 中安装了 Rust 相关插件，比如在 vscode 中需要安装 rust-analyzer。
    安装好插件后，重新启动你的 IDE 看看吧。祝您编码愉快。`n"
}

Install
