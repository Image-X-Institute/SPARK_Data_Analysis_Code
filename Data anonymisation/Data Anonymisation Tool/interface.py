from tkinter import *
from tkinter import ttk

from widgets import *


def main():
    # Create an instance of tkinter window

    win.geometry("650x450")
    win.title("Data Anonymizer")

    frm_label.pack()
    # tell frame not to let its children control its size
    frm_input.pack_propagate(0)
    frm_input.pack(fill="both", side=LEFT, expand="True")
    frm_datatype.pack_propagate(0)
    frm_datatype.pack(fill="both", side=RIGHT, expand="True")

    # Create an instance of style class
    style = ttk.Style(win)

    # Create a label widget
    label.pack(pady=20)

    # Create widgets under title "treatment summary"
    # For user inputting Center name
    label1.grid(row=0, column=0, pady=5)
    entry1.grid(row=0, column=1, pady=5)

    # For user inputting TROG patient id
    label2.grid(row=1, column=0, pady=5)
    entry2.grid(row=1, column=1, pady=5)

    # For user inputting fraction no
    label3.grid(row=2, column=0, pady=5)
    entry3.grid(row=2, column=1, pady=5)

    # For user inputting dose prescription
    label4.grid(row=3, column=0, pady=5)
    entry4.grid(row=3, column=1, pady=5)

    # For user inputting arcs
    label5.grid(row=4, column=0, pady=5)
    entry5.grid(row=4, column=1, pady=5)

    # For user inputting arcs with angles
    label6.grid(row=5, column=0, pady=5)
    entry6.grid(row=5, column=1, pady=5)

    # For user inputting KIM tolerances
    label7.grid(row=6, column=0, pady=5)
    entry7.grid(row=6, column=1, pady=5)

    # For user inputting linac types
    label8.grid(row=7, column=0, pady=5)
    entry8.grid(row=7, column=1, pady=5)

    # For user inputting some notes
    label9.grid(row=8, column=0, pady=5)
    entry9.grid(row=8, column=1, pady=5)

    # Create widgets under title "clinical trial data anonymisation tool"
    # For user selecting datatype to be anonymised
    label10.grid(row=0, column=0)
    menu1.grid(row=0, column=1)

    # For user inputting TROG id in anonymisation
    label11.grid(row=1, column=0, pady=5)
    entry11.grid(row=1, column=1, pady=5)

    label12.grid(row=2, column=0)
    menu2.grid(row=2, column=1)

    # Create a button to open the dialog box

    button1.grid(row=3, column=0)
    button2.grid(row=3, column=1)

    # Create textbox to show the operation logs
    
    outputPanel.grid(row=5, columnspan = 2, sticky='NSWE', padx=5, pady=5)
    sys.stdout = StdoutRedirector(outputPanel)

    win.mainloop()


if __name__ == "__main__":
    main()
