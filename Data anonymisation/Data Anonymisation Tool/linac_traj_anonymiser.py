import os

def ano_linac_traj(filePath: str, trogID: str, patID: str) -> int:
    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            if not subpath.startswith("."):
                numberOfFileAnonymised += ano_linac_traj(filePath + "/" + subpath, trogID, patID)
    elif os.path.isfile(filePath) and filePath.endswith(".bin"):
        print("This is a linac trajectory log:", filePath)
        IDLength = len(patID)
        replaceContent = ''.join(str(i % 10) for i in range(1, IDLength + 1))
        with open(filePath, "rb") as file:
            binaryData = file.read()

        # Find the position of the patID in the binaryData
        startPosition = binaryData.find(patID.encode())

        if startPosition != -1:
            # Calculate the end position of the patID
            end_position = startPosition + len(patID)

            # Replace the target content with the replaceContent
            binaryData = (
                binaryData[:startPosition]
                + replaceContent.encode()
                + binaryData[end_position:]
            )

            # Write the modified binary data back to the file
            filename = filePath.split('/')[-1]
            if patID in filePath:
                patID = filename.split('_')[0]
                newFilename = filename.replace(patID, trogID)
                # outputFilePath = filePath.replace(filename, newFilename)
            else:
                newFilename = "anon_" + filename
            outputFilePath = filePath.replace(filename, newFilename)

            with open(outputFilePath, "wb") as file:
                file.write(binaryData)
            print("Replacement successful!")

            numberOfFileAnonymised += 1
        else:
            print("Patient ID not found in the file.")

    return numberOfFileAnonymised