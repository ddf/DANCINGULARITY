import traer.physics.*;
import processing.opengl.*;
import codeanticode.glgraphics.*;
import damkjer.ocd.*;
import procontroll.*;
import net.java.games.input.*;

GLGraphicsOffScreen offscreen;

GLTexture srcTex, bloomMask, destTex;
GLTexture tex0, tex2, tex4, tex8, tex16;
GLTexture tmp2, tmp4, tmp8, tmp16;
GLTextureFilter extractBloom, blur, blend4, toneMap;

PImage noiseTex;
PFont  numberFont;
PFont  messageFont;

Camera cam;

ControllIO io;

ControllDevice getDevice( int id )
{
  ControllDevice d = null;
  try
  {
    if ( io != null )
    {
      d = io.getDevice(id);
    }
  }
  catch( Exception ex )
  {
  }
  
  return d;
}

DanceMat[] theMats = new DanceMat[9];

ArrayList<String> paletteNames = new ArrayList<String>();
ArrayList<PImage> palettes = new ArrayList<PImage>();
int        activePalette;
float      MAT_SPACING     = 120;

PImage getActivePalette()
{
  return palettes.get(activePalette);
}

void setup()
{
  size( screenWidth, screenHeight, GLConstants.GLGRAPHICS );
  
  setupControls();
  setupVFX();
  
  numberFont  = createFont( "Arial", 12 );
  messageFont = loadFont("Futura-Medium.vlw");

  // initialize all the fancy graphics stuff
  {
    //hint( ENABLE_OPENGL_4X_SMOOTH );
    // Loading required filters.
    extractBloom = new GLTextureFilter(this, "ExtractBloom.xml");
    blur = new GLTextureFilter(this, "Blur.xml");
    blend4 = new GLTextureFilter(this, "Blend4.xml");  
    toneMap = new GLTextureFilter(this, "ToneMap.xml");

    destTex = new GLTexture(this, width, height);

    // Initializing bloom mask and blur textures.
    bloomMask = new GLTexture(this, width, height, GLTexture.FLOAT);
    tex0 = new GLTexture(this, width, height, GLTexture.FLOAT);
    tex2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT);
    tmp2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT); 
    tex4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
    tmp4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
    tex8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT);
    tmp8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT); 
    tex16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);
    tmp16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);

    offscreen = new GLGraphicsOffScreen(this, width, height, true, 4);  
    offscreen.rectMode( CENTER );
    offscreen.colorMode( HSB, 360, 100, 100, 1 );
    
    setupBackground();
    
    noiseTex = loadImage("Noise.png");
  }
  
  // load palettes
  {
    // we'll have a look in the data folder
    PImage palette = null;
    int    paletteID = 0;
    do
    {
      String name = "palette" + paletteID + ".png";
      palette = loadImage( name );
      if ( palette != null )
      {
        palettes.add( palette );
        paletteNames.add( name );
        ++paletteID;
      }
    } while ( palette != null );
    activePalette = 0;
  }
  
  cam = new Camera(this, 0, 0, 475);

  io = ControllIO.getInstance( this );
  io.printDevices();
  
  MAT_AUTO_PLAY = io.getNumberOfDevices() != 9;

  theMats[0] = new DanceMat( getDevice(0), new PVector( MAT_SPACING, MAT_SPACING ) );
  theMats[1] = new DanceMat( getDevice(1), new PVector( 0,  MAT_SPACING ) );
  theMats[2] = new DanceMat( getDevice(2), new PVector( -MAT_SPACING, MAT_SPACING ) );
  theMats[3] = new DanceMat( getDevice(3), new PVector( MAT_SPACING, 0 ) );
  theMats[4] = new DanceMat( getDevice(4), new PVector( 0, 0 ) );
  theMats[5] = new DanceMat( getDevice(5), new PVector( -MAT_SPACING, 0 ) );
  theMats[6] = new DanceMat( getDevice(6), new PVector( MAT_SPACING, -MAT_SPACING ) );
  theMats[7] = new DanceMat( getDevice(7), new PVector( 0, -MAT_SPACING ) );
  theMats[8] = new DanceMat( getDevice(8), new PVector( -MAT_SPACING, -MAT_SPACING ) );
  
  //frameRate(30);
  
  noCursor();
  //cursor(CROSS);
}

float globalScale  = 1;
float globalShearX = 0;
float globalShearY = 0;
float globalJitter = 0;

float cameraJump   = 0;
float cameraOffX   = 0;
float cameraOffY   = 0;
float cameraShake  = 0;

float globalYRot   = 0;
float globalZRot   = 0;

float defaultFx = 0.465f;
float defaultFy = 0.795f;
float fx = defaultFx;
float fx_min = 0.01f;
float fx_max = 1;
float fy = defaultFy;
float fy_min = 0;
float fy_max = 1;


float globalBloomFlash      = 0;
float globalBackgroundFlash = 0;
float globalBackgroundHue   = 0;
float globalBackgroundSat   = 0;

float dancingularityCubeFlash = 0;

float horizontalDisplacement  = 0;
int   horizontalDivision      = 2;
float verticalDisplacement    = 0;
int   verticalDivision        = 2;
float gridDilation            = 0.0f;

float  messageDisplayTimer = 0;
String messageToDisplay    = "";

void mouseDragged()
{
  fx = constrain(float(mouseX) / width, 0.01f, 1);
  fy = 1 - float(mouseY) / height;
}

float dt = 0;

void draw()
{
  dt = 1.0f / frameRate;
  
  if ( messageDisplayTimer > 0 )
  {
    messageDisplayTimer -= dt;
    
    if ( messageDisplayTimer <= 0 )
    {
      messageToDisplay = "";
    }
  }
  
  updateBackground( dt );
  updateVFX();

  float totalHeat = 0;
  for( int i = 0; i < theMats.length; ++i )
  {
    if ( theMats[i] != null )
    {
      theMats[i].update( dt );
      totalHeat += theMats[i].heat();
    }
  }
  
  globalBackgroundHue = constrain( map( totalHeat, 0, 8*theMats.length, 60, 0 ), 0, 60 );
  
  globalScale  = step( globalScale, 0.5f, 1 );
  globalShearX = step( globalShearX, 0.5f, 0 );
  globalShearY = step( globalShearY, 0.5f, 0 );
  globalJitter = step( globalJitter, 0.25f, 0 );
  globalBloomFlash = step( globalBloomFlash, 0.5f, 0 );
  globalBackgroundFlash = step( globalBackgroundFlash, 0.25f, 0 );
  cameraShake = step( cameraShake, 0.25f, 0 );
  dancingularityCubeFlash = step( dancingularityCubeFlash, 0.1f, 0 );
  
  cameraJump *= 0.6f;
  cameraOffX *= 0.95f;
  cameraOffY *= 0.95f;
  globalYRot *= 0.95f;
  globalZRot *= 0.95f;

  background(0);

  srcTex = offscreen.getTexture();

  offscreen.beginDraw();
  { 
    float angle = random( TWO_PI );
    float camSX = 15*cameraShake*sin(angle);
    float camSY = 15*cameraShake*cos(angle);
    float camX = cameraOffX + camSX;
    float camY = cameraOffY + camSY;
    float camZ = 465 + cameraJump;
    cam.jump( camX, camY, camZ );
    cam.aim( camSX, camSY, 0 );
    cam.feed();   

    offscreen.colorMode( HSB, 360, 100, 100 );
    offscreen.background( globalBackgroundHue, globalBackgroundSat, globalBackgroundFlash * 100 );
    offscreen.lights();
    offscreen.setDefaultBlend();
    offscreen.hint( ENABLE_DEPTH_TEST );
    
    renderBackground( offscreen );
    
    offscreen.pushMatrix();
    offscreen.rotateZ( radians(globalZRot) );
    offscreen.rotateY( radians(globalYRot) );
    offscreen.scale( globalScale, 1, 1 );
    offscreen.shearX( globalShearX );
    offscreen.shearY( globalShearY );
    
    if ( DANCINGULARITY_ENABLED )
    {
      offscreen.fill( 255*dancingularityCubeFlash );
      offscreen.noStroke();
      offscreen.box( DANCE_CUBE_SIZE, DANCE_CUBE_SIZE, DANCE_CUBE_SIZE );
    }
    else
    {
      if ( MAT_BUILDUP )
      {
        offscreen.noFill();
        offscreen.stroke( 255 );
        offscreen.box( DANCE_CUBE_SIZE, DANCE_CUBE_SIZE, DANCE_CUBE_SIZE );
      }
  
      if ( MAT_BUILDUP || MAT_BOX_MODE )
      {
        for( int i = 0; i < theMats.length; ++i )
        {
          if ( theMats[i] != null )
          {
            theMats[i].draw( offscreen );
          }
        }
      }
      else
      {
        drawBigGrid();
      }
    }
    
    drawVFX( offscreen );
    
    offscreen.popMatrix();
  }
  offscreen.endDraw();
  
  float bloomfx = constrain( fx - 0.4f*globalBloomFlash, 0.01, 1 );
  float bloomfy = constrain( fy + 0.4f*globalBloomFlash, 0.01, 1.1 );

  // Extracting the bright regions from input texture.
  extractBloom.setParameterValue("bright_threshold", bloomfx);
  extractBloom.apply(srcTex, tex0);

  // Downsampling with blur
  tex0.filter(blur, tex2);
  tex2.filter(blur, tmp2);        
  tmp2.filter(blur, tex2);

  tex2.filter(blur, tex4);        
  tex4.filter(blur, tmp4);
  tmp4.filter(blur, tex4);            
  tex4.filter(blur, tmp4);
  tmp4.filter(blur, tex4);            

  tex4.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);

  tex8.filter(blur, tex16);     
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);        
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);        
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);  

  // Blending downsampled textures.
  blend4.apply(new GLTexture[] { tex2, tex4, tex8, tex16 }, new GLTexture[] { bloomMask } );

  // Final tone mapping into destination texture.
  toneMap.setParameterValue("exposure", bloomfy);
  toneMap.setParameterValue("bright", bloomfx);
  toneMap.apply(new GLTexture[] { srcTex, bloomMask }, new GLTexture[] { destTex } );

  //image(destTex, 0, 0, width, height);
  beginShape( QUADS );
  {
    texture( destTex );
    noStroke();
    //stroke( 255 );
    //textureMode( NORMAL );
    int colums = horizontalDivision;
    int rows   = verticalDivision;
    float h    = height / rows;
    float w    = width / colums;
    float x    = w/2;
    float y    = h/2;
    for( int r = 0; r < rows; ++r )
    {
      for( int c = 0; c < colums; ++c )
      {
        float hoff = horizontalDisplacement * ( r%2==0 ? 1 : -1 );
        float voff = verticalDisplacement * ( c%2==0 ? -1 : 1 );
        float scal = 1 + gridDilation;
        float xs   = w/2 * scal;
        float ys   = h/2 * scal;
        // offset the squares we draw
        {
          vertex( x - xs + hoff, y - ys + voff, c*w,     r*h );
          vertex( x - xs + hoff, y + ys + voff, c*w,     r*h + h );
          vertex( x + xs + hoff, y + ys + voff, c*w + w, r*h + h );
          vertex( x + xs + hoff, y - ys + voff, c*w + w, r*h );
        }
        x += w;
      }
      x  = w/2;
      y += h;
    }
  }
  endShape();
  
    beginDebugText();
    //debugText( "FPS: " + frameRate );
    if ( SHOW_CONTROLS )
    {
      debugText( "exposure (mouseX): " + fx );
      debugText( "brightness (mouseY): " + fy );
      debugText( "pad animation (0,1,2,3,4): " + matButtonAnimationString(MAT_BUTTON_ANIMATION) );
      debugText( "pad fade time (q,a): " + MAT_BUTTON_FADE_TIME );
      debugText( "active palette (p): " + paletteNames.get(activePalette) );
      debugText( "heat increment (y,h): " + MAT_BUTTON_HEAT_INCREMENT );
      debugText( "heat cooldown wait ms (u,j): " + MAT_BUTTON_COOLDOWN_WAIT );
      debugText( "other controls:");
      debugText( "B - begin build-up to dancingularity" );
      debugText( "D - trigger the dancingularity" );
      debugText( "w - horizontal stretch" );
      debugText( "e - horizontal shear" );
      debugText( "r - vertical shear" );
      debugText( "s - camera zoom in" );
      debugText( "d - camera zoom out" );
      debugText( "f - camera random tumble" );
      debugText( "g - camera shake");
      debugText( "left arrow - rotate grid counter-clockwise");
      debugText( "right arrow - rotate grid clockwise" );
      debugText( "up arrow - rotate grid to right" );
      debugText( "right arrow - rotate grid to left" );
      debugText( "t - add jitter to mats" );
      debugText( "b - flash background" );
      debugText( "spacebar - flash bloom (during Dancingularity also flashes cube)" );
      debugText( "k - toggle wireframe" );
      debugText( "c - take a screenshot" );
      debugText( "` - toggle all this text (better framerate without)");
    }
    endDebugText();
    
    if ( SHOW_NUMBERS )
    {
      textFont( numberFont );
      pushMatrix();
      translate( width - 20, 45 );
      scale( 2 );
      textAlign( RIGHT );
      colorMode( HSB, 360, 100, 100 );
      fill( 172, 90, random( 50, 100 ) );
      if ( random(1) < 0.9f )
      {
        text( MAT_BUTTON_FADE_TIME, random(-2,2), random(-2,2) );
      }
      if ( random(1) < 0.9f )
      {
        text( MAT_BUTTON_HEAT_INCREMENT, random(-2,2), random(20,22) );
      }
      if ( random(1) < 0.9f )
      {
        text( MAT_BUTTON_COOLDOWN_WAIT/1000, random(-2,2), random(38,42) );
      }
      popMatrix();
    }
    
  if ( mousePressed )
  {
    rectMode( CENTER );
    noFill();
    colorMode( RGB );
    stroke( 255 );
    rect( mouseX, mouseY, 5, 5 );
  }
  
  // suble noise overlay
  for( float noiseX = 0; noiseX < width; noiseX += noiseTex.width )
  {
    for( float noiseY = 0; noiseY < height; noiseY += noiseTex.height )
    {
      image( noiseTex, noiseX, noiseY );
    }
  }
  
  // message!
  textFont( messageFont );
  textAlign( CENTER, CENTER );
  if ( MAT_BUILDUP )
  {
    fill( 0 );
  }
  else
  {
    fill( 255 );
  }
  text( messageToDisplay, width/2, height/2 );
  
  
  if ( TAKE_SCREENSHOT )
  {
    saveFrame("dancingularity-######.png");
    TAKE_SCREENSHOT = false;
  }
}

void displayMessage( String msg )
{
  messageToDisplay = msg;
  messageDisplayTimer = 5;
}

boolean TAKE_SCREENSHOT = false;
boolean SHOW_CONTROLS = false;
boolean SHOW_NUMBERS  = false;

void beginDebugText()
{
  pushMatrix();
  translate( 20, 20 );
}

void debugText( String txt )
{
  text( txt, 0, 0 );
  translate( 0, 20 );
}

void endDebugText()
{
  popMatrix();
}
