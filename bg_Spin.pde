class SpinningTriangles extends Background
{
  color stripeColors[] = new color[32];
  float animation;
  
  void begin()
  {
    super.begin();
    
    // pick our colors
    int colorIndex = (int)random(0, backgroundColorCount);
    for( int i = 0; i < stripeColors.length; ++i )
    {
      stripeColors[i] = getBackgroundColor( colorIndex );
      colorIndex += (int)random(1,3);
      colorIndex %= backgroundColorCount;
    }
  }
  
  void update( final float dt )
  {
    super.update( dt );
    animation = (animation + dt*0.25f) % 1;
  }
 
  void render()
  {
    float bigDim       = bg.width + 200;
    float stripeHeight = (bigDim / stripeColors.length );
    bg.noStroke();
    
    bg.pushMatrix();
    bg.translate( bg.width/2, bg.height/2, 0 );
    bg.scale( bigDim, bigDim, 1 );
    bg.rotateZ( PI*2*animation );
    
    int sides = stripeColors.length;
    for( int i = 0; i < sides; ++i )
    {
      color c = transformColor( stripeColors[i] );
      bg.fill( c );
      
      bg.beginShape();

      float x1 = cos(2 * PI * i / sides);
      float y1 = sin(2 * PI * i / sides);
      float x2 = cos(2 * PI * (i+1) / sides );
      float y2 = sin(2 * PI * (i+1) / sides );
      
      bg.vertex( x1, y1, 500 );  
      bg.vertex( x2, y2, 500 );
      bg.vertex( 0, 0, 0 );
      
      bg.endShape( CLOSE );
    }
    
    bg.popMatrix();
  }
}
