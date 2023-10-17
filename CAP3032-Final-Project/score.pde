import processing.sound.*;

class Point { //Collectable points
  
  int amount;

  Vector2 position;
  Vector2 velocity;

  boolean isActive;

  //Point constructor
  Point(int _amount, Vector2 _position, Vector2 _velocity) {
    amount = _amount;
    position = _position;
    velocity = _velocity;

    isActive = true;
  }
}

class Score {
  SoundFile pointPickup;
  PImage pointTexture;

  int total;
  //Point object to be kept track of durning game
  ArrayList<Point> points;
  int activePoints;

  // Adjusted width and height to allow some edge room for more reasonable collision detection
  float adjustedWidth;
  float adjustedHeight;

  Score() { //score constructor
    pointPickup = new SoundFile(Game.this, "sounds/402288__matrixxx__retro_coin_02.wav");
    pointPickup.amp(0.6);
    pointTexture = loadImage("Images/Points.png");
    pointTexture.resize(pointTexture.width / 3, pointTexture.height / 3);

    total = 0;
    points = new ArrayList<Point>();
    activePoints = -1;

    adjustedWidth = pointTexture.width / 1.3f;
    adjustedHeight = pointTexture.height / 1.3f;
  }

  //Randomizes point's locatactions
  void GenerateRandom(int amount, float bottomExtantY, float topExtantY) {
    points.clear();

    activePoints = 0;

    for (int i = 0; i < amount; i++) {
      int pointAmount = (int) random(5, 10);
      float pointY    = random(-topExtantY, -bottomExtantY);

      activePoints++;

      points.add(new Point(pointAmount, new Vector2(random(0, width), pointY), new Vector2(0.0f, pointAmount)));
    }
  }

  boolean NoPointsLeft() {
    return activePoints == 0;
  }

  //Draws points and checks for collisions
  void Process(Rocket rocket) {
    for (Point point : points) {
      if (point.isActive) { //Draw
        point.position.x += point.velocity.x;
        point.position.y += point.velocity.y;

        image(pointTexture, point.position.x, point.position.y);

        // Check for AABB collision
        if (rocket.position.x < point.position.x + adjustedWidth && rocket.position.x + rocket.aabbWidth > point.position.x &&
          rocket.position.y < point.position.y + adjustedHeight && rocket.position.y + rocket.aabbHeight > point.position.y) {
          total += point.amount;
          pointPickup.play();
          point.isActive = false;
          activePoints--;
        }

        if (point.position.y > height) {
          point.isActive = false;
          activePoints--;
        }
      }
    }
  }
}
