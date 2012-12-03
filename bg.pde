PImage               backgroundPalette;
GLGraphicsOffScreen  bg;
Background           backgrounds[] = new Background[] 
{ 
  null,
  new LoadingStripes(), 
  new DiagonalStripes(), 
  new DoubleHorizon(), 
  new ConcentricSquares(), 
  new ConcentricHexagons(), 
  new SpinningTriangles()
};

Background activeBackground = null;

void setupBackground()
{
  backgroundPalette = loadImage( "background_palette.jpg" );
  
  if ( activeBackground != null )
  {
    activeBackground.begin();
  }
}

void setActiveBackground( int bindx )
{
  activeBackground = backgrounds[bindx];
  
  if ( activeBackground != null )
  {
    activeBackground.begin();
  }
}

int backgroundColorCount = 10;

color getBackgroundColor( int index )
{
  int pixel = index * (backgroundPalette.width / backgroundColorCount) + 2;
  return backgroundPalette.get( pixel, 5 );
}

void updateBackground( final float dt )
{
  if ( activeBackground != null )
  {
    activeBackground.update( dt );
  }
}

void renderBackground( GLGraphicsOffScreen surface )
{
  if ( activeBackground != null )
  {
    bg = surface;
    
    bg.pushMatrix();
    bg.translate( -bg.width/2, -bg.height/2, -200 );
    
    colorMode( HSB, 360, 100, 100 );
    bg.colorMode( HSB, 360, 100, 100 );
    
    activeBackground.render();
    
    bg.popMatrix();
  }
}

abstract class Background
{
  float hueOffset;
  
  void begin() {}
  
  void update( final float dt )
  {
    hueOffset = (hueOffset + 360*dt) % 360;
  }
  
  color transformColor( color in )
  {
    float h = (hue(in) + hueOffset) % 360;
    float s = saturation(in);
    float b = brightness(in) * 0.5f;
    return color( h, s, b );
  }
  
  abstract void render();
}



