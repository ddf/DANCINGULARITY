// Tracks dancing on a single mat and provides the basic visualization for that mat.
static final int MAT_BUTTON_ANIMATION_NONE    = 0;
static final int MAT_BUTTON_ANIMATION_BOUNCE  = 1;
static final int MAT_BUTTON_ANIMATION_JITTER  = 2;
static final int MAT_BUTTON_ANIMATION_PUFF    = 3;
static final int MAT_BUTTON_ANIMATION_RANDOM  = 4;

int MAT_BUTTON_ANIMATION = MAT_BUTTON_ANIMATION_NONE;

// actually just the length of the "pop" animation, in seconds
float MAT_BUTTON_FADE_TIME        = 1.0f;
float MAT_BUTTON_FADE_TIME_MAX    = 10.f;
float MAT_BUTTON_FADE_TIME_MIN    = 0.1f;

float MAT_BUTTON_BOUNCE_DURATION  = 0.25f;
float MAT_BUTTON_BOUNCE_AMOUNT    = 20;
float MAT_BUTTON_JITTER_INTENSITY = 5;
float MAT_BUTTON_PUFF_AMOUNT      = 10;
float MAT_BUTTON_SPACING          = 40;
float MAT_BUTTON_MIN_HEIGHT       = 10;
float MAT_BUTTON_MAX_HEIGHT       = MAT_BUTTON_SPACING * 2.75f;

// how long a square waits, in milliseconds, before starting to reduce its heat value
float MAT_BUTTON_COOLDOWN_WAIT     = 5000;
float MAT_BUTTON_COOLDOWN_WAIT_MAX = 20000;
float MAT_BUTTON_COOLDOWN_WAIT_MIN = 100;

// how much heat is added to a square every time its button is pressed
float MAT_BUTTON_HEAT_INCREMENT     = 0.02f;
float MAT_BUTTON_HEAT_INCREMENT_MAX = 0.1f;
float MAT_BUTTON_HEAT_INCREMENT_MIN = 0.01f;

boolean MAT_AUTO_PLAY             = true;
boolean MAT_WIREFRAME             = false;
boolean MAT_BUILDUP               = false;
boolean MAT_BOX_MODE              = true;

boolean DANCINGULARITY_ENABLED    = false;
float DANCE_CUBE_SIZE             = MAT_BUTTON_MAX_HEIGHT * 3;

String matButtonAnimationString( int mba )
{
  switch( mba )
  {
    case MAT_BUTTON_ANIMATION_NONE: return "None";
    case MAT_BUTTON_ANIMATION_BOUNCE: return "Bounce";
    case MAT_BUTTON_ANIMATION_JITTER: return "Jitter";
    case MAT_BUTTON_ANIMATION_PUFF: return "Puff";
    case MAT_BUTTON_ANIMATION_RANDOM: return "Random";
  }
  
  return "dunno!";
}

class DanceMat
{
  //////////////////////////////////////
  //
  // BUTTON
  //
  public class Button
  {
    ControllButton btn;
    PVector        pos;
    float          mJitterX;
    float          mJitterY;
    float          mHeat;
    float          mAlpha;
    PVector        mBounce;
    float          mJiggle;
    float          mPuff;
    float          mHeight;
    float          mFromHeight;
    float          lastPress;
    
    Button( ControllButton hBtn, PVector inPos )
    {
      btn = hBtn;
      if ( btn != null )
      {
        btn.plug( this, "pressed", ControllIO.ON_PRESS );
      }
      pos = inPos;
      mBounce = new PVector(0,0);
      mHeight = 0;
      mHeat   = 0;
    }
    
    public void pressed()
    {
      // flash
      mAlpha  = 1;
      
      int animType = MAT_BUTTON_ANIMATION;
      if ( animType == MAT_BUTTON_ANIMATION_RANDOM )
      {
        animType = (int)random(1,3.99);
      }
      
      switch( animType )
      {
        case MAT_BUTTON_ANIMATION_BOUNCE:
        {
          int bounceDir = (int)random(0,3.99);
          switch( bounceDir )
          {
            case 0: mBounce.x = -1; break;
            case 1: mBounce.x = 1; break;
            case 2: mBounce.y = 1; break;
            case 3: mBounce.y = -1; break;
          }
        }
        break;
        
        case MAT_BUTTON_ANIMATION_JITTER:
        {
          mJiggle = MAT_BUTTON_JITTER_INTENSITY;
        }
        break;
        
        case MAT_BUTTON_ANIMATION_PUFF:
        {
          mPuff = 1;
        }
        break;
      }
      
      PVector vfxPos = PVector.add( DanceMat.this.pos, pos );
      
      // heat map
      if ( MAT_BUILDUP )
      {
        mHeat += MAT_BUTTON_HEAT_INCREMENT*2;
        
        vfxPos.z = DanceMat.this.bigBoxHeight*0.55f;
        playVFX( vfxPos );
      }
      else
      {
        mHeat     = constrain( mHeat + MAT_BUTTON_HEAT_INCREMENT, 0, 1 );
        mFromHeight = mHeight = map( mHeat, 0, 1, MAT_BUTTON_MIN_HEIGHT, MAT_BUTTON_MAX_HEIGHT );
        
        vfxPos.z = mHeight + 10;
      }
      
      lastPress = millis();
         
//      if ( !DANCINGULARITY_ENABLED )
//      {  
//        playVFX( vfxPos );
//      }
    }
    
    public float heat() { return mHeat; }
    public float flash() { return mAlpha; }
    
    public void reset()
    {
      mHeat = 0;
    }
    
    void update( float dt )
    {
      if ( mAlpha > 0 )
      {
        mAlpha -= dt / MAT_BUTTON_FADE_TIME;
        if ( mAlpha < 0 ) mAlpha = 0;
      }
      
      if ( mHeight > 0 )
      {
        mHeight -= mFromHeight * dt / MAT_BUTTON_FADE_TIME;
        if ( mHeight < 0 ) mHeight = 0;
      }
      
      if ( mBounce.x > 0 )
      {
        mBounce.x -= dt / MAT_BUTTON_BOUNCE_DURATION;
        if ( mBounce.x < 0 ) mBounce.x = 0;
      }
      
      if ( mBounce.x < 0 )
      {
        mBounce.x += dt / MAT_BUTTON_BOUNCE_DURATION;
        if ( mBounce.x > 0 ) mBounce.x = 0;
      }
      
      if ( mBounce.y > 0 )
      {
        mBounce.y -= dt / MAT_BUTTON_BOUNCE_DURATION;
        if ( mBounce.y < 0 ) mBounce.y = 0;
      }
      
      if ( mBounce.y < 0 )
      {
        mBounce.y += dt / MAT_BUTTON_BOUNCE_DURATION;
        if ( mBounce.y > 0 ) mBounce.y = 0;
      }
      
      if ( mJiggle > 0 )
      {
        mJiggle -= 4 * dt;
        if ( mJiggle < 0 ) mJiggle = 0;
      }
      
      if ( mPuff > 0 )
      {
        mPuff -= 4 * dt;
        if ( mPuff < 0 ) mPuff = 0;
      }
      
      mJitterX = random( -mJiggle, mJiggle );
      mJitterY = random( -mJiggle, mJiggle );

      // no cooldown if we're in the build-up to a dancingularity
      if ( !MAT_BUILDUP && mHeat > 0 && millis() - lastPress > MAT_BUTTON_COOLDOWN_WAIT )
      {
        mHeat -= 0.05 * dt;
        if ( mHeat < 0 ) mHeat = 0;
      }
    }
    
    void setColor( GLGraphicsOffScreen surface, boolean bBoxMode, float alphaAdjust )
    {
      PImage palet = getActivePalette();
      int colorLookup = int( constrain(mHeat*(palet.width-1), 0, palet.width-1));
      //println( "heat is " + mHeat + ", colorLookup is " + colorLookup );
      color c           = palet.get( colorLookup, 2 );
      float h           = surface.hue( c );
      float s           = surface.saturation( c );
      float b           = surface.brightness( c );
      
      if ( bBoxMode )
      {
        if ( MAT_WIREFRAME )
        {
          surface.noFill();
          surface.stroke( h, s, b*0.7f + alphaAdjust );
        }
        else
        {
          surface.noStroke();
          surface.fill( h, s, b*0.7f + alphaAdjust );
        }
      }
      else
      {
        surface.stroke( h, s, b*0.7f + alphaAdjust );
      }
    }
    
    void draw( GLGraphicsOffScreen surface, boolean bBoxMode )
    {      
      float xbnc = mBounce.x * MAT_BUTTON_BOUNCE_AMOUNT;
      float ybnc = mBounce.y * MAT_BUTTON_BOUNCE_AMOUNT;
      
       
      if ( bBoxMode )
      {
        // don't draw the center square in box mode
        if ( pos.x == 0 && pos.y == 0 ) return;
        
        surface.pushMatrix();
        
        surface.translate( pos.x + xbnc + mJitterX, pos.y + ybnc + mJitterY, mHeight / 2 );
        surface.rotateZ( radians( random(-mJiggle*2,mJiggle*2) ) );
  
        setColor(surface, true, 0);
        
        surface.box( 30 + mPuff*MAT_BUTTON_PUFF_AMOUNT, 30 - mPuff*MAT_BUTTON_PUFF_AMOUNT, mHeight );
        
        // glowing bit
        setColor( surface, true, 30*mAlpha );
        surface.translate( 0, 0, mHeight / 2 );
        float glowBoxW = (30 + mPuff*MAT_BUTTON_PUFF_AMOUNT);
        float glowBoxH = (30 - mPuff*MAT_BUTTON_PUFF_AMOUNT);
        surface.box( glowBoxW, glowBoxH, 2 );
        
        surface.popMatrix();
      }
      else
      {
        setColor( surface, false, 30 * mAlpha );
        surface.vertex( pos.x + xbnc + mJitterX, pos.y + ybnc + mJitterY, mHeight );
      }
    }
  }
  
  //////////////////////////////////////
  //
  // INSTANCES
  //
  ControllDevice        mat;
  ArrayList<Button>     buttons = new ArrayList<Button>();
  PVector               pos;
  float                 jitterX;
  float                 jitterY;
  float                 bigBoxHeight;
  
  ControllButton getButton( String name )
  {
    if ( mat != null )
    {
      return mat.getButton(name);
    }
    
    return null;
  }
  
  public DanceMat( ControllDevice inMat, PVector inPos )
  {
    pos = inPos;
    mat = inMat;
    buttons.add( new Button( getButton("B"),      new PVector( -MAT_BUTTON_SPACING, -MAT_BUTTON_SPACING ) ) );
    buttons.add( new Button( getButton("Base"),   new PVector( 0, -MAT_BUTTON_SPACING ) ) );
    buttons.add( new Button( getButton("A"),      new PVector( MAT_BUTTON_SPACING, -MAT_BUTTON_SPACING ) ) );
  
    buttons.add( new Button( getButton("Base 3"), new PVector( -MAT_BUTTON_SPACING, 0 ) ) );
    buttons.add( new Button( null,                new PVector( 0, 0 ) ) );
    buttons.add( new Button( getButton("Base 4"), new PVector( MAT_BUTTON_SPACING, 0 ) ) );
        
    buttons.add( new Button( getButton("Y"),      new PVector( -MAT_BUTTON_SPACING, MAT_BUTTON_SPACING ) ) );
    buttons.add( new Button( getButton("Base 2"), new PVector( 0, MAT_BUTTON_SPACING ) ) ); 
    buttons.add( new Button( getButton("X"),      new PVector( MAT_BUTTON_SPACING, MAT_BUTTON_SPACING ) ) );
  }
  
  public void update( float dt )
  {
    if ( MAT_AUTO_PLAY )
    {
      int bidx = (int)random(0, buttons.size() * 10);
      if ( bidx < buttons.size() )
      {
        buttons.get(bidx).pressed();
      }
    }
    
    for( Button btn : buttons )
    {
      btn.update( dt );
    }
    
    jitterX = random( -globalJitter, globalJitter );
    jitterY = random( -globalJitter, globalJitter );
  }
  
  public void reset()
  {
    for( Button btn : buttons )
    {
      btn.reset();
    }
  }
  
  public float heat()
  {
    float h = 0;
    for( Button btn : buttons )
    {
      h += btn.heat();
    }
    return h;
  }
  
  public void draw( GLGraphicsOffScreen surface )
  {
    if ( MAT_BUILDUP == false )
    {
      surface.colorMode( HSB, 360, 100, 100, 1 );
    }
    else
    {
      surface.colorMode( RGB );
    }
    surface.pushMatrix();
    
    surface.translate( pos.x + jitterX, pos.y + jitterY );
    
    if ( MAT_BUILDUP )
    {
      float totalHeat = 0;
      float biggestFlash = 0;
      for( Button btn : buttons )
      {
        totalHeat    += btn.heat();
        biggestFlash  = max( biggestFlash, btn.flash() );
      }
      bigBoxHeight = constrain( map( totalHeat, 0, 9, 0, DANCE_CUBE_SIZE ), 0, DANCE_CUBE_SIZE-35 );
      surface.noStroke();
      surface.fill( 200 + 55*biggestFlash );
      surface.box( MAT_BUTTON_MAX_HEIGHT, MAT_BUTTON_MAX_HEIGHT, bigBoxHeight );
    }
    else
    {
      if ( MAT_BOX_MODE )
      {
        for( Button btn : buttons )
        {
          btn.draw( surface, true );
        }
      }
      else
      {
        surface.noFill();
        
        surface.beginShape( QUAD_STRIP );
        buttons.get(0).draw( surface, false );
        buttons.get(3).draw( surface, false );
        buttons.get(1).draw( surface, false );
        buttons.get(4).draw( surface, false );
        buttons.get(2).draw( surface, false );
        buttons.get(5).draw( surface, false );
        surface.endShape();
        
        surface.beginShape( QUAD_STRIP );
        buttons.get(3).draw( surface, false );
        buttons.get(6).draw( surface, false );
        buttons.get(4).draw( surface, false );
        buttons.get(7).draw( surface, false );
        buttons.get(5).draw( surface, false );
        buttons.get(8).draw( surface, false );
        surface.endShape();
          
      }
    }
    
    surface.popMatrix();
  }
  
  public float getButtonX( int buttonId )
  {
    Button btn = buttons.get(buttonId);    
    return pos.x + jitterX + btn.pos.x + btn.mJitterX;
  }
  
  public float getButtonY( int buttonId )
  {
    Button btn = buttons.get(buttonId);
    return pos.y + jitterY + btn.pos.y + btn.mJitterY;
  }
  
  public void drawButtonVert( int buttonId, GLGraphicsOffScreen surface )
  {
    buttons.get(buttonId).setColor( surface, false, 30*buttons.get(buttonId).mAlpha );
    surface.vertex( getButtonX(buttonId), getButtonY(buttonId), buttons.get(buttonId).mHeight );
  }
  
  public void drawRowVerts( int rowId, GLGraphicsOffScreen surface )
  {
    drawButtonVert( rowId, surface );
    drawButtonVert( rowId+3, surface );
    drawButtonVert( rowId+1, surface );
    drawButtonVert( rowId+4, surface );
    drawButtonVert( rowId+2, surface );
    drawButtonVert( rowId+5, surface );
  }
}

void drawBigGrid()
{
        offscreen.noFill();
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(0) - 300, theMats[8].getButtonY(0) - 300 );
          offscreen.vertex( theMats[8].getButtonX(0) - 300, theMats[8].getButtonY(0) );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(0), theMats[8].getButtonY(0) - 300 );
          theMats[8].drawButtonVert( 0, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(1), theMats[8].getButtonY(1) - 300 );
          theMats[8].drawButtonVert( 1, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(2), theMats[8].getButtonY(2) - 300 );
          theMats[8].drawButtonVert( 2, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[7].getButtonX(0), theMats[7].getButtonY(0) - 300 );
          theMats[7].drawButtonVert( 0, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[7].getButtonX(1), theMats[7].getButtonY(1) - 300 );
          theMats[7].drawButtonVert( 1, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[7].getButtonX(2), theMats[7].getButtonY(2) - 300 );
          theMats[7].drawButtonVert( 2, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(0), theMats[6].getButtonY(0) - 300 );
          theMats[6].drawButtonVert( 0, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(1), theMats[6].getButtonY(1) - 300 );
          theMats[6].drawButtonVert( 1, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(2), theMats[6].getButtonY(2) - 300 );
          theMats[6].drawButtonVert( 2, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(2) + 300, theMats[6].getButtonY(2) - 300 );
          offscreen.vertex( theMats[6].getButtonX(2) + 300, theMats[6].getButtonY(2) );
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(0) - 300, theMats[8].getButtonY(0) );
          offscreen.vertex( theMats[8].getButtonX(3) - 300, theMats[8].getButtonY(3) );
          
          theMats[8].drawRowVerts( 0, offscreen );
          theMats[7].drawRowVerts( 0, offscreen );
          theMats[6].drawRowVerts( 0, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(2) + 300, theMats[6].getButtonY(2) );
          offscreen.vertex( theMats[6].getButtonX(5) + 300, theMats[6].getButtonY(5) );
          
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(3) - 300, theMats[8].getButtonY(3) );
          offscreen.vertex( theMats[8].getButtonX(6) - 300, theMats[8].getButtonY(6) );
          
          theMats[8].drawRowVerts( 3, offscreen );
          theMats[7].drawRowVerts( 3, offscreen );
          theMats[6].drawRowVerts( 3, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(5) + 300, theMats[6].getButtonY(5) );
          offscreen.vertex( theMats[6].getButtonX(8) + 300, theMats[6].getButtonY(8) );
          
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[8].getButtonX(6) - 300, theMats[8].getButtonY(6) );
          offscreen.vertex( theMats[5].getButtonX(0) - 300, theMats[5].getButtonY(0) );
          
          theMats[8].drawButtonVert( 6, offscreen );
          theMats[5].drawButtonVert( 0, offscreen );
          theMats[8].drawButtonVert( 7, offscreen );
          theMats[5].drawButtonVert( 1, offscreen );
          theMats[8].drawButtonVert( 8, offscreen );
          theMats[5].drawButtonVert( 2, offscreen );
          
          theMats[7].drawButtonVert( 6, offscreen );
          theMats[4].drawButtonVert( 0, offscreen );
          theMats[7].drawButtonVert( 7, offscreen );
          theMats[4].drawButtonVert( 1, offscreen );
          theMats[7].drawButtonVert( 8, offscreen );
          theMats[4].drawButtonVert( 2, offscreen );
          
          theMats[6].drawButtonVert( 6, offscreen );
          theMats[3].drawButtonVert( 0, offscreen );
          theMats[6].drawButtonVert( 7, offscreen );
          theMats[3].drawButtonVert( 1, offscreen );
          theMats[6].drawButtonVert( 8, offscreen );
          theMats[3].drawButtonVert( 2, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[6].getButtonX(8) + 300, theMats[6].getButtonY(8) );
          offscreen.vertex( theMats[3].getButtonX(2) + 300, theMats[3].getButtonY(2) );
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[5].getButtonX(0) - 300, theMats[5].getButtonY(0) );
          offscreen.vertex( theMats[5].getButtonX(3) - 300, theMats[5].getButtonY(3) );
          
          theMats[5].drawRowVerts( 0, offscreen );
          theMats[4].drawRowVerts( 0, offscreen );
          theMats[3].drawRowVerts( 0, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[3].getButtonX(2) + 300, theMats[3].getButtonY(2) );
          offscreen.vertex( theMats[3].getButtonX(5) + 300, theMats[3].getButtonY(5) );
          
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[5].getButtonX(3) - 300, theMats[5].getButtonY(3) );
          offscreen.vertex( theMats[5].getButtonX(6) - 300, theMats[5].getButtonY(6) );
          
          theMats[5].drawRowVerts( 3, offscreen );
          theMats[4].drawRowVerts( 3, offscreen );
          theMats[3].drawRowVerts( 3, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[3].getButtonX(5) + 300, theMats[3].getButtonY(5) );
          offscreen.vertex( theMats[3].getButtonX(8) + 300, theMats[3].getButtonY(8) );
          
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[5].getButtonX(6) - 300, theMats[5].getButtonY(6) );
          offscreen.vertex( theMats[2].getButtonX(0) - 300, theMats[2].getButtonY(0) );
          
          theMats[5].drawButtonVert( 6, offscreen );
          theMats[2].drawButtonVert( 0, offscreen );
          theMats[5].drawButtonVert( 7, offscreen );
          theMats[2].drawButtonVert( 1, offscreen );
          theMats[5].drawButtonVert( 8, offscreen );
          theMats[2].drawButtonVert( 2, offscreen );
          
          theMats[4].drawButtonVert( 6, offscreen );
          theMats[1].drawButtonVert( 0, offscreen );
          theMats[4].drawButtonVert( 7, offscreen );
          theMats[1].drawButtonVert( 1, offscreen );
          theMats[4].drawButtonVert( 8, offscreen );
          theMats[1].drawButtonVert( 2, offscreen );
          
          theMats[3].drawButtonVert( 6, offscreen );
          theMats[0].drawButtonVert( 0, offscreen );
          theMats[3].drawButtonVert( 7, offscreen );
          theMats[0].drawButtonVert( 1, offscreen );
          theMats[3].drawButtonVert( 8, offscreen );
          theMats[0].drawButtonVert( 2, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[3].getButtonX(8) + 300, theMats[3].getButtonY(8) );
          offscreen.vertex( theMats[0].getButtonX(2) + 300, theMats[0].getButtonY(2) );
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[2].getButtonX(0) - 300, theMats[2].getButtonY(0) );
          offscreen.vertex( theMats[2].getButtonX(3) - 300, theMats[2].getButtonY(3) );
          
          theMats[2].drawRowVerts( 0, offscreen );
          theMats[1].drawRowVerts( 0, offscreen );
          theMats[0].drawRowVerts( 0, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[0].getButtonX(2) + 300, theMats[0].getButtonY(2) );
          offscreen.vertex( theMats[0].getButtonX(5) + 300, theMats[0].getButtonY(5) );
          
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[2].getButtonX(3) - 300, theMats[2].getButtonY(3) );
          offscreen.vertex( theMats[2].getButtonX(6) - 300, theMats[2].getButtonY(6) );
          
          theMats[2].drawRowVerts( 3, offscreen );
          theMats[1].drawRowVerts( 3, offscreen );
          theMats[0].drawRowVerts( 3, offscreen );
          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[0].getButtonX(5) + 300, theMats[0].getButtonY(5) );
          offscreen.vertex( theMats[0].getButtonX(8) + 300, theMats[0].getButtonY(8) );
          
        }
        offscreen.endShape();
        
        offscreen.beginShape( QUAD_STRIP );
        {
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[2].getButtonX(6) - 300, theMats[2].getButtonY(6) );
          offscreen.vertex( theMats[2].getButtonX(6) - 300, theMats[2].getButtonY(6) + 300 );

          theMats[2].drawButtonVert( 6, offscreen );          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[2].getButtonX(6), theMats[2].getButtonY(6) + 300 );
          theMats[2].drawButtonVert( 7, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[2].getButtonX(7), theMats[2].getButtonY(7) + 300 );
          theMats[2].drawButtonVert( 8, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[2].getButtonX(8), theMats[2].getButtonY(8) + 300 );

          theMats[1].drawButtonVert( 6, offscreen );          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[1].getButtonX(6), theMats[1].getButtonY(6) + 300 );
          theMats[1].drawButtonVert( 7, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[1].getButtonX(7), theMats[1].getButtonY(7) + 300 );
          theMats[1].drawButtonVert( 8, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[1].getButtonX(8), theMats[1].getButtonY(8) + 300 );

          theMats[0].drawButtonVert( 6, offscreen );          
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[0].getButtonX(6), theMats[0].getButtonY(6) + 300 );
          theMats[0].drawButtonVert( 7, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[0].getButtonX(7), theMats[0].getButtonY(7) + 300 );
          theMats[0].drawButtonVert( 8, offscreen );
          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[0].getButtonX(8), theMats[0].getButtonY(8) + 300 );

          offscreen.stroke( 0, 0, 100 );
          offscreen.vertex( theMats[0].getButtonX(8) + 300, theMats[0].getButtonY(8) );          
          offscreen.vertex( theMats[0].getButtonX(8) + 300, theMats[0].getButtonY(8) + 300 );

        }
        offscreen.endShape();
}
