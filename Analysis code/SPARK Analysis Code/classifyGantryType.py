# Detect gantry type by calculating the difference between KV Gantry angle and 
# the angle in the image file name at the end of each line in KIM logs.
# If the difference is around 0, it is detected as kV Gantry.
# If the difference is around 90, it is detected as MV Gantry.
# If the difference is around 180, it is detected as KV detector. 

import os

def open_file(path):
    data = []
    label = ""
    with open(path) as f:
        for line in f:
            if line.startswith("Frame"):
                label = line
            else:
                data.append(line.split(","))
        f.close()
    return data, label

# KV Gantry data[][2]
# GAF data[][-1] # Gantry File Angle

def classifyAngle(path):
    data = []
    label = ""
    c1 = 0
    c2 = 0
    c3 = 0
    if os.path.isfile(path) and ('.txt' in path) and ('MarkerLocationsGA' in path.split('\\')[-1]):
        data, label = open_file(path)
        extension = data[0][-1].split('.')[-1]
        for row in data:
            KV_gantry = float(row[2])
            GAF = float(row[-1].split('_')[-1].strip('.' + extension))
            diff = abs(KV_gantry-GAF)
            if diff == 0:
                # print(f"difference = {diff}: KV Gantry")
                c1 += 1
            elif diff > 89 and diff <= 91:
                # print(f"difference: = {diff}: MV Gantry")
                c2 += 1
            elif diff > 179 and diff <= 181:
                # print(f"difference: = {diff}: KV detector")
                c3 += 1
    else: print("Wrong file")
    print("KV Gantry: ", c1)
    print("MV Gantry: ", c2)
    print("MV detector: ", c3)

def main():
    folder_path = r''
    site = folder_path.split('\\')[5]
    for pat in range(3,6):
        for fx in range(1,6):
            path = folder_path + r'\PAT' + '0' + str(pat) + r'\Fx' + '0' + str(fx) + r'\MarkerLocationsGA_CouchShift_0.txt'
            if os.path.isfile(path):
                print(f'This is patient {pat} fraction {fx} in {site}')
                classifyAngle(path)


if __name__ == '__main__':
    main()


