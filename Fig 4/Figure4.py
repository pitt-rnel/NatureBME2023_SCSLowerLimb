import matplotlib.pyplot as plt
import pandas
import seaborn as sns


#Figure 4 Equilibrium scores and Extended Data Figure Individual Condition Scores
eq = pandas.read_excel('C:\\Users\\bailey\\Desktop\\RNEL\\kin_analysis\\Eq_Scores.xlsx', header=0, sheet_name='Sheet1')
sns.catplot(x='Condition',y='Eq', hue='Stim',col="Subject", data=eq, kind='box')
sns.catplot(x='Condition',y='Eq', hue='Stim',col="Subject", data=eq, dodge=True)
plt.show()
#Figure 4 Area
area_ec_sway = pandas.read_excel('C:\\Users\\bailey\\Desktop\\RNEL\\kin_analysis\\Area.xlsx', header=0, sheet_name='Sheet1')
sns.catplot(x='Subject',y='Area',hue='Stim',data=area_ec_sway,kind='box')
sns.catplot(x='Subject',y='Area',hue='Stim',data=area_ec_sway, dodge=True)

