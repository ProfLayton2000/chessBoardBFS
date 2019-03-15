int boardSize = 50;
int tileSize = 800/boardSize;
int weight = 5;

float off = radians(20);
float r = tileSize/5;
int showTri = 1;
int showBranches = 1;
int showVertex = 1;
int showEnd = 1;
/*
int sX = (int) random(0,boardSize);
int sY = (int) random(0,boardSize);
int eX = (int) random(0,boardSize);
int eY = (int) random(0,boardSize);
*/

int sX = 0;
int sY = 0;
int eX = 0;
int eY = 1;

int [] visited = new int[boardSize*boardSize];
int [] seen = new int[boardSize*boardSize];
int [] prev = new int[boardSize*boardSize];
int [] layer = new int[boardSize*boardSize];

int [] toDo = new int[boardSize*boardSize];
int nToDo = 0;

void pushStack(int item){
  toDo[nToDo] = item;
  nToDo++;
}

int popStack(){
  nToDo--;
  return(toDo[nToDo]);
}

int emptyStack(){
  return ((nToDo==0) ? 1:0);
}

int getLayer(int i){
  if (prev[i] == -1) return 0;
  return (1+getLayer(prev[i]));
}

void showStack(){
  print("STACK: \n");
  int a;
  for (a=0;a<nToDo;a++){
    print(toDo[a],a,"\n");
  }
}

int isValid(int x, int y, int dX, int dY){
  int nX = x + dX;
  int nY = y + dY;
  if (nX < 0 || nX >= boardSize){ return 0; }
  if (nY < 0 || nY >= boardSize){ return 0; }
  int nI = coToInd(nX,nY);
  if (visited[nI] != 0) { return 0; }
  return 1;
}

int findNeighbours(int x, int y, int[] list){
  int n = 0;
  if (isValid(x,y,2,1) == 1){ list[n] = coToInd(x+2,y+1); n++; }
  if (isValid(x,y,2,-1) == 1){ list[n] = coToInd(x+2,y-1); n++; }
  if (isValid(x,y,-2,1) == 1){ list[n] = coToInd(x-2,y+1); n++; }
  if (isValid(x,y,-2,-1) == 1){ list[n] = coToInd(x-2,y-1); n++; }
  if (isValid(x,y,1,2) == 1){ list[n] = coToInd(x+1,y+2); n++; }
  if (isValid(x,y,1,-2) == 1){ list[n] = coToInd(x+1,y-2); n++; }
  if (isValid(x,y,-1,2) == 1){ list[n] = coToInd(x-1,y+2); n++; }
  if (isValid(x,y,-1,-2) == 1){ list[n] = coToInd(x-1,y-2); n++; }
  return n;
}

int coToInd(int x, int y){ return(x+boardSize*y); }
int getX(int i) { return i % boardSize; }
int getY(int i) { return i / boardSize; }

void setup(){
  size(1400,800);
  background(0);
  
  translate(width/2,height/2);
  translate(-(boardSize*tileSize)/2,-(boardSize*tileSize)/2);
  
  rect(0,0,tileSize*boardSize,tileSize*boardSize);
  int i,j; //row, col
  for (i=0;i<boardSize;i++){
    for (j=0;j<boardSize;j++){
      int fillNo = ((i+j)%2==0) ? 50:255;
      fill(fillNo);
      rect(j*tileSize, i*tileSize,tileSize,tileSize);
      seen[j+boardSize*i] = 0;
      visited[j+boardSize*i] = 0;
      prev[j+boardSize*i] = -1;
    }
  }
  
  translate(tileSize/2,tileSize/2);
  /*for (i=0;i<boardSize;i++){
    for (j=0;j<boardSize;j++){
      text(str(j)+","+str(i),j*tileSize, i*tileSize);
      text(j+boardSize*i,j*tileSize, i*tileSize+10);
    }
  }*/
  
  int curr;
  pushStack(coToInd(sX,sY));
  while (emptyStack() == 0){
    curr = popStack();
    if (visited[curr] != 1){
      print("not seen ", curr,"\n");
      visited[curr] = 1;
      int cX = getX(curr);
      int cY = getY(curr);
      int [] neighbours = new int[8];
      int nNeighbours = findNeighbours(cX, cY, neighbours);
      //print("nNeighbours: ", nNeighbours, "\n");
      //print("neighbours to",cX,",",cY,":\n");
      
      int k;
      for ( k=0;k<nNeighbours;k++){
        //print(k,neighbours[k],"\n");
        if (prev[neighbours[k]] == -1) { prev[neighbours[k]] = curr; }
        if (seen[neighbours[k]] != 1) { pushStack(neighbours[k]); }
        seen[neighbours[k]] = 1;
      }
    }
    //showStack();
  }
  //print("PREVS: \n");
  int z;
  int maxLayer = 0;
  for (z=0;z<boardSize*boardSize;z++){
    layer[z] = getLayer(z);
    maxLayer = (layer[z] > maxLayer) ? layer[z] : maxLayer;
    //print(z, prev[z], " \n");
  }
  
  for (z=0;z<boardSize*boardSize;z++){
    //print(z, prev[z], "\n");
    if (prev[z] != -1){
      strokeWeight(weight);
      stroke(0,layer[z]*255/maxLayer,255-layer[z]*255/maxLayer);
      if (showBranches == 1){
      line(getX(z)*tileSize,getY(z)*tileSize,getX(prev[z])*tileSize,getY(prev[z])*tileSize);
      }
    }
    fill(0,layer[z]*255/maxLayer,255-layer[z]*255/maxLayer);
    if (showVertex == 1){
      ellipse(getX(z)*tileSize,getY(z)*tileSize,tileSize/5,tileSize/5);
    }
  }
  
  if (eX != -1 && eY != -1){
    strokeWeight(weight);
    stroke(255,0,0);
    z = coToInd(eX,eY);
    while (prev[z] != -1){
      strokeWeight(weight);
      stroke(layer[z]*100/layer[coToInd(eX,eY)] + 155,0,0);
      ellipse(getX(z)*tileSize,getY(z)*tileSize,tileSize/10,tileSize/10);
      line(getX(z)*tileSize,getY(z)*tileSize,getX(prev[z])*tileSize,getY(prev[z])*tileSize);
      
      float x2 = getX(z)*tileSize;
      float y2 = getY(z)*tileSize;
      float x1 = getX(prev[z])*tileSize;
      float y1 = getY(prev[z])*tileSize;
      //print("(x1,y1):",(int)(x1/tileSize),(int)(x2/tileSize),"->(x2,y2):",
      //(int)(x2/tileSize),(int)(y2/tileSize),"\n");
      if (showTri == 1){
        float m = -1.0*((y2-y1)/(x2-x1));
        float a = atan(m);
        //print(" gradient:",m);
        //print(" angle:",degrees(a));
        //print("\n");
        fill(0,layer[z]*255/maxLayer,255-layer[z]*255/maxLayer);
        if (x2 > x1){ a += PI; }
        //line(x2,y2,x2+r*cos(a),y2-r*sin(a));
        //line(x2,y2,x2+r*cos(a+off),y2-r*sin(a+off));
        //line(x2,y2,x2+r*cos(a-off),y2-r*sin(a-off));
        triangle(x2,y2,x2+r*cos(a+off),y2-r*sin(a+off),x2+r*cos(a-off),y2-r*sin(a-off));
      }
      z = prev[z];
    }
    if (showEnd == 1){
      fill(244,223,74,200);
      strokeWeight(0);
      ellipse(eX*tileSize,eY*tileSize,2*tileSize,2*tileSize);
      ellipse(sX*tileSize,sY*tileSize,2*tileSize,2*tileSize);
    }
  }
}