import processing.sound.*;

class Obstacle {
  int     type;
  Vector2 position;
  Vector2 velocity;
  float damage;

  boolean isActive;

  // Adjusted width and height to allow some edge room for more reasonable collision detection
  float adjustedWidth;
  float adjustedHeight;

  Obstacle(int _type, Vector2 _position, Vector2 _velocity, int _width, int _height) {
    type     = _type;
    position = _position;
    velocity = _velocity;

    isActive = true;

    adjustedWidth  = _width / 1.7f;
    adjustedHeight = _height / 1.7f;
  }
}

class Obstacles {
  SoundFile fuelPickup;
  PImage[] textures;

  ArrayList<Obstacle> obstacles;
  int activeObstacleCount = 0;

  Obstacles() {
    fuelPickup = new SoundFile(Game.this, "sounds/368651__jofae__game-powerup.mp3");
    fuelPickup.amp(0.6);
    obstacles = new ArrayList<Obstacle>();
    activeObstacleCount = -1;

    textures = new PImage[4];

    // Load images into texture array
    // If we want more obstacles types just make array bigger
    textures[0] = loadImage("Images/Asteroid.png");
    textures[0].resize(textures[0].width / 3, textures[0].height / 3);

    textures[1] = loadImage("Images/Moon.png");
    textures[1].resize(textures[0].width / 2, textures[0].height / 2);

    textures[2] = loadImage("Images/sun-48194.png");
    textures[2].resize(textures[0].width / 2, textures[0].height / 2);

    textures[3] = loadImage("Images/Gas.png");
    textures[3].resize(textures[0].width / 3, textures[0].height / 3);
  }

  void GenerateAsteroidField(int amount, float bottomExtantY, float topExtantY, float v, int mode) {
    obstacles.clear();

    activeObstacleCount = 0;

    for (int i = 0; i < amount; i++) {
      float obstacleY = random(-topExtantY, -bottomExtantY);
      
      if(mode == 2) {
        v = random(10,15);
      }
      else {
        v = random(6,9);
      }
      
      Obstacle obstacle = new Obstacle(0, new Vector2(random(0, width), obstacleY), new Vector2(0.0f, v), textures[0].width, textures[0].height);
      activeObstacleCount++;

      obstacles.add(obstacle);
    }
  }

  void SpawnSun(float height) {
    Obstacle obstacle = new Obstacle(2, new Vector2(random(-50, -20), height), new Vector2(random(7, 20), 0.0f), textures[2].width, textures[2].height);
    obstacles.add(obstacle);
    //activeObstacleCount++;
  }

  void SpawnMoon(float height) {
    Obstacle obstacle = new Obstacle(1, new Vector2(random(width + 20, width + 50), height), new Vector2(random(-24, -7), 0.0f), textures[1].width, textures[1].height);
    obstacles.add(obstacle);
    //activeObstacleCount++;
  }

  void SpawnHealthPack(int amount, float bottomExtantY, float topExtantY) {
    for (int i = 0; i < amount; i++) {
      float obstacleY = random(-topExtantY, -bottomExtantY);
      Obstacle obstacle = new Obstacle(3, new Vector2(random(0, width), obstacleY), new Vector2(0.0f, random(5, 10)), textures[3].width, textures[3].height);
      obstacles.add(obstacle);
      activeObstacleCount++;
    }
  }

  boolean NoObstaclesLeft() {
    return activeObstacleCount == 0;
  }

  void Process(Rocket rocket) {
    for (Obstacle obstacle : obstacles) {
      if (obstacle.isActive) {
        obstacle.position.x += obstacle.velocity.x;
        obstacle.position.y += obstacle.velocity.y;

        image(textures[obstacle.type], obstacle.position.x, obstacle.position.y);

        // Check for AABB collision
        if (rocket.position.x < obstacle.position.x + obstacle.adjustedWidth && rocket.position.x + rocket.aabbWidth > obstacle.position.x &&
          rocket.position.y < obstacle.position.y + obstacle.adjustedHeight && rocket.position.y + rocket.aabbHeight > obstacle.position.y) {
          if (obstacle.type != 3)
          {
          rocket.damageTaken.play();
          }
          rocket.tStart = millis();

          // Asteroid
          if (obstacle.type == 0) {
            rocket.Life(-20.0);
            rocket.isTint = true;
          }

          // Moon
          if (obstacle.type == 1) {
            rocket.Life(-24.0);
            rocket.isTint = true;
          }

          // Sun
          if (obstacle.type == 2) {
            rocket.Life(-24.0);
            rocket.isTint = true;
          }

          // Gas
          if (obstacle.type == 3) {
            fuelPickup.play();
            rocket.Life(20.00);
            rocket.tintGreen = true;
          }

          obstacle.isActive = false;
          activeObstacleCount--;
        }

        // Kill object if it leaves the screen bounds
        switch (obstacle.type) {
        case 0:
          if (obstacle.position.y > height) {
            obstacle.isActive = false;
            activeObstacleCount--;
          }
          break;

        case 1:
          if (obstacle.position.x < 0) {
            obstacle.isActive = false;
          }
          break;

        case 2:
          if (obstacle.position.x > width) {
            obstacle.isActive = false;
          }
          break;

        case 3:
          if (obstacle.position.y > height) {
            obstacle.isActive = false;
            activeObstacleCount--;
          }
          break;
        }
      }
    }
  }
}
