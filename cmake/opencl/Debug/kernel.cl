typedef struct {
  uint *data;
  uint *tmp; // temporary storage with double the size of data
  uint size;  // size of data array. data  is in big edian and has 32 bits of
              // integer and dprec of decimal
  uint dprec; // just for convenience: may or may not be used. dprec=size-1
} decimal;

void AddD(decimal* a, decimal* b, decimal* c){
  // does c=a+b
  ulong psm=0; // used for finding the pass bit
  int pass=0;
  uint sz=a->size;
  for (int i=0;i<sz;i++){
    psm=(ulong)(a->data[i])+(ulong)(b->data[i]);
    if (pass){psm++;}
    if (psm&0x100000000L){pass=1;}
    else {pass=0;}
    c->data[i]=(uint)psm;
  }
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
