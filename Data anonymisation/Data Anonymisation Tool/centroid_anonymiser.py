import os


def ano_centroid(filePath: str, trogID: str) -> int:
    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_centroid(filePath + "/" + subpath, trogID)
    elif os.path.isfile(filePath) and ("centroid" in filePath.split("/")[-1].lower()):
        if filePath.endswith(".txt"):
            print("This is a centroid file:", filePath)
            with open(filePath, "r") as f:
                lines = f.readlines()
                f.close()
            lines[0] = trogID + "\n"
            lines[1] = trogID + " , " + trogID + "\n"
            # print(filePath)
            temp = filePath.split("/")
            temp[-1] = trogID + "_" + "Centroid.txt"
            newPath = "/".join(temp)
            print("New file name:", newPath)

            with open(filePath, "w") as f:
                for line in lines:
                    f.write(line)

            os.rename(filePath, newPath)
        numberOfFileAnonymised += 1

    return numberOfFileAnonymised
