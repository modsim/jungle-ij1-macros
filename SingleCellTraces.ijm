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



	n = Overlay.size;
	cellArea = newArray(n);
	frameNumber = newArray(n);
	Minor = newArray(n);
	Major = newArray(n);
	
	// Iterate over Overlay entries

	
	for (i=0; i<n; i++) {
		// Select a Roi
		Overlay.activateSelection(i);

		// Get slice number and area for the selected ROI
		Stack.getPosition(channel, slice, frame);
		getStatistics(area,major,minor);

		
		frameNumber[i] = d2s(frame,0);
		cellArea[i] = d2s(area,2);
		Minor[i] = d2s(minor,0);
		Major[i] = d2s(major,0);
	}
	Array.show(frameNumber,cellArea, Minor, Major);
}

