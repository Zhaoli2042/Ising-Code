
/*CALCULATE THE MAGNETIZATION PER SPIN OF THIS LATTICE */
float magnet_per_spin(int count, int* lattice){
	float total_site = (float) count * count;
	float TOTAL_SPIN = 0;
	float m;;
	for (int i = 0; i < count; i++){
		for (int j = 0; j < count; j++){
			TOTAL_SPIN += lattice[i * count + j];
		}
	}
	m = TOTAL_SPIN/total_site;
 	//printf("\nTOTAL SPIN IS: %f\n", TOTAL_SPIN);
	//printf("\nMAG PER SPIN IS: %f\n", m); 
	
	return m;
}
