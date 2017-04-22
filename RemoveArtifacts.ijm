// @Double(label = "Artifact threshold") threshold

n = Overlay.size;
markedForRemoval = newArray(0);

for (i=0; i<n; i++) {
	Overlay.activateSelection(i);

	getStatistics(area, mean);
	print(mean);
	print(threshold);

	if (mean > threshold) {
		markedForRemoval = Array.concat(markedForRemoval, i);
	}
}

print(lengthOf(markedForRemoval));

for (j=lengthOf(markedForRemoval)-1; j>=0; j--) {
	Overlay.removeSelection(markedForRemoval[j]);
}
