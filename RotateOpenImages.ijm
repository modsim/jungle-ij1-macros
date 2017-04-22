macro "Rotate open virtual stacks" {
	setBatchMode(true);
	
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
			print("Could not find correct directory. Check temp folder for your results."
		}

		path = directory+trim(getTitle());
		
		if (File.exists(path) || getInfo("image.filename") == getTitle()) {
			path = path+random;
		}
		
		File.makeDirectory(path);

		if (!File.exists(path))
			exit("Unable to create directory");
	
		for (i=1; i<=nSlices; i++) {
			showProgress(i, nSlices);
			setSlice(i);

			run("Duplicate...", "title=temp");
			run("Rotate... ", "angle=1 interpolation=Bilinear slice");
		
			saveAs("tif", path+File.separator+pad(i-1));
			close();
		}
	
	
	run("Image Sequence...", "open=["+dir+"00000.tif] use");	
	}

	setBatchMode(false);
}

function pad(n) {
	str = toString(n);
	while (lengthOf(str)<5)
		str = "0" + str;
	return str;
}

function trim(string) {
	string = replace(string, " ", ""); // removes spaces
	
	return string;
}
