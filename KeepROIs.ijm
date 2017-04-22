macro "Keep ROIs only Action Tool - C037T3e18K" {
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
	j=0;
	index = newArray(n-1);
	for (i=0; i<n; i++) {
		roiManager("select", i);
		Roi.getBounds(x_roi, y_roi,w_roi,h_roi);
		
		if(y1 == 0) {
			if(x_roi < x1 || x_roi > x2 ||  y_roi > y2) {
			print(x_roi,y_roi);
			Roi.setStrokeColor("red");
			index[j] = i;
			j=j+1;
			}
		}
		if(x_roi < x1 || x_roi > x2 || y_roi < y1 || y_roi > y2) {
			print(x_roi,y_roi);
			Roi.setStrokeColor("red");
			index[j] = i;
			j=j+1;
		}
	
	}
	roiManager("Select",index);
	roiManager("Delete");
	run("Remove Overlay");
	run("From ROI Manager");
	selectWindow("ROI Manager");
	run("Close");
}
