<#
.SYNOPSIS
  Interface para instalar, via winget, as aplicações das máquinas Nix que
  existem no Windows.

.DESCRIPTION
  Abre uma janela com as aplicações agrupadas por categoria (espelhando os
  aspects de modules/aspects). Marque as desejadas e clique em "Instalar".

  Use -DryRun para apenas mostrar os comandos sem executá-los.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\system_setup.ps1
#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --------------------------------------------------------------------------
# Catálogo: Categoria | Nome | Id no winget | Aspect de origem | Padrão marcado
# Itens do Nix sem versão Windows (ghostty, kitty, tmux, niri, remmina, ...)
# foram omitidos. Confira um ID com: winget search <nome>
# --------------------------------------------------------------------------
$Catalog = @(
    # Navegadores (desktop/browsers.nix)
    @{ Cat = 'Navegadores'; Name = 'Firefox';           Id = 'Mozilla.Firefox';                Default = $true }
    @{ Cat = 'Navegadores'; Name = 'Google Chrome';     Id = 'Google.Chrome';                  Default = $true }
    @{ Cat = 'Navegadores'; Name = 'Vivaldi';           Id = 'Vivaldi.Vivaldi';                Default = $false }
    @{ Cat = 'Navegadores'; Name = 'Firefox PWA';       Id = 'filips.FirefoxPWA';              Default = $false }

    # Escritório (desktop/office.nix)
    @{ Cat = 'Escritório'; Name = 'LibreOffice';        Id = 'TheDocumentFoundation.LibreOffice'; Default = $true }
    @{ Cat = 'Escritório'; Name = 'Obsidian';           Id = 'Obsidian.Obsidian';              Default = $true }
    @{ Cat = 'Escritório'; Name = 'Microsoft Teams';    Id = 'Microsoft.Teams';                Default = $false }
    @{ Cat = 'Escritório'; Name = 'Calibre';            Id = 'calibre.calibre';                Default = $false }
    @{ Cat = 'Escritório'; Name = 'Okular';             Id = 'KDE.Okular';                     Default = $false }
    @{ Cat = 'Escritório'; Name = 'SpeedCrunch';        Id = 'SpeedCrunch.SpeedCrunch';        Default = $false }
    @{ Cat = 'Escritório'; Name = 'draw.io';            Id = 'JGraph.Draw';                    Default = $false }
    @{ Cat = 'Escritório'; Name = 'OBS Studio';         Id = 'OBSProject.OBSStudio';           Default = $false }
    @{ Cat = 'Escritório'; Name = 'pCloud Drive';       Id = 'pCloudAG.pCloudDrive';           Default = $false }

    # Desktop (desktop/desktop.nix)
    @{ Cat = 'Desktop'; Name = 'LocalSend';             Id = 'LocalSend.LocalSend';            Default = $true }
    @{ Cat = 'Desktop'; Name = 'CopyQ';                 Id = 'hluk.CopyQ';                     Default = $true }
    @{ Cat = 'Desktop'; Name = 'Visual Studio Code';    Id = 'Microsoft.VisualStudioCode';     Default = $true }
    @{ Cat = 'Desktop'; Name = 'DBeaver';               Id = 'DBeaver.DBeaver.Community';      Default = $false }
    @{ Cat = 'Desktop'; Name = 'Meld';                  Id = 'Meld.Meld';                      Default = $false }
    @{ Cat = 'Desktop'; Name = 'Proton VPN';            Id = 'Proton.ProtonVPN';               Default = $false }
    @{ Cat = 'Desktop'; Name = 'GIMP';                  Id = 'GIMP.GIMP.3';                    Default = $false }
    @{ Cat = 'Desktop'; Name = 'Inkscape';              Id = 'Inkscape.Inkscape';              Default = $false }
    @{ Cat = 'Desktop'; Name = 'Pinta';                 Id = 'Pinta.Pinta';                    Default = $false }
    @{ Cat = 'Desktop'; Name = 'darktable';             Id = 'darktable.darktable';            Default = $false }
    @{ Cat = 'Desktop'; Name = 'Scribus';               Id = 'Scribus.Scribus';                Default = $false }
    @{ Cat = 'Desktop'; Name = 'Kdenlive';              Id = 'KDE.Kdenlive';                   Default = $false }
    @{ Cat = 'Desktop'; Name = 'Emacs';                 Id = 'GNU.Emacs';                      Default = $false }

    # CLI (cli/cli-base.nix, cli/cli-tools.nix, cli/neovim.nix, cli/starship.nix)
    @{ Cat = 'CLI'; Name = 'Git';                       Id = 'Git.Git';                        Default = $true }
    @{ Cat = 'CLI'; Name = 'PowerShell 7';              Id = 'Microsoft.PowerShell';           Default = $true }
    @{ Cat = 'CLI'; Name = 'Neovim';                    Id = 'Neovim.Neovim';                  Default = $true }
    @{ Cat = 'CLI'; Name = 'Starship';                  Id = 'Starship.Starship';              Default = $true }
    @{ Cat = 'CLI'; Name = 'GitHub CLI (gh)';           Id = 'GitHub.cli';                     Default = $true }
    @{ Cat = 'CLI'; Name = 'lazygit';                   Id = 'JesseDuffield.lazygit';          Default = $true }
    @{ Cat = 'CLI'; Name = 'ripgrep';                   Id = 'BurntSushi.ripgrep.MSVC';        Default = $true }
    @{ Cat = 'CLI'; Name = 'fd';                        Id = 'sharkdp.fd';                     Default = $true }
    @{ Cat = 'CLI'; Name = 'fzf';                       Id = 'junegunn.fzf';                   Default = $true }
    @{ Cat = 'CLI'; Name = 'zoxide';                    Id = 'ajeetdsouza.zoxide';             Default = $true }
    @{ Cat = 'CLI'; Name = 'eza';                       Id = 'eza-community.eza';              Default = $false }
    @{ Cat = 'CLI'; Name = 'btop';                      Id = 'aristocratos.btop4win';          Default = $false }
    @{ Cat = 'CLI'; Name = 'fastfetch';                 Id = 'Fastfetch-cli.Fastfetch';        Default = $false }
    @{ Cat = 'CLI'; Name = 'ffmpeg';                    Id = 'Gyan.FFmpeg';                    Default = $false }
    @{ Cat = 'CLI'; Name = 'ImageMagick';               Id = 'ImageMagick.ImageMagick';        Default = $false }
    @{ Cat = 'CLI'; Name = 'rclone';                    Id = 'Rclone.Rclone';                  Default = $false }
    @{ Cat = 'CLI'; Name = 'Bitwarden CLI';             Id = 'Bitwarden.CLI';                  Default = $false }
    @{ Cat = 'CLI'; Name = 'tldr (tlrc)';               Id = 'tldr-pages.tlrc';                Default = $false }
    @{ Cat = 'CLI'; Name = 'wget';                      Id = 'JernejSimoncic.Wget';            Default = $false }
    @{ Cat = 'CLI'; Name = 'Node.js LTS';               Id = 'OpenJS.NodeJS.LTS';              Default = $false }
    @{ Cat = 'CLI'; Name = 'lua-language-server';       Id = 'LuaLS.lua-language-server';      Default = $false }
    @{ Cat = 'CLI'; Name = 'Podman';                    Id = 'RedHat.Podman';                  Default = $false }

    # Agentes de IA (ai/agents.nix)
    @{ Cat = 'Agentes de IA'; Name = 'Claude Desktop';  Id = 'Anthropic.Claude';               Default = $false }
    @{ Cat = 'Agentes de IA'; Name = 'Claude Code';     Id = 'Anthropic.ClaudeCode';           Default = $false }
    @{ Cat = 'Agentes de IA'; Name = 'opencode';        Id = 'SST.opencode';                   Default = $false }

    # Fontes (desktop/terminals.nix)
    @{ Cat = 'Fontes'; Name = 'JetBrainsMono Nerd Font'; Id = 'DEVCOM.JetBrainsMonoNerdFont';  Default = $true }
)

function Test-Winget {
    [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

if (-not (Test-Winget)) {
    Write-Error 'winget não encontrado. Instale o "App Installer" pela Microsoft Store.'
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ----------------------------- Interface ----------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = 'System Setup - aplicações do nix-config'
$form.Size = New-Object System.Drawing.Size(760, 720)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

$list = New-Object System.Windows.Forms.ListView
$list.View = 'Details'
$list.CheckBoxes = $true
$list.FullRowSelect = $true
$list.ShowGroups = $true
$list.HeaderStyle = 'Nonclickable'
$list.Location = New-Object System.Drawing.Point(10, 10)
$list.Size = New-Object System.Drawing.Size(724, 400)
$list.Anchor = 'Top, Left, Right, Bottom'
[void]$list.Columns.Add('Aplicação', 280)
[void]$list.Columns.Add('Id winget', 400)

$groups = @{}
foreach ($app in $Catalog) {
    if (-not $groups.ContainsKey($app.Cat)) {
        $g = New-Object System.Windows.Forms.ListViewGroup($app.Cat, $app.Cat)
        $groups[$app.Cat] = $g
        [void]$list.Groups.Add($g)
    }
    $item = New-Object System.Windows.Forms.ListViewItem($app.Name)
    [void]$item.SubItems.Add($app.Id)
    $item.Group = $groups[$app.Cat]
    $item.Checked = [bool]$app.Default
    $item.Tag = $app
    [void]$list.Items.Add($item)
}
$form.Controls.Add($list)

function New-Button($text, $x, $w = 110) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Location = New-Object System.Drawing.Point($x, 420)
    $b.Size = New-Object System.Drawing.Size($w, 30)
    $b.Anchor = 'Bottom, Left'
    $form.Controls.Add($b)
    $b
}

$btnAll = New-Button 'Marcar todos' 10
$btnNone = New-Button 'Desmarcar todos' 130 120
$btnDefault = New-Button 'Padrão' 260 80
$btnInstall = New-Button 'Instalar' 624 110
$btnInstall.Anchor = 'Bottom, Right'
$btnInstall.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(10, 460)
$progress.Size = New-Object System.Drawing.Size(724, 18)
$progress.Anchor = 'Bottom, Left, Right'
$form.Controls.Add($progress)

$log = New-Object System.Windows.Forms.TextBox
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = 'Vertical'
$log.Font = New-Object System.Drawing.Font('Consolas', 9)
$log.Location = New-Object System.Drawing.Point(10, 488)
$log.Size = New-Object System.Drawing.Size(724, 185)
$log.Anchor = 'Bottom, Left, Right'
$form.Controls.Add($log)

function Write-Log($msg) {
    $log.AppendText("$msg`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

$btnAll.Add_Click({ foreach ($i in $list.Items) { $i.Checked = $true } })
$btnNone.Add_Click({ foreach ($i in $list.Items) { $i.Checked = $false } })
$btnDefault.Add_Click({ foreach ($i in $list.Items) { $i.Checked = [bool]$i.Tag.Default } })

$btnInstall.Add_Click({
    $selected = @($list.CheckedItems | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        [void][System.Windows.Forms.MessageBox]::Show('Nada marcado.', 'System Setup')
        return
    }

    foreach ($c in @($btnAll, $btnNone, $btnDefault, $btnInstall, $list)) { $c.Enabled = $false }
    $progress.Maximum = $selected.Count
    $progress.Value = 0
    $ok = @(); $skipped = @(); $failed = @()

    foreach ($app in $selected) {
        Write-Log "==> $($app.Name) ($($app.Id))"
        $wingetArgs = @(
            'install', '--id', $app.Id, '--exact', '--silent',
            '--accept-package-agreements', '--accept-source-agreements'
        )
        if ($DryRun) {
            Write-Log "    [dry-run] winget $($wingetArgs -join ' ')"
            $ok += $app.Name
        }
        else {
            $out = & winget @wingetArgs 2>&1 | Out-String
            $code = $LASTEXITCODE
            # 0x8A150061 = já instalado / sem atualização aplicável
            if ($code -eq 0) { Write-Log '    instalado'; $ok += $app.Name }
            elseif ($code -eq -1978335189 -or $out -match 'already installed|Found an existing package') {
                Write-Log '    já instalado'; $skipped += $app.Name
            }
            else {
                Write-Log "    FALHOU (código $code)"
                Write-Log ($out.Trim() -split "`r?`n" | Select-Object -Last 3 | ForEach-Object { "    $_" } | Out-String).TrimEnd()
                $failed += $app.Name
            }
        }
        $progress.Value++
        [System.Windows.Forms.Application]::DoEvents()
    }

    Write-Log ''
    Write-Log "Concluído: $($ok.Count) instalados, $($skipped.Count) já presentes, $($failed.Count) falhas."
    if ($failed.Count) { Write-Log "Falhas: $($failed -join ', ')" }
    foreach ($c in @($btnAll, $btnNone, $btnDefault, $btnInstall, $list)) { $c.Enabled = $true }
})

[void]$form.ShowDialog()
