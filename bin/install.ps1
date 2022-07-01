# 感谢 [tch1121](https://github.com/tch1121)

function PrintError {
    Write-Host " [ERROR] " -NoNewline -ForegroundColor Red
    Write-Host @args -ForegroundColor White
}

function PrintInfo {
    Write-Host " [INFO] " -NoNewline -ForegroundColor Green
    Write-Host @args -ForegroundColor White
}

function PrintWarn {
    Write-Host " [WARN] " -NoNewline -ForegroundColor Yellow
    Write-Host @args -ForegroundColor White
}

function ReadHost {
    Write-Host " [WARN] " -NoNewline -ForegroundColor Yellow
    return $(Read-Host @args).ToLower()
}

function IsDir {
    param($path)

    return $path -and (Test-Path $path -PathType Container)
}

function IsFile {
    param($path)

    return $path -and (Test-Path $path -PathType Leaf)
}

function RemoveItem() {
    param($path)

    if ($(IsFile $path) -or $(IsDir $path)) {
        Remove-Item $path -Recurse -Force
    }
}

function GetRustVersion {
    $curr_version = ((rustc --version) -split " ")[1]

    if ($curr_version) {
        return $curr_version
    }

    PrintError '获取 Rust 版本失败'
}

function GetLibraryPath {
    [System.IO.Path]::GetFullPath(
        "$(rustup show home)\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\src\rust"
    )
}

function ExistsCommand {
    param($command)

    !($null -eq (Get-Command -Name $command -ErrorAction Ignore))
}

function ExtractZipFrom7z {
    param($filename, $dirname)

    $filename = $("" + $filename).TrimEnd("\")
    & 7z.exe x $filename -aoa $("-o" + $dirname) | Out-Null
}

function ExtractZip {
    param($filename, $dirname, $remove)

    $filename = $("" + $filename).TrimEnd("\")

    if (!$(ExistsCommand Expand-Archive)) {
        if (!$(ExistsCommand 7z)) {
            PrintError "请先安装 7z，然后重新执行安装"
            exit
        }

        ExtractZipFrom7z $filename $dirname
        exit
    }

    try {
        Expand-Archive -Path "$filename" -DestinationPath "$dirname" -Force
    }
    catch {
        PrintWarn "解压失败，请重新尝试安装"
        exit
    }

    if ($remove) {
        RemoveItem $filename
    }
}

function RequestDoc {
    param ($filename)

    $cfilename = $filename
    $tempdir = Join-Path $env:TEMP "rust-library-chinese"

    RemoveItem $tempdir

    $RepositoriesList = @{
        'github' = 'https://github.com/wtklbm/rust-library-i18n.git'
        'gitee'  = 'https://gitee.com/wtklbm/rust-library-chinese.git'
    }

    $Repositories = ReadHost "请选择仓库源 (输入数字。默认: 1)`n  [0]: github`n  [1]: gitee"
    $Repositories -match '^\[?(?<target>[0-1])\]?$' | Out-Null
    $Repositories = if ($Matches.target -eq 0) { $RepositoriesList.github } else { $RepositoriesList.gitee }

    PrintInfo "正在从远程下载中文文档... (可能会很长时间，请耐心等待)"

    git clone --depth 1 -q $Repositories $tempdir

    $distPath = $(Join-Path $tempdir "dist")

    if (!$(IsDir $distPath)) {
        PrintError "克隆仓库失败，请尝试重新安装"
        exit
    }

    $style = ReadHost "请选择文档样式 (输入数字。默认: 0)`n  [0]: 纯中文文档。阅读方便，有看不懂的地方直接看官网原文和源码`n  [1]: 对照文档。阅读起来比较慢，中文翻译只作为参考"
    $style -match '^\[?(?<target>[0-1])\]?$' | Out-Null

    $style = if ($Matches.target -eq 1) {
        $filename = $filename -replace ".zip", "_contrast.zip"
    }

    $filepath = Join-Path $distPath $filename

    if (!$(IsFile $filepath)) {
        $basename = $(Get-ChildItem $distPath)[0].BaseName.Substring(1)
        PrintError "没有找到当前通道的 Rust 版本所对应的中文文档。找到了 $basename 版本的中文文档。"
        exit
    }

    Copy-Item $filepath "./$cfilename"
    RemoveItem $tempdir
}

function Install {
    PrintInfo "Rust 中文文档安装脚本：<https://github.com/wtklbm/rust-library-i18n/blob/main/bin/install.ps1>`n"

    if (!$(ExistsCommand git)) {
        PrintError "请先安装 git，然后重新执行安装"
        return
    }

    if (!$(ExistsCommand rustup)) {
        $url = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
        $exe = "rustup-init.exe"

        # `-UseBasicParsing`: 解决禁用 `IE` 时下载无法解析的问题
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $exe

        if (!$(IsFile $exe)) {
            PrintError "请手动安装 Rust 后重试"
            return
        }

        PrintError "请先手动执行当前目录下的 $exe 文件来安装 Rust"
        return
    }

    $is_install = ReadHost "您确定安装 Rust 中文文档吗？安装中文文档时会切换到 stable 通道，并且会安装 rust-src 组件。如果继续请输入 y 或 n (默认: y)"

    if ($is_install -eq 'n') {
        return
    }

    rustup default stable >$null 2>&1
    rustup component add rust-src >$null 2>&1

    $version = "$(GetRustVersion)"
    $filename = "v$version.zip"

    PrintInfo "当前 Rust 版本是：$version"

    RequestDoc $filename

    $cwdpath = "$(GetLibraryPath)"
    $library = Join-Path $cwdpath 'library'

    if (!$(IsDir $library)) {
        PrintError "请检查该目录是否存在：$library"
        return
    }

    $backup = Join-Path $cwdpath 'library_backup'
    $is_install = ReadHost "您需要备份 rust-src 组件中附带的源文件吗？如果继续请输入 y 或 n (默认: n)"

    if ($is_install -eq 'y') {
        PrintInfo "源文件已备份到 $backup"
        Copy-Item -Recurse -Force "$library" "$backup"
    }

    ExtractZip $filename $cwdpath $True

    Write-Output ""
    PrintInfo "安装完成！`n"
    PrintWarn "请确保在 IDE 中安装了 Rust 相关插件："
    Write-Output "   - Visual Studio Code 需要安装 [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer)"
    Write-Output "   - JetBrains 系列需要安装 [Rust](https://plugins.jetbrains.com/plugin/8182-rust)"
    Write-Output ''
    PrintInfo "安装好插件后，重新启动你的 IDE 看看吧。祝您编码愉快！"
}

Install
