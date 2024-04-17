
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
  mutate(Z_cst_trimmed = ifelse(Z_cst < -10 | Z_cst > 10, NA, Z_cst),
         Z_cst_triRead = ifelse(Z_cst_read < -10 | Z_cst_read > 10, NA, Z_cst_read))

# Convert wave to factor
df$wave <- as.factor(df$wave)

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
