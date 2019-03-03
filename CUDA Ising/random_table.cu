/* CREATES A RANDOM ISING SPIN LATTICE */
#ifndef _random_H_
#define _random_H_

#include <stdio.h>
#include "Ising.h"
void random_table(int count, int* lattice)
{
	int i;
	int j;
	printf("\nHERE WE PRINT OUT OUR INITIALIZED MATRIX\n");
	for (i = 0; i < count; i++)
	{
		for (j = 0; j < count; j++)
		{
			lattice[i * count + j] = (int) pow(-1,rand());
		}
		printf("\n");
	}
		printf("\nOUR INITIAL LATTICE IS\n");
	for (i = 0; i < count; i++)
    {
        for (j = 0; j < count; j++)
        {
            printf("%d\t", lattice[i * count + j]);
        }
        printf("\n");
    }
}

#endif // #ifndef _random_H_
