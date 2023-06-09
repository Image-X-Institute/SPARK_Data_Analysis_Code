from tkinter import *
from tkinter import filedialog
from tkinter import scrolledtext
import os
import threading

from dicom_anonymiser import *
from kimlog_anonymiser import *
from frame_anonymiser import *
from dvh_anonymiser import *
from centroid_anonymiser import *
from acq_anonymiser import *

win = Tk()

frm_label = Frame()
frm_input = LabelFrame(text="Treatment Summary")
frm_datatype = LabelFrame(text="Data Transfer")
frm_submit = Frame()

# treatment summary labels and entries
label1 = Label(frm_input, text="Centre")
entry1 = Entry(frm_input, width=10)

label2 = Label(frm_input, text="TROG patient id")
entry2 = Entry(frm_input, width=10)

label3 = Label(frm_input, text="Fraction")
entry3 = Entry(frm_input, width=10)

label4 = Label(frm_input, text="Dose Prescription")
entry4 = Entry(frm_input, width=10)

label5 = Label(frm_input, text="Arcs")
entry5 = Entry(frm_input, width=10)

label6 = Label(frm_input, text="Arcs with angles")
entry6 = Entry(frm_input, width=10)

label7 = Label(frm_input, text="KIM tolerances")
entry7 = Entry(frm_input, width=10)

label8 = Label(frm_input, text="Linac type")
entry8 = Entry(frm_input, width=10)

label9 = Label(frm_input, text="Notes")
entry9 = Entry(frm_input, width=10)

# Create widgets for clinical Trial Data Anonymization Tool

label10 = Label(frm_datatype, text="Data type: ")

label11 = Label(frm_datatype, text="Replace with TROG ID: ")
entry11 = Entry(frm_datatype, width=10)

label12 = Label(frm_datatype, text="Lianc: ")

data_type = [
    "Choose datatype",
    "DICOM",
    "KIM logs",
    "Frame file",
    "DVH file",
    # "Centroid File",
    # "Acquisition log",
]

menu_datatype = StringVar(frm_datatype)
menu_datatype.set(data_type[0])
menu1 = OptionMenu(frm_datatype, menu_datatype, *data_type)

linac = ["none"]

menu_linac = StringVar(frm_datatype)
menu_linac.set(linac[0])
menu2 = OptionMenu(frm_datatype, menu_linac, *linac)


# Create a label of the interface
label = Label(frm_label, text="Data Anonymisation Tool", font="bold")

# Create a button to anonymize files

def open_folder():
    currdir = os.getcwd()
    tempdir = filedialog.askdirectory(
        parent=win, initialdir=currdir, title="Please select a directory"
    )
    if len(tempdir) > 0:
        print("You choose: %s" % tempdir)
    return tempdir


def open_file():
    currdir = os.getcwd()
    filepath = filedialog.askopenfilename(
        parent=win, initialdir=currdir, title="Please select a file"
    )
    if len(filepath) > 0:
        print("You choose: %s" % filepath)
    return filepath


def anonymise(filePath):
    # filePath = open_folder()
    trogID = entry11.get()
    count = 0
    if menu_datatype.get() == "Choose a datatype":
        pass
    elif menu_datatype.get() == "DICOM":
        print(menu_datatype.get(), "files are going to be anonymised.")
        print(f"Trog id is {trogID}.")
        #     cmd = "python dicom_anonymiser.py" + " " + "\"" + tempdir + "\"" + f" -w --patid {entry11.get()}"
        # os.system(cmd)
        count = dicomAnonymizer(
            filePath, overwriteFile=True, variables={"patientId": trogID}
        )

    elif menu_datatype.get() == "KIM logs":
        print(menu_datatype.get(), "are going to be anonymised.")
        count = ano_kimlogs(filePath)

    elif menu_datatype.get() == "Frame file":
        print(menu_datatype.get(), "files are going to be anonymised.")
        count = ano_frame(filePath, trogID)

    elif menu_datatype.get() == "DVH file":
        print(menu_datatype.get(), "are going to be anonymised.")
        count = ano_dvh(filePath, trogID)

    elif menu_datatype.get() == "Centroid File":
        print(menu_datatype.get(), "files are going to be anonymised.")
        count = ano_centroid(filePath, trogID)

    elif menu_datatype.get() == "Acquisition log":
        print(menu_datatype.get(), "files are going to be anonymised.")
        count = ano_acq(filePath)

    print(f"Anonymised {count} file(s)")


def start_anonymise_by_folder():
    threading.Thread(target=anonymise, args=(open_folder(),)).start()


def start_anonymise_by_file():
    threading.Thread(target=anonymise, args=(open_file(),)).start()


button1 = Button(
    frm_datatype, text="Anonymise by folder", command=start_anonymise_by_folder
)
button2 = Button(
    frm_datatype, text="Anonymise by file", command=start_anonymise_by_file
)

class StdoutRedirector(object):

    def __init__(self, text_area):
        self.text_area = text_area

    def write(self, str):
        self.text_area.insert(END, str)
        self.text_area.see(END)


# add Textbox, show output logs in textbox

outputPanel = scrolledtext.ScrolledText(frm_datatype, wrap='word', height = 11, width=50)

