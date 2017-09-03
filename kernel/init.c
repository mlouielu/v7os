#include <stdint.h>
#include "stm32f1xx_hal.h"

#define __ISR_VECTOR    __attribute__ ((section(".isr_vector")))

extern uint32_t _estack;
extern uint32_t _sbss;
extern uint32_t _ebss;

void reset_handler(void) {
    SystemInit();

    /* Entry point */
    start_kernel();

    /* Should not reach here */
    while (1)
        ;
}

__ISR_VECTOR
uint32_t __isr_vector[] = {
    (uint32_t) &_estack,                /* init sp */
    (uint32_t) reset_handler,           /* reset */
};
