class DoubleHorizon extends Background
{
  color stripeColors[] = new color[16];
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
    
    verticalOffset -= 200 * dt;
  }
  
  void renderStripes( float dim, float stripeHeight )
  {
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
      bg.rect( -dim*2, y, dim*4, stripeHeight );
    }
  }
 
  void render()
  {
    float dim = bg.width*2.0f;
    if ( verticalOffset < 0 )
    {
      verticalOffset += dim;
    }
    
    float stripeHeight = (dim / stripeColors.length );
    bg.rectMode( CORNER );
    bg.noStroke();
    
    // recenter and get further away from the camera
    bg.translate( bg.width/2, bg.height/2, -1500 );
    
    bg.fill( 0, 0, 100 );
    bg.rect( -dim*2, -200, dim*4, 400 );
    
    bg.pushMatrix();
    bg.translate( 0, 200, 0 );
    bg.rotateX( radians( 90 ) );
    
    renderStripes( dim, stripeHeight );
    
    bg.popMatrix();
    
    bg.pushMatrix();
    
    bg.translate( 0, -200, 0 );
    bg.rotateX( radians( 90 ) );
    
    renderStripes( dim, stripeHeight );
    
    bg.popMatrix();
  }
}
