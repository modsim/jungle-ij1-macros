function DeleteMaskedROIs() {
	setBatchMode(true);
	getSelectionBounds(x, y, w, h);
	Stack.getDimensions(width, height, channels, slices, frames);
	x1 = x;
	x2 = x+w;
	y1 = y;
	y2 = y+h;
	print(x1,x2,y1,y2);

	run("To ROI Manager");
	n = roiManager("count");
	currentSlice =  getSliceNumber(); 
	index = newArray(n);
	j=0;
	for (i=0; i<n; i++) {
		roiManager("select", i);
		name = Roi.getName();
		name_split = split(name, "-");
		name_split2 = split(name_split[0], "F");
		roi_frame_no = parseInt(name_split2[0]);
		

		Roi.getBounds(x_roi, y_roi,w_roi,h_roi);
		if(roi_frame_no == currentSlice) {
			if(x_roi > x1 && x_roi < x2 && y_roi > y1 && y_roi < y2) {
				//print(x_roi,y_roi);
				Roi.setStrokeColor("red");
				print(i);
				index[j] = i;
				j=j+1;
			} else {
			}
		}
	}
	if(j > 0) {
		a = Array.slice(index,0,j);
		roiManager("Select", a);
		roiManager("Delete");
	}
	setSlice(currentSlice);
	run("From ROI Manager");
	roiManager("Show all without labels");
	selectWindow("ROI Manager");
	run("Close");
	setBatchMode(false);
}

macro "Delete selcted ROIs only Action Tool - C037T3e18D" {
	
	DeleteMaskedROIs();
	
	
}

macro "Delete selcted ROIs only [d]" {
	DeleteMaskedROIs();
}
