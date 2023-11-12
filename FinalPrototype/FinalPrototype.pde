import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();


float movementSpeed; // used to control speed that the square moves
float targetSquareX;
float targetSquareY;


void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
  movementSpeed = 1; // init movement speed to default
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
    {
      stroke(255, 0, 0, 192); //set color to semi translucent
      rect(0, 0, d.z, d.z);
      targetSquareX = d.x;
      targetSquareY = d.y;
    }
    else if (trialIndex+1==i && i+1 <= trialCount) // highlight next square !!!
    {
      //stroke(0, 255, 0, 192); -- green highlight used in prototype 1
      stroke(128, 128, 128, 128); //set color to semi translucent
      rect(0, 0, d.z, d.z);
    }
    
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  if(checkForSuccess()) // change color of square on success
  {
    if(frameCount % 2 == 0)
      fill(0);
    else
      fill(255);
    circle(0, 0, logoZ/2);
    fill(255, 255, 0, 192);
  }
  else
  {
   fill(60, 60, 192, 192); 
  }
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  //scaffoldControlLogic(); //you are going to want to replace this!
  displayText();
  drawDial();
}




//my example design for control, which is terrible
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  //text("CCW", 830, 660);
  if (mousePressed && dist(830, 660, mouseX, mouseY)<inchToPix(.5f))
    logoRotation = logoRotation - 1 * movementSpeed;

  //upper right corner, rotate clockwise
  //text("CW", width-30, 660);
  if (mousePressed && dist(width-30, 660, mouseX, mouseY)<inchToPix(.5f))
    logoRotation = logoRotation + 1 * movementSpeed;

  //lower left corner, decrease Z
  //text("-", 830, height-inchToPix(.4f));
  if (mousePressed && dist(830, height-inchToPix(.4f), mouseX, mouseY)<inchToPix(.5f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  //text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(width-inchToPix(.4f), height-inchToPix(.4f), mouseX, mouseY)<inchToPix(.5f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  //left middle, move left
  //text("left", 830, 715);
  if (mousePressed && dist(830, 715, mouseX, mouseY)<inchToPix(.5f))
    logoX = logoX - inchToPix(.02f) * movementSpeed;

  //text("right", width-inchToPix(.4f), 715);
  if (mousePressed && dist(width-inchToPix(.4f), 715, mouseX, mouseY)<inchToPix(.5f))
    logoX = logoX + inchToPix(.02f) * movementSpeed;

  //text("UP", 905, 660);
  if (mousePressed && dist(905, 660, mouseX, mouseY)<inchToPix(.5f))
    logoY = logoY - inchToPix(.02f) * movementSpeed;

  //text("DOWN", 905, height-inchToPix(.4f));
  if (mousePressed && dist(905, height-inchToPix(.4f), mouseX, mouseY)<inchToPix(.5f))
    logoY = logoY + inchToPix(.02f) * movementSpeed;
    
   //text("Enter", 905, 715);
}




void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  // check for mouse clicks on the decrease movement speed button
  if(mouseX > width/1.25 - 60 && mouseX < width/1.25 - 20 && mouseY > inchToPix(.8f) - 20 && mouseY < inchToPix(.8f) + 20)
    if(movementSpeed - 0.25 > 0)
      movementSpeed -= 0.25;
      
  // check for mouse clicks on the increase movement speed button
  if(mouseX > width/1.25 + 20 && mouseX < width/1.25 + 60 && mouseY > inchToPix(.8f) - 20 && mouseY < inchToPix(.8f) + 20)
    if(movementSpeed + 0.25 <= 3)
      movementSpeed += 0.25;

}




void mouseReleased()
{
  // ensures trialIndex will always stay within bounds of the list
  if(trialIndex == trialCount)
    return;
  
  boolean check = false;
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  //if (dist(905, 715, mouseX, mouseY)<inchToPix(.5f))
    //check = true;
  
  
  // check if clicked within the button
  if(checkForSuccess())
    if(dist(targetSquareX, targetSquareY, mouseX, mouseY)<inchToPix(.5f))
      check = true;
  
  if(check)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
    
    // reset location, rotation, and movement speed
    logoX = 500;
    logoY = 500;
    logoZ = 50f;
    logoRotation = 0;
    movementSpeed = 1;
  }
}




//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}




//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}




//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}



/* Function: displayText
 * Paremeters: None
 * Return: None
 * This function draws the trial text, movement speed text and buttons, coordinate text of active square, and coordinate text of cursor square to the screen. If the cursor square is in a success state, the color changes to yellow to indicate to the user it is safe to click
*/
void displayText()
{
  // ===== TRIAL TEXT =====
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  
  // ===== MOVEMENT SPEED TEXT AND BUTTONS =====
  text("-", width/1.25 - 50, inchToPix(.8f));
  text("Speed", width/1.25, inchToPix(.8f));
  text("+", width/1.25 + 50, inchToPix(.8f));
  text(nf(movementSpeed, 0, 2), width/1.25 + 100, inchToPix(.8f));
  
  
  textSize(15); // init to 15px
  
  // ===== TARGET COORDINATES =====
  if(checkForSuccess())
    fill(255, 255, 0); // yellow
  else
    fill(173, 216, 230); // light blue
  
  Destination d = destinations.get(trialIndex);
  text("X " + d.x + ", Y " + d.y + ", R "+ d.rotation + ", Z "+ d.z, width/5, inchToPix(.4f));
  
  
  // ===== CURRENT COORDINATES =====
  if(!checkForSuccess())
    fill(255); // reset  
    
  text("X " + logoX + ", Y " + logoY + ", R "+ logoRotation + ", Z "+ logoZ, width/5, inchToPix(.8f));
  
  
  // ===== RESET =====
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  // reset color
  fill(255);
}





/* Function: drawDial
 * Parameters: none
 * Return: none
 * This function draws the dial buttons on the screen. It calculates the neccessary coordinates for checForSuccess() to return true and highlights the buttons for the user to make it easier to move the logo square to the correct coordinates.
*/
void drawDial()
{
  /* Get Data For Coordinate Collection */
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  
  
  
  
  fill(167, 161, 161, 55);
  circle(905, 715, 110); // main dial
  
  circle(830, 655, 60); //CCW circle
  circle(width-30, 655, 60); //CW circle
  circle(830, 765, 40); // - circle
  circle(972, 765, 50); // + circle
  
  fill(255);
  
  if(!closeRotation)
    if(abs(logoRotation-d.rotation) % 360 - 180 <0)
      fill(238,130,238);
  //upper left corner, rotate counterclockwise
  text("CCW", 830, 660);
  fill(255);
  if (mousePressed && dist(830, 660, mouseX, mouseY)<inchToPix(.4f))
    logoRotation = logoRotation - 1 * movementSpeed;

  
  
  if(!closeRotation)
    if(abs(logoRotation-d.rotation)% 360 - 180 > 0)
      fill(238,130,238);
  //upper right corner, rotate clockwise
  text("CW", width-30, 660);
  fill(255);
  if (mousePressed && dist(width-30, 660, mouseX, mouseY)<inchToPix(.4f))
    logoRotation = logoRotation + 1 * movementSpeed;


  if(!closeZ)
    if(logoZ>d.z)
      fill(238,130,238);
  //lower left corner, decrease Z
  text("-", 830, height-inchToPix(.4f));
  fill(255);
  if (mousePressed && dist(830, height-inchToPix(.4f), mouseX, mouseY)<inchToPix(.4f))
    logoZ = constrain(logoZ-inchToPix(.02f) * movementSpeed, .01, inchToPix(4f)); //leave min and max alone!
  
  
  if(!closeZ)
    if(logoZ<d.z)
      fill(238,130,238);
  //lower right corner, increase Z
  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  fill(255);
  if (mousePressed && dist(width-inchToPix(.4f), height-inchToPix(.4f), mouseX, mouseY)<inchToPix(.4f))
    logoZ = constrain(logoZ+inchToPix(.02f) * movementSpeed, .01, inchToPix(4f)); //leave min and max alone! 



  // arrows
  stroke(255);
  if(!closeDist)
    if(abs(logoX-d.x)>inchToPix(0.02f) && logoX > d.x)
      stroke(238,130,238);
  //left middle, move left
  //text("left", 830, 715);
  drawArrow(880, 715,20,180); // left
  stroke(255);
  if (mousePressed && dist(880, 715, mouseX, mouseY)<inchToPix(.4f))
    logoX = logoX - inchToPix(.02f) * movementSpeed;


  if(!closeDist)
    if(abs(logoX-d.x)>inchToPix(0.02f) && logoX < d.x)
      stroke(238,130,238);
  //text("right", width-inchToPix(.4f), 715);
  drawArrow(930, 715,20,0); //right
  stroke(255);
  if (mousePressed && dist(930, 715, mouseX, mouseY)<inchToPix(.4f))
    logoX = logoX + inchToPix(.02f) * movementSpeed;


  if(!closeDist)
    if(abs(logoY-d.y)>inchToPix(0.02f) && logoY > d.y)
      stroke(238,130,238);
  //text("UP", 905, 660);
  drawArrow(905, 690,20,270); //UP
  stroke(255);
  if (mousePressed && dist(905, 690, mouseX, mouseY)<inchToPix(.4f))
    logoY = logoY - inchToPix(.02f) * movementSpeed;


  if(!closeDist)
    if(abs(logoY-d.y)>inchToPix(0.02f) && logoY < d.y)
      stroke(238,130,238);
  //text("DOWN", 905, height-inchToPix(.4f));
  drawArrow(905, 740,20,90);//down
  stroke(255);
  if (mousePressed && dist(905, 740, mouseX, mouseY)<inchToPix(.4f))
    logoY = logoY + inchToPix(.02f) * movementSpeed;
  
   
  //if(checkForSuccess())
    //fill(238,130,238);
  //text("Enter", 905, 715);
  //fill(255);
}


void drawArrow(float cx, float cy, int len, float angle){
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
}
