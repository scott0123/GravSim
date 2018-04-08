//io_handler.c
#include "io_handler.h"
#include <stdio.h>

void IO_init(void)
{
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
	// Reset OTG chip
	*otg_hpi_cs = 0;
	*otg_hpi_reset = 0;
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
//*************************************************************************//
    

    // I will first attempt to write the address to access the HPI_ADDR.
    // after the address is written, EZ-OTG should fetch the data from the address we specified (i think)
    *otg_hpi_address = Address; // gotta dereference that shit

	// DEBUG randomly toggling CS
	*otg_hpi_cs = 0;

    // we put this at the bottom so that incorrect data does not get written first
	// we should be using write mode
	*otg_hpi_w = 0;

    // Write data to HPI_DATA in 16-bit little endian words.
    // try to get it by reading from HPI_DATA probably (do we need to wait some time?)
    *otg_hpi_data = Data; // gotta dereference this time too

    // reset write back to non-active
    *otg_hpi_w = 1;

    // DEBUG cs to 1
//    *otg_hpi_cs = 1;

}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 temp;
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
//*************************************************************************//
    

    // I will again attempt to write the address to access the HPI_ADDR.
    *otg_hpi_address = Address; // gotta dereference that shit

	// DEBUG randomly toggling CS
	*otg_hpi_cs = 0;

    // we should be using read mode
    *otg_hpi_r = 0;

    // the data should be fetched into HPI_DATA now...
    temp = *otg_hpi_data; // gotta dereference this time too

    // reset read back to non-active
    *otg_hpi_r = 1;

	printf("%x\n",temp);

	// DEBUG cs to 1
//	*otg_hpi_cs = 1;

	return temp;
}
