Lasercut files for making materials for Catechesis of the Good Shepherd

# Extract Cut Files (Fusion 360 Script)

Batch-exports all 3D bodies across open Fusion 360 documents into DXF cut files for a laser cutter. Detects standard wood sheet thicknesses (1/8", 3/16", 1/4", 1/2", 3/4") and dowels automatically.

## Install

1. In Fusion 360, go to **Utilities > Add-Ins > Scripts**
2. Click the green **+** next to "My Scripts"
3. Browse to this repo and select `extract_cut_files.py`
4. It will appear as "extract_cut_files" in your scripts list

## Usage

1. Open all the Fusion documents you want to export
2. Run the script from **Utilities > Add-Ins > Scripts > extract_cut_files**
3. Pick an output folder
4. DXFs are named `{material}__{thickness}__{document}__{body}.dxf` so they sort by material type and thickness

# Fonts Used

- [Questrial](https://fonts.google.com/specimen/Questrial)
- [Sassoon Primary Std](https://dafontfamily.net/sassoon-font-free-download/)
- [Courgette](https://fonts.google.com/specimen/Courgette)
