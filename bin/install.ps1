# 感谢 [tch1121](https://github.com/tch1121)

function GetRustHome {
    rustup show home
}

function GetRustVersion {
    $curr_version = (rustc --version) -match ' (?<version>[\d\.z]*?) '
    if ($curr_version) {
        $curr_version = $Matches.version
    }
    else {
        Write-Host '获取rustc版本号失败' -ForegroundColor Red
        exit
    }
    $curr_version
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

function Install {
    if (Exists7z) {
        if ([System.IO.Directory]::Exists("$(GetLibraryPath)")) {
            $url = CreateUri -version (GetRustVersion)
            $zip = [System.IO.Path]::GetFileName($url)
            $library = Join-Path (GetLibraryPath) 'library'
            $backup = Join-Path (GetLibraryPath) 'library_backup'
            try {
                Invoke-WebRequest -Uri $url -OutFile $zip
                Write-Host '[library]' -ForegroundColor Blue
                Write-Host "$library"
                # 备份
                Write-Host '[备份]' -ForegroundColor Blue
                Write-Host "$backup"
                Copy-Item -Recurse -Force "$library" "$backup"
                ExtractZip $zip "$(GetLibraryPath)"
                if ($LASTEXITCODE -eq 0) {
                    Write-Host '[删除]' -ForegroundColor Blue
                    Write-Host (Resolve-Path "$zip")
                    Remove-Item $zip
                }
            }
            catch {
                Write-Host "[下载失败]" -ForegroundColor Red
                Write-Host "$url"
            }
        }
        else {
            Write-Host "[找不到路径]" -ForegroundColor Red
            Write-Host (GetLibraryPath)
        }
    }
    else {
        Write-Host '需要7z'
    }

}

Install
