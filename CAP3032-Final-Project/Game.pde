import processing.sound.*;
SoundFile menuMusic;
SoundFile confirmOption;
SoundFile launchSeq;
SoundFile gameMusic;
SoundFile gameOverMusic;
SoundFile starPickUp;

//Variable To Store Menu Background & Heart
PImage menuBackground, heart;

//Boolean Variables To Keep Track Of Events & Game Logic
boolean modeSelected = false;
boolean hardMode = false;
boolean easyMode = false;
boolean launchStarted = false;
boolean gameLost = false;
boolean pause = false;
boolean back = false;
boolean endMusic = false;

//Variables To Keep Track Of Easy & Hard Mode High Scores
int eHighScore = 0;
int hHighScore = 0;

//Create Background, Rocket, Score, & Obstacle Objects
Background background;
Rocket rocket;
Score score;
Obstacles obstacles;

//Game Setup, Load Sounds & Images, Call Object Constructors
void setup () {
  size(1920, 1080);
  menuMusic = new SoundFile(this, "sounds/space-exploration-by-winniethemoog-from-filmmusic-io.mp3");
  gameMusic = new SoundFile(this, "sounds/disco-club-by-winniethemoog-from-filmmusic-io.wav");
  gameOverMusic = new SoundFile(this, "sounds/382310__myfox14__game-over-arcade.wav");
  gameMusic.amp(0.6);
  confirmOption = new SoundFile(this, "sounds/403005__inspectorj__ui-confirmation-alert-a4.wav");
  launchSeq = new SoundFile(this, "sounds/launch-sequence-81945.wav");
  starPickUp = new SoundFile(this, "sounds/402288__matrixxx__retro_coin_02.wav");
  
  menuMusic.loop();
  
  menuBackground = loadImage("Menu.png");
  heart = loadImage("Images/Heat.png");
  heart.resize(heart.width/18, heart.height/18);
  
  background = new Background();
  rocket = new Rocket();
  
  score = new Score();
  obstacles = new Obstacles();
  
  score.GenerateRandom(10, 30, 400);
  obstacles.GenerateAsteroidField(30, 400, 2000, random(7,11), 1);
}

void draw () {
  background(menuBackground);

  //Mode Selected, Waiting For Launch
  if (modeSelected) {
    
    //Back Arrow Button
    stroke(255, 0, 0);
    strokeWeight(5);
    line(10, 25, 25, 35);
    line(10, 25, 25, 15);
    line(10,25,40,25);
    
    stroke(0);
    strokeWeight(0);
    
    //Launch Button
    ellipseMode(CENTER);
    fill(255, 255, 0);
    ellipse(960, 640, 250, 250);
    fill(255, 51, 51);
    ellipse(960, 640, 200, 200);
    fill(255);
    textSize(50);
    textMode(CENTER);
    text("Launch", 960-75, 650);
    
    //High Score Label
    fill(255);
    textSize(70);
    if (!back && easyMode && eHighScore > 0) {
      text("High Score: " + str(eHighScore), width/8-150, height/2 + 100);
    }
    else if (!back && hardMode && hHighScore > 0) {
      text("High Score: " + str(hHighScore), width/8-150, height/2 + 100);
    }
    else {
      text("High Score: --", width/8-150, height/2 + 100);
    }

    if (launchStarted) {
      background(255);
    }
  }
  //Main Menu
  else {
    //Red X (Exit) Button
    stroke(255, 0, 0);
    strokeWeight(5);
    line(10, 10, 40, 40);
    line(10, 40, 40, 10);
    
    stroke(0);
    strokeWeight(0);
  
    //Easy & Hard Button
    fill(102, 255, 178);
    rect(595, 625, 290, 100, 16);
    fill(255, 51, 51);
    rect(1030, 625, 290, 100, 16);

    textMode(CENTER);
    textSize(100);
    fill(255);
    text("EASY", 740-100, 705);
    text("HARD", 1175-110, 705);
  }

  //Game Started
  if (launchStarted) {
    if(!gameMusic.isPlaying())
    {
      gameMusic.play();
    }
    background(0);

    //Rocket Destroyed, Game Over
    if(rocket.health <= 0.0) {
      gameLost = true;
      gameMusic.stop();
      background.Draw();
      if (easyMode && score.total > eHighScore) {
        eHighScore = score.total; 
      }
      else if (hardMode && score.total > hHighScore) {
        hHighScore = score.total; 
      }
      GameOver();
    }
    else {
      // Update objects
      background.Update();
      rocket.Update(background);

      background.Draw();
      rocket.Draw();
    
      score.Process(rocket);
      obstacles.Process(rocket);
      
      // Add differentiation for hard mode and easy mode
      // When final object passes screen spawn new objects
      if (score.NoPointsLeft()) {
          score.GenerateRandom((int)random(10, 50), 30, random(400, 12000)); 
      }
      
      if (obstacles.NoObstaclesLeft()) {
        if(easyMode) { // Draw obstacles on easy mode
          obstacles.GenerateAsteroidField(20, 400, random(1200, 3000), random(7,11), 1);
          
          obstacles.SpawnSun(random(0, height / 2.0f));
          obstacles.SpawnMoon(random(0, height / 1.5f));
          
          obstacles.SpawnHealthPack(1, 400, random(1200, 3000));
        }
        else if(hardMode) { //Draw obstacles on easy mode
          obstacles.GenerateAsteroidField(30, 400, random(1000, 3500), random(10,15),2);
          
          obstacles.SpawnSun(random(0, height / 2.0f));
          obstacles.SpawnMoon(random(0, height / 1.5f));
          
          obstacles.SpawnSun(random(0, height / 1.0f));
          obstacles.SpawnMoon(random(0, height / 1.2f));
          
          obstacles.SpawnHealthPack(1, 400, random(1200, 3000));
        }
      }
    }
    
    // Draw score in left corner
    textSize(70);
    fill(#FFFFFF);
    text(str(score.total), 50, 50);
    
    //Draw heart & health in right corner
    textSize(70);
    tint(255, 220);
    image(heart, width - 225, 0);
    noTint();
    if(rocket.health > 0) {
      fill(102, 255, 178);
      text((int)rocket.health, width-150, 50);
    }
    else {
      fill(255, 51, 51);
      text(0, width-150, 50);
    }
    
    //Back Button
    if (!gameLost) {
      stroke(255, 0, 0);
      strokeWeight(5);
      line(10, 25, 25, 35);
      line(10, 25, 25, 15);
      line(10,25,40,25);
    }
  }
}

//Game Over, Display To User & Ask To Try Again
void GameOver() {
  if(rocket.health <= 0.0) {
    rocket.GameOver();
    //can add more here
    easyMode = false;
    hardMode = false;
    
    textAlign(CENTER);
    textSize(200);
    fill(255,0,0);
    text("Game Over", width/2, height/2 -50);
    
    fill(255, 51, 51);
    rectMode(CENTER);
    rect(width/2, height/2 + 250, 300, 250, 25);

    textSize(100);
    textLeading(110);
    fill(255);
    text("Try\nAgain?", width/2, height/2 + 225);
    
    rectMode(CORNER);
    textAlign(LEFT);
    if(!endMusic)
    {
      gameOverMusic.play();
      endMusic = true;
    }
  }
}

void mouseClicked() {
  //Easy Mode Selected
  if (modeSelected == false && mouseX >= 595 && mouseX <= 885 && mouseY >= 625 && mouseY <= 725) {
    confirmOption.play();
    modeSelected = true;
    easyMode = true;
    back = false;
  }
  // Hard Mode Selected
  if (modeSelected == false && mouseX >= 1030 && mouseX <= 1320 && mouseY >= 625 && mouseY <= 725) {
    confirmOption.play();
    modeSelected = true;
    hardMode = true;
    back = false;
  }
  // Launch Button Clicked
  if (modeSelected == true && launchStarted == false && mouseX >= 885 && mouseX <= 1030 && mouseY >= 515 && mouseY <= 765) {
    confirmOption.play();
    delay(700);
    launchSeq.play();
    delay(2700);
    launchStarted = true;
    menuMusic.stop();
  }
  // Try Again Button Clicked
  if (gameLost == true && mouseX >= width/2-150 && mouseX <= width/2+150 && mouseY >= height/2 + 125 && mouseY <= height/2 + 375) {
    confirmOption.play();
    endMusic = false;
    gameLost = false;
    modeSelected = false;
    launchStarted = false;
    score.total = 0;
    rocket.health = 100.0;
    menuMusic.loop();
    easyMode = false;
    hardMode = false;
    rocket.resetRocket = true;
    rocket.exOpacity = 240;
    rocket.exSize = 10;
    //reset obsticle positions after trying again
    obstacles.obstacles.clear();
    obstacles.activeObstacleCount = 0;
    score.GenerateRandom(10, 30, 400);
    obstacles.GenerateAsteroidField(30, 400, 2000, random(7,11), 1);
  }
  // Game Back button Clicked
  else if (modeSelected == true && launchStarted == true && mouseX >= 10 && mouseX <= 40 && mouseY >= 10 && mouseY <= 40) {
      confirmOption.play();
      gameLost = true;
      back = true;
      gameMusic.stop();
      delay(1000);
      modeSelected = false;
      launchStarted = false;
      menuMusic.loop();
      score.total = 0;
      rocket.health = 100.0;
      easyMode = false;
      hardMode = false;
      rocket.resetRocket = true;
      rocket.GameOver();
      obstacles.obstacles.clear();
      obstacles.activeObstacleCount = 0;
      score.GenerateRandom(10, 30, 400);
      obstacles.GenerateAsteroidField(30, 400, 2000, random(7,11), 1);
  }
  // Menu Launch Back Button Clicked
  else if (modeSelected == true && launchStarted == false && mouseX >=10 && mouseX <= 40 && mouseY >= 10 && mouseY <= 40) {
    confirmOption.play();
    back = true;
    modeSelected = false;
    easyMode = false;
    hardMode = false;
    obstacles.obstacles.clear();
    obstacles.activeObstacleCount = 0;
  }
  // Main Menu Exit Button Clicked
  else if (modeSelected == false && launchStarted == false && mouseX >=10 && mouseX <= 40 && mouseY >= 10 && mouseY <= 40) {
    confirmOption.play();
    delay(1000);
    exit();
  }
}

//Ship Movement
void keyPressed() {
  //Left
  if (key == 'a') {
    rocket.velocity.x = -rocket.speed;
    //rocket.health -=10; // can remove, used for testing
    if(rocket.flameMultiplier > 5){
      rocket.flameMultiplier--;
    } else if(rocket.flameMultiplier < 5){
      rocket.flameMultiplier++;
    }
  } 
  //Right
  else if (key == 'd') {
    rocket.velocity.x = rocket.speed;
    //rocket.health -=10; // can remove, used for testing
    if(rocket.flameMultiplier > 5){
      rocket.flameMultiplier--;
    } else if(rocket.flameMultiplier < 5){
      rocket.flameMultiplier++;
    }
  }
  //Up
  else if (key == 'w') {
    rocket.velocity.y = -rocket.speed;
    if(rocket.flameMultiplier < 10){
      rocket.flameMultiplier++;
    }
  }
  //Down
  else if (key == 's') {
    rocket.velocity.y = rocket.speed;
    if(rocket.flameMultiplier > 2){
      rocket.flameMultiplier--;
    }
  }
  //Pause Key
  if (key == 'p') {
    if(!pause && launchStarted) {
      noLoop();
      pause = true;
      fill(255);
      noStroke();
      rect(width/2 - 70, height/2, 50, 200);
      rect(width/2 + 20, height/2, 50, 200);
      
    }
    else if (pause && launchStarted){
     loop(); 
     pause = false;
    }
  }
}

void keyReleased() {
  if (key == 'a') {
    rocket.velocity.x = 0.0f;
  }

  if (key == 'd') {
    rocket.velocity.x = 0.0f;
  }

  if (key == 'w') {
    rocket.velocity.y = 0.0f;
  }

  if (key == 's') {
    rocket.velocity.y = 0.0f;
  }
}
