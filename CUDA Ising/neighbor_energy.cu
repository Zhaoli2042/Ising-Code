int neighbor_energy (int count, int i, int j, int* lattice)
{
/* IN 2D SYSTEM, THERE ARE 4 NEAREST NEIGHBORS*/
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
 */		sum_neigh += lattice[neigh[k][0] * count + neigh[k][1]];
		
	}
/* 	printf("\nSum of neighboring spins is: %d\n", sum_neigh);
	
	printf("\n\n\n\n\n"); */
/* PRINT OUT ENERGY OF THIS SINGLE SITE*/
	return sum_neigh;
}
