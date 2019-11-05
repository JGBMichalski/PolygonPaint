/* 
PolyPaint
Author: J. Michalski
Date: November 4, 2019 
*/

//Define global variables
float barWidth; //Width of colour bar
float barHalf;  //Divide the colour bar in half
float threshold;  //Radius of every ellipse that we can click in.
float xOffset = 0.0;  //x offset used for dragging an object
float yOffset = 0.0;  //y offset used for dragging an object
float wdth = 0.0; //Variable also used for dragging an object
float hght = 0.0; //Variable alsu used for dragging an object
int drawColour = 0; //Either draw or change shape colour to this
boolean drawingShape = false; //Are we currently drawing a shape?
boolean mouseMove = false;  //Are we moving a shape with the mouse?
boolean shapeSelected = false;  //Do we currently have a shape selected?
boolean moveVertex = false; //Are we currently moving a vertex with the mouse?
boolean moveX = false;  //Are we currently moving the x transformation of a shape?
boolean moveY = false;  //Are we currently moving the y transformation of a shape?
int movingVertex = -1;  //The vertex value of the vertex we are moving.
int movingX = -1; //The shape that we are moving the x transformation of
int movingY = -1; //The shape that we are moving the y transformation of
int shapeSelectedVal = -1;  //The shape that is currently selected
int mouseMoveNum = -1;  //The shape that we are currently dragging
ArrayList<mShape> shapes; //List of shapes on screen
ArrayList<mVertex> vertexList;  //List of vertices as we are drawing a shape
ColourSelect x; //The colour selector

//Setup Program
void setup() {
  //width, height
  size(640, 640, P3D);
  colorMode(RGB, 255);
  hint(DISABLE_OPTIMIZED_STROKE);
  ellipseMode(RADIUS);  //Draw from the center of the ellipse
  threshold = 10.0; //Set our ellipse radius
  x = new ColourSelect(25, 230, 16);  //Create our colour selector with 16 colours from (25, 25, 25) to (230, 230, 230)
  shapes = new ArrayList<mShape>(); //Create our arraylist to store our shapes
  vertexList = new ArrayList<mVertex>();  //Create our arraylist to store our vertices

  //Select First Colour
  ColourBox clicked = x.getBoxClicked(4, 4);  //Pretend we clicked the box (4, 4)
  drawColour = clicked.fill;  //Get the colour
  int box = x.getBoxIndex(clicked); //Get the box we clicked in the list
  ArrayList<ColourBox> boxes = x.getBoxes(); //Duplicate our arraylist
  for (int i = 0; i < boxes.size(); i++){ //Change the stroke value of the box we clicked
    if (i != box){
      boxes.get(i).stroke = 0;
    } else {
      boxes.get(i).stroke = 255;
    }
  }
  x.setBoxes(boxes); //Update our main arraylist
}

//Draw Image
void draw() {
  background(255, 255, 255); //Draw Background

  //Draw Completed Shapes
  for (int i = 0; i < shapes.size(); i++){
    if (mouseMoveNum == i){ //If we are moving a shape,
      shapes.get(i).setOffset(wdth, hght);  //Update its location
    }

    shapes.get(i).drawShape();  //Draw every shape
    
    if (shapeSelected && shapeSelectedVal == i){  //If we have a shape selected and we are currently looking at that shape,
      shapes.get(i).drawCircles();  //Draw the vertex circles
      shapes.get(i).calculateAxis();  //Calculate the axis points
      shapes.get(i).drawAxis(); //Draw the axis points
    }
  }

  //Draw the edges of the shape we are currently drawing.
  for (int i = 0; i < vertexList.size() - 1; i++){
    fill(drawColour); //Set the fill of the shape we are making to the selected value in the colour selector
    stroke(drawColour); //Set the stroke colour of the shape we are making to the selected value in the colour selector
    line(vertexList.get(i).x, vertexList.get(i).y, vertexList.get(i+1).x, vertexList.get(i+1).y); //Draw the line between the two vector points
  }

  //Draw the vertex points in yellow
  noFill();
  stroke(150, 150, 45);
  strokeWeight(2); //Make the ellipse a little thicker for ease
  for (int i = 0; i < vertexList.size(); i++){
    ellipse(vertexList.get(i).x, vertexList.get(i).y, threshold, threshold); //Draw each vertex
  }
  strokeWeight(1);

  //Draw Rubber Band
  if (vertexList.size() > 0){
    if (mouseX >= barWidth){ //Don't let the rubber band work when over the colour selector
      fill(drawColour);
      stroke(drawColour);
      line(vertexList.get(vertexList.size()-1).x, vertexList.get(vertexList.size()-1).y, mouseX, mouseY);
    }
  }
  
  x.drawColours(); //Draw the colour picker
}

//Actions for when Mouse is Pressed
void mousePressed() {
  //Select a colour from the colour options
  if (mouseX < barWidth){  //If we clicked in the colour bar
    ColourBox clicked = x.getBoxClicked(mouseX, mouseY); //Get the box we clicked
    if (clicked != null){ //Just making sure our pointer is valid
      drawColour = clicked.fill;  //Set the global colour to our selected box colour
      int box = x.getBoxIndex(clicked); //Get the box we clicked in the list
      ArrayList<ColourBox> boxes = x.getBoxes();  //Get the whole list
      for (int i = 0; i < boxes.size(); i++){ //Change the stroke colour of the box we clicked to white
        if (i != box){
          boxes.get(i).stroke = 0;
        } else {
          boxes.get(i).stroke = 255;
        }
      }
      x.setBoxes(boxes); //Return our updated list

      if (shapeSelected){ //If we have a shape selected
        shapes.get(shapeSelectedVal).colour = drawColour; //The shape colour gets changed to the currently selected colour
      }
    }
  } else {
    //If we are outside of the colour bar/selector
    if (shapeSelected){ //If we have a shape selected
      for (int i = 0; i < shapes.get(shapeSelectedVal).vertices.size(); i++){ 
        //Check and see if we are trying to move a Vertex
        if ((abs(shapes.get(shapeSelectedVal).scaleX * (shapes.get(shapeSelectedVal).vertices.get(i).x + shapes.get(shapeSelectedVal).xOffset + shapes.get(shapeSelectedVal).globalX) - mouseX) < threshold) && (abs(shapes.get(shapeSelectedVal).scaleY * (shapes.get(shapeSelectedVal).vertices.get(i).y + shapes.get(shapeSelectedVal).yOffset + shapes.get(shapeSelectedVal).globalY) - mouseY) < threshold)){
          moveVertex = true;
          movingVertex = i;
          println("Moving Vertex: ", movingVertex);
        //Check to see if we are trying to Move in the X direction
        } else if ((abs(shapes.get(shapeSelectedVal).scaleX * (shapes.get(shapeSelectedVal).xTransform.x + shapes.get(shapeSelectedVal).xOffset + shapes.get(shapeSelectedVal).globalX) - mouseX) < (threshold)) && (abs(shapes.get(shapeSelectedVal).scaleY * (shapes.get(shapeSelectedVal).xTransform.y + shapes.get(shapeSelectedVal).yOffset + shapes.get(shapeSelectedVal).globalY) - mouseY) < (threshold))){
          moveX = true;
          movingX = i;
          println("Moving X Direction: ", movingX);
          break;
        //Check to see if we are trying to move in the Y direction
        } else if ((abs(shapes.get(shapeSelectedVal).scaleX * (shapes.get(shapeSelectedVal).yTransform.x + shapes.get(shapeSelectedVal).xOffset + shapes.get(shapeSelectedVal).globalX) - mouseX) < (threshold)) && (abs(shapes.get(shapeSelectedVal).scaleY * (shapes.get(shapeSelectedVal).yTransform.y + shapes.get(shapeSelectedVal).yOffset + shapes.get(shapeSelectedVal).globalY) - mouseY) < (threshold))){
          moveY = true;
          movingY = i;
          println("Moving Y Direction: ", movingY);
          break;
        } 
      }
    }
    //Check which shape the mouse is in
    for (int i = shapes.size() - 1; i > -1; i--){
      if (shapes.get(i).mouseInShape()){
        println("Mouse in shape: ", i);
        mouseMove = true;
        mouseMoveNum = i;
        shapeSelected = true;
        shapeSelectedVal = i;
        xOffset = mouseX-shapes.get(i).xOffset; //Adjsut offset values for proper shifting
        yOffset = mouseY-shapes.get(i).yOffset; //Adjust offset values for proper shifting
        wdth = mouseX-xOffset; //Update 2nd offset values for shifting again (This could be optimised differently)
        hght = mouseY-yOffset; //Update 2nd offset values for shifting again
        break;
      }
    }
    //Add new clicked location to vertex list
    if (!mouseMove && !moveVertex){ //Make sure we are not moving an object or a vertex
      shapeSelected = false;
      shapeSelectedVal = -1;
      vertexList.add(new mVertex(mouseX, mouseY)); //Add the vertex to the list
      //If the last vertex is close to the first vertex, then close the polygon
      if ((abs(vertexList.get(vertexList.size() - 1).x - vertexList.get(0).x) < threshold) && (abs(vertexList.get(vertexList.size() - 1).y - vertexList.get(0).y) < threshold) && (vertexList.size() > 1)){
        vertexList.remove(vertexList.size()-1); //Remove the last point that we just added and just close the shape to the original point
        shapes.add(new mShape(vertexList, drawColour)); //Add the whole polygon as a new shape
        vertexList = new ArrayList<mVertex>();  //Clear our vertex list to start over
      }
    }
  }
}

  void mouseDragged() {
    if (moveX){ //If we are moving the x translation
      shapes.get(movingX).scaleX = 1 + (mouseX - shapes.get(movingX).xTransform.x) / 50;  //Scale it by 1/50 for every pixel shift
      shapes.get(movingX).calculateAxis();  //Update the axis
      println(abs(mouseX - shapes.get(movingX).xTransform.x), " ", movingX);
    } else if (moveY){  //Same as above, but for the Y transformation
      println(abs(mouseY - shapes.get(movingY).yTransform.y), " ", movingY);
      shapes.get(movingY).calculateAxis();
      shapes.get(movingY).scaleY = 1 + (mouseY - shapes.get(movingY).yTransform.y) / 50;
      println(shapes.get(movingY).scaleY);
    } else if(mouseMove) { //Adjust offsets for dragging of a shape and recalculate the axis
      wdth = mouseX-xOffset; 
      hght = mouseY-yOffset; 
      shapes.get(shapeSelectedVal).calculateAxis(); 
    } else if (moveVertex){ //If we are moving a vertex, get points of the moving vertex and update them
      shapes.get(shapeSelectedVal).vertices.get(movingVertex).x = mouseX - shapes.get(shapeSelectedVal).xOffset + shapes.get(shapeSelectedVal).globalX;
      shapes.get(shapeSelectedVal).vertices.get(movingVertex).y = mouseY - shapes.get(shapeSelectedVal).yOffset + shapes.get(shapeSelectedVal).globalY;
      shapes.get(shapeSelectedVal).calculateAxis();
    }
  }

  //Reset all our booleans to false
  void mouseReleased() {
    mouseMove = false;
    moveVertex = false;
    moveX = false;
    moveY = false;
  }

  //Checks a key press. Works with both upper and lowercase letters.
  void keyPressed() {
  // If we press 'q', then we should reset the scales and shifts
  if(key == 'q' || key == 'Q') {
    if (shapeSelectedVal > -1){
      shapes.get(shapeSelectedVal).xOffset = 0.0;
      shapes.get(shapeSelectedVal).scaleX = 1.0;
      shapes.get(shapeSelectedVal).yOffset = 0.0;
      shapes.get(shapeSelectedVal).scaleY = 1.0;
    }
  } else if (key == 'w' || key == 'W'){ //If 'w', move every shape up by 10 pixels
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).globalY -= 10.0;
    }
  } else if (key == 's' || key == 'S'){ //If 's', move every shape down by 10 pixels
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).globalY += 10.0;
    }
  } else if (key == 'a' || key == 'A'){ //If 'a', move every shape to the left by 10 pixels
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).globalX -= 10.0;
    }
  } else if (key == 'd' || key == 'D'){ //If 'd', move every shape to the right by 10 pixels
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).globalX += 10.0;
    }
  } else if (key == 'x' || key == 'X'){ //If 'x', reset scale and offset of every shape (as opposed to just the selected one)
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).xOffset = 0.0;
      shapes.get(i).scaleX = 1.0;
      shapes.get(i).yOffset = 0.0;
      shapes.get(i).scaleY = 1.0;
    }
  } else if (key == 'z' || key == 'Z'){ //If 'z', scale up every object
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).scaleX += 0.5;
      shapes.get(i).scaleY += 0.5;
    }
  } else if (key == 'c' || key == 'C'){ //If 'c', scale down every object
    for (int i = 0; i < shapes.size(); i++){
      shapes.get(i).scaleX -= 0.5;
      shapes.get(i).scaleY -= 0.5;
    }
  }
}

/**********************************************
************** COLOUR BOX CLASS ***************
* Box for every colour in the colour selector *
***********************************************/
class ColourBox {
  private float X1; //X location of first coordinate
  private float X2; //X location of second coordinate
  private float Y1; //Y location of first coordinate
  private float Y2; //X location of second coordinate
  private int fill; //Colour value of the box
  private int stroke; //Outline colour of the box
  
  ColourBox(){} //Blank constructor

  ColourBox(float x1, float y1, float x2, float y2, int fillColour, int strokeColour){ //Main constructor
    X1 = x1;
    Y1 = y1;
    X2 = x2;
    Y2 = y2;
    fill = fillColour;
    stroke = strokeColour;
  }
  
  //For debugging: Output bounds of the box
  void outputBounds(){ 
    println("X1: ", X1, " Y1: ", Y1, " X2: ", X2, " Y2: ", Y2);
  }
  
}

/******************************
**** COLOUR SELECTOR CLASS ****
*******************************/
class ColourSelect {
  private int beginColour;  //First colour
  private int endColour;  //Last colour
  private int numOfColours; //How many colours we have
  private int inc;  //Our increment between each colour
  private float barHeightSpacing; //How high is each box
  private ArrayList<Integer> colours = new ArrayList<Integer>();  //List of the colours of every box
  private ArrayList<ColourBox> cBox = new ArrayList<ColourBox>(); //List of every box
  
  ColourSelect(int firstColour, int lastColour, int numberOfColours){ //Main Constructor
    numOfColours = numberOfColours;
    endColour = lastColour;
    beginColour = firstColour;
    
    inc = floor((endColour - beginColour) / (float)numberOfColours); //Calculate every other colour in between the beginning and ending colour
    
    barWidth = width/(float)4;  //Have our colour selector take up only 1/4 of the screen
    barHalf = barWidth/(float)2;  //Have one box only take up a maximum of 1/2 of that 1/4 of the screen
    barHeightSpacing = height/((float)numOfColours/(float)2); //Get the height of each box
    
    //Draw a red box for debugging purposes
    stroke(0);
    fill(255, 0, 0);
    rect(0.0, 0.0, barWidth, height);
    
    //Create a box with all the required locations and add it to the master list
    for (int i = 0; i < numOfColours; i++){
      colours.add(beginColour + inc*i);
      if (i < numOfColours/2){
        ColourBox x = new ColourBox(0.0, barHeightSpacing*i, barHalf, barHeightSpacing*(i+1), colours.get(i), 0);
        cBox.add(x);
      } else {
        ColourBox x = new ColourBox(barHalf, barHeightSpacing*(i-(numOfColours/2)), barWidth, barHeightSpacing*(i+1-(numOfColours/2)),  colours.get(i), 0);
        cBox.add(x);
      }
    }
  }
  
  //Returns the array of boxes
  ArrayList<ColourBox> getBoxes(){
    return cBox;
  }

  //Sets the array of boxes
  void setBoxes(ArrayList<ColourBox> boxes){
    cBox = boxes;
  }

  //Checks to see if a box was clicked
  ColourBox getBoxClicked(int x, int y){
    for (int i = 0; i < cBox.size(); i ++){
      ColourBox check = cBox.get(i);
      if (check.X1 < x && check.X2 > x && check.Y1 < y && check.Y2 > y){ //Simple box bounds check
        return check;
      }
    }
    return null;
  }
    
  //Returns the index in the box list that the given box is in
  int getBoxIndex(ColourBox box){
    for (int i = 0; i < cBox.size(); i++){
      if (cBox.get(i) == box){
        return i;
      }
    }
    return -1;
  }
    
  //Draws the colour selector
  void drawColours(){
    ColourBox selected = new ColourBox(); //Will be coloured last to make the white outline cover the whole square
    for (int i = 0; i < numOfColours; i++){ 
      colours.add(beginColour + inc*i); //Add colour to the list
      ColourBox x = cBox.get(i);  //Get the next box
      if (x.stroke == 255){ //If the stroke colour is white, then redraw it at the end
        selected = x;
      }
      //Draw each box
      fill(x.fill);
      stroke(x.stroke);
      rect(x.X1, x.Y1, x.X2-x.X1, x.Y2-x.Y1);
    }
    //Draw the last selected box
    fill(selected.fill);
    stroke(selected.stroke);
    rect(selected.X1, selected.Y1, selected.X2-selected.X1, selected.Y2-selected.Y1);
  }
}

/************************
**** MY VERTEX CLASS ****
* Who needs PVectors... *
*************************/
class mVertex{
  private float x; //X location
  private float y; //Y location

  mVertex(int xIn, int yIn){ //Main Constructor
    x = xIn;
    y = yIn;
  }
}


/***********************
**** MY SHAPE CLASS ****
*  Data for each Shape *
************************/
class mShape{
  ArrayList<mVertex> vertices;  //List of vertices for each shape
  float xOffset = 0.0;  //Local x offset (Draw with mouse)
  float yOffset = 0.0;  //Locat Y offset
  float globalX = 0.0;  //Global x offset (zoom with keys)
  float globalY = 0.0;  //Global y offset
  int colour; //Shape colour
  mVertex xTransform; //Location of the x transformation node
  mVertex yTransform; //Location of the y transformation node
  mVertex center; //Location of the center of the shape
  float scaleX = 1.0; //Scale value in the x direction
  float scaleY = 1.0; //Scale value in the y direction

  mShape(ArrayList<mVertex> inputVertex, int inputColour){  //Main constructor
    vertices = inputVertex;
    colour = inputColour;
    center = getCenter();
  }

  //Draw the shape on the screen
  void drawShape(){
    fill(colour);
    stroke(0);
    beginShape();
    for (int i = 0; i < vertices.size(); i++){
      vertex(scaleX*(vertices.get(i).x + xOffset + globalX), scaleY*(vertices.get(i).y + yOffset + globalY));
    }
    endShape(CLOSE);
  }

  //Draw the vertex circles if the shape is selected
  void drawCircles(){
    noFill();
    stroke(175, 75, 75);
    strokeWeight(2);
    for (int j = 0; j < vertices.size(); j++){
      ellipse(scaleX*(vertices.get(j).x + xOffset + globalX), scaleY*(vertices.get(j).y + yOffset + globalY), threshold, threshold);
    }
    strokeWeight(1);
  }

  //Calculate the x and y transform axis based off the center point
  void calculateAxis(){
    center = getCenter();
    yTransform = new mVertex((int)(center.x + xOffset + globalX), (int)(center.y + yOffset + globalY - 25));
    xTransform = new mVertex((int)(center.x + xOffset + globalX + 25), (int)(center.y + yOffset + globalY));
  }

  //Draw the transformation axis
  void drawAxis(){
    noFill();
    stroke(75, 175, 75);
    strokeWeight(2);
    //Draw Y Axis
    line(scaleX*yTransform.x, scaleY*xTransform.y, scaleX*yTransform.x, scaleY*yTransform.y);
    ellipse(scaleX*yTransform.x, scaleY*yTransform.y, threshold, threshold);
    //Draw X Axis
    line(scaleX*yTransform.x, scaleY*xTransform.y, scaleX*xTransform.x, scaleY*xTransform.y);
    ellipse(scaleX*xTransform.x, scaleY*xTransform.y, threshold, threshold);
    strokeWeight(1);
  }

  //Set our local offset values
  void setOffset(float x, float y){
    xOffset = x;
    yOffset = y;
  }

  //Set our global offset values
  void setGlobals(float x, float y){
    globalX = x;
    globalY = y;
  }

  //Get the center vertex of the shape
  mVertex getCenter(){
    float x = 0, y = 0;
    for (int i = 0; i < vertices.size(); i++){
      x += vertices.get(i).x;
      y += vertices.get(i).y;
    }
    x = x / (float)vertices.size();
    y = y / (float)vertices.size();
    mVertex result = new mVertex((int)x, (int)y);
    return result;
  }

  //Checks if the mouse is currently in the shape
  boolean mouseInShape(){
    boolean result = false;

    int next = 0;
    for (int current=0; current<vertices.size(); current++) {

      next = current+1; 
      if (next == vertices.size()) next = 0;

      mVertex vCurr = vertices.get(current);  //Get our current vertex 
      mVertex vNext = vertices.get(next); //Get our next vertex
      //Add transformation information:
      float vCurrX = (vCurr.x + xOffset + globalX)*scaleX;
      float vCurrY = (vCurr.y + yOffset + globalY)*scaleY;
      float vNextX = (vNext.x + xOffset + globalX)*scaleX;
      float vNextY = (vNext.y + yOffset + globalY)*scaleY;

      //Check to see if we are in the shape and return the result when we are finished
      if (((vCurrY >= mouseY && vNextY + yOffset < mouseY) || (vCurrY < mouseY && vNextY >= mouseY)) && (mouseX < (vNextX -vCurrX)*(mouseY-vCurrY) / (vNextY-vCurrY)+vCurrX)) {
              result = !result;
      }
    }
    return result;
  }
}