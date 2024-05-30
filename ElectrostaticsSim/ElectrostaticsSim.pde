import controlP5.*;
import org.hipparchus.linear.*;

int simulationRes;

Grid3D mainGrid;
Slicer mainSlicer;


/* UI */
ControlP5 mainUi;
Screen2D mainScreen2D;
SlicerUi mainSlicerUi;
ObjectUi mainObjectUi;

/* Default Fonts */
HashMap<String, PFont> fontMap;

/* Fun */
PImage backGroundImg;


public void setup() {
  size(10, 10);
  surface.setAlwaysOnTop(true);

  /* init fonts */
  fontMap = new HashMap<String, PFont>();
  fontMap.put("h1", createFont("JetBrainsMono.ttf", 24, true));
  fontMap.put("h2", createFont("JetBrainsMono.ttf", 20, true));
  fontMap.put("h3", createFont("JetBrainsMono.ttf", 14, true));
  fontMap.put("p", createFont("JetBrainsMono.ttf", 12, true));

  /* init ui */
  mainUi = new ControlP5(this);
  //mainScreen2D = new Screen2D(this, 5);
  //mainSlicerUi = new SlicerUi(this, fontMap, mainSlicer, mainScreen2D);
  //mainObjectUi = new ObjectUi(this);
  
  mainGrid = new Grid3D(1, 1);
  /*
  for (int i=1; i<3; i++) {
    for (int j=1; j<3; j++) {
      for (int k=1; k<3; k++) {
        mainGrid.getInitCell(i, j, k).setCharge(null);
        mainGrid.getInitCell(i, j, k).setPotential(Double.valueOf(0));
      }
    }
  }
  */
  
  mainGrid.getInitCell(1, 1, 1).setPotential(Double.valueOf(5));
  mainGrid.getInitCell(1, 1, 1).setCharge(null);
  
  mainGrid.solveSystem();
  
  /* fun */
  /*
  backGroundImg = loadImage("greenFN.jpg");
  backGroundImg.resize(200, 200);
  image(backGroundImg, 0, 0);
  
  /* title * /
  System.out.println(fontMap.get("h1"));
  Textlabel title = mainUi.addTextlabel("Title")
                          .setText("Green FN Electrostatics Simulator")
                          .setColor(color(255, 200, 0))
                          .setFont(fontMap.get("h1"))
                          .setPosition(width/2 - 300, 25);
                          
  */
}


public void draw() {
  
}
