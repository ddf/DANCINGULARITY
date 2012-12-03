class LoadingStripes extends Background
{
  color stripeColors[] = new color[16];
  
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
 
  void render()
  {
    float stripeHeight = ((float)bg.height / stripeColors.length );
    bg.rectMode( CORNER );
    bg.noStroke();
    
    bg.fill( transformColor( stripeColors[0] ) );
    // one fullscreen because the z-fighting 
    // that happens when the camera moves is really cool looking    
    bg.rect( 0, 0, bg.width, bg.height );
    
    // just a bunch of horizontal stripes
    for( int i = 0; i < stripeColors.length; ++i )
    {
      color c = transformColor( stripeColors[i] );
      bg.fill( c );
      bg.rect( 0, i * stripeHeight, bg.width, stripeHeight );
    }
  }
}
