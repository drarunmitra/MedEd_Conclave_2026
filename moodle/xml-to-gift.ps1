# Convert the Moodle XML question banks in questions/ to GIFT format.
#
# Why this exists: the SARAL 2.0 instance (setfacilitysaral2.org) offers only
# Aiken, Blackboard, Cloze, GIFT, Missing word and MStar LSP XML on its question
# import screen — the core Moodle XML format plugin is not enabled. Confirmed
# 2026-08-14 on the import page for course 394.
#
# The XML files stay the source of truth. GIFT is derived, so the two cannot
# drift: re-run this after editing any XML.
#
#     pwsh -File moodle/xml-to-gift.ps1
#
# Output: questions/gift/*.txt, one per bank, ready for
# Question bank -> Import -> GIFT format.
#
# Two transformations are not cosmetic:
#
#  1. True/false questions are emitted as two-option multiple choice. GIFT's
#     {T#a#b} feedback syntax is documented ambiguously — whether the first
#     message belongs to the false response or to the wrong response depends on
#     which page you read — and getting it backwards would show a learner the
#     opposite message. Two-option multichoice makes the mapping explicit.
#
#  2. Newlines become <br>. A blank line terminates a GIFT question, and the
#     <pre><code> blocks in these banks contain them.

$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcDir = Join-Path $root 'questions'
$outDir = Join-Path $srcDir 'gift'

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

# GIFT reserves ~ = # { } : and \ . Backslash first, or it would double-escape
# the escapes added afterwards.
function ConvertTo-GiftText {
    param([string]$s)
    if ($null -eq $s) { return '' }
    $s = $s -replace '\\', '\\'
    $s = $s -replace '~', '\~'
    $s = $s -replace '=', '\='
    $s = $s -replace '#', '\#'
    $s = $s -replace '\{', '\{'
    $s = $s -replace '\}', '\}'
    $s = $s -replace ':', '\:'
    # A blank line ends a GIFT question; keep the visual line break instead.
    $s = $s -replace "`r`n", '<br>'
    $s = $s -replace "`n", '<br>'
    return $s.Trim()
}

$summary = @()

foreach ($f in (Get-ChildItem (Join-Path $srcDir '*.xml') | Sort-Object Name)) {
    $x  = [xml](Get-Content -Raw -Encoding UTF8 $f.FullName)
    $qs = @($x.quiz.question)

    $cat = @($qs | Where-Object { $_.type -eq 'category' })[0].category.InnerText
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add("// Generated from $($f.Name) by moodle/xml-to-gift.ps1 - do not edit by hand.")
    $out.Add("// Import with: Question bank -> Import -> GIFT format.")
    $out.Add('')
    $out.Add('$CATEGORY: ' + $cat)
    $out.Add('')

    $n = 0
    foreach ($q in ($qs | Where-Object { $_.type -ne 'category' })) {
        $n++
        $name = ConvertTo-GiftText ([string]$q.name.InnerText)
        $text = ConvertTo-GiftText ([string]$q.questiontext.InnerText)
        $gfb  = ConvertTo-GiftText ([string]$q.generalfeedback.InnerText)

        $out.Add("// question: $n")
        $out.Add("::${name}::[html]${text}{")

        foreach ($a in @($q.answer)) {
            $atxt = [string]$a.text.InnerText
            # truefalse answers arrive as the bare words true/false
            if ($q.type -eq 'truefalse') {
                $atxt = if ($atxt.Trim().ToLower() -eq 'true') { '<p>True</p>' } else { '<p>False</p>' }
            }
            $marker = if ($a.fraction -eq '100') { '=' } else { '~' }
            $ans = ConvertTo-GiftText $atxt
            $fb  = ConvertTo-GiftText ([string]$a.feedback.InnerText)
            $out.Add("${marker}[html]${ans}#[html]${fb}")
        }

        $out.Add("####[html]${gfb}")
        $out.Add('}')
        $out.Add('')
    }

    $dest = Join-Path $outDir ($f.BaseName + '.txt')
    # UTF-8 without BOM: Moodle's GIFT importer reads a BOM as part of the first
    # question's name.
    [System.IO.File]::WriteAllText($dest, ($out -join "`r`n"), (New-Object System.Text.UTF8Encoding($false)))
    $summary += [pscustomobject]@{ Bank = $f.BaseName; Questions = $n; Category = $cat }
}

$summary | Format-Table -AutoSize
"Total questions: {0}" -f ($summary | Measure-Object -Property Questions -Sum).Sum
"Written to: $outDir"
