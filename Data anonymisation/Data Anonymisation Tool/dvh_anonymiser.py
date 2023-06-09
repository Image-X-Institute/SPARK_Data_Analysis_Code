import os


def ano_dvh(filePath: str, trogID: str) -> int:

    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("This is a directory:", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_dvh(filePath + "/" + subpath, trogID)
    elif os.path.isfile(filePath) and ("DVH" in filePath):
        flag = 0
        if filePath.endswith(".txt"):
            print("This is a dvh text file:", filePath)
            lines = []
            with open(filePath, "r") as f:
                lines = f.readlines()
                f.close()
            with open(filePath, "w") as f:
                for line in lines:
                    if "Patient Name" in line or "Patient ID" in line:
                        temp = line.split(":")
                        temp[1] = " " + trogID + "\n"
                        line = ":".join(temp)
                        f.write(line)
                        flag = 1
                        pass
                    else:
                        f.write(line)
                f.close()
        if flag == 1:
            numberOfFileAnonymised += 1

    return numberOfFileAnonymised
