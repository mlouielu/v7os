#include <stdint.h>
#include "stm32f1xx_hal.h"

void __early_uart_enable(void) {
    /* Using USART1 in stm32p103 */
    /* Enable GPIO TX/RX clock */
    __HAL_RCC_GPIOA_CLK_ENABLE();
    /* Enable USART2 clock */
    __HAL_RCC_USART2_CLK_ENABLE();

    GPIO_InitTypeDef GPIO_InitStruct = {
        .Pin = GPIO_PIN_2,
        .Mode = GPIO_MODE_AF_PP,
        .Pull = GPIO_PULLUP,
        .Speed = GPIO_SPEED_FREQ_HIGH,
    };
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    GPIO_InitStruct.Pin = GPIO_PIN_3;
    GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    /* USART init */

    /* Set the USART peripheral in the Asynchronous mode (UART Mode) */
    /* UART2 configured as follow:
        - Word Length = 8 Bits
        - Stop Bit = One Stop bit
        - Parity = None
        - BaudRate = 9600 baud
        - Hardware flow control disabled (RTS and CTS signals) */
    UART_HandleTypeDef UartHandle;
    UartHandle.Instance = USART2;
    UartHandle.Init.BaudRate = 115200;
    UartHandle.Init.WordLength = UART_WORDLENGTH_8B;
    UartHandle.Init.StopBits = UART_STOPBITS_1;
    UartHandle.Init.Parity = UART_PARITY_NONE;
    UartHandle.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    UartHandle.Init.Mode = UART_MODE_TX_RX | UART_IT_RXNE;
    UartHandle.Init.OverSampling = UART_OVERSAMPLING_16;

    HAL_UART_Init(&UartHandle);
    NVIC_SetPriority(USART2_IRQn, 0xE);
}

void __printk_putchar(char c)
{
    if (c == '\n')
        __printk_putchar('\r');

    while (!(USART2->SR & USART_SR_TXE))
        ;
    USART2->DR = (0xff) & c;
}

void __early_uart_helloworld(void) {
    char *s = "Hello World!";

    while (*s)
        __printk_putchar(*s++);
}


void v7m_init(void) {

}

void start_kernel(void) {
    v7m_init();
    __early_uart_enable();
    __early_uart_helloworld();

    /* Never reach here */
    while (1)
        ;
}
