
// flock class
class Flock {

  // flock population size
  int npop;
  // flock leader size
  int nleader;
  // declare array of agents to populate flock
  Agent[] agent;
  // declare array of aggregate position of agents in flock
  PVector[] c;
  // declare array of aggregate direction of agents in flock
  PVector[] v;

  // constructor (n is desired population size, p is desired leader size)
  Flock(int n, int l) {
    // store population size
    npop = n;
    // store leader size
    nleader = l;
    // initialize array of agents
    agent = new Agent[npop + nleader];
    // initalize array of agent positions
    c = new PVector[agent.length];
    // initialize array of agent directions
    v = new PVector[agent.length];
    // initialize each agent in array
    // initialize leader agents
    int spwn_h = height/2;
    int spwn_w = width/2;
    for (int i = 0; i < nleader; i++) {
      agent[i] = new Agent(spwn_w, spwn_h, true);
    }
    // initialize normal agents
    for (int i = nleader; i < agent.length; i++) {
      agent[i] = new Agent(spwn_w, spwn_h, false);
    }
  }

  // update flock positions
  void update() {
    // aggregate the position of each agent in the flock
    for (int i = 0; i < agent.length; i++) {
      c[i] = agent[i].c;
    }
    // aggregate the direction of each agent in the flock
    for (int i = 0; i < agent.length; i++) {
      v[i] = agent[i].v;
    }
    // update positions of each agent
    for (int i=0; i < agent.length; i++) {
      agent[i].update(c, v, i);
    }
  }

  // Render Flock
  void render() {
    for (int i = 0; i < npop; i++) {
      agent[i].render();
    }
  }
}

