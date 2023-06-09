import os
import matplotlib.pyplot as plt


def openFile(path):
    data = []
    label = []
    with open(path) as f:
        for line in f:
            if line.startswith("Frame"):
                label = line.split(",")
            else:
                data.append(line.split(", "))
        f.close()
    return data, label


def getTimeGantryData(path):

    time_gantry = []
    last_time = 0
    last_index = 0
    CBCT_ends_temp = []
    CBCT_ends = []
    CBCT_starts = []
    for fx in path:
        temp = []  # temp[[time,gantry]]
        for file in os.listdir(fx):
            file = fx + "\\" + file
            if (
                (file.split("\\")[-1]).startswith("MarkerLocationsGA")
                and os.path.isfile(file)
                and (".txt" in file)
            ):
                print(file)
                data = []
                label = []
                data, label = openFile(file)
                # check if the file has a filename to be deleted
                if label == [] or label[2].strip() == "Gantry":
                    for item in data:
                        temp.append([float(item[1].replace(',','')), float(item[2].replace(',',''))])
                
        print(len(temp))    
        
        mark_temp, CBCT_ends_temp = findCBCTEndPoints(temp)
        # mark_temp, CBCT_ends_temp = pretreatment_vs_treatment(temp)

        for data in mark_temp:
            # print('data:', data)
            # print('lasttime',last_time)
            data[0] = data[0] + last_time
        for point in CBCT_ends_temp:
            point[0] = point[0] + last_time
        #     point[3] += last_index

        if mark_temp[2][1] > mark_temp[0][1]:
            start_pos = 'bottom'
        else: start_pos = 'top'
        CBCT_starts.append([mark_temp[0][0], mark_temp[0][1], start_pos])

        CBCT_ends += CBCT_ends_temp
        time_gantry = time_gantry + mark_temp
        # print(time_gantry)
        print(fx)
        print("time", time_gantry[-1][0])
        last_time = time_gantry[-1][0]
        last_index += len(mark_temp)
        print(last_time)

    return time_gantry, CBCT_ends, CBCT_starts


def findCBCTEndPoints(temp):
    t = 0
    s = 0
    x0 = -1
    y0 = -1
    pos = ""
    CBCT_end_points = []
    CBCT_start_points = []
    while t < len(temp) - 1:
        if t != 0 and temp[t][0] == 0:
            s = t
        if (temp[t + 1][0] - temp[t][0]) > 80: #check if there is a time gap between CBCT and arc1
            # x0 = temp[t][1]
            # y0 = temp[t][2]
            break
        else:
            t += 1

    if s > 0:
        for i in range(s, t + 1):
            # temp[i][1] += temp[s-1][1]
            temp[i][1] += 40

    # CBCT_start_points.append([temp[s][0],temp[s][1]])

    if t == len(temp) - 1:
        pass
    else:
        x0 = temp[t][0]
        y0 = temp[t][1]
        if temp[t - 1][1] >= y0:
            pos = "bottom"
        else:
            pos = "top"
        CBCT_end_points.append([x0, y0, pos])
    return temp, CBCT_end_points


def findCBCTEndPointsInRNSH(logs):
    t = 0
    s = 0
    x0 = -1
    y0 = -1
    pos = ""
    possible_end_points = []
    CBCT_end_points = []

    gantry = [coor[1] for coor in logs]
    min_gantry = min(gantry)
    print("min:",min_gantry)
    while t < len(logs) - 1:
        # find if there is more than one CBCT, if so add the end time of the former CBCT data to the latter one
        if t != 0 and logs[t][0] == 0:
            s = t

        if (logs[t + 1][0] - logs[t][0]) > 5:
            print("t:", t)
            print("time:", logs[t][0])
            print("next time", logs[t+1][0])
            possible_end_points.append(t)
            print(logs[t][0],logs[t][1])
        t += 1

    print("possible_end_points", possible_end_points)


    for index in possible_end_points:
        print(logs[index])
        if index == len(logs) - 1:
            pass
        elif abs(logs[index][1] - min_gantry) < 10:
            x0 = logs[index][0]
            y0 = logs[index][1]
            if logs[index - 1][1] >= y0:
                pos = "bottom"
            else:
                pos = "top"
            CBCT_end_points.append([x0, y0, pos, index+1])
    print("CBCT_end_points", CBCT_end_points)
    return logs, CBCT_end_points

def findCBCTEndPointsInLiverpool(logs):
    t = 0
    s = 0
    x0 = -1
    y0 = -1
    pos = ""
    possible_end_points = []
    CBCT_end_points = []

    gantry = [coor[1] for coor in logs]
    max_gantry = max(gantry)
    print("min:",max_gantry)
    while t < len(logs) - 1:
        # find if there is more than one CBCT
        if t != 0 and logs[t][0] == 0:
            s = t

        if (logs[t + 1][0] - logs[t][0]) > 5:
            print("t:", t)
            print("time:", logs[t][0])
            print("next time", logs[t+1][0])
            possible_end_points.append(t)
            print(logs[t][0],logs[t][1])
        t += 1

    print("possible_end_points", possible_end_points)


    for index in possible_end_points:
        print(logs[index])
        if index == len(logs) - 1:
            pass
        elif abs(logs[index][1] - max_gantry) < 10:
            x0 = logs[index][0]
            y0 = logs[index][1]
            if logs[index - 1][1] >= y0:
                pos = "bottom"
            else:
                pos = "top"
            CBCT_end_points.append([x0, y0, pos, index+1])
    print("CBCT_end_points", CBCT_end_points)
    return logs, CBCT_end_points

def plotData(folders):

    folder_path = folders[0].split("\\")
    image_name = (
        folder_path[-4] + "_" + folder_path[-2] + "_" + folder_path[-1].split("-")[0]
    )
    save_path = folders[0] + "\\" + image_name + ".png"

    time_gantry, CBCT_ends, CBCT_starts = getTimeGantryData(folders)

    y_gantry = []
    x_time = []

    for data in time_gantry:
        x_time.append(data[0])
        y_gantry.append(data[1])

    
    indexs = []
    plt.xlabel("Time in sec")
    plt.ylabel("kV Gantry in degree")
    plt.plot(x_time, y_gantry, "o", markersize=5)
    # CBCT_starts[1] = [584.992, 22, 'top']
    
    # CBCT_ends.append([857.865, -29.94, 'top'])

# CBCT_ends.append([time, gantry, position])
    print(CBCT_ends)

    if CBCT_ends:
        for coor in CBCT_ends:
            plt.plot(coor[0], coor[1], "s")
            if coor[2] == "top":
                text_position = (-20, 13)
            else:
                text_position = (-20, -25)

            plt.annotate(
                "CBCT ends",
                (coor[0], coor[1]),
                xytext=text_position,
                textcoords="offset pixels",
            )
    
    # if CBCT_starts:
    #     for coor in CBCT_starts:
    #         plt.plot(coor[0], coor[1], "s")
    #         if coor[2] == "top":
    #             text_position = (-20, 13)
    #         else:
    #             text_position = (-20, -25)

    #         plt.annotate(
    #             "CBCT starts",
    #             (coor[0], coor[1]),
    #             xytext=text_position,
    #             textcoords="offset pixels",
    #         )


# if the data is from RNSH, use the below code and comment from line 219 to 240
    # print(CBCT_ends)
    # if CBCT_ends:
    #     for coor in CBCT_ends:
    #         indexs.append(coor[3])
    # # indexs[0] = 609
    # x_time_CBCT = x_time[:indexs[0]]
    # x_time_treatment = x_time[indexs[0]:]
    # y_gantry_CBCT = y_gantry[:indexs[0]]
    # y_gantry_treatment = y_gantry[indexs[0]:]

    # plt.plot(x_time_CBCT, y_gantry_CBCT, "ro", markersize=5, label= "kV fluoro only imaging")
    # plt.plot(x_time_treatment, y_gantry_treatment, "go", markersize=5, label = "Treatment arc")
    plt.legend(loc = 'best')

    plt.title("kV gantry rotation vs KIM-measured time")
    plt.savefig(save_path)
    plt.show()
    # plt.close()


def main():

    # path = [r""]
    folders = [
        r"",
    ]
    # folders.append(path)
    plotData(folders)

if __name__ == '__main__':
    main()
