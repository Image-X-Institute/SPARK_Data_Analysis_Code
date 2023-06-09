# Analysis code

## SPARK Triangulation Code

The SPARK Triangulation Code performing kV/MV triangulation for post-treatment verification of KIM in four Centers. For details please look into the [KVMV triangulation documentation.docx](https://github.com/ACRF-Image-X-Institute/SPARK-data-analysis-code/blob/main/Analysis%20code/SPARK%20Triangulation%20Code/KVMV%20triangulation%20documentation.docx).

## SPARK Analysis Code
### classifyGantryAngle.py
The classifyGantryAngle.py is for determining gantry type in the image name (i.e., whether it is MV gantry, kV gantry or kV imager angle) by calculating the difference between KV source angle in the KIM log files and the gantry angle in the image file name.
If the difference is around 0, it is detected as kV Gantry.
If the difference is around 90, it is detected as MV Gantry.
If the difference is around 180, it is detected as KV detector.

For Elekta systems, the gantry angle in the Frames.xml file was always MV gantry.

#### How to use
Pass the folder path which contains KIM logs (MarkerLocationsGA_CouchShift.txt) to the variable ‘folder_path’ in main function, which the default is ‘’. Then run the script.

### DICOM.py
In DICOM.py there are two functions about processing dicom files. 

Function compare_dicom is to compare the differences in between two dicom file headers. The function was used compare the anonymised dicom file and the original one. It will print the result in the terminal. 

Function read_dicom_header is used to read the header information in a dicom file. The function will print the dicom header information in the terminal.

#### How to use
Pass the dicom file path into the parameter ‘path’ and run the script.

### plotTimeVSGantry.py
plotTimeVSGantry.py is to plot gantry vs time in kV images and point out the CBCT. Time and gantry are read from KIM log files (MarkerLocationsGA_CouchShift*.txt).

To detect the CBCT part, the code searches for the time interval between CBCT and treatment arcs. Usually, the time interval is larger than 80 and larger than the time interval between the treatment arcs. If such a time interval is found, which means it is the end of the CBCT. The CBCT start point is at the start of each fraction and the timestamps of CBCT starts points are 0.
If the data is from RNSH, use ‘findCBCTEndPointsInRNSH’ function in line 46. That’s because with the patients at RNSH, KIM was not run during the CBCT but instead a pre-treatment learning arc was performed, where the gantry was rotated while acquiring kV images, but treatment was not being delivered.

#### How to use
Pass the folder path to parameter ‘folders’ in the main function. The folder should contain the KIM log files (MarkerLocationsGA_CouchShift.txt). If there are more than one folder for one fraction you should pass them all. The parameter would be like:

```
Folders = [
	r”~/patient01/fx1-1”,
	r”~/patient01/fx1-2”,
]
```

Then run the script.
