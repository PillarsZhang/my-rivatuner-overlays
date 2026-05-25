param(
    [string] $TemplatePath = (Join-Path $PSScriptRoot 'my.template.ovl'),
    [string] $OutputPath = (Join-Path $PSScriptRoot 'my.ovl'),
    [int] $Size = 8,
    [double] $Opacity = 0.75
)

# Multiplies every role opacity below. 1.0 keeps the palette as authored.
if ($Opacity -gt 1.0) {
    $Opacity = $Opacity / 100.0
}

# Master settings written into the generated overlay.
$FontFace = 'Consolas'
$FontHeight = -[Math]::Abs($Size)
$FontWeight = 700
$ZoomRatio = 2.0
$FullWidth = -18
$PingAddress = '223.5.5.5'

# Keep RTSS' temperature unit out of the template's ASCII placeholders.
$TemperatureUnit = ([char] 0x00B0) + 'C'

$Palette = @{
    Primary = 'FFFFFF'
    Body = 'D6DEE8'
    Label = '9EA7B3'
    Title = 'F3F3F3'
    Metadata = '8A98A8'
    Detail = 'B8C7D9'
    Accent = '60CDFF'
    Network = '8FBED6'
    Warning = 'FF6B6B'
    GraphFill = '4F6B88'
}

$RoleOpacity = @{
    Primary = 1.0
    Body = 1.0
    Label = 1.0
    Title = 1.0
    Metadata = 1.0
    Detail = 1.0
    Accent = 1.0
    Network = 1.0
    Warning = 1.0
    GraphFill = 0.14
    GraphLine = 0.50
    FrametimeGraph = 160 / 255
}

function ConvertTo-RtssColor {
    param(
        [Parameter(Mandatory)]
        [string] $Rgb,
        [Parameter(Mandatory)]
        [double] $RoleAlpha
    )

    if ($Rgb -notmatch '^[0-9A-Fa-f]{6}$') {
        throw "RGB color '$Rgb' must use six hexadecimal digits."
    }

    $alpha = [Math]::Clamp($Opacity * $RoleAlpha, 0.0, 1.0)
    $alphaByte = [int] [Math]::Round($alpha * 255)
    $normalizedRgb = $Rgb.ToUpperInvariant()

    if ($alphaByte -eq 255) {
        return $normalizedRgb
    }

    return ('{0:X2}{1}' -f $alphaByte, $normalizedRgb)
}

$replacements = @{
    '{{FONT_FACE}}' = $FontFace
    '{{FONT_HEIGHT}}' = $FontHeight.ToString()
    '{{FONT_WEIGHT}}' = $FontWeight.ToString()
    '{{ZOOM_RATIO}}' = $ZoomRatio.ToString()
    '{{FULL_WIDTH}}' = $FullWidth.ToString()
    '{{PING_ADDRESS}}' = $PingAddress
    '{{TEMP_UNIT}}' = $TemperatureUnit
    '{{COLOR_PRIMARY}}' = ConvertTo-RtssColor -Rgb $Palette.Primary -RoleAlpha $RoleOpacity.Primary
    '{{COLOR_BODY}}' = ConvertTo-RtssColor -Rgb $Palette.Body -RoleAlpha $RoleOpacity.Body
    '{{COLOR_LABEL}}' = ConvertTo-RtssColor -Rgb $Palette.Label -RoleAlpha $RoleOpacity.Label
    '{{COLOR_TITLE}}' = ConvertTo-RtssColor -Rgb $Palette.Title -RoleAlpha $RoleOpacity.Title
    '{{COLOR_METADATA}}' = ConvertTo-RtssColor -Rgb $Palette.Metadata -RoleAlpha $RoleOpacity.Metadata
    '{{COLOR_DETAIL}}' = ConvertTo-RtssColor -Rgb $Palette.Detail -RoleAlpha $RoleOpacity.Detail
    '{{COLOR_ACCENT}}' = ConvertTo-RtssColor -Rgb $Palette.Accent -RoleAlpha $RoleOpacity.Accent
    '{{COLOR_NETWORK}}' = ConvertTo-RtssColor -Rgb $Palette.Network -RoleAlpha $RoleOpacity.Network
    '{{COLOR_WARNING}}' = ConvertTo-RtssColor -Rgb $Palette.Warning -RoleAlpha $RoleOpacity.Warning
    '{{COLOR_GRAPH_FILL}}' = ConvertTo-RtssColor -Rgb $Palette.GraphFill -RoleAlpha $RoleOpacity.GraphFill
    '{{COLOR_GRAPH_LINE}}' = ConvertTo-RtssColor -Rgb $Palette.Accent -RoleAlpha $RoleOpacity.GraphLine
    '{{COLOR_FRAMETIME_GRAPH}}' = ConvertTo-RtssColor -Rgb $Palette.Accent -RoleAlpha $RoleOpacity.FrametimeGraph
}

# Preserve RTSS' single-byte overlay symbols such as the degree sign byte.
$encoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$overlay = [System.IO.File]::ReadAllText($TemplatePath, $encoding)

foreach ($entry in $replacements.GetEnumerator()) {
    $overlay = $overlay.Replace($entry.Key, $entry.Value)
}

$unresolved = [regex]::Matches($overlay, '\{\{[^}]+\}\}') |
    ForEach-Object { $_.Value } |
    Sort-Object -Unique

if ($unresolved) {
    throw "Unresolved template tokens: $($unresolved -join ', ')"
}

[System.IO.File]::WriteAllText($OutputPath, $overlay, $encoding)
Write-Host "Generated $OutputPath from $TemplatePath"
