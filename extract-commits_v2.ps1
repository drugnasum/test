<#
.SYNOPSIS
    抽取指定用户在指定 git repo、指定 Branch 中每次 commit 的 diff 文件及每个文件的追加/变更/删除行数和 commit 信息
.PARAMETER RepoPath
    Git 仓库的本地路径
.PARAMETER Branch
    目标分支名
.PARAMETER Author
    作者匹配字符串 (支持 git log --author 的语法，如名字或邮箱片段)
.PARAMETER Format
    输出格式: Json (默认) | Text
.PARAMETER OutputPath
    输出文件路径 (默认: 当前目录下的 output.json)
.PARAMETER Since
    起始日期 (可选)，格式如 "2024-01-01"
.PARAMETER Until
    截止日期 (可选)，格式如 "2024-12-31"
.EXAMPLE
    .\extract-commits.ps1 -RepoPath "C:\my-repo" -Branch main -Author "zhangsan"
.EXAMPLE
    .\extract-commits.ps1 -RepoPath "C:\my-repo" -Branch develop -Author "lisi" -Format Text -Since "2024-01-01"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$RepoPath,

    [Parameter(Mandatory = $true)]
    [string]$Branch,

    [Parameter(Mandatory = $true)]
    [string]$Author,

    [ValidateSet("Text", "Json")]
    [string]$Format = "Json",

    [string]$OutputPath = (Join-Path (Get-Location) "output.json"),

    [string]$Since,

    [string]$Until
)

$ErrorActionPreference = "Stop"

# ---------- 验证 ----------
if (-not (Test-Path -LiteralPath $RepoPath)) {
    Write-Error "仓库路径不存在: $RepoPath"
    exit 1
}

$originalLocation = Get-Location
try {
    Set-Location -LiteralPath $RepoPath

    # 检查是否是有效的 git repo
    $isRepo = git rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "不是有效的 Git 仓库: $RepoPath"
        exit 1
    }

    # ---------- 构建 git log 参数 ----------
    $logArgs = @("log", "--reverse", "--author=$Author", $Branch)
    if ($Since) { $logArgs += "--since=$Since" }
    if ($Until) { $logArgs += "--until=$Until" }

    # 获取该分支上由指定 Author 提交的所有 commit hash
    $commitHashes = & git @logArgs --format="%H"
    if (-not $commitHashes -or $commitHashes.Count -eq 0) {
        Write-Host "未找到匹配的 commit (Branch: $Branch, Author: $Author)"
        exit 0
    }

    # 空树 hash，用于处理 root commit
    $emptyTree = "4b825dc642cb6eb9a060e54bf899d9b8b0718c2b"

    # ---------- 结果收集 ----------
    $allCommits = @()

    foreach ($hash in $commitHashes) {
        $hash = $hash.Trim()
        if ([string]::IsNullOrEmpty($hash)) { continue }

        # 获取 commit 元信息
        $commitInfo = & git log -1 --format="%H|%an|%ae|%ad|%s" --date=iso $hash
        $parts = $commitInfo -split '\|', 5
        $fullHash    = $parts[0]
        $authorName  = $parts[1]
        $authorEmail = $parts[2]
        $date        = $parts[3]
        $subject     = $parts[4]

        # 获取 commit body (完整 message)
        $body = & git log -1 --format="%b" $hash

        # 判断是否为 merge commit
        $parentCount = (& git rev-list --count --parents -n 1 $hash | ForEach-Object { ($_ -split ' ').Count - 1 })
        $isMerge = $parentCount -ge 2

        # ---------- 获取文件级 diff 统计 ----------
        $files = @()

        if ($isMerge) {
            # merge commit: 使用 git diff-tree 读取与第一个 parent 的差异
            $rawDiff = & git diff-tree --no-commit-id -r --numstat $hash 2>$null
            if (-not $rawDiff) {
                # merge commit 没有额外改动（fast-forward 可能性）
            }
            else {
                foreach ($line in $rawDiff) {
                    if ($line -match '^(\d+)\s+(\d+)\s+(.+)$') {
                        $a = [int]$Matches[1]
                        $d = [int]$Matches[2]
                        $f = $Matches[3]
                        $files += @{ File = $f; Added = $a; Deleted = $d; Modified = [Math]::Min($a, $d) }
                    }
                }
            }
        }
        else {
            # 普通 commit
            # 先尝试 diff 到 parent
            $numstat = & git diff $hash~1 $hash --numstat 2>$null
            if ($LASTEXITCODE -ne 0 -or -not $numstat) {
                # root commit: 和空树比较
                $numstat = & git diff --numstat $emptyTree $hash 2>$null
            }
            if ($numstat) {
                foreach ($line in $numstat) {
                    if ($line -match '^(\d+)\s+(\d+)\s+(.+)$') {
                        $a = [int]$Matches[1]
                        $d = [int]$Matches[2]
                        $f = $Matches[3]
                        $files += @{ File = $f; Added = $a; Deleted = $d; Modified = [Math]::Min($a, $d) }
                    }
                }
            }

            # 处理二进制文件 (numstat 显示 -  -  )
            $binFiles = & git diff $hash~1 $hash --stat --diff-filter=A 2>$null | Select-String 'Bin'
            if (-not $binFiles) {
                $binFiles = & git show --stat --diff-filter=A --format="" $hash 2>$null | Select-String 'Bin'
            }
        }

        # ---------- 汇总 ----------
        $totalAdded    = ($files | ForEach-Object { $_.Added } | Measure-Object -Sum).Sum
        $totalDeleted  = ($files | ForEach-Object { $_.Deleted } | Measure-Object -Sum).Sum
        $totalModified = [Math]::Min($totalAdded, $totalDeleted)

        $commitObj = [PSCustomObject]@{
            Hash         = $fullHash
            AuthorName   = $authorName
            AuthorEmail  = $authorEmail
            Date         = $date
            Subject      = $subject
            Body         = $body
            IsMerge      = $isMerge
            TotalAdded   = $totalAdded
            TotalDeleted = $totalDeleted
            TotalModified = $totalModified
            Files        = $files
        }

        $allCommits += $commitObj
    }

    # ---------- 输出 ----------
    $jsonPayload = $allCommits | ForEach-Object {
        [PSCustomObject]@{
            hash          = $_.Hash
            authorName    = $_.AuthorName
            authorEmail   = $_.AuthorEmail
            date          = $_.Date
            subject       = $_.Subject
            body          = $_.Body
            isMerge       = $_.IsMerge
            totalAdded    = $_.TotalAdded
            totalDeleted  = $_.TotalDeleted
            totalModified = $_.TotalModified
            files         = @($_.Files | ForEach-Object {
                [PSCustomObject]@{
                    file     = $_.File
                    added    = $_.Added
                    deleted  = $_.Deleted
                    modified = $_.Modified
                }
            })
        }
    } | ConvertTo-Json -Depth 5

    if ($Format -eq "Json") {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($OutputPath, $jsonPayload, $utf8NoBom)
        Write-Host "已输出至: $OutputPath"
        Write-Host "共 $($allCommits.Count) 个 commit (Author: $Author, Branch: $Branch)"
    }
    else {
        # Text 格式
        $index = 0
        foreach ($c in $allCommits) {
            $index++
            Write-Host ("=" * 80)
            Write-Host "[$index / $($allCommits.Count)]"
            Write-Host "Commit    : $($c.Hash)"
            Write-Host "Author    : $($c.AuthorName) <$($c.AuthorEmail)>"
            Write-Host "Date      : $($c.Date)"
            if ($c.IsMerge) { Write-Host "Type      : Merge Commit" }
            Write-Host "Message   : $($c.Subject)"
            if ($c.Body) {
                $c.Body -split "`n" | ForEach-Object { Write-Host "            $_" }
            }
            Write-Host ""

            if ($c.Files.Count -eq 0) {
                Write-Host "  (No file changes)"
            }
            else {
                Write-Host ("{0,-6} {1,-6} {2,-6}   {3}" -f "Added", "Mod.", "Del.", "File")
                Write-Host ("{0,-6} {1,-6} {2,-6}   {3}" -f "-----", "-----", "-----", "----")
                foreach ($f in $c.Files) {
                    Write-Host ("+{0,-5} ~{1,-5} -{2,-5}  {3}" -f $f.Added, $f.Modified, $f.Deleted, $f.File)
                }
                Write-Host ("{0,-6} {1,-6} {2,-6}   {3}" -f "-----", "-----", "-----", "----")
                Write-Host ("+{0,-5} ~{1,-5} -{2,-5}  (total)" -f $c.TotalAdded, $c.TotalModified, $c.TotalDeleted)
            }
            Write-Host ""
        }

        Write-Host ("=" * 80)
        Write-Host "共 $($allCommits.Count) 个 commit for '$Author' on branch '$Branch'"
    }
}
finally {
    Set-Location -LiteralPath $originalLocation
}
