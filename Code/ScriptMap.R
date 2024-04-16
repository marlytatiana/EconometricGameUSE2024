# Install and load the necessary packages
if (!require(ggplot2)) {
  install.packages("ggplot2")
  library(ggplot2)
}

if (!require(maps)) {
  install.packages("maps")
  library(maps)
}
library(tidyverse)
# Get map data
world_map <- map_data("world")

# Plot the map
ggplot() +
  geom_polygon(data = world_map, aes(x=long, y = lat, group = group)) +
  coord_fixed(1.3) +
  labs(title = "World Map")

value <- world_map %>% 
  select(c("value", "long", "lat"))

# Plot the map with a different projection

# Plot the map with the heatmap
ggplot() +
  geom_polygon(data = world_map, aes(x=long, y = lat, group = group), fill = "lightgray") +
  geom_tile(data = value, aes(x = long, y = lat, fill = value)) +
  scale_fill_gradient(low = "blue", high = "red") +
  coord_quickmap() +
  labs(title = "Heatmap on World Map")
