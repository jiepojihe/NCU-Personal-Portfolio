# ============================================================
#  一键脚本：setup-portfolio.ps1
#  作用：在你的本机网络通畅的环境下，一次跑完"装好 Git 后
#        从 init 到 push 的全部步骤"。
#  作者：冯禹馨（学号 6601126057）· 护理学
# ============================================================
#
#  使用方法（在 PowerShell 里执行）：
#     1) 先安装 Git：  https://git-scm.com/download/win
#     2) 登录 GitHub： https://github.com （浏览器）
#     3) 生成 Token：  https://github.com/settings/tokens/new
#                     勾选 repo 权限，保存好 token
#     4) 把本脚本放到 c:\Users\HP\Desktop\第五周\ 下
#     5) 右键本文件 → "使用 PowerShell 运行"
#        若被系统拦截，先执行：
#           Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#
# ============================================================

# ---------- 1) 配置区（请按需修改） ----------
$RepoName     = "NCU-Personal-Portfolio"
$RepoDesc     = "南昌大学 - 个人课程作品集（护理学 - 冯禹馨 - 6601126057）"
$Visibility   = "public"                              # public / private
$Branch       = "main"
$UserName     = "冯禹馨"
$UserEmail    = "6601126057@email.ncu.edu.cn"         # 改成你 GitHub 注册邮箱

# ---------- 2) 准备工作 ----------
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  南昌大学 - 个人作品集  一键初始化脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ---------- 3) 检查 Git ----------
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "[X] 没找到 git！请先安装：https://git-scm.com/download/win" -ForegroundColor Red
    pause; exit 1
}
Write-Host "[OK] git : $(git --version)" -ForegroundColor Green

# ---------- 4) 检查 gh（可选） ----------
$gh = Get-Command gh -ErrorAction SilentlyContinue
$useGh = $false
if ($gh) {
    Write-Host "[OK] gh  : $($(gh --version) -split "`n")[0]" -ForegroundColor Green
    $ghAuth = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) { $useGh = $true }
}

# ---------- 5) git init ----------
if (-not (Test-Path ".git")) {
    git init -b $Branch | Out-Null
    Write-Host "[OK] git init -b $Branch" -ForegroundColor Green
} else {
    Write-Host "[--] .git 已存在，跳过 init" -ForegroundColor DarkYellow
}

# ---------- 6) 配置身份 ----------
git config user.name  $UserName
git config user.email $UserEmail
Write-Host "[OK] user.name  = $UserName"    -ForegroundColor Green
Write-Host "[OK] user.email = $UserEmail"   -ForegroundColor Green

# ---------- 7) 首次 commit ----------
git add .
$staged = (git status --short) -join "`n"
if ($staged) {
    git commit -M "init: 创建个人作品集主仓库（16 周目录 + 文档）" | Out-Null
    Write-Host "[OK] 首次 commit 完成" -ForegroundColor Green
} else {
    Write-Host "[--] 没有新文件可提交（可能已提交过），跳过" -ForegroundColor DarkYellow
}

# ---------- 8) 远程仓库 ----------
$RemoteUrl = "https://github.com/$UserName/$RepoName.git"
if ($useGh) {
    # 走 gh（最丝滑）
    $flag = if ($Visibility -eq "public") { "--public" } else { "--private" }
    gh repo create $RepoName $flag --description $RepoDesc --source=. --remote=origin --push 2>&1 | ForEach-Object { Write-Host $_ }
    Write-Host "[OK] gh 已创建并 push" -ForegroundColor Green
} else {
    # 走 HTTPS + PAT
    Write-Host ""
    Write-Host "[>>] 请在浏览器打开 https://github.com/new  手动建一个空仓库：" -ForegroundColor Cyan
    Write-Host "     Repository name : $RepoName" -ForegroundColor White
    Write-Host "     Description     : $RepoDesc"  -ForegroundColor White
    Write-Host "     Visibility      : $Visibility" -ForegroundColor White
    Write-Host "     [!] 不要勾选 Add a README / .gitignore / license" -ForegroundColor Red
    Write-Host ""
    Read-Host "  仓库建好后，按回车继续"

    $ghUser = Read-Host "  请输入你的 GitHub 用户名"
    $pat    = Read-Host "  请输入 GitHub Personal Access Token（不会回显）" -AsSecureString
    $token  = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                  [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat))
    $RemoteUrl = "https://${ghUser}:${token}@github.com/${ghUser}/${RepoName}.git"

    git remote remove origin 2>$null
    git remote add origin $RemoteUrl
    git push -u origin $Branch
    Write-Host "[OK] push 完成" -ForegroundColor Green

    # 出于安全，移除凭据 URL
    $cleanUrl = "https://github.com/${ghUser}/${RepoName}.git"
    git remote set-url origin $cleanUrl
    Write-Host "[OK] 远端 URL 已清理为：$cleanUrl" -ForegroundColor Green
}

# ---------- 9) 最终汇报 ----------
$pubUrl = "https://github.com/$UserName/$RepoName"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  全部完成！" -ForegroundColor Green
Write-Host "  公开 URL ： $pubUrl" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "接下来每周："
Write-Host "  cd `"$PSScriptRoot`""
Write-Host "  git add ."
Write-Host "  git commit -M `"weekXX: 你的提交说明`""
Write-Host "  git push"
Write-Host ""
pause
