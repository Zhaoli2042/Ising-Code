#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include </home/zlc6394/project/r2.cu>
#include </home/zlc6394/project/neighbor_energy.cu>


void Fast_MC(int count, int* lattice, int* new_lattice, double T, int chose_x, int chose_y)
{
	
// FLIP THE CHOSEN ONE!
	new_lattice[chose_x * count + chose_y] = (-1) * lattice[chose_x * count + chose_y];

/* CALCULATE 1st NEIGHBORS*/
		
		int chose[5][2] = {
		{chose_x, chose_y+1},
		{chose_x, chose_y-1},
		{chose_x-1, chose_y},
		{chose_x+1, chose_y},
		{chose_x, chose_y}
		};
	for (int i = 0; i < 5; i++){
/*		printf("\nNeighbor and self(last): (%d, %d)\n", chose[i][0], chose[i][1]);*/
	}
/*	printf("\n");*/
	
	if ((chose_y+1) > (count-1)) {
		chose[0][0] = chose_x;
		chose[0][1] = 0;
	}
	
	if ((chose_y-1) < 0) {
		chose[1][0] = chose_x;
		chose[1][1] = count - 1;
	} 

	if ((chose_x-1) < 0) {
		chose[2][0] = count - 1;
		chose[2][1] = chose_y;
	} 
	
	if ((chose_x+1) > (count-1)) {
		chose[3][0] = 0;
		chose[3][1] = chose_y;
	} 
/* 	for (int i = 0; i < 5; i++){
		printf("\n Neighbor and self(last): (%d, %d)\n", chose[i][0], chose[i][1]);
	} */
	

/* Then we need to call neigh_energy and plug in the old lattice to calculate the old energy*/
/* COMPUTE THE OLD CONFIGURATION ENERGY*/
	int old_spin;
	old_spin = 0;
	int e;
	double old_energy;
	for (int l = 0; l < 5; l++){

		e = neighbor_energy(count, chose[l][0], chose[l][1], lattice);
// 		printf("\n old energy of that site is: %d\n", e);  
		old_spin += e * lattice[chose[l][0] * count + chose[l][1]];
		/*NOTE THAT HERE WE USED SPIN AT SITE TIMES SUM OF SURROUNDING SPINS*/

	}
// 	printf("\nTotal Spin of old configuration is: %d\n", old_spin);  
	old_energy = old_spin * (-1) * (0.5);
// 	printf("OLD CONFIGURATION ENERGY IS: %f", old_energy);  
/* COMPUTE THE ENERGY OF THE NEW CONFIGURATION*/
	int new_spin;
	new_spin = 0;
	double new_energy;
	for (int l = 0; l < 5; l++){

		e = neighbor_energy(count, chose[l][0], chose[l][1], new_lattice);
// 		printf("\n new energy of that site is: %d\n", e);  
		new_spin += e * new_lattice[chose[l][0] * count + chose[l][1]];
		/*NOTE THAT HERE WE USED SPIN AT SITE TIMES SUM OF SURROUNDING SPINS*/
	}
// 	printf("\nTotal Spin of new configuration is: %d\n", new_spin);
 	new_energy = new_spin * (-1) * (0.5);
// 	printf("NEW CONFIGURATION ENERGY IS: %f", new_energy); 
/* TO CALCULATE DELTA IN ENERGY, DELTA_ENERGY = NEW - OLD */
	double delta_energy;
	delta_energy = new_energy - old_energy;
//	printf("DELTA_ENERGY is: %f", delta_energy);
	double acc_prob;
	double boltz_factor;
	boltz_factor = exp(- delta_energy / T);
// 	printf("\nBOLTZMANN FACTOR IS: %f", boltz_factor); 
	acc_prob = min((double) 1, boltz_factor);
// 	printf("\n ACCEPTIING PROBABILITY IS: %f", acc_prob); 
	double random_num;
	random_num = r2();
// 	printf("\nRANDOM NUMBER IS: %f", random_num);
	if (random_num < acc_prob){
// 		printf("\nACCEPT\n"); 
// 		printf("OUR NEW LATTICE IS: \n"); 
			for (int i = 0; i < count; i++){
				for (int j = 0; j < count; j++){
				lattice[i * count + j] = new_lattice[i * count + j];
// 				printf("%d\t", new_lattice[i * count + j]); 
				}
//				printf("\n");
				}
	}
}

//double min(double a, double b){
//	double out;
//	out = b;
//	if (a < b){
//		out = a;
//	}
//	return out;
//}
