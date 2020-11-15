##Project Data

whoop_data<-read.csv("Project_data*.csv")
View(whoop_data)
#install.packages("data.table")
library(data.table)

colnames(sleep)
sleep<-data.table(whoop_data)
View(sleep)
sleep_agg<-sleep[, j=list(hours_in_bed = mean(HiB.Today, na.rm = TRUE), sum(ifelse(is.na(HiB.Today), 0, 1)),
                               rec_today = mean(Rec.Today., na.rm = TRUE), sum(ifelse(is.na(Rec.Today.), 0, 1)),
                               heart_rate_var = mean(HRV.Today, na.rm = TRUE), sum(ifelse(is.na(HRV.Today), 0, 1)),
                               sp_today = mean(SP..Today, na.rm = TRUE), sum(ifelse(is.na(SP..Today), 0, 1)),
                               hours_of_sleep = mean(HoS.Today, na.rm = TRUE), sum(ifelse(is.na(HoS.Today), 0, 1)),
                               se_today = mean(SE..Today, na.rm = TRUE), sum(ifelse(is.na(SE..Today), 0, 1)),
                               LST_hours = mean(Light.Sleep.Time..hours..Today, na.rm = TRUE), sum(ifelse(is.na(Light.Sleep.Time..hours..Today), 0, 1)),
                               SWST_hours = mean(Slow.Wave.Sleep.Time..hours..Today, na.rm = TRUE), sum(ifelse(is.na(Slow.Wave.Sleep.Time..hours..Today), 0, 1)),
                               REM_hours = mean(REM.Sleep.Time..hours..Today, na.rm = TRUE), sum(ifelse(is.na(REM.Sleep.Time..hours..Today), 0, 1)),
                               WT_hours = mean(Wake.Time..hours..Today, na.rm = TRUE), sum(ifelse(is.na(Wake.Time..hours..Today), 0, 1)),
                               dist_count = mean(Disturbances..count..Today, na.rm = TRUE), sum(ifelse(is.na(Disturbances..count..Today), 0, 1)),
                               SD_hours = mean(Sleep.Debt..hours..Today, na.rm = TRUE), sum(ifelse(is.na(Sleep.Debt..hours..Today), 0, 1))),
                               by = list(FName, Wk)]

sleep_data<-na.omit(sleep_agg)
summary(sleep_data)
View(sleep_data)

start_dat<-read.csv("softball_start.csv")

View(start_dat)

install.packages("eeptools")
library(eeptools)
#install.packages("ggplot2")
library(ggplot2)

merge_dat<-merge(sleep_data, start_dat, by = c("FName"), all.x = TRUE)
summary(merge_dat$hours_in_bed)
summary(merge_dat$rec_today) 
summary(merge_dat$heart_rate_var) 
summary(merge_dat$sp_today) 
summary(merge_dat$hours_of_sleep)
summary(merge_dat$se_today)
summary(merge_dat$LST_hours)
summary(merge_dat$SWST_hours) 
summary(merge_dat$REM_hours)
summary(merge_dat$WT_hours) 
summary(merge_dat$dist_count)
summary(merge_dat$SD_hours)
colnames(merge_dat)
View(merge_dat)

##T test
t.test(merge_dat$hours_in_bed[merge_dat$Starter == 1], merge_dat$hours_in_bed[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$rec_today[merge_dat$Starter == 1], merge_dat$rec_today[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$heart_rate_var[merge_dat$Starter == 1], merge_dat$heart_rate_var[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$sp_today[merge_dat$Starter == 1], merge_dat$sp_today[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$hours_of_sleep[merge_dat$Starter == 1], merge_dat$hours_of_sleep[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$se_today[merge_dat$Starter == 1], merge_dat$se_today[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$LST_hours[merge_dat$Starter == 1], merge_dat$LST_hours[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$SWST_hours[merge_dat$Starter == 1], merge_dat$SWST_hours[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$REM_hours[merge_dat$Starter == 1], merge_dat$REM_hours[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$WT_hours[merge_dat$Starter == 1], merge_dat$WT_hours[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$dist_count[merge_dat$Starter == 1], merge_dat$dist_count[merge_dat$Starter == 0], conf.level = 0.95)
t.test(merge_dat$SD_hours[merge_dat$Starter == 1], merge_dat$SD_hours[merge_dat$Starter == 0], conf.level = 0.95)

##visuals
p<-ggplot(merge_dat, aes(x = factor(Starter), y = hours_in_bed , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Hours in Bed for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Hours in Bed") + theme(legend.position = "none")

p<-ggplot(merge_dat, aes(x = factor(Starter), y = rec_today , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Recovery Percentage for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Recovery %")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = heart_rate_var , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Heart Rate Variability for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Heart Rate Variability")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = sp_today , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Sleep Performance for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Sleep Performance")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = hours_of_sleep , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Total Hours of Sleep for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Total Hours of Sleep")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = se_today , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Sleep Efficiency for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Sleep Efficiency (%)")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = LST_hours , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Light Sleep Time in hours for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Light Sleep Time in hours")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = SWST_hours , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Slow Wave Sleep Time in hours for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Slow Wave Sleep Time in hours")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = REM_hours , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean REM Sleep Time in hours for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "REM Sleep Time in hours")+ theme(legend.position = "none")

p<-ggplot(merge_dat, aes(x = factor(Starter), y = WT_hours , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Wake Time in hours for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Wake Time in hours")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = dist_count , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Disturbances Count for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Disturbances Count")+ theme(legend.position = "none")


p<-ggplot(merge_dat, aes(x = factor(Starter), y = SD_hours , color = factor(Starter)))
p + geom_boxplot(outlier.size = 0) + labs(title="Mean Sleep Debt in hours for Starters/Non-Starters", x = "Starter(1)/Non-Starter(0)", y = "Sleep Debt in hours")+ theme(legend.position = "none")

