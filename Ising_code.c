#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void random_table(int count, int lattice[16][16]);
int neighbor_energy(int count, int i, int j, int lattice[16][16]);
void Fast_MC(int count, int lattice[16][16],int new_lattice[16][16], double T);
double magnet_per_spin(int count, int lattice[16][16]);
void SPATIAL_CORR(int count, int C[16][16], int record_lat[16][16], int lattice[16][16]);
double min(double a, double b);
double r2();
int main()
/* because static memory doesn't support variable size of arrays, 
(UHHHHH) here we let size to be a number, 
remember to change the number, if you want to change the size of the lattice,
also change count*/
{
	int count = 16;
	static int lattice[16][16];
	static int neigh[4][2];
	static int chose[5][2];
	static int new_lattice[16][16];
	
	double T;
	double m; /*MAGNET PER SPIN*/
	double total_m; /*variable for calculating mean*/
	double total_m2; /*variable for calculating variance and std*/
/* TOTAL NUMBER OF MONTE CARLO STEPS*/
	int STEP = 1000000;
	
	T = 0.5d;
	printf("\nT: %f \n", T);
	memset( chose, 1, sizeof(chose) );
	memset( neigh, 0, sizeof(neigh) );
	memset( lattice, 0, sizeof(lattice) );
	memset( new_lattice, 0, sizeof(new_lattice) );
	random_table (count, lattice);
	
	int sum_nei_spin;	
	int summed_energy = 0;
	int single_energy;
	

	for (int i = 0; i < count; i++){
		for (int j = 0; j < count; j++){ 
/* compute energy for single site (i,j) */
		
		/* printf("\n Site (%d, %d)", i, j); */
		sum_nei_spin = neighbor_energy(count, i, j, lattice);
		single_energy = lattice[i][j] * sum_nei_spin;
/* 		printf("\n Single Energy: %d", single_energy); */
		summed_energy += single_energy;
	}
	}
/*	printf("\n Summed Energy is: %d", summed_energy); */
	double Total_energy;
	Total_energy = summed_energy * (-1) * (0.5);
	printf("\n Total Energy of this system is: %f\n", Total_energy); 
	
/* FOR CALCULATING THE SPATIAL CORRELATION */
/* DECLARE THESE VARIABLES */
/* NOTE THAT THE VARIABLES ARE CALCULATED ONE MORE TIME HERE*/
	static int C[16][16] = {{0}};
	static double C_mean[16][16] = {{0}};
	static int record_lat[16][16] = {{0}};
	static double relat_mean[16][16] = {{0}};
	for (int q = 0; q < count; q++){
		for (int w = 0; w < count; w++){
			record_lat[q][w] = lattice[q][w];

			C[q][w] = lattice[0][0] * lattice[q][w];
			
/* 			printf("%d\t", record_lat[q][w]); */
			}
/* 		printf("\n"); */
	}
	
/* RUN THROUGH THESE MC STEPS */
	for (int i = 0; i < STEP; i++){
	Fast_MC(count, lattice, new_lattice, T);
	SPATIAL_CORR(count, C, record_lat, lattice);
/* WHY WRITE SUCH A USELESS IF STATEMENT??? IDK... MAYBE STATIC MEMORY IS DANGEROUS */
	m = magnet_per_spin(count, lattice);
	/* printf("FOR THIS CONFIG, MAGNET PER SPIN IS: %f", m); */
	total_m += m;
	total_m2 += m * m;

		
/* PRINT OUT THE CONFIG AND MEAN MAGNETIZATION EVERY N STEPS */

/* 		if ((i % (STEP / 10)) == 0){
			
		printf("\n");
		printf("\nTHIS RUN IS STEP %d\n", i);
		printf("\nMAGNETIZATION PER SPIN FOR THIS RUN IS: %f\n", m);
			for (int x = 0; x < count; x++){
				for (int y = 0; y < count; y++){ 
					printf("%d\t", lattice[x][y]);
				}
				printf("\n");
			}	
		} */
	}
	
/* TREAT THE DATA, CALCULATE AVERAGES AND STANDARD DEVIATIONS*/
	double mean_m = total_m/STEP;
	double mean_m2 = total_m2/STEP;
	double mean2_m = mean_m * mean_m;
	
	printf("\nEND OF MC RUNS\n");
	
/* 	printf("\nMEAN SQUARE OF m is: %f\n", mean2_m);
	printf("\nMEAN OF SQUARE m is: %f\n", mean_m2); */
	double ST_D = sqrt(mean_m2 - mean2_m);
	printf("\nMEAN VALUE OF m IS: %f\n", mean_m);
	printf("\nSTANDARD DEVIATION OF m IS: %f\n", ST_D);
/* PRINT OUT FINAL LATTICE SITE SPINS */
	printf("\nTHIS IS THE FINAL CONFIG OF LATTICE\n");
	for (int i = 0; i < count; i++){
		for (int j = 0; j < count; j++){ 
		    printf("%d\t", lattice[i][j]);
        }
        printf("\n");
	}	
	/* <sisj> and <sj>*/
	/* ALSO WRITE dist */
	double CRIJ[count * count]; 
	double dist[count * count];
	printf("\n<SiSj>(C) wrt. to site (0, 0) is:\n");
	for (int i = 0; i < count; i++){
		for (int j = 0; j < count; j++){ 
			printf("%d\t", C[i][j]);
       }
        printf("\n");
	}	
	printf("\nRECORD_LATTICE IS\n");
	for (int i = 0; i < count; i++){
		for (int j = 0; j < count; j++){ 
			printf("%d\t", record_lat[i][j]);
       }
        printf("\n");
	}	
/* 	for (int i = 0; i < (count * count); i++){
		printf("%d, %d\t", dist[i], CRIJ[i]);
		printf("\n");
	} */
	return 0;
}
/* CREATES A RANDOM ISING SPIN LATTICE */
void random_table(int count, int lattice[16][16])
{
	int i;
	int j;
	for (i = 0; i < count; i++)
	{
		for (j = 0; j < count; j++)
		{
			lattice[i][j] = pow(-1,rand());
		}
	}
		printf("\nOUR INITIAL LATTICE IS\n");
	for (i = 0; i < count; i++)
    {
        for (j = 0; j < count; j++)
        {
            printf("%d\t", lattice[i][j]);
        }
        printf("\n");
    }
}

/* FIND THE NEIGHBORS AND CALCULATE THE SPINS */
/* WITH PERIODIC BOUNDARY CONDITION */
int neighbor_energy (int count, int i, int j, int lattice[16][16])
{

	int neigh[4][2] = {
		{i, j+1},
		{i, j-1},
		{i-1, j},
		{i+1, j}
	};
	if ((j+1) > (count-1)) {
		neigh[0][0] = i;
		neigh[0][1] = 0;
	} 
	
	if ((j-1) < 0) {
		neigh[1][0] = i;
		neigh[1][1] = count - 1;
	} 

	if ((i-1) < 0) {
		neigh[2][0] = count - 1;
		neigh[2][1] = j;
	} 
	
	if ((i+1) > (count-1)) {
		neigh[3][0] = 0;
		neigh[3][1] = j;
	} 
/*	printf("Site is %d, %d: \t", i, j); */
	int k;
	int sum_neigh = 0;
/* 	printf("\nWE ARE AT SITE (%d, %d)\n", i, j); */
	for (k = 0; k < 4; k++)
	{	
/* 		printf("\n neigh is: (%d, %d)", neigh[k][0], neigh[k][1]);
		printf(" Spin of that neighbor: %d", lattice[neigh[k][0]][neigh[k][1]]);
 */		sum_neigh += lattice[neigh[k][0]][neigh[k][1]];
		
	}
/* 	printf("\nSum of neighboring spins is: %d\n", sum_neigh);
	
	printf("\n\n\n\n\n"); */
/* PRINT OUT ENERGY OF THIS SINGLE SITE*/
	return sum_neigh;
}

void Fast_MC(int count, int lattice[16][16], int new_lattice[16][16], double T)
{
	int chose_x;
	chose_x = rand()%(count);
	int chose_y;
	chose_y = rand()%(count);
/*	printf("(%d, %d)\n", chose_x, chose_y); */
/* int new_lattice[count][count]; DONOT ASK ME WHY...TRIED AND ONLY THIS WORKS */
	
/* NEED TO COMPUTE THE ENERGIES OF 4 NEIGHBOR SITES and ITSELF*/
/* COPY OLD LATTICE TO NEW ONE*/
/* 	printf("\nCOPIED and CHANGED NEW LATTICE IS: \n"); */
	for (int i = 0; i < count; i++)
    {
        for (int j = 0; j < count; j++)
        {
			if ((i == chose_x) && (j == chose_y)){
				/* FLIP SIGN OF CHOSEN SPIN*/
				new_lattice[i][j] = (-1) * lattice[i][j];
			}else{
				new_lattice[i][j] = lattice[i][j];
			}
/*         printf("%d\t", new_lattice[i][j]); */
		}
/*        printf("\n");*/
    }
	
/* 	printf("\nRANDOM NUMBERS: (%d, %d)\n", chose_x, chose_y);
	printf("\n fliped new lattice spin: %d\n", new_lattice[chose_x][chose_y]); */

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
/* 		printf("\n old energy of that site is: %d\n", e);  */
		old_spin += e * lattice[chose[l][0]][chose[l][1]];
		/*NOTE THAT HERE WE USED SPIN AT SITE TIMES SUM OF SURROUNDING SPINS*/

	}
/* 	printf("\nTotal Spin of old configuration is: %d\n", old_spin);  */
	old_energy = old_spin * (-1) * (0.5);
/* 	printf("OLD CONFIGURATION ENERGY IS: %f", old_energy);  */
/* COMPUTE THE ENERGY OF THE NEW CONFIGURATION*/
	int new_spin;
	new_spin = 0;
	double new_energy;
	for (int l = 0; l < 5; l++){

		e = neighbor_energy(count, chose[l][0], chose[l][1], new_lattice);
/* 		printf("\n new energy of that site is: %d\n", e);  */
		new_spin += e * new_lattice[chose[l][0]][chose[l][1]];
		/*NOTE THAT HERE WE USED SPIN AT SITE TIMES SUM OF SURROUNDING SPINS*/
	}
/* 	printf("\nTotal Spin of new configuration is: %d\n", new_spin);
 */	new_energy = new_spin * (-1) * (0.5);
/* 	printf("NEW CONFIGURATION ENERGY IS: %f", new_energy); */
/* TO CALCULATE DELTA IN ENERGY, DELTA_ENERGY = NEW - OLD */
	double delta_energy;
	delta_energy = new_energy - old_energy;
/*	printf("DELTA_ENERGY is: %f", delta_energy);*/
	double acc_prob;
	double boltz_factor;
	boltz_factor = exp(- delta_energy / T);
/* 	printf("\nBOLTZMANN FACTOR IS: %f", boltz_factor); */
	acc_prob = min(1.d, boltz_factor);
/* 	printf("\n ACCEPTIING PROBABILITY IS: %f", acc_prob); */
	double random_num;
	random_num = r2();
/* 	printf("\nRANDOM NUMBER IS: %f", random_num); */
	if (random_num < acc_prob){
/* 		printf("\nACCEPT\n"); */
/* 		printf("OUR NEW LATTICE IS: \n"); */
			for (int i = 0; i < count; i++){
				for (int j = 0; j < count; j++){
				lattice[i][j] = new_lattice[i][j];
/* 				printf("%d\t", new_lattice[i][j]); */
				}	
/*				printf("\n");*/
				}
	}
}

/*CALCULATE THE MAGNETIZATION PER SPIN OF THIS LATTICE */
double magnet_per_spin(int count, int lattice[16][16]){
	double total_site = (count) * (count);
	double TOTAL_SPIN;
	double m;
	TOTAL_SPIN = 0.d;
	for (int i = 0; i < count; i++){
		for (int j = 0; j < count; j++){
			TOTAL_SPIN += lattice[i][j];
		}
	}
	m = TOTAL_SPIN/total_site;
/* 	printf("\nTOTAL SPIN IS: %f\n", TOTAL_SPIN);
	printf("\nMAG PER SPIN IS: %f\n", m); */
	
	return m;
}

/* THE WAY I CALCULATE SPATIAL CORRELATION IS TO CALCULATE ALL PAIRS
OF SPIN INTERACTIONS THE OTHER SPINS HAVE WITH THE SPIN AT (1,1).
SO THERE ARE (count + 1) * (count + 1) - 1 pairs of INTERACTIONS,
THIS IS THE SIZE OF MY c(rij) array */

void SPATIAL_CORR(int count, int C[16][16], int record_lat[16][16], int lattice[16][16])
{
	
/* 	printf("\n\n");
	printf("\nOUR RECORDED LATTICE IS: \n"); */
	for (int q = 0; q < count; q++){
		for (int w = 0; w < count; w++){
			
			record_lat[q][w] += lattice[q][w] ;

			C[q][w] += lattice[0][0] * lattice[q][w];
/* 			printf("%d\t", record_lat[q][w]); */
			}
/* 			printf("\n"); */
	}
/* 	printf("\n\n"); */
}

/* COMPARING 2 DOUBLE AND YIELD THE SMALLER VALUE */
double min(double a, double b){
	double out;
	if (a < b){
		out = a;
	}else{
		out = b;
	}
	return out;
}

/* RANDOM NUMBER GENERATOR BETWEEN 0 and 1 */
double r2()
{
    return (double)rand() / (double)RAND_MAX ;
}
