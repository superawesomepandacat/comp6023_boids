
// flock parameters (population size, leader size, number of goals)
int init_pop_size = 500;
int init_leader_size = 5;
PVector preferred_direction = PVector.random2D();

// declare flock object
Flock flock;

// setup program
void setup() {
  // setup window
  size(850, 680);
  noStroke();
  smooth();
  // initialize flock
  flock = new Flock(init_pop_size, init_leader_size);
  // print preferred direction
  print("Preferred direction is "+preferred_direction+".\n");
  print("Angle of preferred direction is "+degrees(preferred_direction.heading())+".\n");
}

// animate the flock
void draw() {
  colorMode(HSB, 255);
  background(53,84,117);
  // update agents positions and directions
  flock.update();
  // render agents
  flock.render();
}

