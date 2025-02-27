# init_project.ps1
# FX閾ｪ蜍募｣ｲ雋ｷEA繝励Ο繧ｸ繧ｧ繧ｯ繝医ｒ蛻晄悄蛹悶☆繧輝owerShell繧ｹ繧ｯ繝ｪ繝励ヨ

# 繧ｹ繧ｯ繝ｪ繝励ヨ縺ｮ繝・ぅ繝ｬ繧ｯ繝医Μ繧貞叙蠕・
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupScript = Join-Path $scriptPath "setup_project.ps1"

# 繝励Ο繧ｸ繧ｧ繧ｯ繝医・蛻晄悄蛹悶Γ繝・そ繝ｼ繧ｸ繧定｡ｨ遉ｺ
Write-Host "FX閾ｪ蜍募｣ｲ雋ｷEA繝励Ο繧ｸ繧ｧ繧ｯ繝医ｒ蛻晄悄蛹悶＠縺ｾ縺・.." -ForegroundColor Cyan

# setup_project.ps1繧貞ｮ溯｡・
if (Test-Path $setupScript) {
    & $setupScript
} else {
    Write-Host "繧ｻ繝・ヨ繧｢繝・・繧ｹ繧ｯ繝ｪ繝励ヨ ($setupScript) 縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縲・ -ForegroundColor Red
}

# 谺｡縺ｮ繧ｹ繝・ャ繝励・譯亥・
Write-Host ""
Write-Host "谺｡縺ｮ繧ｹ繝・ャ繝・" -ForegroundColor Yellow
Write-Host "1. EA繧偵さ繝ｳ繝代う繝ｫ縺吶ｋ: compile_ea.ps1" -ForegroundColor Yellow
Write-Host "2. EA繧樽T4縺ｫ繧､繝ｳ繧ｹ繝医・繝ｫ縺吶ｋ: install_to_mt4.ps1" -ForegroundColor Yellow
Write-Host ""

# 荳譎ょ●豁｢
Read-Host "菴輔°繧ｭ繝ｼ繧呈款縺励※邨ゆｺ・＠縺ｦ縺上□縺輔＞..."
