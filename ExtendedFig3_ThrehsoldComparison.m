clear
clc

[data]=xlsread('Thresholds.xlsx');
data=data/1000;
errorbar([1,2],[mean(data(1:4,1)),mean(data(1:4,2))],[std(data(1:4,1)),std(data(1:4,2))])
xlim([0.5 2.5])
hold on
errorbar([1,2],[mean(data(1:13,3)),mean(data(1:13,4))],[std(data(1:13,3)),std(data(1:13,4))])
errorbar([1,2],[mean(data(1:8,5)),mean(data(1:8,6))],[std(data(1:8,5)),std(data(1:8,6))])
ylim([0.5 5])