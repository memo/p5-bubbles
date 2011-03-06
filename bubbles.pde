import noc.*;



/************************************* VECTORFIELD ****************************************/
class VECTORFIELD {
  private float fNoiseMin, fNoiseMax;    // used for scaling values to white and black
  private float fScaleMult, fSpeedMult;
  private int iOctaves;
  private float fFallOff;
  
  VECTORFIELD(int to, float tf, float ts1, float ts2) {
    init( to, tf, ts1, ts2);
  }

  void init(int to, float tf, float ts1, float ts2) {
    float w = 500, h = 500;
    iOctaves = to;
    fFallOff = tf;
    fScaleMult = 0.01 * ts1;      // some good default values
    fSpeedMult = 0.0005 * ts2;
    fNoiseMin = 1;
    fNoiseMax = 0;
    noiseDetail(iOctaves, fFallOff);

    for(int x=0; x<w; x++) {
      for(int y=0; y<h; y++) {
        float c = noise(x * fScaleMult, y * fScaleMult);
        fNoiseMin = min(c, fNoiseMin);
        fNoiseMax = max(c, fNoiseMax);
      }
    }
  }

  float force(float x, float y, float z, float fScaleMultExtra, float fSpeedMultExtra) {
    float f = fScaleMult * fScaleMultExtra;
    float f2 = fSpeedMult * fSpeedMultExtra;
    noiseDetail(iOctaves, fFallOff);
    float c = map( noise(x*f, y*f, z + f2 * millis()), fNoiseMin, fNoiseMax, -0.2, 1.2);
    c = max(min(c, 1), 0);
    return c;
  }

}

/************************************* NODE ****************************************/
class msaNode {
  Vector3D pos;   // position;
  Vector3D vel;   // velocity;
  Vector3D acc;   // acceleration

  Vector3D rot;   // rotation;
  Vector3D rvel;  // rotational velocity;
  Vector3D racc;  // rotational acceleration
  float radius;
  float mass;
  float time;
  float life;
  
  msaNode(Vector3D p, Vector3D v, float tm, float tr, float l) {
    pos = p.copy();
    vel = v.copy();
    acc = new Vector3D(0, 0, 0);
    mass = tm;
    radius = tr;
    time = 0;
    life = l;
  }
  
  boolean update() {
      float fAngle = VectorField.force(pos.x, pos.y, 10, 2, 1) * PI * 2;
    vel.x += cos(fAngle)*0.05;
    vel.y += sin(fAngle)*0.05;
    
    vel.add(acc);
    pos.add(vel);
    time++;
    return (life==0 || time<life);    // return true if particle is still alive
  }
  
  void render() {
    stroke(0);
    fill(255);
    ellipse(pos.x, pos.y, radius*2, radius*2);
  }

}

/************************************* SYSTEM ****************************************/
class msaPSystem extends msaNode {
  ArrayList nodes;
  
  msaPSystem(Vector3D p, Vector3D v, float tm, float tr, float l)  {
    super(p, v, tm, tr, l);
    nodes = new ArrayList();
  }
  
  void run() {
    for(int i = nodes.size()-1; i>=0; i--){
      msaNode n = (msaNode) nodes.get(i);
      if(n.update()) n.render();    // update and render if still alive
      else nodes.remove(i);        // else remove
    }
  }
  
  void AddNode() {
    nodes.add(new msaNode(pos, new Vector3D(random(-1, 1), random(-1, 1), 0), mass, random(radius), life));
  }
  
  void setPos(Vector3D p) {
    pos = p.copy();
  }
 
 int numNodes() {
   return nodes.size();
 }
}



/************************************* APP  ****************************************/
msaPSystem ps;
VECTORFIELD VectorField = new VECTORFIELD(2, 0.5, 1, 1);
void setup() {
  size(500, 500) ;
  colorMode(RGB,255,255,255,100) ;
  ps = new msaPSystem(new Vector3D(width/2, height/2, 0), new Vector3D(), 1, 20, 100) ;
  frameRate(30);
  smooth() ;
}

void draw() {
  background(180);
  ps.run();
  ps.AddNode();
  if(keyPressed) println(ps.numNodes());
  
  
}

void mouseMoved() {
  ps.setPos(new Vector3D(mouseX, mouseY, 0));
}
