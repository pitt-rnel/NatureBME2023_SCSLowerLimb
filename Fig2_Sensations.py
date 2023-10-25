import plotly.graph_objs as go
import numpy as np
from plotly import tools
from shapely.ops import cascaded_union
from shapely.geometry import box, Polygon, Point, LineString
from scipy.spatial import ConvexHull
import aggregateHelper as hf
import os
import base64
import pandas as pd

XRANGE = [513, 1293]
YRANGE = [50, 850]


colorOrder = ['rgba(0,149,153,1)', 'rgba(75,121,201,1)', 'rgba(175,95,158,1)', 'rgba(214,30,30,1)', 'rgba(148,103,189,1)','rgba(140,86,75,1)','rgba(227, 119,194,1)', 'rgba(23,190,207,1)', 'rgba(79,221,112,1)']
imgRoot = 'C:/Users/ROB106/OneDrive - University of Pittsburgh/Sensory Analysis/scs_uh3-master/scs_uh3-master/ImageBank/Dash'
imgList = ['Blegs', 'Flegs', 'dors_left', 'dors_right', 'sole_left', 'sole_right']
imgName = ['Blegs', 'Flegs', 'Ldors', 'Rdors', 'Lsole', 'Rsole']

min_num_of_trials = 1           # minimum number of polygons per electrode



def getFigTemplate(nRows, nCols, sub):
    figure = tools.make_subplots(rows=nRows, cols=nCols,
                                 subplot_titles=imgName, vertical_spacing =0.05)
    tmp = []
    if sub=='LSP02b':
        imgRoot = 'C:/Users/ROB106/OneDrive - University of Pittsburgh/Sensory Analysis/scs_uh3-master/scs_uh3-master/ImageBank/Dash/LSP02b'
    elif sub=='LSP05':
        imgRoot = 'C:/Users/ROB106/OneDrive - University of Pittsburgh/Sensory Analysis/scs_uh3-master/scs_uh3-master/ImageBank/Dash/LSP05'
    elif sub=='LNP02':
        imgRoot = 'C:/Users/ROB106/OneDrive - University of Pittsburgh/Sensory Analysis/scs_uh3-master/scs_uh3-master/ImageBank/Dash/LNP02'

    encodeList = []
    for img in imgList:
        imgPath = os.path.join(imgRoot, img + '.png')  # replace with your own image
        encodeList.append(base64.b64encode(open(imgPath, 'rb').read()))

    for idx in range(1, nRows * nCols + 1):

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

        tmp.append({
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
            'source': 'data:image/png;base64,{}'.format(encodeList[(idx % 6)-1])
        })

    figure['layout']['images'] = tmp
    figure['layout'].update(height=600*nRows, width=1750)

    return figure


def generateCumulativeElectrodeArea(lineList, colorIdx, rfImg, subject):
    dataList = []
    area = []
    centroids = []
    if len(lineList) >= min_num_of_trials:
        if subject=='LSP02b' and rfImg=='Flegs':
            dataList=[]
        else:
            newLineList = []
            rfIdx = imgName.index(rfImg)
            # clean up and split each line into multi polygons if necessary
            for iLine_preTrial in lineList:
                if iLine_preTrial != []:

                    iLine_preTrial = [x for x in iLine_preTrial if str(x) != 'nan']
                    if hasattr(iLine_preTrial[0],"__len__"):
                        iLine = sum(iLine_preTrial, [])      # combine all reps
                    else:
                        iLine = iLine_preTrial

                    X = iLine[0::2]
                    Y = iLine[1::2]
                    pointList = [iPoint for iPoint in zip(X, Y)]# if
                    pointDiff = []
                    for iPoint1, iPoint2 in zip(pointList[:-1], pointList[1:]):
                        pointDiff.append(Point(iPoint1).distance(Point(iPoint2)))
                    lineSegments = list(np.where(np.array(pointDiff)>100)[0])       # divide into segments where distance in consecutive points is greater than twice the mean distance
                    lineSegments.insert(0, 0)
                    lineSegments.append(len(pointDiff))
                    newLineList.extend([pointList[start:fin] for start, fin in zip(lineSegments[:-1], lineSegments[1:]) if fin-start > 3])

            numLines = len(newLineList)
            if numLines >= min_num_of_trials:
                # get all hulls
                hullCoords = []
                for points in newLineList:
                    if len(points) < 10:          # at least 3 needed for convex hull
                        points = zip([0, -1, 0, 1], [1, 0, 1, -1])
                        hull = ConvexHull(np.array(points))
                    else:
                        try:        # this is just for those 2 instances where the artifact is from 1e-27 to 0
                            if subject=='LNP02':
                                hull = LineString(np.array(points)).buffer(10)
                                hullCoords.append(hull)
                            else:
                                hull = ConvexHull(np.array(points))
                                hullCoords.append(Polygon([points[ix] for ix in hull.vertices]))

                        except:
                            print('')


                if hullCoords:
                    for temp in hullCoords:
                        polyUnion = cascaded_union(temp)
                        if polyUnion.geometryType() == 'Polygon':
                            x, y = polyUnion.exterior.xy
                            dataList.append(go.Scatter(x=list(x), y=list(y), mode='none', fill='toself', opacity=0.4,
                                                       hoverinfo='none',
                                                       fillcolor=hf.colorOrder[colorIdx]))
                            area.append(polyUnion.area)
                            centroids.append(polyUnion.centroid)
                        else:
                            for iPoly in polyUnion:      # in case of non overlapping RFs polyUnion can be MultiPolygon
                                x, y = iPoly.exterior.xy
                                dataList.append(go.Scatter(x=list(x), y=list(y), mode='lines', opacity=0.4,
                                                       hoverinfo='none',
                                                       line_color=hf.colorOrder[colorIdx]))


        return dataList


subjects=['LSP02b','LSP05','LNP02']
ImgParts={'LSP02b': [{'Electrode1' : ['Blegs' , 'Lsole'], 'Electrode2' : ['Blegs', 'Ldors']}], 'LSP05': [{'Electrode1' : ['Flegs' , 'Ldors', 'Lsole'], 'Electrode2' : ['Blegs', 'Ldors','Lsole']}], 'LNP02': [{'Electrode1' : ['Blegs' , 'Lsole'], 'Electrode2' : ['Flegs', 'Ldors']}]}
electrodes={'LSP02b': ['Electrode1', 'Electrode2'], 'LSP05': ['Electrode1', 'Electrode2'], 'LNP02': ['Electrode1', 'Electrode2']}

for sub in subjects:
    if sub=='LSP02b':
        color_indx=0
    elif sub=='LSP05':
        color_indx=1
    elif sub=='LNP02':
        color_indx=2

    for elecs in range(0,2):
        finalFig_all = getFigTemplate(3, 2, sub)  # len(subjectList), len(hf.imgName))
        colIX = 0
        resultDict = {}
        for figs in range(0, len(ImgParts[sub][0][electrodes[sub][elecs]])):
            df = pd.read_excel(sub+'_'+electrodes[sub][elecs]+'.xlsx', sheet_name=ImgParts[sub][0][electrodes[sub][elecs]][figs])
            resultDict.setdefault(ImgParts[sub][0][electrodes[sub][elecs]][figs],[]).append(df)
        for img in resultDict.keys():
            plotlyData = generateCumulativeElectrodeArea(resultDict[img][0].values.tolist(), color_indx,img, sub)
            if plotlyData:
                [finalFig_all.append_trace(trace,  (hf.imgName.index(img))/2+1, (hf.imgName.index(img))%2+1, ) for trace in plotlyData]

            colIX = (colIX + 1) % 9
        finalFig_all.show()

