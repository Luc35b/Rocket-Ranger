import processing.sound.*;

class Rocket { //Rocket class variables
  SoundFile quietThrust;
  SoundFile damageTaken;
  
  PImage texture;

  Vector2 position;
  Vector2 velocity;
  float   speed;
  boolean resetRocket = false;
  
  float aabbWidth;
  float aabbHeight;
  
  float health;
  
  //Rocket tail flame variables
  float flameX;
  float flameY;
  float flameSize;
  float flameMultiplier;
  
  //Rocket explosion variables
  int exOpacity = 240;
  float exSize = 10;
  float ex, ey, erad;
  int er, eg, eb, eo;
  
  //Varibales for color change collision effects
  boolean isTint = false;
  boolean tintGreen = false;
  float tCurr = 0, tStart = 10000; 
  float dmgFlashDur = 250;

  //Rocket object constructor
  Rocket() {
    //Rocket sounds
    quietThrust = new SoundFile(Game.this, "sounds/515122__matrixxx__rocket_thrust_02.wav");
    quietThrust.amp(0.5);
    damageTaken = new SoundFile(Game.this, "sounds/361010__projectsu012__bassdrum2-sfxr.wav");
    
    //Rocket image
    texture = loadImage("Images/Spaceship.png");
    texture.resize(texture.width/5, texture.height/5);
    
    //Initial position and speed
    position = new Vector2((width - texture.width) / 2.0f, height - texture.height);
    velocity = new Vector2(0.0f, 0.0f);
    speed = 10.0f;
    
    // Adjust height of collision box for the rocket. 
    aabbWidth = texture.width;
    aabbHeight = texture.height - 50;
    
    //Intial health
    health = 100.0;
    
    flameMultiplier = 5;
  }

  // Draw rocket
  void Draw() {
    if (resetRocket == true) {
      position = new Vector2((width - texture.width) / 2.0f, height - texture.height);
      resetRocket = false;
    }
    if(health > 0) {
      if(!quietThrust.isPlaying())
      {
        quietThrust.play();
      }
      
      //Red tint
      if(isTint && tCurr - tStart <= 250) {
        tCurr = millis();
        tint(220, 35, 35, 126);
        image(texture, position.x, position.y);
        noTint();
      } //Green tint
      else if(tintGreen && tCurr - tStart <= 250) {
        tCurr = millis();
        tint(35, 220, 35, 126);
        image(texture, position.x, position.y);
        noTint();
      }//Normal
      else {
       isTint = false;
       tintGreen = false;
       image(texture, position.x, position.y); 
      }
      
      //Draw rocket flames
      noStroke();
      fill(55, 0, 255, 200);
      for (int i = 0; i < 10; i++) {
        flameX = position.x + 50 + random(-5, 5);
        flameY = position.y + 90 + i * flameMultiplier + noise(i);
        flameSize = 1 + i;
        circle(flameX, flameY, flameSize);
        circle(flameX-28, flameY, flameSize);
      }
    }  
  }

  // Handle rocket movement, logic, or input
  void Update(Background background) {
    if(health > 0) {
      position.x += velocity.x;
      position.y += velocity.y;
    }
    
    // Keep the rocket inside the game boundary
    if (position.x < 0) position.x = 0.0f;
    if (position.x > width - texture.width) position.x = width - texture.width;
    if (position.y < 0) position.y = 0.0f;
    if (position.y > height - texture.height) position.y = height - texture.height;
  }
  
  // Called when a health related collison occurs
  void Life(float life) {
    health += life;
    if(health >= 100.00) {
      health = 100.00; 
    }
  }
  
  // On rocket destroyed
  void GameOver() {
    quietThrust.stop();
    if(health <= 0.0) {
      Explosion();
    }
  }
  
  void Explosion() { //explosion animation
    noStroke();
     
    for (int i = 0; i < 50; i++) {  
      eo = exOpacity;
      if (random(1) < 0.5) {
        er = (int)random(240,255);
        eg = (int)random(75,200);
        eb = 0;
      } 
      else {
        er = 155;
        eg = 155;
        eb = 155;
      }
      fill(er, eg, eb, eo);
    
      ex = position.x + 40 + random(-exSize, exSize);
      ey = position.y + 80 + random(-exSize, exSize);
      erad = random(1, 40);
   
      circle(ex, ey, erad);
    }
    // Disapate explosion
    exSize += 2;
    exOpacity -= 5;
  }
}
