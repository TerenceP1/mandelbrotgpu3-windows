typedef struct {
  uint *data;
  // uint *tmp; ineffecient waste of space// temporary storage with double the
  // size of data
  uint size;  // size of data array. data  is in big edian and has 32 bits of
              // integer and dprec of decimal
  uint dprec; // just for convenience: may or may not be used. dprec=size-1
} decimal;
/*
typedef struct {
  decimal* x, *y, *nx, *ny, *ox, *oy; // ox and oy are original x and y. sqTmp is for storing y^2(useless)
  uint* tmp;
  char* re; // string with re in decimal
  char* im; // string with im in decimal
  decimal *tDig; // stores a digit or 10 during string to decimal conversion and bound check
  decimal *tenth; // stores one tenth or a power of it
  decimal *xSq, *ySq; // for checking whether number exceeded bounds
  int *rgb; // stores rgb values for pixels row by row with r then g then b
  int maxItr;
  int frame;
  decimal *xCh, *yCh; // how much to step per pixel
  decimal *zoom; // How much to zoom per frame
} kernelIn;
*/

// operation is a multi-stage proccess
typedef struct {
  decimal zoom; // Zoom per frame
  decimal tenth; // stores one tenth
  uint* tmp;
} globalInit; // initializes all global decimals

void AddD(decimal *a, decimal *b, decimal *c) {
  // does c=a+b
  ulong psm = 0; // used for finding the pass bit
  uint sz = a->size;
  for (int i = sz - 1; i >= 0; i--) {
    psm = (ulong)(a->data[i]) + (ulong)(b->data[i]) + (ulong)(c->data[i]);
    c->data[i] = psm;
    if (i > 0) {
      c->data[i - 1] = psm >= 0x100000000L;
    }
  }
}

void NegD(decimal *a) {
  int sz = a->size;
  for (int i = 0; i < sz; i++) {
    a->data[i] = ~(a->data[i]);
  }
  ulong carry=0;
  for (int i = sz - 1; i >= 0; i--) {
    ulong tmp=(ulong)(a->data[i]) + carry;
    a->data[i]=tmp;
    carry=tmp>=0x100000000L;
  }
}

void SubD(decimal *a, decimal *b, decimal *c) {
  NegD(b);
  AddD(a, b, c);
  NegD(b);
}

// tmp will be size size*3. size*2 is used for multiply and full tmp is used for
// division

void MulD(decimal *a, decimal *b, decimal *c) {
  ulong mltT;
  int pass = 0;
  ulong tSm;
  int sz = a->size;
  for (int i=0;i<sz;i++){
    c->data[i]=0;
  }
  for (int i = sz - 1; i > 0; i++) {
    for (int j = 0; j <= i; j++) {
      mltT = (ulong)(a->data[j]) * (ulong)(b->data[i - j]);
      // Add least significant half
      ulong hf = mltT & 0xffffffffL;
      tSm=hf+(ulong)(c->data[i]);
      // Pass the carry without path divergence
      if (i>0){
        c->data[i-1]+=tSm>=0x100000000L;
        if (i>1){
          c->data[i-2]+=c->data[i-1]==0;
        }
      }
      // Add the most significant half
      hf = mltT >> 32;
      if (i>0) {
        tSm=hf+(ulong)(c->data[i-1]);
        // Pass the carry without path divergence
        if (i>1){
          c->data[i-2]+=tSm>=0x100000000L;
        }
      }
    }
  }
}

void CopyD(decimal *a, decimal *b) {
  int sz = a->size;
  for (int i = 0; i < sz; i++) {
    b->data[i] = a->data[i];
  }
}

void RecD(uint a, decimal *b, uint *tmp) {
  // Newton-Raphson
  // input is assumed to be greater than 1
  int sz = b->size;
  int prec = b->dprec;
  for (int i = 0; i < sz; i++) {
    b->data[i] = 0;
  }
  int lg = 0;
  int tmpSz = sz;
  while (tmpSz > 0) {
    tmpSz /= 2;
    lg++;
  }
  decimal _1, _2, _3;
  decimal *x = &_1, *nx = &_2, *tint = &_3;
  x->size = sz;
  x->dprec = sz - 1;
  x->data = tmp;
  nx->size = sz;
  nx->dprec = sz - 1;
  nx->data = tmp + sz;
  tint->size = sz;
  tint->dprec = sz - 1;
  tint->data = tmp + (2 * sz);
  for (int i = 0; i < sz; i++) {
    x->data[i] = 0;
    nx->data[i] = 0;
    tint->data[i] = 0;
  }
  // two->data[0]=2;
  if (a == 2) {
    x->data[1] = 1;
    CopyD(x, b);
    return;
  } else {
    x->data[2] = 1;
  }
  for (int i = 0; i < lg; i++) {
    tint->data[0] = a;
    CopyD(x, nx);
    MulD(nx, tint, nx);
    tint->data[0] = 2;
    SubD(nx, tint, nx);
    NegD(nx);
    MulD(x, nx, nx);
  }
  CopyD(x, b);
}

int CmpD(decimal* a, decimal* b) {
  // returns -1 if a<b, 0 if a=b, and 1 if a>b
  int sz = a->size;
  if ((int)(a->data[0])<(int)(b->data[0])){
    return -1;
  }
  else if ((int)(a->data[0])>(int)(b->data[0])){
    return 1;
  }
  else {
    for (int i=1;i<sz;i++){
      if (a->data[i]<b->data[i]){
        return -1;
      }
      else if (a->data[i]>b->data[i]){
        return 1;
      }
    }
  }
  return 0;
}

void ZeroD(decimal* a){
  for (int i=0;i<a->size;i++){
    a->data[i]=0;
  }
}

void SetD(global globalInit* a, private char* b, decimal* c){
  ZeroD(c);
  // convert decimal part
  //RecD(10,a->tenth,a->tmp);
  int i=0;
  while (b[i]!='\0'){i++;}
  i--;
  while (b[i]!='.'){
    c->data[0]=b[i]-'0';
    MulD(c,a->tenth,c);
    i--;
  }
  // convert integer part
  int sign=b[0]=='-'; // negate at end
  i=0;
  if (sign)i++;
  while (b[i]!='.'){
    c->data[0]*=10;
    c->data[0]+=b[i]-'0';
    i++;
  }
  if (sign){NegD(c);}
}
/*Will be redesigned for anti-branch divergence
int mandelbrot(global kernelIn* a){
  ZeroD(a->x);
  ZeroD(a->y);
  ZeroD(a->nx);
  ZeroD(a->ny);
  //ZeroD(a->sqTmp);
  ZeroD(a->xSq);
  ZeroD(a->ySq);
  ZeroD(a->tDig);
  a->tDig->data[0]=4;
  for (int i=0;i<a->maxItr;i++){
    MulD(a->x,a->x,a->xSq,a->tmp);
    MulD(a->y,a->y,a->ySq,a->tmp);
    SubD(a->xSq,a->ySq,a->nx);
    MulD(a->x,a->y,a->ny,a->tmp);
    AddD(a->ny,a->ny,a->ny);
    CopyD(a->ny,a->y);
    CopyD(a->nx,a->x);
    AddD(a->xSq,a->ySq,a->xSq);
    if (CmpD(a->xSq,a->tDig)==1){
      return i;
    }
  }
  return -1;
}

void toRgb(int res, global kernelIn*a, int row, int col){
  int r,g,b;
  if (res==-1){
    r=0;
    g=0;
    b=0;
  }
  else {
    double h=((double)res)/100.0*360.0;
    double x=1.0-fabs(((h/60.0)-(((double)((int)(h/120.0))*2.0)))-1);
    double r_=0,g_=0,b_=0;
    if (h<60.0){
      r_=1;
      g_=x;
    }
    else if (h<120.0){
      g_=1;
      r_=x;
    }
    else if (h<180.0){
      g_=1;
      b_=x;
    }
    else if (h<240.0){
      b_=1;
      g_=x;
    }
    else if (h<300.0){
      r_=1;
      b_=x;
    }
    else{
      b_=1;
      r_=x;
    }
    a->rgb[3*(3840*row+col)]=(int)(r_*255);
    a->rgb[3*(3840*row+col)+1]=(int)(g_*255);
    a->rgb[3*(3840*row+col)+2]=(int)(b_*255);
  }
}

kernel void genRow(global kernelIn* a){
  private char zoom[18] = {'0', '.', '7', '9', '4', '3', '2', '8', '2', '3', '4', '7', '2', '4', '2', '8', '2','\0'};
  SetD(a,zoom,a->zoom);
  SetD(a,a->re,a->ox);
  SetD(a,a->im,a->oy);
  int row=get_global_id(0);
  int iRow=row%2160;
}
*/

kernel void globalInitK(global globalInit a){
  RecD(10,&(a->tenth),a->tmp);
  private char zoom[18] = {'0', '.', '7', '9', '4', '3', '2', '8', '2', '3', '4', '7', '2', '4', '2', '8', '2','\0'};
  SetD(&a,zoom,&(a->zoom));
}
kernel void test(global uint *a, global uint *b, global uint *c) {
  //printf(":)\n\n");
  volatile uint bruh = 0;
  for (int i = 0; i < 1000000000; i++) {
    int j = 1 + 1;
    bruh += i;
  }
  //printf("STALL!!!!!!\n\n");
  *c = *a + *b;
  //printf("DONE!!!!!!\n\n");
}
