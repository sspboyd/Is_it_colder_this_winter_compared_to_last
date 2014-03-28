//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;
PFont font;
Table temps;


float margin;

  float chartX1;
  float chartX2;
  float chartY1;
  float chartY2;


void setup() {
  background(255);
  size(900, 600);
  // rSn = 47;
  rSn = 29;
  // rSn = 18;
  randomSeed(rSn);
  font = createFont("Helvetica", 24);  //requires a font file in the data folder

	margin = width * pow(PHI, 7);
	println("margin = " + margin);

   chartX1 = margin;
   chartX2 = width - (margin);
   chartY1 = margin * 4;
   chartY2 = height - (margin);


	// create data table and insert data
	temps = new Table();
	temps.addColumn("Date");
	temps.addColumn("Temp1");
	temps.addColumn("Temp2");

	for (int i = 0; i < 183; ++i) {
		TableRow newRow = temps.addRow();
		newRow.setInt("Date", temps.lastRowIndex());
		newRow.setFloat("Temp1", (80 * noise(i/100.0))-40);
		newRow.setFloat("Temp2", ((80 * noise(47 + i/100.0))) - 40);
	}
// println(temps);
  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

void draw() {
	background(255);
	noFill();
	stroke(0);
	//rect(chartX1, chartY1, width-(margin*2), height-(margin*2));

	for (int i = 0; i < temps.getRowCount(); i++) {
		TableRow cRow = temps.getRow(i);
		float t1temp = cRow.getFloat("Temp1");
		float t2temp = cRow.getFloat("Temp2");



		float t1x = map(i, 0, temps.getRowCount()-1, chartX1+margin * 2, chartX2);
		float t1y = map(t1temp, 40, -40, chartY1, chartY2);

		float t2x = t1x;
		float t2y = map(t2temp, 40, -40, chartY1, chartY2);

		if(t1temp<t2temp){ // is it colder this year than last?
			stroke(50, 50, 255);
		}else{
			stroke(255, 50, 50);
		}
		line(t1x, t1y, t2x, t2y);
		ellipse(t1x,t1y, 3,3);

	}

	stroke(200);
	for (int i = 40; i > -41; i-=10) {
		float ly = map(i, 40, -40, chartY1, chartY2);
		line(chartX1+margin * 2, ly, chartX2, ly);
		fill(0);
		textFont(font);
		text(i, chartX1,ly+8);
	}

}




















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
