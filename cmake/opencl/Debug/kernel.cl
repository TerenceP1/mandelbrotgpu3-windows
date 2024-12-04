typedef struct {
  uint *data;
  //uint *tmp; ineffecient waste of space// temporary storage with double the size of data
  uint size;  // size of data array. data  is in big edian and has 32 bits of
              // integer and dprec of decimal
  uint dprec; // just for convenience: may or may not be used. dprec=size-1
} decimal;

void AddD(decimal* a, decimal* b, decimal* c){
  // does c=a+b
  ulong psm=0; // used for finding the pass bit
  int pass=0;
  uint sz=a->size;
  for (int i=sz-1;i>=0;i--){
    psm=(ulong)(a->data[i])+(ulong)(b->data[i]);
    if (pass){psm++;}
    if (psm&0x100000000L){pass=1;}
    else {pass=0;}
  }
}

void NegD(decimal* a){
  int sz=a->size;
  for (int i=0;i<sz;i++){
    a->data[i]=~(a->data[i]);
  }
  for (int i=sz-1;i>=0;i--){
    a->data[i]++;
    if (a->data[i]){break;}
  }
}

void SubD(decimal* a, decimal* b, decimal* c){
  NegD(b);
  AddD(a,b,c);
  NegD(b);
}

// tmp will be size size*3. size*2 is used for multiply and full tmp is used for division

void MulD(decimal*a, decimal*b, decimal*c, uint* tmp){
  ulong mltT;
  ulong carry=0;
  int sz=a->size;
  for (int i=0;i<sz*2;i++){
    tmp[i]=0;
  }
  for (int i=0;i<sz;i++){
    for (int j=0;j<sz;j++){
      mltT=(ulong)(a->data[i])*(ulong)(b->data[j]);
      // Add least significant half
      ulong hf=mltT&0xffffffffL;
      carry=(ulong)(tmp[1+i+j])+hf;
      tmp[i+j+1]=(uint)carry;
      if (carry&0x100000000L){
        // Add the carry
        for (int k=i+j;k>=0;k--){
          tmp[k]++;
          if (tmp[k]){break;}
        }
      }
      // Add the most significant half
      hf=mltT>>32;
      carry=(ulong)(tmp[i+j])+hf;
      tmp[i+j]=(uint)carry;
      if (carry&0x100000000L){
        // Add the carry
        if (i+j>0){
          for (int k=i+j-1;k>=0;k--){
            tmp[k]++;
            if (tmp[k]){break;}
          }
        }
      }
    }
  }
  for (int i=1;i<1+sz;i++){
    c->data[i-1]=tmp[i];
  }
}

void CopyD(decimal* a, decimal* b){
  int sz=a->size;
  for (int i=0;i<sz;i++){
    b->data[i]=a->data[i];
  }
}

void RecD(uint a, decimal* b, uint* tmp){
  // Newton-Raphson
  // input is assumed to be greater than 1
  int sz=b->size;
  int prec=b->dprec;
  for (int i=0;i<sz;i++){
    b->data[i]=0;
  }
  int lg=0;
  int tmpSz=sz;
  while (tmpSz>0){
    tmpSz/=2;
    lg++;
  }
  decimal* x,nx,two;
  x->size=sz;
  x->dprec=sz-1;
  x->data=tmp;
  nx->size=sz;
  nx->dprec=sz-1;
  nx->data=tmp+sz;
  two->size=sz;
  two->dprec=sz-1;
  two->data=tmp+(2*sz);
  
}

kernel void test(global uint *a, global uint *b, global uint *c) {
  printf(":)\n\n");
  volatile uint bruh = 0;
  for (int i = 0; i < 1000000000; i++) {
    int j = 1 + 1;
    bruh += i;
  }
  printf("STALL!!!!!!\n\n");
  *c = *a + *b;
  printf("DONE!!!!!!\n\n");
}
