import os

# INI configuration files are tiny; anything larger is projection/volume data
# and is skipped when searching a folder.
MAX_INI_FILE_SIZE = 1024 * 1024  # 1 MB

# Known non-text data stored alongside the reconstruction INI files
BINARY_EXTENSIONS = (".dcm", ".his", ".scan", ".img", ".raw", ".zip", ".png", ".jpg")


def is_dicom_file(filePath: str) -> bool:
    # DICOM files carry the magic bytes "DICM" at offset 128,
    # even when saved without a .dcm extension
    try:
        with open(filePath, "rb") as f:
            f.seek(128)
            return f.read(4) == b"DICM"
    except OSError:
        return False


def has_identification_section(filePath: str) -> bool:
    try:
        with open(filePath, "r", encoding="latin-1") as f:
            for line in f:
                if line.strip().upper() == "[IDENTIFICATION]":
                    return True
    except OSError:
        return False
    return False


def is_recon_ini_file(filePath: str) -> bool:
    extension = os.path.splitext(filePath)[1].lower()
    if extension in BINARY_EXTENSIONS:
        return False
    try:
        if os.path.getsize(filePath) > MAX_INI_FILE_SIZE:
            return False
    except OSError:
        return False
    if is_dicom_file(filePath):
        return False
    return has_identification_section(filePath)


def ano_recon_file(filePath: str) -> int:
    with open(filePath, "r", encoding="latin-1") as f:
        lines = f.readlines()

    outputLines = []
    removedLines = 0
    patID = ""
    inIdentification = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            inIdentification = stripped.upper() == "[IDENTIFICATION]"
            outputLines.append(line)
        elif inIdentification and stripped:
            if stripped.upper().startswith("PATIENTID="):
                patID = stripped.split("=", 1)[1].strip()
            removedLines += 1
        else:
            outputLines.append(line)

    if removedLines == 0:
        print("No [IDENTIFICATION] entries found in:", filePath)
        return 0

    with open(filePath, "w", encoding="latin-1") as f:
        f.writelines(outputLines)
    print(f"Removed {removedLines} line(s) under [IDENTIFICATION] in: {filePath}")

    if patID:
        remaining = sum(patID in line for line in outputLines)
        if remaining:
            print(
                f"Warning: patient ID '{patID}' still appears in {remaining} "
                "other line(s) of this file (e.g. directory paths under [XVI])."
            )
    return 1


def ano_cbct_recon(filePath: str) -> int:
    numberOfFileAnonymised = 0
    if os.path.isdir(filePath):
        print("this is a directory", filePath)
        for subpath in os.listdir(filePath):
            if subpath.startswith("."):
                continue
            fullPath = os.path.join(filePath, subpath)
            if os.path.isdir(fullPath):
                numberOfFileAnonymised += ano_cbct_recon(fullPath)
            elif is_recon_ini_file(fullPath):
                print("This is a CBCT reconstruction file:", fullPath)
                numberOfFileAnonymised += ano_recon_file(fullPath)
    elif os.path.isfile(filePath):
        print("This is a CBCT reconstruction file:", filePath)
        numberOfFileAnonymised += ano_recon_file(filePath)
    return numberOfFileAnonymised
