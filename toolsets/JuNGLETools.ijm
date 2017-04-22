macro "-" {} //menu divider

macro "Generate Results Table Action Tool - C037R00ffL22d2L24d4L26d6D88D8aD8c" {
	generateResultsTable();
}

macro "Generate Results Table" {
	generateResultsTable();
}

function generateResultsTable() {
	/* 
	 *  TODO Is it possible to run this macro with the ROI manager in batch mode
	 *  -> batch mode gives a huge performance boost
	 */
	requires("1.48d");

	// Get number of channels
	Stack.getDimensions(width, height, channels, slices, frames);

	fakeZStack = false;
	if (slices > 1) {
		fakeZStack = true;
		frames = nSlices;
	}

	// Initialize arrays for storing cell numbers and areas
	cellNumber = newArray(frames);
	
	overallArea = newArray(frames);
	areaStddevS1 = newArray(frames);
	areaStddevS2 = newArray(frames);
	overallAreaStddev = newArray(frames);
	
	overallFluorescence = newArray(frames*channels);
	fluorescenceStddevS1 = newArray(frames*channels);
	fluorescenceStddevS2 = newArray(frames*channels);
	overallFluorescenceStddev = newArray(frames*channels);
	
	// Iterate over Overlay entries
	n = Overlay.size;
	
	for (i=0; i<n; i++) {
		// Select a Roi
		Overlay.activateSelection(i);

		// Get slice number and area for the selected ROI
		Stack.getPosition(channel, slice, frame);

		if (fakeZStack) {
			frame = getSliceNumber();
		}
		
		getStatistics(area);

		// Iterate over channels to get intensity
		// NOTE: Position is 1-based
		for (c=2; c<=channels; c++) {
			// If we have two or more channels it's unlikely that we have a fake z-stack
			Stack.setPosition(c, slice, frame);

			getStatistics(area,mean);
			// Measurements
			//List.setMeasurements;
			//meanIntensity = List.getValue("Mean");

			// Compute the idx using an offset and the current frame
			idx = (frames * (c-1)) + (frame - 1);
			overallFluorescence[idx] += mean;
			fluorescenceStddevS1[idx] += mean;
			fluorescenceStddevS2[idx] += pow(mean,2);
		}

		// Add values to the arrays
		cellNumber[frame-1] += 1;
		overallArea[frame-1] += area;
		areaStddevS1[frame-1] += area;
		areaStddevS2[frame-1] += pow(area,2);
	}

	/* COMPUTE STANDARD DEVIATION OF AREA */
	// Iterate over frames
	for (j=0; j<frames; j++) {
		N = cellNumber[j];
		
		// Compute stddev of area
		s2 = areaStddevS2[j];
		s1 = areaStddevS1[j];
		overallAreaStddev[j] = sqrt((N * s2 - pow(s1, 2)) / (N * (N-1)));
	}

	/* COMPUTE STANDARD DEVIATION OF FLUORESCENCE */
	// Iterate over frames
	for (k=0; k<frames; k++) {
		N = cellNumber[k];

		// Iterate over channels
		for (c=2; c<=channels; c++) {
			// Determine correct index
			// Note: k is zero-based in compared to the previous computation of idx
			idx = (frames * (c-1)) + k;
			
			// Compute stddev of fluorescence
			s2 = fluorescenceStddevS2[idx];
			s1 = fluorescenceStddevS1[idx];
			overallFluorescenceStddev[idx] = sqrt((N * s2 - pow(s1, 2)) / (N * (N-1)));
		}
	}

	/* DEBUG OUTPUT
	Array.show("Array", overallFluorescence);
	Array.show("StdDev S1 Array", fluorescenceStddevS1);
	Array.show("StdDev S2 Array", fluorescenceStddevS2);
	Array.show("StdDev Array", overallFluorescenceStddev);
	Array.show("CellNumber", cellNumber); */
	
	//overallFluorescence1 = Array.slice(overallFluorescence, 0, frames);
	if (channels >= 2) {
		overallFluorescence2 = Array.slice(overallFluorescence, frames, (frames*2));
		overallFluorescenceStddev2 = Array.slice(overallFluorescenceStddev, frames, (frames*2));
	}

	if (channels >= 3) {
		overallFluorescence3 = Array.slice(overallFluorescence, (frames*2), (frames*3));
		overallFluorescenceStddev3 = Array.slice(overallFluorescenceStddev, (frames*2), (frames*3));
	}

	if (channels >= 4) {
		overallFluorescence4 = Array.slice(overallFluorescence, (frames*3), (frames*4));
		overallFluorescenceStddev4 = Array.slice(overallFluorescenceStddev, (frames*3), (frames*4));
	}

	// Create array of frame numbers and convert numbers
	frameNumber = newArray(frames);
	for (j=0; j<frameNumber.length; j++) {
		frameNumber[j] = d2s(j+1, 0);
		cellNumber[j] = d2s(cellNumber[j], 0);
		overallArea[j] = d2s(overallArea[j], 2);
		//overallFluorescence1[j] = d2s(overallFluorescence1[j]/cellNumber[j], 2);
		if (channels >= 2) {
			overallFluorescence2[j] = d2s(overallFluorescence2[j]/cellNumber[j], 2);
			overallFluorescenceStddev2[j] = d2s(overallFluorescenceStddev2[j], 2);
		}
		if (channels >= 3) {
			overallFluorescence3[j] = d2s(overallFluorescence3[j]/cellNumber[j], 2);
			overallFluorescenceStddev3[j] = d2s(overallFluorescenceStddev3[j], 2);
		}
		if (channels >= 4) {
			overallFluorescence4[j] = d2s(overallFluorescence4[j]/cellNumber[j], 2);
			overallFluorescenceStddev4[j] = d2s(overallFluorescenceStddev4[j], 2);
		}
	}

	//for (j=0; j<overallFluorescence.length; j++) {
	//	overallFluorescence[j] = d2s(overallFluorescence[j], 2);
	//}
	
	Frame = frameNumber;
	Number = cellNumber;
	Area = overallArea;
	AreaStdDev = overallAreaStddev;
  	//Fluorescence = Array.slice(overallFluorescence, 0, frames-1);
  	//Fluorescence1 = overallFluorescence1;
  	
  	if (channels >= 2) {
  		Fluorescence1Mean = overallFluorescence2;
  		Fluorescence1StdDev = overallFluorescenceStddev2;
  	}
  	if (channels >= 3) {
  		Fluorescence2Mean = overallFluorescence3;
  		Fluorescence2StdDev = overallFluorescenceStddev3;
  	}
  	if (channels >= 4) {
  		Fluorescence3Mean = overallFluorescence4;
  		Fluorescence3StdDev = overallFluorescenceStddev4;
  	}

	if (channels == 1) {
		Array.show("Results for "+getTitle(), Frame, Number, Area, AreaStdDev);
	}

	if (channels == 2) {
		Array.show("Results for "+getTitle(), Frame, Number, Area, AreaStdDev, Fluorescence1Mean, Fluorescence1StdDev);
	}

	if (channels == 3) {
		Array.show("Results for "+getTitle(), Frame, Number, Area, AreaStdDev, Fluorescence1Mean, Fluorescence1StdDev, Fluorescence2Mean, Fluorescence2StdDev);
	}

	if (channels == 4) {
		Array.show("Results for "+getTitle(), Frame, Number, Area, AreaStdDev, Fluorescence1Mean, Fluorescence1StdDev, Fluorescence2Mean, Fluorescence2StdDev, Fluorescence3Mean, Fluorescence3StdDev);
	}
}

function addRoiToOverlay() {
	Stack.getPosition(channel, slice, frame);
	Stack.getDimensions(width, height, channels, slices, frames);	
	
	// Check for fake z-stack and replace properties.
	// Sophie's data has several slices and only one frame.
	fakeZStack = false;
	if (slices > 1) {
		fakeZStack = true;
		frames = nSlices;
		frame = getSliceNumber();
	}
	
	name = call("de.fzj.jungle.util.MacroUtilities.getFrameString", frame, frames);
	Roi.setName(name);
	
	Overlay.addSelection();

	// channels == 1 is the case for a single channel stack loaded from nd2
	if (fakeZStack || channels == 1) {
		Overlay.setPosition(frame);
	} else {
		Overlay.setPosition(channel, slice, frame);
	}
}

macro "Add ROI to Overlay [a]" {
	addRoiToOverlay();
}

macro "Add ROI to Overlay Shortcut [F12]" {
	addRoiToOverlay();
}

macro "Add Roi to Overlay Action Tool - C037T0e18A" {
	addRoiToOverlay();
}

function closeAllWindows() {
	if (!getBoolean("Are you sure you want to close all windows?")) {
		return;
	}
	
	// Close all windows (results, log, etc)
	listOfWindowTitles = getList("window.titles"); 
	for (i=0; i<listOfWindowTitles.length; i++){ 
		windowName = listOfWindowTitles[i]; 
		selectWindow(windowName); 
		run("Close");
	}
	
	// Close all images
	while (nImages>0) { 
		selectImage(nImages); 
		close(); 
	}
}

macro "Close All Windows [c]" {
	closeAllWindows();
}

macro "Close All Windows Action Tool - C037T3e18C" {
	closeAllWindows();
}

macro "Delete ROI from Manager [d]" {
	// The returned index is only -1 if no item is selected.
	if (roiManager("index") == -1) {
		return;
	}
	
	roiManager("Delete");
}

macro "Generate Traces Action Tool - C037R00ffL22d2L24d4L26d6D88D8aD8c" {
	generateTrace();
}

macro "Generate Traces" {
	generateTrace();
}

function generateTrace() {
	/*
	 * Use case: select several ROIs in current frame by adding them to the Overlay.
	 */
	requires("1.48d");

	// Get number of channels
	Stack.getDimensions(width, height, channels, slices, frames);

	fakeZStack = false;
	if (slices > 1) {
		fakeZStack = true;
		frames = nSlices;
	}

	// Initialize arrays for storing cell numbers and areas
	roiNumber = Overlay.size;
	intensities = newArray(frames*roiNumber); // Current assumption: channels = 2 (only one fluorescence channel)
//	intensities = newArray(frames*(channels-1)*roiNumber); // more general case

	// Iterate over Overlay entries	
	for (i=0; i<roiNumber; i++) {
		// Select a Roi
		Overlay.activateSelection(i);

		// Get slice number and area for the selected ROI
		Stack.getPosition(channel, slice, frame);

		if (fakeZStack) {
			frame = getSliceNumber();
		}

		// Iterate over channels to get intensity
		// NOTE: Position is 1-based
		for (c=2; c<=channels; c++) {
			// Iterate over frames
			// NOTE: Frames are 1-based
			for (j=0; j<frames; j++) {
				// If we have two or more channels it's unlikely that we have a fake z-stack
				Stack.setPosition(c, slice, j);
	
				getStatistics(area,mean);
	
				// Compute the idx using an offset and the current frame
				idx = (frames * i) + j;
				intensities[idx] = mean;
			}
		}
	}

	for (i=0; i<roiNumber; i++) {
		for (j=(i*frames), k=0; j<((i+1)*frames); j++, k++) {
			setResult("Cell "+d2s(i, 0), k, intensities[j]);
		}
	}
	
	setOption("ShowRowNumbers", true);
	updateResults;
}

macro "Remove Channel" {	
	// Channel number to remove
	channelToRemove = getNumber("Channel to remove (starting with 1)", 1);

	setBatchMode("hide");
	// Remember the title for further processing
	imageTitle = getTitle();
	
	// Split multichannel stack
	run("Split Channels");

	// Close the to be removed channel
	close("C"+channelToRemove+"-"+imageTitle);

	// Merge with only defined channels remaining	
	Stack.getDimensions(width, height, channels, slices, frames);
	keepChannel = newArray(channels);
	Array.fill(keepChannel, true);
	keepChannel[channelToRemove-1] = false;
	
	mergeChannelsParameterString = "";
	channelCounter = 1;
	for (i=0; i<keepChannel.length; i++) {
		if (keepChannel[i]) {
			mergeChannelsParameterString = mergeChannelsParameterString + "c" + channelCounter + "=C" + i+1 + "-" + imageTitle + " ";
			channelCounter++;
		}
	}
	
	mergeChannelsParameterString = mergeChannelsParameterString + "create";
	run("Merge Channels...", mergeChannelsParameterString);
	
	// Switch to Grayscale
	Stack.setDisplayMode("grayscale");

	// Show final stack
	setBatchMode("show");
}

macro "Remove Minipixels" {
	/* 
	 *  TODO Is it possible to run this macro with the ROI manager in batch mode
	 *  -> batch mode gives a huge performance boost
	 */
	requires("1.48d");
	
	// Iterate over Overlay entries
	n = Overlay.size;
	
	// Iterate backwards so that we can remove and iterate at the same time..
	for (i=n-1; i>=0; i--) {
		// Select a Roi
		Overlay.activateSelection(i);
	
		// Get area for the active ROI
		getStatistics(area, mean, min, max);
		Roi.getProperties
		
		// TODO Extend to area < epsilon
		if (area == 0) {
			Overlay.removeSelection(i);
		}
	}
	
	// Just select the first ROI since we cannot deselect a ROI..
	Overlay.activateSelection(0);
}

macro "Remove Artifacts" {
	/* 
	 *  TODO Is it possible to run this macro with the ROI manager in batch mode
	 *  -> batch mode gives a huge performance boost
	 */
	requires("1.48d");
	
	// Iterate over Overlay entries
	n = Overlay.size;
	
	// Iterate backwards so that we can remove and iterate at the same time..
	for (i=n-1; i>=0; i--) {
		// Select a Roi
		Overlay.activateSelection(i);
	
		// Get area for the active ROI
		getStatistics(area, mean, min, max);
		Roi.getProperties
		
		// TODO Extend to area < epsilon
		if (mean > 900 || area < 0.1) {
			Overlay.removeSelection(i);
		}
	}
	
	// Just select the first ROI since we cannot deselect a ROI..
	Overlay.activateSelection(0);
}

macro "Prepare For Presentation" {
	imageTitle = getTitle();
	Stack.getDimensions(width, height, channels, slices, frames);
	isImageHyperstack=Stack.isHyperstack;

	/* Open watermark */
	open("https://ibtmodsimhub.ibt.kfa-juelich.de/imagej/fzj_watermark.tif");
	logoWidth = getWidth();

	/* Add watermark to overlay */
	selectImage(imageTitle);
	logoOffset = 10;
	logoX = getWidth()-logoWidth-logoOffset;
	logoY = logoOffset;
	run("Add Image...", "image=fzj_watermark.tif x="+logoX+" y="+logoY+" opacity=100 zero");

	/* Close watermark image */
	selectImage("fzj_watermark.tif");
	close();

	// Add scalebar to overlay
	run("Scale Bar...", "width=5 height=4 font=24 color=White background=None location=[Lower Right] overlay label");

	// Add time to overlay (hyperstack)
	if (isImageHyperstack) {
		run("Hyperstack to Stack");
		selectWindow(imageTitle);
	}

	run("Label...", "format=0 starting=0 interval=8 x=0 y=20 font=24 text=min range=1-"+frames+" use");

	if (isImageHyperstack) {
		run("Stack to Hyperstack...", "order=xyczt(default) channels="+channels+" slices="+slices+" frames="+frames+" display=Grayscale");
	}
}

macro "Process open images" {
	setBatchMode(true);

	// Use the prompt as alternative, when something fails
	// outputDir = getDirectory("Choose your output directory");

	imgArray = newArray(nImages);
	for (i=0; i<nImages; i++) {
		selectImage(i+1);
		imgArray[i] = getImageID();
	}
	
	for (i=0; i<imgArray.length; i++) {
		selectImage(imgArray[i]);
	
		// Get directory from which the image was loaded
		directory = getInfo("image.directory");			

		if (directory == "") {
			// if the image's directory cannot be determined write to temp folder
			directory = getDirectory("temp");
			print("Could not find correct directory. Check temp folder for your results.");
		}

		// Get filename and title of current image
		imgFilename = getInfo("image.filename");
		imgTitle = getTitle();

		if (imgFilename == "" || endsWith(imgFilename, ".nd2")) {
			// image.filename not available
			imgFilenameWithoutExtension = trim(imgTitle);
		} else {
			imgFilenameWithoutExtension = stripExtension(imgFilename);
		}
		
		roiFilename = directory + imgFilenameWithoutExtension + "_rois.tif";
		resultsFilename = directory + imgFilenameWithoutExtension + "_results.csv";

		// Set correct scale
		//run("Set Scale...", "distance=1 known=0.07 pixel=1 unit=micron");

		// Execute plugin on image
		run("MASTER PLUGIN", "segmentation profile=balaban filter=sizeandconvexhull minimalSize=0.7 backgroundSize=41.3 deviation=0.20");

		saveAs("Tiff", roiFilename);
		close();		

		// Save results to file
		selectWindow("Results for "+imgTitle);
		saveAs("Results", resultsFilename);
		
		// Close results table
		run("Close");
	}
}

function stripExtension(filename) {
	dotIdx = lastIndexOf(filename, ".");

	return substring(filename,0,dotIdx);
}

function getExtension(filename) {
	dotIdx = lastIndexOf(filename, ".");

	return substring(filename, dotIdx+1, lengthOf(filename));
}

function cleanTitle(title) {
	dashIdx = indexOf(title, "-");
	
	return substring(title, dashIdx+1, lengthOf(title));
}

function trim(string) {
	string = replace(string, " ", ""); // removes spaces
	
	return string;
}

macro "Process Directory" {
	showMessage("This macro is not functional without changing the internals. Take a lookt at the sourcecode and feel free to experiment.");

	/*
	directory = getDirectory("Select the directory"); 

	// get the initial list (without opening the files) 
	list = getFileList(directory); 
	Array.sort(list); 

	for (i=0;i<list.length;i++) { 
		if (File.isDirectory(directory+list[i])) {
			continue;
		}
		
		open(directory+list[i]); 
	        wait(250); // wait a second

		// setMinAndMax(480, 620);
		
	        //Overlay.remove();

		//imgTitle = stripExtension(getTitle());
	        //run("Duplicate...", "title="+imgTitle+"_cropped.tif duplicate channels=1-3 frames=1-80");

		//filename = directory + imgTitle + "_cropped.tif";
	        //saveAs("Tiff", filename);
		
		//close();
		//close();

		// Get directory from which the image was loaded
		if (directory == "") {
			// if the image's directory cannot be determined write to temp folder
			directory = getDirectory("temp");
			print("Could not find correct directory. Check temp folder for your results.");
		}

		// Get filename and title of current image
		imgFilename = getInfo("image.filename");
		imgTitle = getTitle();

		if (imgFilename == "" || endsWith(imgFilename, ".nd2")) {
			// image.filename not available
			imgFilenameWithoutExtension = trim(imgTitle);
		} else {
			imgFilenameWithoutExtension = stripExtension(imgFilename);
		}
		
		roiFilename = directory + imgFilenameWithoutExtension + "_rois.tif";
		resultsFilename = directory + imgFilenameWithoutExtension + "_results.csv";

		// Set correct scale
		//run("Set Scale...", "distance=1 known=0.07 pixel=1 unit=micron");

		// Execute plugin on image
		run("MASTER PLUGIN", "segmentation profile=DFG filter=sizeandconvexhull minimalSize=0.2 backgroundSize=41.3 deviation=0.25");

		saveAs("Tiff", roiFilename);
		close();

		// Save results to file
		selectWindow("Results for "+imgTitle);
		saveAs("Results", resultsFilename);
		
		// Close results table
		run("Close");
	}
	*/
}

macro "Save Images To TIFF" {
	requires(1.49);

	// Select directory for saving
	outputDir = getDirectory("Choose your output directory");

	// Just open the ND2 files (all positions as virtual stack)
	imgArray = newArray(nImages);
	for (i=0; i<nImages; i++) {
		selectImage(i+1);
		imgArray[i] = getImageID();
	}
	
	for (i=0; i<imgArray.length; i++) {
		selectImage(imgArray[i]);
		imageTitle = getTitle();
		imageFilenameWithoutExtension = trim(imageTitle);

		// Save as TIFF
		saveAs("Tiff", outputDir + imageFilenameWithoutExtension + ".tif");
		
		// Close processed stacks
		selectImage(imgArray[i]);
		close();
	}
}