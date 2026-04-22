import os
import re

def ano_linac_traj_learn(filePath: str, redcapID: str, patID: str) -> int:
    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_linac_traj_learn(
                    os.path.join(filePath, subpath), redcapID, patID
                )

    elif os.path.isfile(filePath) and filePath.endswith(".bin"):
        print("This is a linac trajectory log:", filePath)
        filename = os.path.basename(filePath)

        with open(filePath, "rb") as file:
            binaryData = file.read()

        if not patID.strip():
            # Try to extract patient ID from inside the file
            match = re.search(r'Patient ID:[ \t]*([^\s\x00]+)', binaryData.decode('latin-1'))
            if match:
                patID = match.group(1)
                print(f"Patient ID extracted from file: '{patID}'")
            else:
                # Fall back to filename prefix
                patID = filename.split('_')[0]
                print(f"Patient ID extracted from filename: '{patID}'")

        IDLength = len(patID)
        replaceContent = redcapID[:IDLength].ljust(IDLength, 'x')

        patIDBytes = patID.encode('latin-1')
        replaceBytes = replaceContent.encode('latin-1')

        if patIDBytes in binaryData:
            binaryData = binaryData.replace(patIDBytes, replaceBytes)

            newFilename = filename.replace(patID, replaceContent)
            outputFilePath = os.path.join(os.path.dirname(filePath), newFilename)

            with open(outputFilePath, "wb") as file:
                file.write(binaryData)
            print(f"Patient ID '{patID}' replaced with REDCap ID '{replaceContent}'. Output: {newFilename}")
            numberOfFileAnonymised += 1
        else:
            print(f"Patient ID '{patID}' not found inside the file.")

    return numberOfFileAnonymised
