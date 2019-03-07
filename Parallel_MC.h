#ifndef OPT_KERNEL
#define OPT_KERNEL


#define HISTO_WIDTH  1024
#define HISTO_HEIGHT 1
#define HISTO_LOG 10

#define UINT8_MAX 255



void MC( int8_t* grid_device, size_t x, size_t y, size_t z, int steps);


void copyToDeviceGrid(int8_t* grid_device, int8_t* grid_host, unsigned int n );
void copyToDeviceTotal(int* total_device, int* total_host);


void CopyFromDeviceGrid(int8_t* grid_host, int8_t* grid_device, unsigned int n) ;

void copyFromDeviceTotal(int* total_host, int* total_device);


void FreeDeviceGrid(int8_t * grid_device);
void FreeDeviceTotal(int* total_device);

int8_t * convert(int8_t** input, int HEIGHT, int WIDTH);
int8_t * AllocateDeviceGrid(int8_t * grid_host, int n);
int* AllocateDeviceTotal(int* total_host);
#endif
