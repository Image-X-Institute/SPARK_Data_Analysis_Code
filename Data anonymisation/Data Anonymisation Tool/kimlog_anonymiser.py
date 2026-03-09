import os
import re
from typing import Union


def open_file(path: str) -> Union[list, str]:
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


def ano_kimlogs(filePath: str) -> int:
    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("This is a directory", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_kimlogs(
                    filePath + "\\" + subpath,
                )
    elif (
        os.path.isfile(filePath)
        and (".txt" in filePath)
        and ("MarkerLocations" in filePath.split("\\")[-1])
    ):
        print("This is a KIM log file:", filePath)
        data = []
        label = ""
        data, label = open_file(filePath)

        # check if the file has a filepath to be deleted
        if label.endswith("Filename\n") or data[0][-1].endswith(("tiff\n", "hnd\n")):
            for item in data:
                fileName = item[-1].strip()
                if not fileName.startswith(("Ch", "Frame")):
                    # print(fileName)
                    # if there is a ',' in file path, item[-2] would be the first half of the filepath
                    if re.search("^.?[a-zA-Z]", item[-2]):
                        item.pop(-2)

                    item[-1] = item[-1].split("\\")
                    temp = item[-1][-1]
                    item[-1] = " " + temp.lstrip()
                # save data in a new file
                # p = filePath.split(".")
                # p[0] = p[0] + "_del_path"

            with open(filePath, "w") as n_f:
                n_f.write(label)
                for line in data:
                    n_f.write(",".join(line))
                n_f.close()
            numberOfFileAnonymised += 1
        else:
            pass
    return numberOfFileAnonymised
