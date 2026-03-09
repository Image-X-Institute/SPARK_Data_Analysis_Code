import xml.etree.ElementTree as ET
import os


def ano_frame(filePath: str, trogID: str) -> int:

    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            # ignore hidden folders
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_frame(filePath + "/" + subpath, trogID)
    elif os.path.isfile(filePath) and ("_Frames.xml" in filePath.split("/")[-1]):
        print("This is a frame file:", filePath)
        numberOfFileAnonymised += 1
        tree = ET.parse(filePath)
        root = tree.getroot()
        for fn in root.iter("FirstName"):
            fn.text = str(trogID)

        for ln in root.iter("LastName"):
            ln.text = str(trogID)

        for id in root.findall("./Patient/ID"):
            id.text = str(trogID)

        for description in root.iter("Description"):
                    description.text = ""

        tree.write(filePath)

        
    else:
        pass

    return numberOfFileAnonymised
