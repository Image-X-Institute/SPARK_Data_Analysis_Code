import os


def ano_acq(filePath: str) -> int:

    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_acq(filePath + "/" + subpath)
    elif os.path.isfile(filePath) and ("acquisition" in filePath.split("/")[-1]):
        print("This is a acquisition log:", filePath)
        flag = 0
        lines = []
        with open(filePath, "r") as f:
            lines = f.readlines()
            f.close()
        with open(filePath, "w") as f:
            for line in lines:
                if "kvFramePath" in line or "mvFramePath" in line:
                    flag = 1
                    pass
                else:
                    f.write(line)
            f.close()
        if flag == 1:
            numberOfFileAnonymised += 1
    return numberOfFileAnonymised
