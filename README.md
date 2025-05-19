# Habitat_suitability

# Habitat Suitability Curve Fitting

- Author: Francesca Padoan  
- Institution: École Polytechnique Fédérale de Lausanne (EPFL)  
- MATLAB Version: 2024b  
- Date: 17 May 2025  
- Reference: Padoan et al., 2024 (River Research and Applications)
- Contact: francesca.padoan@epfl.ch

---

# Overview

This MATLAB script implements a mathematical framework for fitting *Habitat Suitability Curves (HSCs)* using empirical water depth and flow velocity preference data for *adult* and *juvenile* fish life stages.

By applying *Gaussian* and *Gamma* distributions, the code creates smooth, analytical representations of habitat preference curves derived from raw suitability tables.

---

# Features

- Fits *Gaussian* (depth) and *Gamma* (velocity) functions on empirical habitat preference data.
- Supports both *adult* and *juvenile* fish stages.
- Visualizes model fits with R² values.
- Fully modular and extendable for other species or variables.

---

# Input Data Format

Input Excel files must be structured with the following columns (example for flow velocity):

| Reference | VMin | VMax | Vopt1 | Vopt2 |
|-----------|------|------|-------|-------|

- Rows 2 onward contain numeric values.
- Separate sheets are used for "Adult" and "Juvenile" data.
- Two files are expected:
  - `Water depth_adult_juvenile.xlsx`
  - `Water velocity_adult_juvenile.xlsx`

---

# How to Run

1. Install MATLAB R2024b.
2. Ensure the 'Curve Fitter' App is installed.
3. Clone or download this repository.
4. Open and run 'Fit_H_U_Adult_Juvenile.m'.

> The script uses relative paths; it must be run from the root folder.

---

# Output

- Two subplots comparing raw suitability points with fitted curves:
  - Water Depth – Adults and Juveniles
  - Flow Velocity – Adults and Flow Velocity 
- 'R²' values printed in the legends for model performance evaluation.


