#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
//#include <cutil.h>

//INCLUDE THE KERNELS
//#include <neighbor_energy.cu>
#include </home/cwj8781/Ising-Code/CUDA Ising/random_table.cu>
#include </home/cwj8781/Ising-Code/CUDA Ising/Fast_MC.cu>
#include </home/cwj8781/Ising-Code/CUDA Ising/magnet.cu>
#include </home/cwj8781/Ising-Code/CUDA Ising/Parallel_MC.cu>
#include </home/cwj8781/Ising-Code/CUDA Ising/Parallel_MC.h>
#include <stdio.h>

int main()
/* because static memory doesn't support variable size of arrays, 
(F*CK THIS COMPILER) here we let size to be a number, 
remember to change the number, if you want to change the size of the lattice,
also change count*/
{
	int count = 16;
	int8_t *lattice_host;
	static int chose[5][2];
	float T;
//	float m; //Average magnet
	float total_m;
	float total_m2;
/* TOTAL NUMBER OF MONTE CARLO STEPS*/
	int STEP = 1000000;	
	T = 3.5;
	printf("\nT: %f \n", T);
	memset( chose, 1, sizeof(chose) );
	lattice_host = (int8_t*) malloc(count * count * sizeof(int));
	random_table(count, lattice_host);
	printf("\nNEW GENERATED LATTICE IS \n");
	for (int i = 0; i < count; i++){
      	for (int j = 0; j < count; j++){
      	printf("%d\t", lattice_host[i * count + j]);
      	}
      	printf("\n");
	}
	
/* Do memory allocation */
	int steps = 1000;
	int x = count;
	int y = count;
	int z =1 ;
	int n = x* y * z;
	int* total_host = (int*) malloc(sizeof(int*));	
	int val = 0;
	*total_host = val;
	int* total_device = AllocateDeviceTotal(total_host);
	int8_t* lattice_device = AllocateDeviceGrid(lattice_host, n);
	copyToDeviceGrid(lattice_device, lattice_host, n);
	copyToDeviceTotal(total_device, total_host);
	MC(lattice_device, x, y, z, steps,total_device );
	CopyFromDeviceGrid(lattice_host, lattice_device, n);
	CopyFromDeviceTotal(total_host, total_device);
	int t = *total_host;
	printf("%d \n", t);

printf("\nEND OF THE RUNS\n");
//CALCULATE AVERAGE MAGNET
//float mean_m = total_m/STEP;
//float mean_m2 = total_m2/STEP;
//float mean2_m = mean_m * mean_m;

//float ST_D = sqrt(mean_m2 - mean2_m); //STANDARD DEVIATION OF AVERAGE MAGNET
//	printf("\nTOTAL m is : %f\n", total_m);
//	printf("\nMEAN VALUE OF m IS: %f\n", mean_m);
//	printf("\nSTANDARD DEVIATION OF m IS: %f\n", ST_D);
/* TREAT THE DATA, CALCULATE AVERAGES AND STANDARD DEVIATIONS*/

printf("\nFINAL lattice is :\n");
for (int i = 0; i < count; i++){
      for (int j = 0; j < count; j++){
      printf("%d\t", lattice_host[i * count + j]);
      }
      printf("\n");
}

	
	return 0;
}












