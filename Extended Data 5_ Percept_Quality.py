import aggregateHelper as hf
import pandas as pd
import plotly.express as px
import numpy as np
import pandas as pd

# get handle to database
subject=['Subject1','Subject2','Subject3']

Paraesthetic_Feeling=['ElectricCurrent','Tingle', 'Buzz', 'Shock', 'Numb']
Natural_Feeling=['Pulsing','Pressure', 'Touch', 'Sharp', 'Tap', 'UrgeToMove', 'Vibration', 'Flutter', 'Itch', 'Tickle', 'Prick', 'Cool', 'Warm']




for sub in subject:
    df = pd.read_excel('Percept_Quality.xlsx', sheet_name=sub)
    fig = px.sunburst(df, path=['Naturalness', 'Modality'], color='Naturalness',
                      color_discrete_map={'Natural':'#956E41', 'Paraesthetic':'#7F8FA9'})
    fig.update_layout(uniformtext=dict(minsize=15))
    fig.show()
    # fig.write_image('P:/analysis/human/uh3_stim/Percept Quality/%s_Sunburst.svg'%sub)
