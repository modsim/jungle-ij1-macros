// Iterate over Overlay entries
n = Overlay.size;
counter = n;

roiIds = newArray(nSlices+1);
for (j=0; j<roiIds.length; j++)
      roiIds[j] = -1;

tempRois = newArray(0);
	
for (i=0; i<n; i++) {
	// Select a Roi
	Overlay.activateSelection(i);
	Roi.getBounds(x, y, width, height);
	centerX = round(x+width/2);
	centerY = round(y+height/2);

	frame = getSliceNumber(); // 1-based
	
	if (roiIds[frame] == -1) {
		xpoints = newArray(1);
		xpoints[0] = centerX;
		ypoints = newArray(1);
		ypoints[0] = centerY;
		makeSelection("point", xpoints, ypoints);
		Overlay.addSelection;
		roiIds[frame] = counter;
		counter = counter+1;
	} else {
		Overlay.activateSelection(roiIds[frame]);
		getSelectionCoordinates(xpoints, ypoints);
		tempRois = Array.concat(tempRois, roiIds[frame]);
		xpoints = Array.concat(xpoints, centerX);
		ypoints = Array.concat(ypoints, centerY);
		makeSelection("point", xpoints, ypoints);
		Overlay.addSelection;
		Overlay.setPosition(frame);
		roiIds[frame] = counter;
		counter = counter+1;
		//setKeyDown("shift");
		//makePoint(centerX, centerY);
		//setKeyDown("none");
		//setKeyDown("esc");
	}
}

for (k=tempRois.length-1; k>=0; k--) {
	Overlay.removeSelection(tempRois[k]);
}

for (r=n-1; r>=0; r--) {
	Overlay.removeSelection(r);
}

