# My RivaTuner Overlays

Personal RTSS / RivaTuner Statistics Server overlay layouts generated from a template.

Chinese version: [README.md](README.md)

## Examples

`my.ovl` (HDR)

![Genshin Impact example](docs/images/example-my-yuanshen.png)

![Euro Truck Simulator 2 example](docs/images/example-my-eurotrucks2.png)

`my.ovl` (SDR)

![SDR example](docs/images/example-my-sdr.png)

`my-opacity100.ovl` (HDR)

![Opaque version example](docs/images/example-my-opacity100.png)

## Notes

- My layout is tuned for a 4K screen, so other resolutions or scaling ratios may need manual adjustment.
- This layout does not require MSI Afterburner, but it likely requires [RTSS 7.3.7 or later](https://www.guru3d.com/download/rtss-rivatuner-statistics-server-download/).
- Data source compatibility is not handled; this layout currently only depends on RTSS' built-in internal HAL.
- Low FPS statistics require `Enable benchmark mode` in RTSS settings and `Percentile buffer` set to `ring`.
- `RTT` is the latency from pinging `223.5.5.5` (Alibaba Cloud public DNS); it shows a red `999` when disconnected, so users outside China should adjust it as needed.

## Usage

You can directly use `my.ovl`, `my-size10-opacity75.ovl`, or `my-opacity100.ovl`.

If you want to change the size or opacity, regenerate the layout:

Generate the default version:

```powershell
pwsh -File .\my.palette.ps1
```

Generate a version with custom size and opacity:

```powershell
pwsh -File .\my.palette.ps1 -OutputPath .\my-size10-opacity75.ovl -Size 10 -Opacity 75
```

For secondary layout edits, modify the layout directly in OverlayEditor.
To sync those edits back to the template, it is recommended to use a coding agent to check layout positions, naming, and apply the changes.

## Files

- `my.ovl`
  Generated with the default `Size=8` and `Opacity=75`, ready to use.

- `my-size10-opacity75.ovl`
  A slightly larger generated layout with `Size=10` and `Opacity=75`, ready to use.

- `my-opacity100.ovl`
  An opaque generated layout with the default `Size=8` and `Opacity=100`, ready to use.

- `my.template.ovl`
  Template file containing `{{...}}` placeholders.

- `my.palette.ps1`
  Generator script for size, opacity, colors, and output file path.
