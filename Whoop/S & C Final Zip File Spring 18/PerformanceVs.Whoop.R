library(glmnet)
library(data.table)
hitstats<-read.csv("newhitstats.csv", header=TRUE)
whoop<-read.csv("bestwhoop.csv", header = TRUE)

####Aggregating + Merging Data

#######Hitting stats
hitstats<-data.table(hitstats)
head(hitstats)
hitstats_agg<-as.data.frame(hitstats[,j=list(mean(H, na.rm=T),
                                          sum(ifelse(is.na(H),0,1)),
                                          mean(RBI, na.rm=T),
                                          sum(ifelse(is.na(RBI),0,1)),
                                          mean(R, na.rm=T),
                                          sum(ifelse(is.na(R),0,1)),
                                          mean(AVG, na.rm=T),
                                          sum(ifelse(is.na(AVG),0,1)),
                                          mean(K, na.rm=T),
                                          sum(ifelse(is.na(K),0,1)),
                                          mean(X2B, na.rm=T),
                                          sum(ifelse(is.na(X2B),0,1)),
                                          mean(HR, na.rm=T),
                                          sum(ifelse(is.na(HR),0,1)),
                                          mean(BB, na.rm=T),
                                          sum(ifelse(is.na(BB),0,1)),
                                          mean(AB, na.rm=T),
                                          sum(ifelse(is.na(AB),0,1))),
                                          by=list(FName,Wk)])
hitstats_agg<-na.omit(hitstats_agg)
colnames(hitstats_agg)=c("FName", "Wk", "H", "Number3", "RBI", "Number4", "R", "Number5", "AVG", "Number6", "K", "Number 7", "X2B",
                         "Number8", "HR", "Number9", "BB", "Number10", "AB", "Number11")


###### Whoop data
whoop<-data.table(whoop)
whoop_agg<-as.data.frame(whoop[,j=list(mean(Rec.Today., na.rm=T),
                                       sum(ifelse(is.na(Rec.Today.),0,1)),
                                       mean(RHR.Today, na.rm=T),
                                       sum(ifelse(is.na(RHR.Today),0,1)),
                                       mean(HRV.Today, na.rm=T),
                                       sum(ifelse(is.na(HRV.Today),0,1)),
                                       mean(SP..Today, na.rm=T),
                                       sum(ifelse(is.na(SP..Today),0,1)),
                                       mean(HoS.Today, na.rm=T),
                                       sum(ifelse(is.na(HoS.Today),0,1)),
                                       mean(HiB.Today, na.rm=T),
                                       sum(ifelse(is.na(HiB.Today),0,1)),
                                       mean(SE..Today, na.rm=T),
                                       sum(ifelse(is.na(SE..Today),0,1)),
                                       mean(Light.Sleep.Time..hours..Today, na.rm=T),
                                       sum(ifelse(is.na(Light.Sleep.Time..hours..Today),0,1)),
                                       mean(Slow.Wave.Sleep.Time..hours..Today, na.rm=T),
                                       sum(ifelse(is.na(Slow.Wave.Sleep.Time..hours..Today),0,1)),
                                       mean(REM.Sleep.Time..hours..Today, na.rm=T),
                                       sum(ifelse(is.na(REM.Sleep.Time..hours..Today),0,1)),
                                       mean(Wake.Time..hours..Today, na.rm=T),
                                       sum(ifelse(is.na(Wake.Time..hours..Today),0,1)),
                                       mean(Disturbances..count..Today, na.rm=T),
                                       sum(ifelse(is.na(Disturbances..count..Today),0,1)),
                                       mean(Sleep.Debt..hours..Today, na.rm=T),
                                       sum(ifelse(is.na(Sleep.Debt..hours..Today),0,1))),
                                       by=list(FName, Wk)])
whoop_agg<-na.omit(whoop_agg)
colnames(whoop_agg)=c("FName","Wk","RecToday","Number", "RHRToday","Number2", "HRVToday", "num3"
                      , "SPToday", "num4", "HoSToday", "num5", "HiBtoday", "num6", "SEToday", "num7", "LightSleepToday"
                      , "num8", "SlowWaveToday", "num9", "REMSleepToday", "num10", "WakeTimeToday", "num11", "Disturbances", "num12","SleepDebt", "num13")

######
library(plyr)
df3<-join(whoop_aggnoJc, hitstats_agg, type="left")
whoop_aggnoJc<-whoop_agg[-c(10),]

#df5<-df3[-c(10),]

whoop_aggno<-data.table(whoop_aggnoJc)
hitstats_agg<-data.table(hitstats_agg)

df3<-df3[!df3$AB==0,]


####linreg
attach(df3)
plot(HRVToday~H)
lm_hit<-lm(HRVToday~H)
summary(lm_hit)

#########Lasso hits
library(glmnetUtils)

x=as.matrix(whoop_aggno[,c(3,5,7,9,11,13,15,17,19,21,23,25,27)], data=data)
yhit=as.matrix(df3$H, TRUE)
cvfithit<-cv.glmnet(x, yhit)
coef(cvfithit, s="lambda.min")

lambda=coef(cvfit, s="lambda.1se")
cvfit$lambda.min

######## Lasso RBI
yrbi=as.matrix(df3$RBI, TRUE)
cvfitrbi<-cv.glmnet(x, yrbi)
coef(cvfitrbi, s="lambda.min")

#####lassso AVG
yavg= as.matrix(df5$AVG, TRUE)
cvfitavg<-cv.glmnet(x, yavg)
coef(cvfitavg, s="lambda.min")

##### Lasso R
yr<-as.matrix(df5$R, TRUE)
cvfitr<-cv.glmnet(x,yr)
coef(cvfitr, s="lambda.min")

#### Lasso K
yk<-as.matrix(df5$K, TRUE)
cvfitk<-cv.glmnet(x, yk)
coef(cvfitk, s="lambda.min")

#### Lasso 2B
y2b<-as.matrix(df5$X2B, TRUE)
cvfit2b<-cv.glmnet(x, y2b)
coef(cvfit2b, s="lambda.min")

#### Lasso HR
yhr<-as.matrix(df5$HR, TRUE)
cvfithr<-cv.glmnet(x, yhr)
coef(cvfithr, s="lambda.min")

### Lasso Walks
yw<-as.matrix(df5$BB, TRUE)
cvfityw<-cv.glmnet(x, yw)
coef(cvfityw, s="lambda.min")


#plots
library(ggplot2)
ggplot(df3, aes(R, RecToday)) +geom_point() +geom_smooth(method=lm)

ggplot(df3, aes(x=factor(Wk), RecToday)) + geom_boxplot()

ggplot(df3, aes(K, REMSleepToday)) + geom_point() + geom_smooth(method=lm)
ggplot(df3, aes(AVG, HRVToday)) + geom_point() + geom_smooth(method=lm)
ggplot(df3, aes(H, HRVToday)) + geom_point() + geom_smooth(method=lm)
ggplot(df3, aes(RBI, HRVToday)) + geom_point() + geom_smooth(method=lm)
ggplot(df3, aes(AVG, HoSToday)) + geom_point() + geom_smooth(method = lm)
ggplot(df3, aes(R, RecToday)) + geom_point() + geom_smooth(method = lm)
ggplot(df3, aes(H, HiBtoday))+ geom_point() + geom_smooth(method=lm)
ggplot(df3, aes(RBI, RecToday)) + geom_point() + geom_smooth(method = lm)
