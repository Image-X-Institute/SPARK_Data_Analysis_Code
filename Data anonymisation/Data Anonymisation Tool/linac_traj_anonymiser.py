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
        replace_content = '1234567890'
        with open(filePath, "rb") as file:
            binary_data = file.read()

        # Find the position of the patID in the binary_data
        start_position = binary_data.find(patID.encode())

        if start_position != -1:
            # Calculate the end position of the patID
            end_position = start_position + len(patID)

            # Replace the target content with the replace_content
            binary_data = (
                binary_data[:start_position]
                + replace_content.encode()
                + binary_data[end_position:]
            )

            # Write the modified binary data back to the file
            filename = filePath.split('/')[-1]
            if patID in filePath:
                patID = filename.split('_')[0]
                new_filename = filename.replace(patID, trogID)
                # output_filePath = filePath.replace(filename, new_filename)
            else:
                new_filename = "anon_" + filename
            output_filePath = filePath.replace(filename, new_filename)

            with open(output_filePath, "wb") as file:
                file.write(binary_data)
            print("Replacement successful!")

            numberOfFileAnonymised += 1
        else:
            print("Patient ID not found in the file.")

    return numberOfFileAnonymised