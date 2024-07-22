
pacman::p_load(
  arcgis,
  geodata,
  sf, dots,
  tidyverse,
  elevatr, terra,
  rayshader
)
url <- "https://services1.arcgis.com/ZGrptGlLV2IILABw/arcgis/rest/services/Pop_Admin1/FeatureServer/0"

data <- arcgislayers::arc_open(
  url
)
admin1_population <- arcgislayers::arc_select(
  data,
  fields = c(
    "HASC_1", "ISO2", "Population"
  ),
  where = "ISO2 = 'KZ'"
) |>
  sf::st_drop_geometry()

country_admin1_sf <- geodata::gadm(
  country = "KAZ",
  level = 1,
  path = getwd()
) |>
  sf::st_as_sf() |>
  sf::st_cast("MULTIPOLYGON")

crs <- "+proj=tmerc +lat_0=0 +lon_0=6 +k=1 +x_0=2500000 +y_0=0 +ellps=bessel +units=m +no_defs +type=crs"

country_admin1_population <- dplyr::left_join(
  country_admin1_sf,
  admin1_population,
  by = "HASC_1"
) |>
  sf::st_transform(crs = crs)


population_dots <- dots::dots_points(
  shp = country_admin1_population,
  col = "Population",
  engine = engine_sf_random,
  divisor = 50000
)

p <- ggplot() +
  geom_sf(
    data = country_admin1_population,
    fill = "#153041",
    color = "#204863",
    linewidth = .5
  ) +
  geom_sf(
    data = population_dots,
    aes(),
    color = "#ffd301",
    size = .1
  ) +
  coord_sf(crs = crs) +
  theme_void()

print(p)

ggsave("kazakhstan-50K-dot-density.png", plot = p, width = 10, height = 8, dpi = 300)
