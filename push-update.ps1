# ============================================================
#  push-update.ps1  ——  把本次新增/修改的文件推送上去
#  用法：右键本文件 →「使用 PowerShell 运行」
#  作者：冯禹馨（6601126057）· 护理学
# ============================================================

# 让脚本自动切到它自己所在的文件夹（无论从哪里双击）
Set-Location -Path $PSScriptRoot

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  把最新改动推送到 GitHub               " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ---------- 0) 检查 git ----------
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "[X] 没找到 git！" -ForegroundColor Red
    Write-Host "    请先安装：https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "    装完记得关掉所有 PowerShell 窗口，重新打开再运行本脚本。" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 1
}
Write-Host "[OK] git : $(git --version)" -ForegroundColor Green

# ---------- 1) 检查是不是 git 仓库 ----------
if (-not (Test-Path ".git")) {
    Write-Host "[X] 当前文件夹还不是 git 仓库（没有 .git 目录）" -ForegroundColor Red
    Write-Host "    说明之前那一步 git init 没成功，请先联系我。" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 1
}

# ---------- 2) 检查有没有配 remote ----------
$remote = git remote -v
if (-not $remote) {
    Write-Host "[X] 没有绑定远程仓库地址（git remote 为空）" -ForegroundColor Red
    Write-Host "    请先执行：git remote add origin https://github.com/冯禹馨/NCU-Personal-Portfolio.git" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 1
}
Write-Host "[OK] 远程仓库：" -ForegroundColor Green
$remote | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }

# ---------- 3) 当前分支名 ----------
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
Write-Host "[OK] 当前分支：$branch" -ForegroundColor Green

# ---------- 4) 查看有没有改动 ----------
Write-Host ""
Write-Host "[1/3] 扫描改动 ..." -ForegroundColor Yellow
git add .
$staged = (git status --porcelain)
if (-not $staged) {
    Write-Host "      没有新改动，可能已经推过了。" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  打开看看：https://github.com/冯禹馨/NCU-Personal-Portfolio" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}
Write-Host "      发现以下改动：" -ForegroundColor Green
$staged | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }

# ---------- 5) commit ----------
Write-Host ""
Write-Host "[2/3] 创建提交 ..." -ForegroundColor Yellow
$defaultMsg = "feat: 补全 16 周实验模板 + License + 贡献指南 + Issue/PR 模板"
$msg = Read-Host "      提交说明（直接回车用默认：$defaultMsg）"
if ([string]::IsNullOrWhiteSpace($msg)) { $msg = $defaultMsg }
git commit -m "$msg" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "      [X] 提交失败，见上方报错。" -ForegroundColor Red
    Read-Host "按回车键退出"; exit 1
}
Write-Host "      [OK] 提交成功" -ForegroundColor Green

# ---------- 6) push ----------
Write-Host ""
Write-Host "[3/3] 推送到 GitHub ..." -ForegroundColor Yellow
git push -u origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "      [X] 推送失败，见上方报错。" -ForegroundColor Red
    Write-Host "      常见原因：网络不通 / 未登录 GitHub / 需要重新授权" -ForegroundColor Yellow
    Read-Host "按回车键退出"; exit 1
}

# ---------- 7) 完成 ----------
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ALL DONE  全部完成！                   " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  打开仓库查看：https://github.com/冯禹馨/NCU-Personal-Portfolio" -ForegroundColor Cyan
Write-Host ""
Read-Host "按回车键退出"
