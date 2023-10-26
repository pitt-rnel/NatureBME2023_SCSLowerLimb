import matplotlib.pyplot as plt
import pandas
import seaborn as sns

#Figure 5 FGA Scores
fga = pandas.read_excel('C:\\Users\\bailey\\Desktop\\RNEL\\kin_analysis\\FGA_bothsubjects.xlsx', header=0, sheet_name='Sheet1')
sns.catplot(x='Subject',y='FGA',hue='Condition',data=fga,kind='bar')

