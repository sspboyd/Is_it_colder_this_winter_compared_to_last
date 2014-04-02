import java.util.Map;

//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;
PFont font;
Table t;
CompData compData;
String[] tempData;

// (t)emperature (h)ash(m)ap - this holds all temp data for a location
HashMap<String,Float> thm = new HashMap<String,Float>(); 

// Layout Variables
float margin;
float chartX1;
float chartX2;
float chartY1;
float chartY2;

int MAX_TEMP = 30;
int MIN_TEMP = -30;


DateTimeFormatter formatter = DateTimeFormat.forPattern("yyyy-MM-dd");
DateTime baseTimeStart, baseTimeEnd;
DateTime compTimeStart, compTimeEnd;
int compIntervalYrs, timelineDurationInDays;

void setup() {
	background(255);
	size(900, 600);

	rSn = 47; // 4,7,11,18,29,47,76,123,199
	randomSeed(rSn);

	font = createFont("Helvetica", 24);  //requires a font file in the data folder

	margin = width * pow(PHI, 7);
	// println("margin = " + margin);

	chartX1 = (margin * 1);
	chartX2 = width - (margin);
	chartY1 = (margin * 1);
	chartY2 = height - (margin*6);


	// t = loadTemps("toronto.txt"); // old way
	// new way is a function that is given a hashmap and a file to load in 
	loadTemps(thm, "eng-daily-01012012-12312012.csv");
	loadTemps(thm, "eng-daily-01012013-12312013.csv");
	loadTemps(thm, "eng-daily-01012014-12312014.csv");
	// println("thm: " + thm);


	// Comparison data
	// # of warmer than last year days
	// compData = new CompData(t);

	
	 compIntervalYrs = 1; 
	 baseTimeStart = new DateTime(2013, 10, 1, 0, 0, 0, 0);;  // October 2013
	 baseTimeEnd = new DateTime(2014, 3, 30, 0, 0, 0, 0);
	 compTimeStart = baseTimeStart.minusYears(compIntervalYrs);
	 compTimeEnd = baseTimeEnd.minusYears(compIntervalYrs);
	 timelineDurationInDays = Days.daysBetween(baseTimeStart.withTimeAtStartOfDay() , baseTimeEnd.withTimeAtStartOfDay() ).getDays();
	println("time line Duration in Days: " + timelineDurationInDays);
	println("setup done: " + nf(millis() / 1000.0, 1, 2));
// 	noLoop();
}

void draw() {
	background(255);

	// Draw horiz temp guidelines
	stroke(200);
	for (int i = MAX_TEMP; i > MIN_TEMP-1; i-=10) {
		float ly = map(i, MAX_TEMP, MIN_TEMP, chartY1, chartY2);
		line(chartX1+margin * 2, ly, chartX2, ly);
		fill(0);
		textFont(font);
		text(i, chartX1,ly+8);
	}


	/*
	for(DateTime currDate = baseTimeStart; currDate.isBefore(baseTimeEnd); currDate = date.plusMonths(1)){
		// draw month vert lines and timeline ticks/labels
	}
	*/
	float pt1x = -9999;
	float pt1y = -9999; // previous t1 temp x/y
	for (DateTime currDate = baseTimeStart; currDate.isBefore(baseTimeEnd); currDate = currDate.plusDays(1)){
		float t1 = 0;
		float t2 = 0;
		DateTime compTimeDate = currDate.minusYears(compIntervalYrs);

		String baseFormattedDate = formatter.print(currDate);
		String compFormattedDate = formatter.print(compTimeDate);
		// println(baseFormattedDate +  " vs " + compFormattedDate);

		if((thm.get(baseFormattedDate) != null) && (thm.get(compFormattedDate) != null)){
			t1 = thm.get(baseFormattedDate);
			t2 = thm.get(compFormattedDate);
			// println(baseFormattedDate + ", " + t1 + " vs " + t2 + ", " + compFormattedDate);
		}
		color tempClr;

		float t1x = map(daysSinceBaseStartTime(currDate) , 0 , timelineDurationInDays, chartX1+margin*2, chartX2);
		float t1y = map(t1, MAX_TEMP, MIN_TEMP, chartY1, chartY2);

		float t2x = t1x;
		float t2y = map(t2, MAX_TEMP, MIN_TEMP, chartY1, chartY2);

		if(t1<t2){ // is it colder this year than last?
			tempClr = color(50, 50, 255);
		}else{
			tempClr = color(255, 50, 50);
		}
		stroke(tempClr);
		strokeWeight(2);
		line(t1x, t1y, t2x, t2y);
		fill(tempClr);
		ellipse(t1x, t1y, 3,  3);

		// if(pt1x != -9999){
		// 	line(t1x, t1y, pt1x, pt1y);
		// }
		pt1x = t1x;
		pt1y = t1y;
	}
	
	/*
	for (int i = 0; i < t.getRowCount(); i++) {
		TableRow cRow = t.getRow(i);
		float t1temp = cRow.getFloat("Temp1");
		float t2temp = cRow.getFloat("Temp2");

		color tempClr;

		float t1x = map(i, 0, t.getRowCount()-1, chartX1+margin * 2, chartX2);
		float t1y = map(t1temp, 40, -40, chartY1, chartY2);

		float t2x = t1x;
		float t2y = map(t2temp, 40, -40, chartY1, chartY2);

		if(t1temp<t2temp){ // is it colder this year than last?
			tempClr = color(50, 50, 255);
		}else{
			tempClr = color(255, 50, 50);
		}
		stroke(tempClr);
		line(t1x, t1y, t2x, t2y);
		fill(tempClr);
		ellipse(t1x,t1y, 3,3);
	}
	*/

	/*
	int daysWarmer = compData.getDaysWarmer();
	int daysColder = compData.getDaysColder();
	float totalWarmerDelta = compData.getTotalWarmerDelta()/daysWarmer;
	float totalColderDelta = compData.getTotalColderDelta()/daysColder;

	fill(255,100,100);
	String dwt = "Days Warmer: " + daysWarmer;
	text(dwt, chartX2-textWidth(dwt), chartY1+margin-10);
	String twdt = "Warmer on Average: " + nf(totalWarmerDelta, 0, 2);
	text(twdt, chartX2-textWidth(twdt), chartY1 + margin *2-10);

	fill(100,100,255);
	String dct = "Days Colder: " + daysColder;
	text(dct, chartX2-textWidth(dct), chartY2);
	String tcdt = "Colder on Average: " + nf(totalColderDelta, 0, 2);
	text(tcdt, chartX2-textWidth(tcdt), chartY2 - margin*1);
	*/
}

/*
Table loadTemps(String _input){
	
	String input = _input;
	String[] loadedData = loadStrings(input);
	// String[] loadedData = loadStrings("toronto.txt");
	println("loadedDate.length: " + loadedData.length);

	Table tempTimeline = new Table();
	tempTimeline.addColumn("Date");
	tempTimeline.addColumn("Temp");

	for (int j = 0; j < loadedData.length; j++) {
		String r = loadedData[j];
		String[] loadedDataRow = split(loadedData[j], TAB);
		String indxData = "";
		/*
		for (int k = 0; k < loadedDataRow.length; k++) {
			indxData += "i: " + k + " = data: " + loadedDataRow[k] + ", ";
		}
		println(indxData);
		
		String dt = loadedDataRow[2];
		float t1 = float(loadedDataRow[6]);
		
		TableRow newRow = tempTimeline.addRow();
		newRow.setString("Date", dt);
		newRow.setFloat("Temp", t1/10);
	}

	// create the temperature comparison table
	Table cmprTempData = new Table();
	cmprTempData.addColumn("Date");
	cmprTempData.addColumn("Temp1");
	cmprTempData.addColumn("Temp2");


	// for (int i = 0; i < tempTimeline.getRowCount(); i++) {
	for (int i = 0; i < 183; i++) {
		TableRow lyRow = tempTimeline.getRow(i);
		String lyDate = lyRow.getString("Date");
		String cyDate = lyDate.substring(0, 3) + (int(lyDate.substring(3, 4)) + 1) + lyDate.substring(4);

		TableRow cyTempRow = tempTimeline.findRow(cyDate, "Date");

		if(cyTempRow != null){ // make sure there is an entry for the current year too
			float t1 = cyTempRow.getFloat("Temp");
			float t2 = lyRow.getFloat("Temp");
			if((t1 > -9990) && (t2 > -9998)){ // make sure there aren't dummy data entries (-9999)
				TableRow newCmprRow = cmprTempData.addRow();
				newCmprRow.setString("Date", lyDate);
				newCmprRow.setFloat("Temp1", t1);
				newCmprRow.setFloat("Temp2", t2);
				println("Date: " + lyDate + ", Temp1: " + t1 + ", Temp2: " + t2);
			}
		}
	}
	println("cmprTempData.getRowCount() = " + cmprTempData.getRowCount());
	return cmprTempData;
}
*/

int daysSinceBaseStartTime(DateTime _cdt){
	DateTime cdt = _cdt;
	return Days.daysBetween(baseTimeStart.withTimeAtStartOfDay() , cdt.withTimeAtStartOfDay() ).getDays();
}


void loadTemps(HashMap _hm, String _filename){
	String filename = _filename;
	HashMap<String,Float> hm = _hm;

	String[] loadedData = loadStrings(filename);
	// println("loadedDate.length: " + loadedData.length);

	int dataRowOffset = 25; // first row is 0, second is 1...
	for (int j = dataRowOffset; j < dataRowOffset+365; j++) {
		String r = loadedData[j];
			String[] loadedDataRow = split(loadedData[j], ",");
			String dt = scrubQuotes(loadedDataRow[0]);
			float t1 = float(scrubQuotes(loadedDataRow[9].substring(1,loadedDataRow[9].length()-1)));
			if(t1+1 != 1){ // this is my way of avoid using Float.isNaN() which won't work in Processing.js
				hm.put(dt, t1);
				// println("hm.put(" + dt + ", " + t1 + ")");
			}
	}
}

// modified from http://www.openprocessing.org/sketch/49248
String scrubQuotes(String _input){
	String input = _input;
	if (input.length() > 2) {
		// remove quotes at start and end, if present
		if (input.startsWith("\"") && input.endsWith("\"")) {
			input = input.substring(1, input.length() - 1);
		}
	}
	// make double quotes into single quotes
	// array[i] = array[i].replaceAll("\"\"", "\"");
	String output = input;
	return output;
}
  



	// create the temperature comparison table
	/*
	Table cmprTempData = new Table();
	cmprTempData.addColumn("Date");
	cmprTempData.addColumn("Temp1");
	cmprTempData.addColumn("Temp2");


	// for (int i = 0; i < tempTimeline.getRowCount(); i++) {
	for (int i = 0; i < 183; i++) {
		TableRow lyRow = tempTimeline.getRow(i);
		String lyDate = lyRow.getString("Date");
		String cyDate = lyDate.substring(0, 3) + (int(lyDate.substring(3, 4)) + 1) + lyDate.substring(4);

		TableRow cyTempRow = tempTimeline.findRow(cyDate, "Date");

		if(cyTempRow != null){ // make sure there is an entry for the current year too
			float t1 = cyTempRow.getFloat("Temp");
			float t2 = lyRow.getFloat("Temp");
			if((t1 > -9990) && (t2 > -9998)){ // make sure there aren't dummy data entries (-9999)
				TableRow newCmprRow = cmprTempData.addRow();
				newCmprRow.setString("Date", lyDate);
				newCmprRow.setFloat("Temp1", t1);
				newCmprRow.setFloat("Temp2", t2);
				println("Date: " + lyDate + ", Temp1: " + t1 + ", Temp2: " + t2);
			}
		}
	}
	println("cmprTempData.getRowCount() = " + cmprTempData.getRowCount());
	return cmprTempData;
}
*/


class CompData {
	int daysWarmer, daysColder;
	float totalWarmerDelta, totalColderDelta;
	Table tempDataTable;

	CompData(Table _t){
		tempDataTable = _t;
		for (int i = 0; i < tempDataTable.getRowCount(); i++) {
			TableRow cRow = tempDataTable.getRow(i);
			float t1temp = cRow.getFloat("Temp1");
			float t2temp = cRow.getFloat("Temp2");

			if(t1temp > t2temp){ // warmer than last year
				daysWarmer++;
				totalWarmerDelta += t1temp;
			}else{ // colder than last year
				daysColder++;
				totalColderDelta -=t2temp;
			}
		}
	}

	int getDaysWarmer(){
		return daysWarmer;
	}
	int getDaysColder(){
		return daysColder;
	}
	float getTotalWarmerDelta(){
		return totalWarmerDelta;
	}
	float getTotalColderDelta(){
		return totalColderDelta;
	}
}













/////////////////////////////////////////////////////////////////////
  //		UI and Image Saving Functions						 //
/////////////////////////////////////////////////////////////////////
void keyPressed() {
  if (key == 'S') screenCap();
}

void mousePressed(){}

void screenCap() {
  // save functionality in here
  String outputDir = "out/";
  String sketchName = getSketchName() + "-";
  String randomSeedNum = "rS" + rSn + "-";
  String dateTimeStamp = "" + year() + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  String fileType = ".tif";
  String fileName = outputDir + sketchName + randomSeedNum + dateTimeStamp + fileType;
  save(fileName);
  println("Screen shot taken and saved to " + fileName);
}

String getSketchName(){
  String[] path = split(sketchPath, "/");
  return path[path.length-1];
}
