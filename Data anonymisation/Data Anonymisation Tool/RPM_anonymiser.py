import os

def ano_RPM(filePath: str, trogID: str) -> int:
    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_RPM(filePath + "/" + subpath, trogID)
    elif os.path.isfile(filePath) and filePath.endswith(".vxp"):
        print("This is a vxp file:", filePath)
        with open(filePath, "r") as f:
            lines = f.readlines()
            f.close()

        for i, line in enumerate(lines):
            if "Patient_ID" in line:
                print(line)
                temp = line.split('=')
                temp[1] = trogID + '\n'
                lines[i] = '='.join(temp)

        with open(filePath, "w") as f:
            for line in lines:
                f.write(line)

        temp = filePath.split('/')
        temp[-1] = trogID + '_' + temp[-1].split('_')[1]
        newPath = '/'.join(temp)

        print("New file name:", newPath)
        os.rename(filePath,newPath)

        numberOfFileAnonymised += 1

    return numberOfFileAnonymised