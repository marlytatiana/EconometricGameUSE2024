
# To install and open the R packages that you need for this code.
need <- c("tidyverse", "glue", "ggthemes", "readstata13", "haven", "ggplot2", 
          "readxl", "dplyr", "zoo", "stringr", "xtable", "stargazer", 
          "xtable", "RNHANES", "skimr")
have <- need %in% rownames(installed.packages())
if(any(!have)) install.packages(need[!have])
invisible(lapply(need,library,character.only=TRUE))
rm(list=ls())

################################################################################
# Paths, working directory
# working directory
getwd()
# "D:/1_Procurement/survey-procurers/03_code" <---- Repository location
list.files()
# wd <- list()

# Commonly used paths in my working directory

# Data coming from Dropbox
# If working from UU file
folder <- "F:/EconometricGame2024/Clean"
pisaOECD_clean <- read.csv("F:/EconometricGame2024/Clean/pisaOECD_clean.txt")
View(pisaOECD_clean)

## Standardized maths score across waves within country & school
stats_2015 <- pisaOECD_clean %>%
  filter(wave == 2015) %>%
  group_by(cnt, cntschid) %>%
  summarise(
    mean_2015 = mean(mean_math_score, na.rm = TRUE),
    sd_2015 = sd(mean_math_score, na.rm = TRUE),
    mean_2015read = mean(mean_read_score, na.rm = TRUE),
    sd_2015_read = sd(mean_read_score, na.rm = TRUE)
  )
  

# Join the stats back to the original data
df <- pisaOECD_clean %>%
  left_join(stats_2015, by = c("cnt", "cntschid"))

# Create the standardized variable
df <- df %>%
  mutate(Z_cst = (mean_math_score - mean_2015) / sd_2015 ,
         Z_cst_read = (mean_read_score - mean_2015read) / sd_2015_read )

# Trim the Z_cst variable 
df <- df %>%
  mutate(Z_cst_trimmed = ifelse(Z_cst < -5 | Z_cst > 5, NA, Z_cst),
         Z_cst_triRead = ifelse(Z_cst_read < -5 | Z_cst_read > 5, NA, Z_cst_read))


# Convert wave to factor
df$wave <- as.factor(df$wave)


# Assuming your data frame is named df and it has a column named st126q01ta
# Create the schoolstart variable
df <- df %>%
  mutate(schoolstart = case_when(
    st126q01ta == "3 or younger" ~ 3,
    st126q01ta == "4" ~ 4,
    st126q01ta == "5" ~ 5,
    st126q01ta == "6" ~ 6,
    st126q01ta == "7" ~ 7,
    st126q01ta == "8" ~ 8,
    st126q01ta == "9 or older" ~ 9,
    TRUE ~ NA_real_
  ))



# Create the density plot
distributionMaths<- ggplot(df, aes(x = Z_cst_trimmed)) +
  geom_density(aes(fill = wave), alpha = 0.5) +
  scale_fill_manual(values = c("2015" = "gray", "2018" = "green", "2022" = "purple")) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Maths Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=13, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8))
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/distributionMaths.png", distributionMaths)


distributionRead<- ggplot(df, aes(x = Z_cst_triRead)) +
  geom_density(aes(fill = wave), alpha = 0.5) +
  scale_fill_manual(values = c("2015" = "gray", "2018" = "green", "2022" = "purple")) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Reading Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=13, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8))
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/distributionRead.png", distributionRead)


#

# Create data
data <- data.frame(
  x=df[["cnt"]],
  y=df[["mean_math_score"]]
)

# Horizontal version
ggplot(data, aes(x=x, y=y)) +
  geom_segment( aes(x=x, xend=x, y=0, yend=y), color="skyblue") +
  geom_point( color="blue", size=4, alpha=0.6) +
  theme_light() +
  coord_flip() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.border = element_blank(),
    axis.ticks.y = element_blank()
  )

datacountries <- read_dta("F:/EconometricGame2024/Clean/table_countries.dta")

## Standardized maths score across waves within country & wave
stats_wave_country <- df %>%
  group_by(cnt, wave, schoolstart) %>%
  summarise(
    mean_math_cws = mean(mean_math_score, na.rm = TRUE),
    mean_read_cws = mean(mean_read_score, na.rm = TRUE),
  )


# Calculate the average across countries
avg_wave_country <- df %>%
  group_by(wave, schoolstart) %>%
  summarise(
    avg_math_cws = mean(mean_math_score, na.rm = TRUE) , 
    avg_read_cws = mean(mean_read_score, na.rm = TRUE)
  )



schoolage_maths <- ggplot(stats_wave_country, aes(schoolstart, mean_math_cws)) +
  geom_point(color = "blue", alpha = 0.2) +
  geom_line(data = avg_wave_country, aes(y = avg_math_cws), color = "black", size = 1.5) +
  facet_wrap(~ wave) +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=13, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8)) +
  labs(x = "Age of start school", y = "Average", title = "Maths Score") 
plot(schoolage_maths)
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/schoolage_maths.png", schoolage_maths)


schoolage_reading <- ggplot(stats_wave_country, aes(schoolstart, mean_read_cws)) +
  geom_point(color = "purple", alpha = 0.2) +
  geom_line(data = avg_wave_country, aes(y = avg_read_cws), color = "black", size = 1.5) +
  facet_wrap(~ wave) +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=13, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8)) +
  labs(x = "Age of start school", y = "Average", title = "Reading Score")
plot(schoolage_reading)
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/schoolage_reading.png", schoolage_reading)



####

# Calculate mean and sd for each country and school in 2015, 2018, and 2022
stats <- pisaOECD_clean %>%
  filter(wave %in% c(2015, 2018, 2022)) %>%
  group_by(cnt, cntschid, wave) %>%
  summarise(
    mean_math = mean(mean_math_score, na.rm = TRUE),
    sd_math = sd(mean_math_score, na.rm = TRUE),
    mean_read = mean(mean_read_score, na.rm = TRUE),
    sd_read = sd(mean_read_score, na.rm = TRUE)
  )

# Join the stats back to the original data
df_standard <- pisaOECD_clean %>%
  left_join(stats, by = c("cnt", "cntschid", "wave"))

# Create the standardized variables
df_standard <- df_standard %>%
  mutate(
    Z_cst_math = (mean_math_score - mean_math) / sd_math,
    Z_cst_read = (mean_read_score - mean_read) / sd_read
  )

# Convert wave to factor
df_standard$wave <- as.factor(df$wave)


distributionMaths_wave <- ggplot(df_standard, aes(x = Z_cst_math)) +
  geom_density(aes(fill = wave), alpha = 0.5) +
  scale_fill_manual(values = c("2015" = "gray", "2018" = "blue", "2022" = "purple")) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Maths Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=13, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8))
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/distributionMaths_wave.png", distributionMaths_wave)

distributionRead_wave <- ggplot(df_standard, aes(x = Z_cst_read)) +
  geom_density(aes(fill = wave), alpha = 0.5) +
  scale_fill_manual(values = c("2015" = "gray", "2018" = "blue", "2022" = "purple")) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Reading Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=13, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8))
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/distributionRead_wave.png", distributionRead_wave)


df_standard <- df_standard %>%
  mutate(parentEduc = if_else(paredint > 12, 1, 0))

df_standard$parentEduc <- as.factor(df_standard$parentEduc)
df_standard$wave <- as.factor(df_standard$wave)

# Remove rows where parentEduc is NA
df_standard_plot <- df_standard %>%
  filter(!is.na(parentEduc))


# Create the density plot
distributionMaths_Educ<- ggplot(df_standard_plot, aes(x = Z_cst_math)) +
  geom_density(aes(fill = (parentEduc)), alpha = 0.5) +
  scale_fill_manual(values = c("red", "blue"), 
                    labels = c("Low education", "High education"),
                    breaks = c("0", "1"),
                    name = "Parent Education") +
  #facet_wrap(~ wave) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Maths Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=11, family= "Georgia")) +
  theme(legend.position = "bottom") 
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/distributionMaths_Educ.png", distributionMaths_Educ)

# Create the density plot
distributionRead_Educ<- ggplot(df_standard_plot, aes(x = Z_cst_read)) +
  geom_density(aes(fill = (parentEduc)), alpha = 0.5) +
  scale_fill_manual(values = c("red", "blue"), 
                    labels = c("Low education", "High education"),
                    breaks = c("0", "1"),
                    name = "Parent Education") +
  #facet_wrap(~ wave) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Reading Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=11, family= "Georgia")) +
  theme(legend.position = "bottom") 
ggsave("C:/Users/6809758/Documents/GitHub/EconometricGameUSE2024/Graphs/distributionRead_Educ.png", distributionRead_Educ)




# Create the density plot
ggplot(df_standard_plot, aes(x = Z_cst_math)) +
  geom_density(aes(fill = (parentEduc)), alpha = 0.5) +
  scale_fill_manual(values = c("red", "blue"), 
                    labels = c("Low education", "High education"),
                    breaks = c("0", "1"),
                    name = "Parent Education") +
  facet_wrap(~ wave) +
  labs(x = "Standardized score within country and school", y = "Density", title = "Maths Score") +
  theme_classic() +
  theme(plot.title =element_text(hjust = 0.5)) +
  theme(axis.title = element_text(size=12)) +
  theme(plot.title =element_text(size=13)) +
  theme(text=element_text(size=12, family= "Georgia")) +
  theme(legend.position = c(0.8, 0.8))
