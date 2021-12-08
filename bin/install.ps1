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

function GetRustHome {
    rustup show home
}

function GetRustVersion {
    $curr_version = (rustc --version) -match ' (?<version>[\d\.z]*?) '

    if ($curr_version) {
        $curr_version = $Matches.version
        return $curr_version
    }

    PrintError '获取rustc版本号失败'
}

function CreateUri {
    param($version)

    "https://github.com/wtklbm/rust-library-i18n/raw/main/dist/v$version.zip"
}

function GetLibraryPath {
    [System.IO.Path]::GetFullPath(
        "$(GetRustHome)\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\src\rust"
    )
}

function Exists7z {
    !($null -eq (Get-Command -Name 7z -ErrorAction Ignore))
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
    param ($url, $filename)

    if ($(is_file $filename)) {
        return $True
    }

    try {
        PrintInfo "正在从远程下载中文文档... (可能会很长时间，请耐心等待)"

        Invoke-WebRequest -Uri $url -OutFile $filename
    }
    catch {
        PrintError "下载失败：$url"
        PrintWarn "该错误可能是因为网络问题造成的，如果链接是正确的，请多尝试几次。您也可以手动下载，然后将下载好的文件重命名为 $filename，并放在当前目录下"

        return $False
    }

    return $True
}

function Install {
    PrintInfo "Rust 中文文档安装脚本：<https://github.com/wtklbm/rust-library-i18n/blob/main/bin/install.ps1>`n"

    if (!$(Exists7z)) {
        PrintError "请先安装 7z 软件，然后重新执行命令"
        return
    }

    $version = "$(GetRustVersion)"
    PrintWarn "当前 Rust 版本是：$version`n"

    $is_install = $(Read-Host '您确定安装 Rust 中文文档吗？如果继续请输入 y').ToLower()

    if ($is_install -ne 'y') {
        return
    }

    $url = CreateUri -version $version
    $filename = [System.IO.Path]::GetFileName($url)

    if (!$(RequestDoc $url $filename)) {
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
