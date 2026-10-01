# AirExposure

<img src="man/figures/logo.png" align="right" width="220"

AirExposure is an R package for estimating individual exposure to air
pollution using both fixed-location and mobility-based approaches.

The package integrates information on daily mobility, activity
schedules, travel routes, and hourly pollutant concentrations to
estimate personal exposure in urban environments and compare traditional
and dynamic exposure assessment methods.

## Installation

```r
remotes::install_github("flortames/AirExposure")
```

## Main features

- Retrieve hourly pollutant concentration grids.
- Aggregate pollutant concentrations over user-defined time periods.
- Compare alternative travel routes using air pollution information.
- Estimate daily exposure using a Dynamic Exposure Method (DEM).
- Estimate daily exposure using a Fixed-Location-Based Method (FLBM).
- Compare mobility-based and fixed-location exposure estimates.
- Assess exposure along alternative travel routes.

## Vignette

A complete workflow describing dynamic PM2.5 exposure assessment in the
Mendoza Metropolitan Area is available through the package vignette:

- *Dynamic PM2.5 Exposure Assessment in Mendoza Metropolitan Area*

## Mendoza case study

The package documentation and vignette include a case study based on
hourly PM2.5 concentration grids from the Mendoza Metropolitan Area
(Argentina). The grids used for the case study are publicly available through
Zenodo:

**DOI:** [Mendoza PM2.5 dataset](https://doi.org/10.5281/zenodo.22797605)

The dataset contains 24 hourly PM2.5 concentration grids corresponding
to 1 August 2019.

## Citation

If you use AirExposure in your work, please consider citing the related
publications listed below.

## Related publications

Tames, M.F., Puliafito, S.E., Urquiza, J. et al. Spatio-temporal analysis of 
bicyclists’ PM2.5 exposure levels in a medium sized urban agglomeration. 
Environ Monit Assess 196, 1194 (2024). 
https://doi.org/10.1007/s10661-024-13356-w

Tames, M.F., Urquiza, J., Berná-Peña, L.L. et al. Modeling Influence of 
Population Mobility to Airborne PM2.5 Exposure. Environ Model Assess 30, 
1235–1251 (2025). https://doi.org/10.1007/s10666-025-10050-0