class Background {
  // Texture
  PImage textureTop;
  PImage textureBottom;

  // Scrolling
  float scrollSpeed;
  float scrollY;

  Background() {
    textureTop = loadImage("Images/Stars.png");
    textureTop.resize(textureTop.width*5, textureTop.height*5);

    textureBottom = loadImage("Images/Stars.png");
    textureBottom.resize(textureBottom.width*5, textureBottom.height*5);

    scrollSpeed = 3.0f;
    scrollY = 0.0f;
  }

  void Draw() {
    // Scroll background using translate
    pushMatrix();
    translate(0.0f, background.scrollY);

    // Draw two images. Ontop of the other to create the illusion of an infinite scrolling background
    image(textureTop, 0.0f, -textureTop.height);
    image(textureBottom, 0.0f, 0.0f);

    // Whenever the scrolling exceeds the bounds of the top image reset the scrollY back to zero.
    // This completels the illusion of an infinite scrolling background
    if (background.scrollY > textureTop.height) {
      scrollY = 0.0f;
    }
    popMatrix();
  }

  void Update() {
    scrollY += scrollSpeed; 
  }
}
