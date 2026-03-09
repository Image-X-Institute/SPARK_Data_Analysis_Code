using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace getkVAndMVTimestamps
{
    class Program
    {
        static void Main(string[] args)
        {
            // Inputs
            string parentPath = args[0];
            //"G:\\KIM Gating\\2 Patient Images\\Pat01\\Fx01";
            string outputPath = args[1];
            // "C:\\users\\desktop";
            //

            string kVFolder = parentPath + "\\KIM-KV";
            string MVFolder = parentPath + "\\KIM-MV";

            // Grab string of filenames
            string[] listOfkVImages = Directory.GetFiles(kVFolder, "*.tiff");
            string[] listOfMVImages = Directory.GetFiles(MVFolder, "*.tiff");

            // 1. Get the kV information first and output text file
            int noOfkVHNDFiles = listOfkVImages.Length;
            StreamWriter kVTextFile = new StreamWriter(outputPath + "\\kVTimestampsFromCSharp.txt");
            kVTextFile.WriteLine("n\tkVFilename\ttimestamp\th\tm\ts\tms");

            for (int n = 0; n < noOfkVHNDFiles; n++)
            {
                string kVFilename = listOfkVImages[n];
                FileInfo kVFileInfo = new FileInfo(kVFilename);

                // Get the Windows creation time stamp          
                DateTime kVTimestamp = kVFileInfo.LastWriteTime;
                double h = kVTimestamp.Hour;
                double m = kVTimestamp.Minute;
                double s = kVTimestamp.Second;
                double ms = kVTimestamp.Millisecond;
                // Total timestamp in seconds
                double timestamp = h * 60 * 60 + m * 60 + s + ms / 1000;

                kVFilename = Path.GetFileNameWithoutExtension(kVFilename);

                //Console.WriteLine(n + " " + kVFilename + " " + s + " " + ms + " " + timestamp);
                //Console.ReadLine();

                kVTextFile.WriteLine(n + 1 + "\t" + kVFilename + "\t" + timestamp + "\t" + h + "\t" + m + "\t" + s + "\t" + ms);
            }

            kVTextFile.Close();

            // 2. Get the MV information and output text file
            int noOfMVHNDFiles = listOfMVImages.Length;
            StreamWriter MVTextFile = new StreamWriter(outputPath + "\\MVTimestampsFromCSharp.txt");
            MVTextFile.WriteLine("n\tMVFilename\ttimestamp\th\tm\ts\tms");

            for (int n = 0; n < noOfMVHNDFiles; n++)
            {
                string MVFilename = listOfMVImages[n];
                FileInfo MVFileInfo = new FileInfo(MVFilename);

                // Get the Windows creation time stamp          
                DateTime MVTimestamp = MVFileInfo.LastWriteTime;
                double h = MVTimestamp.Hour;
                double m = MVTimestamp.Minute;
                double s = MVTimestamp.Second;
                double ms = MVTimestamp.Millisecond;
                // Total timestamp in seconds
                double timestamp = h * 60 * 60 + m * 60 + s + ms / 1000;

                MVFilename = Path.GetFileNameWithoutExtension(MVFilename);
                MVTextFile.WriteLine(n + 1 + "\t" + MVFilename + "\t" + timestamp + "\t" + h + "\t" + m + "\t" + s + "\t" + ms);
            }

            MVTextFile.Close();


        }
    }
}
