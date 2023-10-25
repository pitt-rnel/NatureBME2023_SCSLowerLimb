clc
clear

data=xlsread('McGill Pain Scores Summary.xlsx');

figure;

plot(data(2:5,2),'-o');
hold on
plot(data(2:5,3),'-o');
plot(data(2:12,4),'-o');

ylabel('McGill Pain Score')
xlabel('Weeks')

figure;

bar([51,0,48;15,33,47])