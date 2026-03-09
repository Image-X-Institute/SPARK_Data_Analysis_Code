import difflib
import pydicom as dcm

def compare_dicom(path_1, path_2):

    text1 = []
    text2 = []

    ds_ori: dcm.FileDataset = dcm.dcmread(path_1)
    ds_ano: dcm.FileDataset = dcm.dcmread(path_2)

    line_num1 = 0
    line_num2 = 0

    for line in ds_ori:
        # print(line_num1)
        # print(str(line))
        text1.append(str(line))
        line_num1 += 1

    # return text
    for line in ds_ano:
        # print(line_num2)
        text2.append(str(line))
        # print(str(line))
        line_num2 += 1

    for line in difflib.unified_diff(
        text1, text2, fromfile=path_1, tofile=path_2, lineterm="", n=0
    ):
        print(line)

def read_dicom_header(path):
    path_1 = r""

    text1 = []

    ds: dcm.FileDataset = dcm.dcmread(path_1)

    line_num1 = 0

    for line in ds:
        # print(line_num1)
        # print(str(line))
        text1.append(str(line))
        line_num1 += 1

def main():
    path1 = r''
    path2 = r''
    read_dicom_header(path1)
    compare_dicom(path1,path2)

if __name__ == "__main__":
    main()
