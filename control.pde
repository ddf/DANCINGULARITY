import javax.sound.midi.*;
import processing.core.PApplet;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collection;

ArrayList<MidiDevice>  midiDevices = new ArrayList<MidiDevice>();

static final int MAT_BUTTON_FADE_TIME_CTRL         = 5;  // slider 6
static final int MAT_BUTTON_HEAT_INCREMENT_CTRL    = 6;  // slider 7
static final int MAT_BUTTON_COOLDOWN_WAIT_CTRL     = 7;  // slider 8
static final int SHOW_NUMBERS_CTRL                 = 39; // button 8S
static final int BLOOM_BRIGHTNESS_CTRL             = 0;  // slider 1
static final int BLOOM_EXPOSURE_CTRL               = 1;  // slider 2
static final int SCREENSHOT_CTRL                   = 45; // record button
static final int HORIZ_DISPLACEMENT_CTRL           = 2;  // slider 3
static final int HORIZ_DIVISION_CTRL               = 18; // knob 3
static final int VERT_DISPLACEMENT_CTRL            = 3;  // slider 4
static final int VERT_DIVISION_CTRL                = 19; // knob 4
static final int GRID_DILATION_CTRL                = 4;  // slider 5

static final HashMap<Character, String> messages = new HashMap<Character, String>();
static
{
  messages.put( '7', "TAKE YR SHOES OFF" );
  messages.put( '8', "EVERYBODY DANCE" );
  messages.put( '9', "DANCE\nLIKE\nCRAZY" );
  messages.put( '0', "FILL THE\n9 SQUARES" );
  messages.put( '-', "ALMOST THERE" );
  messages.put( '=', "THE DANCINGULARITY" );
  messages.put( 'u', "KOKOROMI" );
  messages.put( 'i', "ROBOEXOTICA" );
};

void setupControls()
{
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    
    MidiDevice.Info midiSport = null;
    for( MidiDevice.Info info : infos )
    {
      System.out.println( info.getName() + ", desc[ " + info.getDescription() + " ], vendor[ " + info.getVendor() + " ]" );
      if ( info.getDescription().contains("nanoKONTROL") )
      {
        try
        {
          MidiDevice dev = MidiSystem.getMidiDevice( info );
          dev.open();
          Transmitter trans = dev.getTransmitter();
          trans.setReceiver( new MIDIReceiver() );
          
          midiDevices.add( dev );
        }
        catch( MidiUnavailableException mue )
        {
          println( "Couldn't get device for " + info.getDescription() + ": " + mue );
        }
      }
    }
}

class MIDIReceiver implements Receiver
{ 
  public void send( MidiMessage message, long timeStamp )
  {
    if ( message instanceof ShortMessage )
    {
      ShortMessage sm = (ShortMessage)message;
      if ( sm.getCommand() == ShortMessage.CONTROL_CHANGE )
      {
        //println("MIDIReceiver received control change " + sm.getData1() + " with value " + sm.getData2() + " at " + timeStamp );
        
        switch ( sm.getData1() )
        {
          case MAT_BUTTON_FADE_TIME_CTRL:
          {
            MAT_BUTTON_FADE_TIME = map( sm.getData2(), 0, 127, MAT_BUTTON_FADE_TIME_MIN, MAT_BUTTON_FADE_TIME_MAX );
          }
          break;
          
          case MAT_BUTTON_HEAT_INCREMENT_CTRL:
          {
            MAT_BUTTON_HEAT_INCREMENT = map( sm.getData2(), 0, 127, MAT_BUTTON_HEAT_INCREMENT_MIN, MAT_BUTTON_HEAT_INCREMENT_MAX );
          }
          break;
          
          case MAT_BUTTON_COOLDOWN_WAIT_CTRL:
          {
            MAT_BUTTON_COOLDOWN_WAIT = map( sm.getData2(), 0, 127, MAT_BUTTON_COOLDOWN_WAIT_MIN, MAT_BUTTON_COOLDOWN_WAIT_MAX );
          }
          break;
          
          case HORIZ_DISPLACEMENT_CTRL:
          {
            horizontalDisplacement = map( sm.getData2(), 0, 127, 0, width/2 );
          }
          break;
          
          case HORIZ_DIVISION_CTRL:
          {
            horizontalDivision = (int)map( sm.getData2(), 0, 127, 4, 16 );
          }
          break;
          
          case VERT_DIVISION_CTRL:
          {
            verticalDivision = (int)map( sm.getData2(), 0, 127, 4, 16 );
          }
          break;
          
          case VERT_DISPLACEMENT_CTRL:
          {
            verticalDisplacement = map( sm.getData2(), 0, 127, 0, height/2 );
          }
          break;
          
          case GRID_DILATION_CTRL:
          {
            gridDilation = map( sm.getData2(), 127, 0, -0.9, 0 );
          }
          break;
          
          case SHOW_NUMBERS_CTRL:
          {
            SHOW_NUMBERS = sm.getData2() > 0;
          }
          break;
          
          case BLOOM_EXPOSURE_CTRL:
          {
            fy = map( sm.getData2(), 0, 127, fy_min, fy_max );
          }
          break;
          
          case BLOOM_BRIGHTNESS_CTRL:
          {
            fx = map( sm.getData2(), 127, 0, fx_min, fx_max );
          }
          break;
          
          case SCREENSHOT_CTRL:
          {
            if ( sm.getData2() == 127 )
            {
              TAKE_SCREENSHOT = true;
            }
          }
          break;
          
          default: break;
        }
      }
    }
  }
  
  public void close()
  {
  }
}

float randomSign()
{
  return random(1) > 0.5f ? 1 : -1;
}

float step( float inValue, float rate, float minValue )
{
  if ( inValue > minValue )
  {
    inValue -= dt / rate;
    if ( inValue < minValue ) inValue = minValue;
  }
  
  return inValue;
}

void keyPressed()
{
  // eat the esc key so it won't quit the sketch
  if ( key == ESC )
  {
    key = 0;
  }
  
  if ( key == 't' )
  {
    playVFX( new PVector(0,0,0) );
  }
  
  if ( key == '>' && !DANCINGULARITY_ENABLED )
  {
    MAT_BUILDUP = !MAT_BUILDUP;
    if ( MAT_BUILDUP )
    {
      for( DanceMat m : theMats )
      {
        m.reset();
      }
      
      globalBackgroundSat = 100;
      setActiveBackground( 0 );
    }
    else
    {
      setActiveBackground( 0 );
    }
  }
  
  if ( key == '?' && (MAT_BUILDUP || DANCINGULARITY_ENABLED) )
  {
    DANCINGULARITY_ENABLED = !DANCINGULARITY_ENABLED;
    if ( DANCINGULARITY_ENABLED )
    {
      setActiveBackground( int(random(1,7)) );
      dancingularityCubeFlash = 1;
      MAT_BUILDUP = false;
    }
    else
    {
      globalBackgroundFlash = 1;
      globalBackgroundSat   = 0;
      for( DanceMat m : theMats )
      {
        m.reset();
      }
      
      setActiveBackground( 0 );
    }
  }
  
//  // fade time
//  if ( key == 'o' ) { MAT_BUTTON_FADE_TIME += 0.1f; }
//  if ( key == 'l' ) { MAT_BUTTON_FADE_TIME = max( MAT_BUTTON_FADE_TIME - 0.1f, 0.1f ); }
//  
//  // how quick we get hot
//  if ( key == 'p' ) { MAT_BUTTON_HEAT_INCREMENT += 0.01f; }
//  if ( key == ';' ) { MAT_BUTTON_HEAT_INCREMENT = max( MAT_BUTTON_HEAT_INCREMENT - 0.01f, 0.01f ); }
//
//  // how long we wait before starting cooldown  
//  if ( key == '[' ) { MAT_BUTTON_COOLDOWN_WAIT += 500; }
//  if ( key == '\'' ) { MAT_BUTTON_COOLDOWN_WAIT = max( MAT_BUTTON_COOLDOWN_WAIT - 500, 0 ); }

  // global transforms
  if ( key == 'f' ) globalScale += 0.5f;  
  if ( key == 's' ) globalShearX += PI/8;  
  if ( key == 'd' ) globalShearY += PI/8;  
  if ( key == 'v' ) globalJitter += 4;
  
  // camera zoom in
  if ( key == 'a' ) cameraJump -= 100;  
  // camera zoom out
  if ( key == 'z' ) cameraJump += 100;
  // camera random tumble
  if ( key == 'x' )
  {
    cameraOffX = random( 300, 500 ) * randomSign();
    cameraOffY = random( 300, 500 ) * randomSign();
  }
  
  if ( key == 'c' ) cameraShake = 1;
  
  if ( key == '\'' ) MAT_WIREFRAME = !MAT_WIREFRAME;
  if ( key == ';' ) MAT_BOX_MODE  = !MAT_BOX_MODE;
  
  // grid rotations
  if ( key == CODED )
  {
    if ( keyCode == LEFT )
    {
      globalZRot -= 30;
    }
    else if ( keyCode == RIGHT )
    {
      globalZRot += 30;
    }
    else if ( keyCode == UP )
    {
      globalYRot += 30;
    }
    else if ( keyCode == DOWN )
    {
      globalYRot -= 30;
    }
    else if ( keyCode == KeyEvent.VK_INSERT )
    {
      MAT_AUTO_PLAY = !MAT_AUTO_PLAY;
    }
  }
  
  if ( key == 'Q' )
  {
    println( "Calling exit().");
    exit();
  }
  
  if ( key == DELETE )
  {
    for( DanceMat m : theMats )
    {
      m.reset();
    }
  }
  
  if ( key == ' ' )
  {
    globalBloomFlash = 1;
    
    if ( DANCINGULARITY_ENABLED )
    {
      dancingularityCubeFlash = 1;
    }
  }
  
  // background flash
  if ( key == 'n' ) globalBackgroundFlash = 1;
  
  // palette switch
  if ( key == 'h' ) activePalette = (activePalette+1) % palettes.size();
  
  if ( key == BACKSPACE )
  {
    saveFrame("dancingularity-####.png");
  }
  
//  if ( key == '`' )
//  {
//    SHOW_CONTROLS = !SHOW_CONTROLS;
//  }
  
//  if ( key == ']' ) { SHOW_NUMBERS = !SHOW_NUMBERS; }
  
  // animations for the small squares
  if ( key == '1' ) MAT_BUTTON_ANIMATION = MAT_BUTTON_ANIMATION_NONE;  
  if ( key == '2' ) MAT_BUTTON_ANIMATION = MAT_BUTTON_ANIMATION_BOUNCE;
  if ( key == '3' ) MAT_BUTTON_ANIMATION = MAT_BUTTON_ANIMATION_JITTER;  
  if ( key == '4' ) MAT_BUTTON_ANIMATION = MAT_BUTTON_ANIMATION_PUFF;
  if ( key == '5' ) MAT_BUTTON_ANIMATION = MAT_BUTTON_ANIMATION_RANDOM;
  
  if ( messages.containsKey( key ) )
  {
    String message = messages.get( key );
    displayMessage( message );
  }
  
  // background changing
//  if ( key == '=' ) setActiveBackground( 0 );  
//  if ( key == '6' ) setActiveBackground( 1 );
//  if ( key == '7' ) setActiveBackground( 2 );
//  if ( key == '8' ) setActiveBackground( 3 );
//  if ( key == '9' ) setActiveBackground( 4 );
//  if ( key == '0' ) setActiveBackground( 5 ); 
//  if ( key == '-' ) setActiveBackground( 6 );
}
