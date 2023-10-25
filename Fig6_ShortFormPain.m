clc
clear

data=xlsread('All_subs.xlsx');

figure;
subplot(2,2,1)
plot([nanmean(data(1,1:4)) nanmean(data(2,1:4)) nanmean(data(3,1:4)) nanmean(data(4,1:4))],'-o')
ylim([0 6])
subplot(2,2,2)
plot([nanmean(data(6,1:4)) nanmean(data(7,1:4)) nanmean(data(8,1:4)) nanmean(data(9,1:4))],'-o')
ylim([0 6])
subplot(2,2,3)
plot([nanmean(data(11,1:4)) nanmean(data(12,1:4)) nanmean(data(13,1:4))...
    nanmean(data(14,1:4)) nanmean(data(15,1:4)) nanmean(data(16,1:4)) nanmean(data(17,1:4)) nanmean(data(18,1:4))...
    nanmean(data(19,1:4)) nanmean(data(20,1:4)) nanmean(data(21,1:4)) nanmean(data(22,1:4))],'-o')
ylim([0 6])

