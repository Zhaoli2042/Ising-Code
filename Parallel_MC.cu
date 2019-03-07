#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <iostream>
#include <cstddef>
#define __STDC_FORMAT_MACROS 1
#include <inttypes.h>
#include <cstdio>


#include <math.h>
//#include <cutil.h>
//#include "util.h"
#include "Parallel_MC.h"

__global__ void MC_kernel(int8_t* grid_device,int steps)
{
	//printf("%d \n", grid_device[threadIdx.x]);
//	int tid = threadIdx.x;
//	int bid = blockIdx.x; 	
 
}

__global__ void get_total_kernel(int8_t* grid_device, int* total) 
{
	*total = 20;
	//printf("%d \n", *total);
}



void MC(int8_t* grid_device, size_t x, size_t y, size_t z,  int steps, int* total_device)
{
    /* This function should only contain a call to the GPU 
       histogramming kernel. Any memory allocations and
       transfers must be done outside this function */
     dim3 dimGrid( ceil(x*y*z / 256),1);
     dim3 dimBlock(256,1);
     printf("hey \n");
     MC_kernel<<<dimGrid, dimBlock>>>(grid_device, steps);
	 cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess)
        {
                printf("error is %s \n",cudaGetErrorString(err));
        }
     get_total_kernel<<<dimGrid, dimBlock>>>(grid_device, total_device);	 
}


/* Include below the implementation of any other functions you need */
void copyToDeviceInput(int8_t* grid_device,int8_t* grid_host, unsigned int HEIGHT, unsigned int WIDTH )
{
//printf("copy to device input \n");
size_t size = HEIGHT * WIDTH  * sizeof(int8_t);
  	
cudaError_t err = cudaMemcpy(grid_device,grid_host,size, cudaMemcpyHostToDevice);

if (err != cudaSuccess)
{
	printf("error Copy To: %s \n", cudaGetErrorString(err));
}
}


void copyToDeviceGrid(int8_t* grid_device, int8_t* grid_host, unsigned int n )
{
	int size = n *  sizeof(int8_t);
        cudaError_t err = cudaMemcpy(grid_device, grid_host, size, cudaMemcpyHostToDevice );
	if (err != cudaSuccess)
{
        printf("error in CopyToDeviceGrid: %s \n", cudaGetErrorString(err));
}

}

void copyToDeviceTotal(int* total_device, int* total_host)
{
cudaError_t err = cudaMemcpy(total_device, &total_host, sizeof(int), cudaMemcpyHostToDevice );

	if (err != cudaSuccess)
{
        printf("error CopyToDevieTotal: %s \n", cudaGetErrorString(err));
}

}


void CopyFromDeviceGrid(int8_t* grid_host, int8_t* grid_device, unsigned int n)
{
    int size = n * sizeof(int8_t); 
    cudaError_t status = cudaMemcpy(grid_host, grid_device, size, cudaMemcpyDeviceToHost);
	if (status != cudaSuccess) {
	printf("error in CopyFromDeviceGrid:  %s \n", cudaGetErrorString(status));
	}
}

void CopyFromDeviceTotal(int* total_host, int* total_device)
{
        cudaError_t status = cudaMemcpy(total_host, total_device, sizeof(int), cudaMemcpyDeviceToHost);
        if (status != cudaSuccess) {
        printf("error in CopyFromDeviceTotal:  %s \n", cudaGetErrorString(status));
        }

}


void FreeDeviceGrid(int8_t * grid_device)
{
    cudaFree(grid_device);
    grid_device = NULL;
}

void FreeDeviceTotal(int* total_device)
{
	cudaFree(total_device);
	total_device = NULL;
}

int8_t * AllocateDeviceGrid(int8_t * grid_host, int n)
{
    int8_t * grid_device =  grid_host;
    int size = n * sizeof(uint8_t);
    cudaError_t err = cudaMalloc((void**) &grid_device, size);
	if (err != cudaSuccess)
{
        printf("error Allocate device grid: %s \n", cudaGetErrorString(err));
}

    return grid_device;
}

int* AllocateDeviceTotal(int* total_host)
{
	int* total_device = total_host;
	int size =  sizeof(int);
	cudaError_t err = cudaMalloc((void**) &total_device, size);
	if (err != cudaSuccess)
{
        printf("error Copy To: %s \n", cudaGetErrorString(err));
}

	return total_device;
}

int8_t * convert(int8_t** input, int HEIGHT, int WIDTH)
{
	int8_t* one_d = (int8_t*)malloc(sizeof(int8_t) * WIDTH * HEIGHT);
	for (int i =0 ; i < HEIGHT; i++)
	{
	for (int j= 0; j<WIDTH; j++)
	{
	     one_d[i * WIDTH + j] = input[i][j];
	}
	}

	return one_d;

}
