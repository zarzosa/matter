class Particle{
  JSONObject json;
  private float positionX, positionY, speed, size, sizeMaxLimitation, opacity, direction, newDirection, cushioning, stopFactor, fillRed, fillBlue, fillGreen, sizeInChangeFactor, sizeOutChangeFactor, opacityInChangeFactor, opacityOutChangeFactor;
  int dispersionProbability, stopHueMin, stopHueMax, stopSaturationMin, stopSaturationMax, stopBrightnessMin, stopBrightnessMax;
  boolean stop, increaseSize, useDirection, useStopColor, continuousCanvas;
  String imageDirection;
  color c;
  
  Particle(JSONObject json){
    this.json =json;
    
    // General
    positionX = random(json.getJSONObject("general").getJSONObject("initialPosition").getInt("minX"),json.getJSONObject("general").getJSONObject("initialPosition").getInt("maxX"));
    positionY = random(json.getJSONObject("general").getJSONObject("initialPosition").getInt("minY"),json.getJSONObject("general").getJSONObject("initialPosition").getInt("maxY"));
    stopFactor = json.getJSONObject("general").getFloat("stopFactor");
    useDirection = json.getJSONObject("general").getBoolean("useDirection");
    
    // Shape
    size = 0.5;
    
    // Movement
    speed = random(json.getJSONObject("movement").getJSONObject("speed").getFloat("min"),json.getJSONObject("movement").getJSONObject("speed").getFloat("min"));
    continuousCanvas = json.getJSONObject("movement").getBoolean("continuousCanvas");
    useStopColor = json.getJSONObject("movement").getJSONObject("stop").getBoolean("use");
    stopHueMin = json.getJSONObject("movement").getJSONObject("stop").getJSONObject("hue").getInt("min");
    stopHueMax = json.getJSONObject("movement").getJSONObject("stop").getJSONObject("hue").getInt("max");
    stopSaturationMin = json.getJSONObject("movement").getJSONObject("stop").getJSONObject("saturation").getInt("min");
    stopSaturationMax = json.getJSONObject("movement").getJSONObject("stop").getJSONObject("saturation").getInt("max");
    stopBrightnessMin = json.getJSONObject("movement").getJSONObject("stop").getJSONObject("brightness").getInt("min");
    stopBrightnessMax = json.getJSONObject("movement").getJSONObject("stop").getJSONObject("brightness").getInt("max");
    
    // Direction
    imageDirection = json.getJSONObject("direction").getString("imageDirection");
    cushioning = json.getJSONObject("direction").getFloat("cushioning");
    dispersionProbability = json.getJSONObject("direction").getInt("dispersionProbability");
    
    // Transform
    sizeMaxLimitation = random(json.getJSONObject("transform").getJSONObject("sizeMaxLimitation").getFloat("min"),json.getJSONObject("transform").getJSONObject("sizeMaxLimitation").getFloat("max"));
    sizeInChangeFactor = json.getJSONObject("transform").getJSONObject("sizeChangeFactor").getFloat("in");
    sizeOutChangeFactor = json.getJSONObject("transform").getJSONObject("sizeChangeFactor").getFloat("out");
    opacity = random(50,100);
    opacityInChangeFactor = json.getJSONObject("transform").getJSONObject("opacityChangeFactor").getFloat("in");
    opacityOutChangeFactor = json.getJSONObject("transform").getJSONObject("opacityChangeFactor").getFloat("out");
    fillRed = random(json.getJSONObject("transform").getJSONObject("fillRed").getInt("min"),json.getJSONObject("transform").getJSONObject("fillRed").getInt("max"));
    fillGreen = random(json.getJSONObject("transform").getJSONObject("fillGreen").getInt("min"),json.getJSONObject("transform").getJSONObject("fillGreen").getInt("max"));
    fillBlue = random(json.getJSONObject("transform").getJSONObject("fillBlue").getInt("min"),json.getJSONObject("transform").getJSONObject("fillGreen").getInt("max"));
    direction = 0;
    
    stop = false;
    increaseSize = true;
    
    int landingHueMin = json.getJSONObject("general").getJSONObject("landing").getJSONObject("hue").getInt("min");
    int landingHueMax = json.getJSONObject("general").getJSONObject("landing").getJSONObject("hue").getInt("max");
    int landingSaturationMin = json.getJSONObject("general").getJSONObject("landing").getJSONObject("saturation").getInt("min");
    int landingSaturationMax = json.getJSONObject("general").getJSONObject("landing").getJSONObject("saturation").getInt("max");
    int landingBrightnessMin = json.getJSONObject("general").getJSONObject("landing").getJSONObject("brightness").getInt("min");
    int landingBrightnessMax = json.getJSONObject("general").getJSONObject("landing").getJSONObject("brightness").getInt("max");
    boolean landingZone = false;
    while(!landingZone) {
      c = image.get( int(positionX) , int(positionY) );
      if((hue(c) >= landingHueMin && hue(c) <= landingHueMax) && (saturation(c) >= landingSaturationMin && saturation(c) <= landingSaturationMax) && (brightness(c) >= landingBrightnessMin && brightness(c) <= landingBrightnessMax)){
        landingZone = true;
      }else{
        positionX = random(json.getJSONObject("general").getJSONObject("initialPosition").getInt("minX"),json.getJSONObject("general").getJSONObject("initialPosition").getInt("maxX"));
        positionY = random(json.getJSONObject("general").getJSONObject("initialPosition").getInt("minY"),json.getJSONObject("general").getJSONObject("initialPosition").getInt("maxY"));
      }
    } 
  }

  void run(){
    if(!stop){
      draw();
      move();
      if(useDirection){
        directionManager();
      }
      transform();
      stop();
    }
  }
  
  void draw(){
    fill(fillRed,fillGreen,fillBlue,opacity);
    noStroke();
    ellipse(positionX,positionY,size,size);
  }
  
  void move(){
    positionX += speed*cos(direction);
    positionY += speed*sin(direction);
    
    if(continuousCanvas){
      positionX = ( positionX>width ? -width : positionX );
      positionY = ( positionY>height ? positionY-height : positionY );
      positionX = ( positionX<0 ? positionX+width : positionX );
      positionY = ( positionY<0 ? positionY+height : positionY );
    }
    
    c = image.get( int(positionX) , int(positionY) );
  }
  
  void directionManager(){    
    if(imageDirection.equals("none") == false){
      float value = 0;
      if(imageDirection.equals("hue")){
        value = hue(c);
      }else if(imageDirection.equals("saturation")){
        value = saturation(c);
      }else if(imageDirection.equals("brightness")){
        value = brightness(c);
      }
      
      
      newDirection = map( value , 0 , 255 , 0 , TWO_PI );
      
      if(random(100) < dispersionProbability){
        direction = random(TWO_PI);
      }
      else{
        direction = direction * cushioning + newDirection * (1-cushioning);
      }
    }else{
      if(round(random(dispersionProbability)) == 0){
        newDirection = random(TWO_PI);
      }else{
        direction = direction * cushioning + newDirection * (1-cushioning);
      }
    }
  }
  
  void transform(){
    if(increaseSize){
      size += sizeInChangeFactor;
      opacity += opacityInChangeFactor;
      if(size >= sizeMaxLimitation){
       increaseSize = false;
      }
    }else{
      size -= sizeOutChangeFactor;
      opacity -= opacityOutChangeFactor;
    }
    if(size <= 0.2){
      size = 0.2;
    }
  }
  
  void stop(){
    if(useStopColor && ((hue(c) >= stopHueMin && hue(c) <= stopHueMax) && (saturation(c) >= stopSaturationMin && saturation(c) <= stopSaturationMax) && (brightness(c) >= stopBrightnessMin && brightness(c) <= stopBrightnessMax))){
      stop = true;
    }else if((size <= stopFactor) && increaseSize == false){
      stop = true;
    }
  }

}