PrintWriter output;

//colors
color black=color(0);
color white=color(255);

//variables
int itr; //iteration
float pixBright;
float maxBright=0;
int maxBrightPos=0;
int prevMaxBrightPos;
int cntr=1;
int row;
int col;

//scanner parameters
float odl = 210;  //distance between webcam and turning axle, [milimeter], not used yet
float photoCount = 120;  //number of phases profiling per revolution
float katLaser = 25*PI/180;  //angle between laser and camera [radian]
float katOperacji=2*PI/photoCount;  //angle between 2 profiles [radian]

//coordinates
float x, y, z;  //cartesian cords., [milimeter]
float ro;  //first of polar coordinate, [milimeter]
float fi; //second of polar coordinate, [radian]
float b; //distance between brightest pixel and middle of photo [pixel]
float pxmmpoz = 5; //pixels per milimeter horizontally 1px=0.2mm
float pxmmpion = 5; //pixels per milimeter vertically 1px=0.2mm

PImage[] images = new PImage[photoCount];

//================= CONFIG ===================

void setup() {
  // Load image files into PImages
  for(int i = 0; i < photoCount; i++){
    images[i] = loadImage("image"+i+".jpg");
  }
  //output file
  output=createWriter("skan.asc");  //plik wynikowy *.asc
}

//============== MAIN PROGRAM =================

void draw() {
  PImage photo=createImage(cam.width,cam.height,RGB);
  cam.read();
  delay(2000);
  for (itr=0;itr<photoCount;itr++) {
    cam.read();
    photo.loadPixels();
    cam.loadPixels();
    for (int n=0;n<photo.width*photo.height;n++){
      photo.pixels[n]=cam.pixels[n];
    }
    photo.updatePixels();
    set(20,20,cam);
    String nazwaPliku="photo-"+nf(itr+1, 3)+".png";
    photo.save(nazwaPliku);
    rotate();
    delay(500);
  }
  count();
  noLoop();
 
}

void count(){
  for (itr=0; itr<photoCount; itr++){
    String nazwaPliku="photo-"+nf(itr+1, 3)+".png";
    PImage skan=loadImage(nazwaPliku);
    String nazwaPliku2="odzw-"+nf(itr+1, 3)+".png";
    PImage odwz=createImage(skan.width, skan.height, RGB);
    skan.loadPixels();
    odwz.loadPixels();
    int currentPos;
    fi=itr*katOperacji;
    println(fi);

    for(row=0; row<skan.height; row++){  //starting row analysis
    maxBrightPos=0;
    maxBright=0;
      for(col=0; col<skan.width; col++){
        currentPos = row * skan.width + col;
        pixBright=brightness(skan.pixels[currentPos]);
        if(pixBright>maxBright){
          maxBright=pixBright;
          maxBrightPos=currentPos;
        }
        odwz.pixels[currentPos]=black; //setting all pixels black
      }
     
      odwz.pixels[maxBrightPos]=white; //setting brightest pixel white
     
      b=((maxBrightPos+1-row*skan.width)-skan.width/2)/pxmmpoz;
      ro=b/sin(katLaser);
      //output.println(b + ", " + prevMaxBrightPos + ", " + maxBrightPos); //I used this for debugging
     
      x=ro * cos(fi);  //changing polar coords to kartesian
      y=ro * sin(fi);
      z=row/pxmmpion;
     
      if( (ro>=-30) && (ro<=60) ){ //printing coordinates
        output.println(x + "," + y + "," + z);
      }
     
    }//end of row analysis
   
    odwz.updatePixels();
    odwz.save(nazwaPliku2);
   
  }
  output.flush();
  output.close();
}
