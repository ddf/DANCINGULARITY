ParticleSystem vfx;
PImage         vfx_sprite;
float          vfx_fade_time = 25.5f;

void setupVFX()
{
  vfx = new ParticleSystem( 0, 0.0, -0.9, 0.05f );
  vfx_sprite = loadImage("particle.png");
}

void updateVFX()
{
  vfx.tick();

  // remove particles that are too old
  for ( int i = 0; i < vfx.numberOfParticles(); ++i )
  {
    if ( vfx.getParticle( i ).age() > vfx_fade_time )
    {
      vfx.removeParticle( vfx.getParticle(i) );
      --i;
    }
  }
}

void drawVFX( GLGraphicsOffScreen surface )
{
  surface.colorMode( HSB );
  surface.noStroke();
  surface.beginShape( QUADS );
  //  surface.texture( vfx_sprite );
  //  surface.textureMode( NORMAL );
  surface.setBlendMode( ADD );
  //surface.hint( DISABLE_DEPTH_TEST );
  for ( int i = 0; i < vfx.numberOfParticles(); ++i )
  {
    Particle p = vfx.getParticle(i);
    
    surface.fill( 57, 50, map( p.age(), vfx_fade_time*0.75f, vfx_fade_time, 100, 0 ) );

    float sz = 4;
    surface.vertex( p.position().x() - sz, p.position().y() - sz, p.position().z() );
    surface.vertex( p.position().x() - sz, p.position().y() + sz, p.position().z() );
    surface.vertex( p.position().x() + sz, p.position().y() + sz, p.position().z() );
    surface.vertex( p.position().x() + sz, p.position().y() - sz, p.position().z() );

    //surface.image( vfx_sprite, p.position().x(), p.position().y(), 128, 128 );
    //surface.blend( vfx_sprite, 0, 0, 64, 64, (int)p.position().x() - 32, (int)p.position().y() - 32, 64, 64, ADD );
  }
  surface.endShape();
}

void playVFX( PVector pos )
{
  int burst = 10;
  float vel = 10;
  for ( int i = 0; i < burst; ++i )
  {
    Particle p = vfx.makeParticle( 1, pos.x, pos.y, pos.z );
    float xvel = random( -vel, vel );
    float yvel = random( -vel, vel );
    p.velocity().set( xvel, yvel, 5 );
  }
}

