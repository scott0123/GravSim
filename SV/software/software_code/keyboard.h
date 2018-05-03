#ifndef _KEYBOARD_H
#define _KEYBOARD_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>

#include "system.h"
#include "alt_types.h"
#include <unistd.h>  // usleep 
#include "sys/alt_irq.h"
#include "io_handler.h"

#include "cy7c67200.h"
#include "usb.h"
#include "lcp_cmd.h"
#include "lcp_data.h"

int keyboard_main(void);

#endif
