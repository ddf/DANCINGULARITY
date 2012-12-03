class DiagonalStripes extends Background
{
  color stripeColors[] = new color[32];
  float verticalOffset;
  
  void begin()
  {
    super.begin();
    
    verticalOffset = 0;
    
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
    
    verticalOffset += 100 * dt;
  }
 
  void render()
  {
    float dim = bg.width*1.25f;
    verticalOffset %= dim;
    
    float stripeHeight = (dim / stripeColors.length );
    bg.rectMode( CORNER );
    bg.noStroke();
    
    bg.pushMatrix();
    bg.translate( bg.width/2, bg.height/2, 0 );
    bg.rotateZ( radians( -45 ) );
    
    // just a bunch of horizontal stripes
    for( int i = 0; i < stripeColors.length; ++i )
    {
      color c = transformColor( stripeColors[i] );
      bg.fill( c );
      
      float y = (i*stripeHeight) - verticalOffset;
      if ( y < -stripeHeight )
      {
        y += dim;
      }
      bg.rect( -dim/2, -dim/2 + y, dim, stripeHeight );
    }
    
    bg.popMatrix();
  }
}
