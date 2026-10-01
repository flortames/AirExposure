# Convert Points to LINESTRING Geometries

Converts a set of ordered point coordinates into one or more LINESTRING
geometries. If a grouping variable is provided, one LINESTRING is
created for each group.

## Usage

``` r
points_to_line(data, long, lat, id_field = NULL, sort_field = NULL)
```

## Arguments

- data:

  A data frame containing point coordinates.

- long:

  Character. Name of the longitude column.

- lat:

  Character. Name of the latitude column.

- id_field:

  Optional character. Name of the column used to group points into
  different LINESTRING geometries.

- sort_field:

  Optional character. Name of the column used to order points before
  creating the LINESTRING geometries.

## Value

If `id_field` is `NULL`, returns an `sfc_LINESTRING` object with CRS
EPSG:4326.

If `id_field` is provided, returns an `sf` object containing one
LINESTRING for each group and a column with the corresponding group
identifier.

## Examples

``` r
if (FALSE) { # \dontrun{
# trajectory must contain point coordinates
# and an identifier for each route

line <- points_to_line(
  data = trajectory,
  long = "long",
  lat = "lat",
  id_field = "alternative",
  sort_field = "ID"
)
} # }
```
