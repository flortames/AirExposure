# AirExposure

AirExposure is an R package for estimating individual exposure to air
pollution using both fixed-location and mobility-based approaches.

The package integrates information on daily mobility, activity schedules,
travel routes, and hourly pollutant concentrations to estimate personal
exposure in urban environments.

## Mendoza case-study dataset

The hourly PM2.5 concentration grids used in the Mendoza (Argentina)
case study are publicly available through Zenodo:

**DOI:** https://doi.org/10.5281/zenodo.22797605

The dataset contains 24 hourly PM2.5 concentration grids corresponding
to 1 August 2019 and is used throughout the package documentation and
vignettes.

## Main features

- Estimation of daily exposure using dynamic mobility patterns.
- Comparison of alternative travel routes.
- Integration with the TomTom Routing API.
- Estimation of hourly and daily pollutant exposure.
- Comparison between dynamic and fixed-location exposure models.

## Package structure

- `R/` contains all package functions.
- `tests/` contains the automated unit tests.
- `man/` contains the generated documentation.

## Related publications

Tames, M.F., Puliafito, S.E., Urquiza, J. et al. Spatio-temporal analysis of 
bicyclists’ PM2.5 exposure levels in a medium sized urban agglomeration. 
Environ Monit Assess 196, 1194 (2024). 
https://doi.org/10.1007/s10661-024-13356-w

Tames, M.F., Urquiza, J., Berná-Peña, L.L. et al. Modeling Influence of 
Population Mobility to Airborne PM2.5 Exposure. Environ Model Assess 30, 
1235–1251 (2025). https://doi.org/10.1007/s10666-025-10050-0