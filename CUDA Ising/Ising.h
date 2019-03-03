#ifndef _CUDA_Ising_H_
#define _CUDA_Ising_H_

typedef struct
{
  //size of lattice
  unsigned int size;

  //Pointer to the first element of matrix represented
  int* elements;

} Matrix;

#endif // _CUDA_Ising_H_
