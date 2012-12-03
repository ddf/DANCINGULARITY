class ConcentricSquares extends Background
{
  color stripeColors[] = new color[8];
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
    bg.rectMode( CENTER );
    bg.noStroke();
    
    bg.pushMatrix();
    bg.translate( bg.width/2, bg.height/2, 0 );
    
    for( int i = 0; i < stripeColors.length; ++i )
    {
      color c = transformColor( stripeColors[i] );
      bg.fill( c );
      
      float dim = stripeHeight + i*stripeHeight + bigDim*animation;
      if ( dim > bigDim + stripeHeight )
      {
        dim -= bigDim;
      }
      
      bg.pushMatrix();
      bg.translate( 0, 0, dim * -0.1f );
      bg.rect( 0, 0, dim, dim );
      bg.popMatrix();
    }
    
    bg.popMatrix();
  }
}
