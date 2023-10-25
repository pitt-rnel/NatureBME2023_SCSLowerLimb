import pymongo
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image, ImageDraw
import plotly.graph_objs as go
import os
import base64
import plotly
from plotly import tools
from plotly.subplots import make_subplots
import pandas as pd

# instantiate the mongo client
client = pymongo.MongoClient('10.226.19.226', 15213)
db = client.uh3_stim
collection = 'uh3_stim'

XRANGE = [513, 1293]
YRANGE = [50, 850]

encodeList = []

imgList = ['Blegs', 'Flegs', 'dors_left', 'dors_right', 'sole_left', 'sole_right']
imgName = ['Blegs', 'Flegs', 'Ldors', 'Rdors', 'Lsole', 'Rsole']
colormaps=['Greens','Blues','Purples']


LNP02_elec=['Unipolar: 37', 'Unipolar: 37', 'Unipolar: 37', 'Unipolar: 37', '36::35', '36::35', '36::35', 'Unipolar: 24', 'Unipolar: 24', 'Unipolar: 24', 'Unipolar: 24', 'Unipolar: 24']
def getFigTemplate(sub):
    nRows = 3
    nCols = 2

    imgRoot = 'P:\\analysis\\human\\uh3_stim\\ImageBank\\Dash\\'+sub
    # imgRoot = 'P:\\users\\amn69\\Projects\\human\\gitRepo_UH3\\ImageBank\\Dash'
    encodeList=[]
    for img in imgList:
        imgPath = os.path.join(imgRoot, img + '.png')  # replace with your own image
        encodeList.append(base64.b64encode(open(imgPath, 'rb').read()))
    tmpr = []
    figure = make_subplots(rows=nRows, cols=nCols,
                                 subplot_titles=imgName, vertical_spacing=0.05)
    for idx in range(1, nRows * nCols + 1):
        mask = np.zeros([YRANGE[1], XRANGE[1], ])

        # layout plotly figure

        figure['layout']['xaxis%d' % idx].update({
            'fixedrange': True,
            'range': XRANGE,
            'ticklen': 0,
            'showgrid': False,
            'zeroline': False,
            'showline': False,
            'ticks': '',
            'showticklabels': False
        })
        figure['layout']['yaxis%d' % idx].update({
            'fixedrange': True,
            'range': YRANGE,
            'ticklen': 0,
            'showgrid': False,
            'zeroline': False,
            'showline': False,
            'ticks': '',
            'showticklabels': False
        })

        tmpr.append({
            'xref': 'x%d' % idx,
            'yref': 'y%d' % idx,
            'x': XRANGE[0],
            'y': YRANGE[0],
            'yanchor': 'bottom',
            # 'xanchor':'left',
            'sizex': XRANGE[1] - XRANGE[0],
            'sizey': YRANGE[1] - YRANGE[0],
            'sizing': 'stretch',
            'layer': 'above',
            'source': 'data:image/png;base64,{}'.format(encodeList[(idx % 6) - 1])
        })
    figure['layout']['images'] = tmpr

    figure['layout'].update(height=600 * nRows, width=1750)
    return figure

def generateHeatmapFig(subject, elec, week, thresh=6000):
    print('Generating RF for %s %s' % (subject, elec))
    masks = []
    trl_len=[]
    nRows = 3
    nCols = 2
    # elec=LNP02_elec[week-1]
    for idx in range(1, nRows * nCols + 1):
        img=imgName[idx-1]
        tmp = list(db[collection].find({'mdf_metadata.subject': subject,
                                        'mdf_metadata.trialType': {'$in': ['Static', 'MultiVE']},
                                        'mdf_metadata.electrodeLabel': {'$regex':elec},
                                        'mdf_metadata.week': week,
                                        #                                'mdf_metadata.stimParams.cathAmp': {'$lte': thresh},
                                        'mdf_metadata.' + img: {"$exists": 1, "$ne": []}},
                                       {'mdf_metadata.' + img: 1, '_id': 0}))
        mask = np.zeros([YRANGE[1], XRANGE[1], ])

        if len(tmp) != 0:
            for iLine2 in tmp:  # trial
                if (type(iLine2['mdf_metadata'][img][0]) != list):
                    iLine = iLine2['mdf_metadata'][img]
                else:
                    iLine = iLine2['mdf_metadata'][img][0]

                if len(iLine) % 2 == 1:
                    iLine = iLine[:-1]

                if len(iLine) > 10:
                    imgMask = Image.new('L', (XRANGE[1], YRANGE[1]), 0)
                    ImageDraw.Draw(imgMask).polygon(iLine, outline=1, fill=1)
                    mask += np.array(imgMask)
        masks.append(mask)
        trl_len.append(len(tmp))
    return masks,trl_len

for iSub in ['LSP02b','LSP05','LNP02']:

    print (iSub)
    if iSub == 'LSP02b':
        colorIdx = 0
        iElec = 'Unipolar: 01'
        weeks=4
    elif iSub == 'LSP05':
        colorIdx = 1
        iElec = 'Unipolar: 09'
        weeks = 4
    if iSub == 'LNP02':
        colorIdx = 2
        weeks = 12

    masks_tmp=[]
    masks=[]
    trllen_tmp=[]

    ImgParts = {'LSP02b': ['Blegs', 'Lsole'], 'LSP05': ['Blegs', 'Lsole'], 'LNP02': ['Blegs', 'Ldors', 'Lsole']}

    for week in range(0, 4):
        print("Loading Week "+ str(week+1))
        for figs in range(0, len(ImgParts[iSub])):
            df = pd.read_excel(iSub + '_Week' + str(week + 1) + '.xlsx', sheet_name=ImgParts[iSub][figs],header=None)
            masks.append(df)
        masks_tmp.append(masks)


    temp_max=[]
    for i in range(0,6):
        temp = []
        for j in range(0,4):
            if(len(masks_tmp[j][i])>0):
                temp.append(np.max(np.array(masks_tmp[j][i])))
            else:
                temp.append(None)
        temp_max.append(np.nanmax(temp))

    masks_norm_tmp=[]
    for i in range(0,6):
        masks_norm = []
        for j in range(0, weeks):
            if(temp_max[i]!=None):
                masks_norm.append(masks_tmp[j][i]/temp_max[i])
            else:
                masks_norm.append([])
        masks_norm_tmp.append(masks_norm)

    for week in range(1,weeks+1):
        figure = getFigTemplate(iSub)
        print('Week %d'%week)
        for idx in range(1, 3 * 2 + 1):
            print('Drawing '+imgName[idx-1])
            if iSub == 'LSP02b':
                figure.append_trace(
                    go.Heatmap(z=masks_norm_tmp[idx - 1][week - 1], zmin=0, zmax=1,
                               colorscale=[[0, "#FFFFFF"], [0.1, "#cceaeb"], [1, "#00777a"]]),
                    (idx - 1) / 2 + 1,
                    (idx - 1) % 2 + 1)
            elif iSub == 'LSP05':
                figure.append_trace(
                    go.Heatmap(z=masks_norm_tmp[idx - 1][week - 1], zmin=0, zmax=1, colorscale=[[0, "#FFFFFF"],[0.1, "#dbe4f4"],[1, "#3c61a1"]]),
                    (idx - 1) / 2 + 1,
                    (idx - 1) % 2 + 1)
            elif iSub == 'LNP02':
                figure.append_trace(
                    go.Heatmap(z=masks_norm_tmp[idx - 1][week - 1], zmin=0, zmax=1, colorscale=[[0, "#FFFFFF"],[0.1, "#efdfec"],[1, "#8c4c7e"]]),
                    (idx - 1) / 2 + 1,
                    (idx - 1) % 2 + 1)
        print('Saving plot')
        figure.show()
        # figure.write_image('P://analysis//human//uh3_stim//RF_heatmaps//Normalized to Main Figure//%s//%s_Week%d.svg' % (iSub, iElec.replace(":", "_"), week))