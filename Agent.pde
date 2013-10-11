
// agent class
class Agent {
  // agent position c, direction v
  PVector c, v;
  // agent size
  float r;
  // agent max velocity, comfort distance and sphere of influence
  float max_vel = 2;
  float max_ang_vel = 3;
  float comfort_dist = 15;
  float sphere_infl = 100;
  // knowledgable or not knowledgable
  boolean knowledge;
  // preferred direction weight
  float w;

  // animation parameters (see render function)
  float sx = -90, sy = 0;
  float ax = -40, ay = 0;
  float bx = 5, by = 40;
  float cx = -40, cy = 0;
  float dx = 5, dy = -40;
  float ex = 10, ey = 0;
  float animOff = random(TWO_PI);
  float tailStep = 0, tailSpeed = random(2, 3);
  float s;

  // constructor
  Agent(int xInit, int yInit, boolean lead) {
    // initialize position vector with initial position
    c = new PVector(xInit, yInit);
    // store preferred direction vector
    // initialize direction vector with randomness
    v = PVector.random2D();
    // set magnitude to max velocity
    v.setMag(max_vel);
    // set scale
    s = random(.05, .25);
    // set agent size
    r = s * 20;
    // if leader then knowledgable
    knowledge = lead;
    // randomize preferred direction weight
    w = random(0, 2);
  }

  // update agent position
  void update(PVector[] cj, PVector[] vj, int i) {

    // animation parameter
    this.tailStep += this.tailSpeed;

    // compute desired direction
    PVector d = new PVector(0, 0);
    d = PVector.random2D();
    d = desired_direction(d, cj, vj, i);
    // if has preferred direction, factor that in
    if (knowledge){
      d.add( PVector.mult(preferred_direction, w) );
      d.normalize();  
    } else {
      d = d;
    }
    // compute angle from v to d
    float v_d_angle = atan2(v.x*d.y - v.y*d.x, v.x*d.x + v.y*d.y);
    // limit turning angle
    if (v_d_angle < 0) {
      v.rotate(radians(-max_ang_vel));
    } 
    else {
      v.rotate(radians(max_ang_vel));
    }
    // set velocity
    v.setMag(max_vel);
    // update position
    c.add(v);
    // wrap around
    borders();
  }

  // compute desired direction
  PVector desired_direction(PVector d, PVector[] cj, PVector[] vj, int i) {

    // check if there is another agent within comfort distance
    boolean uncomfortable = comfort_check(cj, i);

    // if uncomfortable, seperation
    if (uncomfortable) {
      d = compute_seperation(d, cj, i);
    } 
    else {
      d = compute_cohesion_alignment(d, cj, vj, i);
    }

    return d;
  }

  // compute cohesion and alignment
  PVector compute_cohesion_alignment(PVector d, PVector[] cj, PVector[] vj, int i) {

    // store flock_size
    float nAgents = cj.length;
    if (cj.length != vj.length) {
      print("Warning: cj and vj have different lengths.");
    }

    // Boids: cohesion
    PVector cohesion = new PVector(0, 0);
    // Boids: alignment
    PVector alignment = new PVector(0, 0);

    // for all agents in the flock (cohesion and alignment)
    for (int j = 0; j < nAgents; j++) {
      // if not self
      if (j != i) {
        // check distance from self to neighbour within influence distance
        if (PVector.dist(c, cj[j]) < sphere_infl) {
          // subtract self position from neighbour position
          PVector temp_c = PVector.sub(cj[j], c);
          // normalize vector
          temp_c.normalize();
          // add vector to aggregrated cohesion direction
          cohesion.add(temp_c);
          // add normalized direction vector to alignment direction
          PVector temp_v = vj[j];
          temp_v.normalize();
          alignment.add(temp_v);
        }
      }
      // if self
      else {
        // add normalized direction vector to alignment direction
        PVector temp_v = vj[j];
        temp_v.normalize();
        alignment.add(temp_v);
      }
    }

    // combine cohesion and alginment
    d = PVector.add(cohesion, alignment);
    // add randomness
    d = random_dir(d);
    // normalize vector
    d.normalize();

    return d;
  }

  // compute seperation
  PVector compute_seperation(PVector d, PVector[] cj, int i) {

    // store flock_size
    float nAgents = cj.length;

    // Boids: seperation
    PVector seperation = new PVector(0, 0);
    // for all agents in the flock (cohesion and alignment)
    for (int j = 0; j < nAgents; j++) {
      // if not self
      if (j != i) {
        // check distance from self to neighbour within comfort distance
        if (PVector.dist(c, cj[j]) < comfort_dist+r) {
          // find directional vector from neighbour to self
          PVector temp_c = PVector.sub(c, cj[j]);
          // normalize vector
          temp_c.normalize();
          // add vectors to aggregrated speration direction
          seperation.add(temp_c);
        }
      }
    }
    seperation.normalize();
    // update desired direction
    d = seperation;
    // add randomness
    d = random_dir(d);
    // normalize direction
    d.normalize();
    // return desired direction
    return d;
  }

  // check for agents in comfort zone
  boolean comfort_check(PVector[] cj, int i) {
    float nAgents = cj.length;
    int count = 0;
    // check for each agent
    for (int j = 0; j < nAgents; j++) {
      if (count > 0) break;
      // if not self
      if (j != i) {
        // check distance from self to neighbour within influence distance
        if (PVector.dist(c, cj[j]) < comfort_dist+r) {
          count++;
        }
      }
    }
    if (count!=0) {
      return true;
    } 
    else {
      return false;
    }
  }

  // wraparound
  void borders() {
    if (c.x < -r) c.x = width+r;
    if (c.y < -r) c.y = height+r;
    if (c.x > width+r) c.x = -r;
    if (c.y > height+r) c.y = -r;
  }

  // add randomness
  PVector random_dir(PVector d) {
    PVector random_direction = PVector.random2D();
    random_direction.mult(0.5);
    d.add(random_direction);

    return d;
  }

  // render agent
  // All credits to the rendering codes of each agent goes to Nat at the following blog:
  // http://flashyprogramming.wordpress.com/2010/03/22/boids-perlin-noise-flow-field/
  void render() {
    float sy = 30*sin( this.tailStep*.1 + this.animOff);
    float theta = v.heading();

    if (knowledge) {
      fill(0);
    } 
    else {
      fill(255);
    }

    pushMatrix();

    translate(this.c.x, this.c.y);
    scale(this.s, this.s);
    rotate(theta);
    bezier( this.sx, this.sy, this.ax, this.ay, this.bx, this.by, this.ex, this.ey );
    bezier( this.sx, this.sy, this.cx, this.cy, this.dx, this.dy, this.ex, this.ey );
    line( this.sx, this.sy, this.ex, this.ey);

    popMatrix();
  }
}

