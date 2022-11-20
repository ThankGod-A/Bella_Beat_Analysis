# To load packages needed to manipulate, analyze and visualize the data
library(tidyverse)
library(readr)
library(skimr)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(scales)
library(ggpubr)
library(ggsci)
library(viridis)
library(RColorBrewer)
library(ggrepel)

# To load and import the files needed
Daily_Activity <- read.csv("/Users/DieuMerci/Downloads/Coursera_Capstone/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
Daily_Sleep <- read.csv("/Users/DieuMerci/Downloads/Coursera_Capstone/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
Minute_Sleep <- read.csv("/Users/DieuMerci/Downloads/Coursera_Capstone/Fitabase Data 4.12.16-5.12.16/minuteSleep_merged.csv")
Hourly_Steps <- read.csv("/Users/DieuMerci/Downloads/Coursera_Capstone/Fitabase Data 4.12.16-5.12.16/hourlySteps_merged.csv")

# To check for distinct users/participant using n_distinct() functions.
n_distinct(Daily_Activity$Id)
n_distinct(Daily_Sleep$Id)
n_distinct(Minute_Sleep$Id)
n_distinct(Hourly_Steps$Id)

# To check for numbers of duplicated rows in each datasets using sum() and duplicated() functions
sum(duplicated(Daily_Activity))
sum(duplicated(Daily_Sleep))
sum(duplicated(Minute_Sleep))
sum(duplicated(Hourly_Steps))

# To remove the duplicates from Daily_Sleep and Minute_Sleep dataframe using distinct() and drop_na() function
Daily_Sleep <- Daily_Sleep %>% 
  distinct() %>% 
  drop_na()

Minute_Sleep <- Minute_Sleep %>% 
  distinct() %>% 
  drop_na()

# To check for NA's using colSums() and is.na() functions
colSums(is.na(Daily_Activity))
colSums(is.na(Daily_Sleep))
colSums(is.na(Minute_Sleep))
colSums(is.na(Hourly_Steps))

# To check for NULLs using is.null() function
is.null(Daily_Activity)
is.null(Daily_Sleep)
is.null(Minute_Sleep)
is.null(Hourly_Steps)

# To understand the structure and shape of the data frames
skim_without_charts(Daily_Activity)
glimpse(Daily_Sleep)
str(Minute_Sleep)
glimpse(Hourly_Steps)

# To Format date and date_time columns, and renaming them to Date
Daily_Activity <- Daily_Activity %>%
  rename(Date = ActivityDate) %>%
  mutate(Date = as_date(Date, format = "%m/%d/%Y"))

Daily_Sleep <- Daily_Sleep %>% 
  rename(Date = SleepDay) %>% 
  mutate(Date = as.POSIXct(Date, format ="%m/%d/%Y %I:%M:%S %p" , tz=Sys.timezone()))

Hourly_Steps <- Hourly_Steps %>% 
  rename(Date_Time = ActivityHour) %>% 
  mutate(Date_Time = as.POSIXct(Date_Time,format ="%m/%d/%Y %I:%M:%S %p" , tz=Sys.timezone()))

# To separate the timestamp column in 'Hourly_Step' dataframe into two columns, that is, Data & Time columns
Hourly_Steps_1 <- Hourly_Steps %>%
  separate(Date_Time, into = c("Date", "Time"), sep= " ")

# To analyze Quick Summary Statistics For Daily Activity and Daily Sleep data frame using select() and summary() function
Daily_Activity %>%
  select(
    TotalSteps,
    TotalDistance,
    SedentaryMinutes) %>%
  summary()

Daily_Sleep %>%
  select(
    TotalSleepRecords,
    TotalMinutesAsleep,
    TotalTimeInBed)%>%
  summary()

# To merge Daily_Activity and Daily_Sleep data frame and using merge() function
Combined_Data <- merge(Daily_Activity, Daily_Sleep, by=c("Id"))

#___________________ANALYZE AND SHARE PHASE____________________

# To analyze the summary statistic of some variables in Combined_Data
Combined_Data %>% 
  select(TotalSteps,
         TotalDistance,
         SedentaryMinutes,
         TotalTimeInBed,
         TotalSleepRecords,
         TotalMinutesAsleep) %>% 
  summary()

# To analyze the total number of steps, average number of steps, and average minutes asleep taken by users daily
Combined_A <- Combined_Data %>%
  mutate(Day = weekdays(Date.x)) %>% 
  group_by(Day) %>%
  summarize(Number_of_Steps = sum(TotalSteps),
            Avg_Steps = mean(TotalSteps),
            Avg_Sleep = mean(TotalMinutesAsleep))
print(Combined_A)

# Using the Daily_Activity table to analyze the total and average number of steps, and total calories burnt by users daily
DA <- Daily_Activity %>%
  mutate(Day = weekdays(Date)) %>% 
  group_by(Day) %>%
  summarize(Number_of_Steps = sum(TotalSteps),
            Avg_Steps = mean(TotalSteps),
            Total_Calories = sum(Calories)) %>% 
  arrange(desc(Number_of_Steps))
print(DA)

# To analyze the number of daily steps per hour by users.
Hourly_Steps_2 <- Hourly_Steps_1 %>% 
  group_by(Time) %>% 
  summarize(Number_of_Steps = sum(StepTotal),
            Average_Steps = mean(StepTotal))
print(Hourly_Steps_2)

# To analyze the number of users who had Sufficient/Normal sleep time and Insufficient sleep time daily and it's percentage
DS <- Daily_Sleep %>%
  mutate(Day = weekdays(Date)) %>% 
  group_by(Day) %>%
  summarize(Normal_Sleep = sum(TotalMinutesAsleep >= 480), 
            Insufficient_Sleep = sum(TotalMinutesAsleep < 480),
            Percentage = (Insufficient_Sleep/(Insufficient_Sleep + Normal_Sleep)) * 100) %>%
  arrange(desc(Normal_Sleep))
print(DS)

# To view the relationship between steps and calories
ggplot(Daily_Activity, aes(x = TotalSteps, y = Calories)) + 
  geom_jitter() +
  geom_smooth(method = "loess", color = "blue") +
  labs(title = "Steps Vs Calories", x = "Daily Steps", y = "Calories") +
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

# To view the relationship betwen Total active minutes and calories burnt
DA_1 <- Daily_Activity %>% 
  mutate(TotalActiveMinutes = FairlyActiveMinutes + LightlyActiveMinutes + VeryActiveMinutes)
ggplot(data = DA_1, mapping = aes(x = TotalActiveMinutes, y = Calories)) + 
  geom_jitter() +
  geom_smooth(method = "loess", color = "blue") +
  labs(title = "Minutes Vs Calories", x = "Active Minutes", y = "Calories") +
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

ggarrange(
  ggplot(Daily_Activity, aes(x = TotalSteps, y = Calories)) + 
    geom_jitter() +
    geom_smooth(method = "loess", color = "blue") +
    labs(title = "Steps Vs Calories", x = "Daily Steps", y = "Calories") +
    theme(plot.background = element_rect(fill = "#D9DFE0")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(plot.title = element_text(face = "bold")),
  ggplot(data = DA_1, mapping = aes(x = TotalActiveMinutes, y = Calories)) + 
    geom_jitter() +
    geom_smooth(method = "loess", color = "blue") +
    labs(title = "Minutes Vs Calories", x = "Active Minutes", y = "Calories") +
    theme(plot.background = element_rect(fill = "#D9DFE0")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(plot.title = element_text(face = "bold")))

# To view the relationship between Time in Bed Vs Minutes Asleep
ggplot(Daily_Sleep, aes(x = TotalTimeInBed, y = TotalMinutesAsleep)) + 
  geom_jitter() +
  geom_smooth(method = "loess", color = "blue") +
  labs(title = "Time In Bed Vs Sleep", x = "Time In Bed", y = "Minutes Asleep") +
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

# To view the number of steps taken by users in each hour of the day
ggplot(data = Hourly_Steps_2) +
  geom_col(mapping = aes(x=Time, y = Number_of_Steps)) + 
  labs(title = "Steps by Time of Day", x="", y="") + 
  scale_fill_gradient(low = "blue", high = "darkgreen") +
  theme(axis.text.x = element_text(angle = 90)) + 
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(face = "bold")) +
  scale_y_continuous(labels = number)

# To view average daily step taken by users in each hour of the day
ggplot(data = Hourly_Steps_2) +
  geom_col(mapping = aes(x=Time, y = Average_Steps, fill = Average_Steps)) + 
  labs(title = "Steps by Time of Day", x="", y="") + 
  scale_fill_gradient(low = "blue", high = "darkgreen") +
  theme(axis.text.x = element_text(angle = 90)) + 
  geom_hline(yintercept = 400 ) +
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

# To view the relationship between daily steps and sedentary minutes
ggplot(Daily_Activity, aes(x = TotalSteps, y = SedentaryMinutes)) + 
  geom_jitter() +
  labs(title = "Steps Vs Sedentary_Mins", x = "Total Steps", y = "Sedentary Minutes") +
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

# To view the relationship between daily steps and daily sleep
ggplot(Combined_Data, aes(x = TotalSteps, y = TotalMinutesAsleep)) + 
  geom_jitter() +
  geom_smooth(method = "loess", color = "blue") +
  labs(title = "Steps Vs Sleep", x = "Daily Steps", y = "Daily Sleep") +
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

# To view average step taken (during the weekday) daily by users
Combined_B <- Combined_Data %>%
  mutate(Day = weekdays(Date.x)) %>% 
  group_by(Day) %>%
  summarize(Number_of_Steps = sum(TotalSteps),
            Avg_Steps = mean(TotalSteps),
            Avg_Sleep = mean(TotalMinutesAsleep))
ggplot(data = Combined_B) +
  geom_col(mapping = aes(x=Day, y = Avg_Steps, fill = Avg_Steps)) + 
  labs(title = "Steps by Weekday", x="", y ="") + 
  theme(axis.text.x = element_text(angle = 45)) + 
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))

# To view the average minutes of sleep (during the weekday) daily by users
Combined_C <- Combined_Data %>%
  mutate(Day = weekdays(Date.x)) %>% 
  group_by(Day) %>%
  summarize(Number_of_Steps = sum(TotalSteps),
            Avg_Steps = mean(TotalSteps),
            Avg_Sleep = mean(TotalMinutesAsleep))
ggplot(data = Combined_C) +
  geom_col(mapping = aes(x=Day, y = Avg_Sleep, fill = Avg_Sleep)) + 
  labs(title = "Minute of sleep by Weekday", x="", y ="") + 
  theme(axis.text.x = element_text(angle = 45)) + 
  theme(plot.background = element_rect(fill = "#D9DFE0")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(face = "bold"))
