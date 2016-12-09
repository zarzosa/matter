Particle particle[];

JSONObject jsonGeneral;
JSONObject [] jsonParticle;

PImage image;

int groupNumber;
int [] numberOfParticles;
int totalParticles;

void setup(){
  jsonGeneral = loadJSONObject("data-general.json");
  
  groupNumber = jsonGeneral.getJSONObject("particles").getInt("groupNumber");
  jsonParticle = new JSONObject[groupNumber];
  numberOfParticles = new int[groupNumber];
  for(int i=0 ; i<groupNumber ; i++){
    jsonParticle[i] = loadJSONObject(jsonGeneral.getJSONObject("particles").getJSONObject(str(i)).getString("json"));
    numberOfParticles[i] = jsonGeneral.getJSONObject("particles").getJSONObject(str(i)).getInt("amount");
  }

  size(1600,900);
  smooth();
  
  background(jsonGeneral.getJSONObject("canvas").getJSONObject("background").getInt("red"),jsonGeneral.getJSONObject("canvas").getJSONObject("background").getInt("green"),jsonGeneral.getJSONObject("canvas").getJSONObject("background").getInt("blue"));
  
  image = loadImage(jsonGeneral.getString("image"));
  
  totalParticles = 0;
  for(int i=0 ; i<numberOfParticles.length ; i++){
      totalParticles+=numberOfParticles[i];
  }
  particle = new Particle[totalParticles];
  int particleCount = 0;
  for(int i=0; i<groupNumber; i++){
    for(int j=0; j<numberOfParticles[i]; j++) {
      particle[particleCount] = new Particle(jsonParticle[i]);
      particleCount++;
    }
  }
}

void draw(){
  for(int i=0; i<totalParticles; i++) {
      particle[i].run();
  }
}

void keyPressed() {
  if(keyPressed) {
    if(key == 's' || key == 'S') {
      save("data/image.png");
    }
  }
}