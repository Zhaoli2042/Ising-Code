#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
//#include <cutil.h>

//INCLUDE THE KERNELS
//#include <neighbor_energy.cu>
#include </home/zlc6394/project/random_table.cu>
#include </home/zlc6394/project/Fast_MC.cu>
#include </home/zlc6394/project/magnet.cu>
#include <stdio.h>

int main()
/* because static memory doesn't support variable size of arrays, 
(F*CK THIS COMPILER) here we let size to be a number, 
remember to change the number, if you want to change the size of the lattice,
also change count*/
{
	int count = 16;
	int *lattice;
	static int chose[5][2];
	int *new_lattice;
	
	float T;
//	float m; //Average magnet
	float total_m;
	float total_m2;
/* TOTAL NUMBER OF MONTE CARLO STEPS*/
	int STEP = 1000000;	
	T = 3.5;
	printf("\nT: %f \n", T);
	memset( chose, 1, sizeof(chose) );
	lattice = (int*) malloc(count * count * sizeof(int));
	new_lattice = (int*) malloc(count * count * sizeof(int));
	random_table(count, lattice);
	printf("\nNEW GENERATED LATTICE IS \n");
	for (int i = 0; i < count; i++){
      	for (int j = 0; j < count; j++){
      	printf("%d\t", lattice[i * count + j]);
      	}
      	printf("\n");
	}

	
	
	
	int chose_x;
	int chose_y;		
/* RUN THROUGH THESE MC STEPS */
for (int t = 0; t < STEP; t++){

chose_x = rand()%(count);
chose_y = rand()%(count);
// COPY ORIGINAL LATTICE TO THE NEW LATTICE
//printf("\nFlipped element is [%d, %d]\n", chose_x, chose_y);
//printf("\nCOPIED and CHANGED NEW LATTICE IS: \n");
//memcpy(new_lattice, lattice, count*count);
        for (int i = 0; i < count; i++)
    {
        for (int j = 0; j < count; j++)
        {
        //printf("\nHERE j is %d\n", j);
	new_lattice[i * count + j] = lattice[i * count + j];
//         printf("%i\t", new_lattice[i * count + j]);
                }
//        printf("\n");
    }

Fast_MC(count, lattice, new_lattice, T, chose_x, chose_y);
//printf("\nflipped new lattice is :\n");
//for (int i = 0; i < count; i++){
//	for (int j = 0; j < count; j++){
//	printf("%d\t", lattice[i * count + j]);
//	}
//	printf("\n");
//}
//CALCULATE TOTAL MAGNET OF THIS RUN
float m = magnet_per_spin(count, lattice);
//printf("step is %d, m is %f", STEP, m);
total_m += m;
total_m2 += m*m;
}

printf("\nEND OF THE RUNS\n");
//CALCULATE AVERAGE MAGNET
float mean_m = total_m/STEP;
float mean_m2 = total_m2/STEP;
float mean2_m = mean_m * mean_m;

float ST_D = sqrt(mean_m2 - mean2_m); //STANDARD DEVIATION OF AVERAGE MAGNET
	printf("\nTOTAL m is : %f\n", total_m);
	printf("\nMEAN VALUE OF m IS: %f\n", mean_m);
	printf("\nSTANDARD DEVIATION OF m IS: %f\n", ST_D);
/* TREAT THE DATA, CALCULATE AVERAGES AND STANDARD DEVIATIONS*/

printf("\nFINAL lattice is :\n");
for (int i = 0; i < count; i++){
      for (int j = 0; j < count; j++){
      printf("%d\t", lattice[i * count + j]);
      }
      printf("\n");
}

	
	return 0;
}












