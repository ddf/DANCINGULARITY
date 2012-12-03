class ConcentricHexagons extends Background
{
  color stripeColors[] = new color[16];
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
    
    for( int i = 0; i < stripeColors.length; ++i )
    {
      color c = transformColor( stripeColors[i] );
      bg.fill( c );
      
      float dim = stripeHeight + i*stripeHeight + bigDim*(1-animation);
      if ( dim > bigDim + stripeHeight )
      {
        dim -= bigDim;
      }
      
      bg.pushMatrix();
      bg.translate( 0, 0, dim * -0.1f );
      bg.rotateZ( PI/2 );
      bg.scale( dim, dim, 1 );
      
      bg.beginShape();
      
      int sides = int(6 + 3*sin(animation*PI));
      for (int v = 0; v < sides; v++) 
      {
        float x = cos(2 * PI * v / sides);
        float y = sin(2 * PI * v / sides);
        
        bg.vertex( x, y, 0 );
      }
      
      bg.endShape( CLOSE );
      
      bg.popMatrix();
    }
    
    bg.popMatrix();
  }
}
