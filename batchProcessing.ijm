saveAs("Results", "/home/helfrich/Images/2013_05_06_A.N.436u.437/General Results.txt");
run("Select All");
run("Select All");
roiManager("Select", 0);
run("Select All");
roiManager("Select", newArray(0,1,2,3,4,5));
roiManager("Save", "/home/helfrich/Images/2013_05_06_A.N.436u.437/RoiSet.zip");
run("MASTER PLUGIN", "preprocessing segmentation");

# Load file ($name)
# Run MASTER PLUGIN
# Save output (general results and ROIs) to file $name_results.csv and $name_rois.zip
# Continue with new file