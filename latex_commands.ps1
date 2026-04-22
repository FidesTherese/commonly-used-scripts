# ==============================================================================
# latex_commands.ps1
# PowerShell version of latex_commands.zsh
#
# Usage:
#   . .\latex_commands.ps1
#   Invoke-LuaLaTeX   main.tex
#   Invoke-PdfLaTeX   main.tex --noclear
#   Invoke-XeLaTeX    main.tex
#   Invoke-PlatEx     main.tex
#   Invoke-UplatEx    main.tex
# ==============================================================================


# ------------------------------------------------------------------------------
# Global variables
# ------------------------------------------------------------------------------
$script:_TEX_FILTERED_ARGS = @()
$script:_TEX_NOCLEAR       = 0


# ------------------------------------------------------------------------------
# _TexParseArgs
# ------------------------------------------------------------------------------
function _TexParseArgs {
    $script:_TEX_NOCLEAR       = 0
    $script:_TEX_FILTERED_ARGS = @()

    foreach ($arg in $args) {
        if ($arg -eq '--noclear') {
            $script:_TEX_NOCLEAR = 1
        } else {
            $script:_TEX_FILTERED_ARGS += $arg
        }
    }
}


# ------------------------------------------------------------------------------
# _TexCleanup
# ------------------------------------------------------------------------------
function _TexCleanup {
    param(
        [int]      $ExitStatus,
        [string[]] $ExtraExtensions,
        [string[]] $RemainingArgs
    )

    $allExtensions = @('aux', 'log', 'out', 'toc') + $ExtraExtensions

    foreach ($arg in $RemainingArgs) {
        if ($arg -like '*.tex') {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($arg)
            foreach ($ext in $allExtensions) {
                $target = "${base}.${ext}"
                if (Test-Path $target) {
                    Remove-Item $target -Force
                }
            }
        }
    }

    return $ExitStatus
}


# ------------------------------------------------------------------------------
# _TexNormalizePath
#
# lualatex / pdflatex 等は絶対パスや ".\" プレフィックスを正しく扱えない。
# そのため:
#   - .tex ファイルの引数はファイル名のみに変換し、
#     カレントディレクトリを該当ファイルのディレクトリに一時変更して実行する。
#   - それ以外の引数 (オプションフラグ等) はそのまま渡す。
# ------------------------------------------------------------------------------
function _TexRun {
    param(
        [string]   $Compiler,
        [string[]] $FilteredArgs
    )

    # .tex ファイルを探して、そのディレクトリとファイル名を取得する
    $texFile  = $FilteredArgs | Where-Object { $_ -like '*.tex' } | Select-Object -First 1
    $otherArgs = $FilteredArgs | Where-Object { $_ -notlike '*.tex' }

    if ($texFile) {
        # 絶対パスに解決
        $absPath  = (Get-Item $texFile).FullName
        $dir      = Split-Path $absPath -Parent
        $fileName = Split-Path $absPath -Leaf

        # コンパイラはファイル名のみを受け取り、カレントディレクトリで実行
        Push-Location $dir
        try {
            & $Compiler @otherArgs $fileName
        } finally {
            Pop-Location
        }
    } else {
        # .tex ファイルがない場合はそのまま実行
        & $Compiler @FilteredArgs
    }
}


function Invoke-LuaLaTeX {
    _TexParseArgs @args
    _TexRun -Compiler 'lualatex' -FilteredArgs $script:_TEX_FILTERED_ARGS
    $exitStatus = $LASTEXITCODE
    if ($script:_TEX_NOCLEAR -eq 0) {
        _TexCleanup -ExitStatus $exitStatus `
                    -ExtraExtensions @('nav', 'snm') `
                    -RemainingArgs   $script:_TEX_FILTERED_ARGS | Out-Null
    }
    return $exitStatus
}

function Invoke-PdfLaTeX {
    _TexParseArgs @args
    _TexRun -Compiler 'pdflatex' -FilteredArgs $script:_TEX_FILTERED_ARGS
    $exitStatus = $LASTEXITCODE
    if ($script:_TEX_NOCLEAR -eq 0) {
        _TexCleanup -ExitStatus $exitStatus `
                    -ExtraExtensions @('nav', 'snm') `
                    -RemainingArgs   $script:_TEX_FILTERED_ARGS | Out-Null
    }
    return $exitStatus
}

function Invoke-XeLaTeX {
    _TexParseArgs @args
    _TexRun -Compiler 'xelatex' -FilteredArgs $script:_TEX_FILTERED_ARGS
    $exitStatus = $LASTEXITCODE
    if ($script:_TEX_NOCLEAR -eq 0) {
        _TexCleanup -ExitStatus $exitStatus `
                    -ExtraExtensions @('nav', 'snm') `
                    -RemainingArgs   $script:_TEX_FILTERED_ARGS | Out-Null
    }
    return $exitStatus
}

function Invoke-PlatEx {
    _TexParseArgs @args
    _TexRun -Compiler 'platex' -FilteredArgs $script:_TEX_FILTERED_ARGS
    $exitStatus = $LASTEXITCODE
    if ($script:_TEX_NOCLEAR -eq 0) {
        _TexCleanup -ExitStatus $exitStatus `
                    -ExtraExtensions @('nav', 'snm') `
                    -RemainingArgs   $script:_TEX_FILTERED_ARGS | Out-Null
    }
    return $exitStatus
}

function Invoke-UplatEx {
    _TexParseArgs @args
    _TexRun -Compiler 'uplatex' -FilteredArgs $script:_TEX_FILTERED_ARGS
    $exitStatus = $LASTEXITCODE
    if ($script:_TEX_NOCLEAR -eq 0) {
        _TexCleanup -ExitStatus $exitStatus `
                    -ExtraExtensions @('nav', 'snm') `
                    -RemainingArgs   $script:_TEX_FILTERED_ARGS | Out-Null
    }
    return $exitStatus
}