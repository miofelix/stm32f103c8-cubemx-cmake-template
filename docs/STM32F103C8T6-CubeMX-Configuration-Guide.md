# Complete STM32CubeMX Configuration Guide for STM32F103C8T6

## 1. Purpose of This Report

This report provides a rigorous and comprehensive guide for configuring the **STM32F103C8T6** microcontroller using **STM32CubeMX**. It covers project creation, pinout planning, clock-tree configuration, GPIO setup, peripheral configuration, DMA, NVIC, middleware, code-generation rules, hardware design constraints, and conflict-avoidance strategies.

The target MCU is:

**STM32F103C8T6**
**Family:** STM32F1
**Core:** Arm Cortex-M3
**Maximum SYSCLK:** 72 MHz
**Flash:** 64 KB
**SRAM:** 20 KB
**Package:** LQFP48
**Nominal supply:** 3.3 V
**Operating supply range:** 2.0 V to 3.6 V

This guide is written for projects using STM32CubeMX, STM32CubeIDE, HAL, LL, CMake, Makefile, OpenOCD, ST-LINK, or custom embedded build systems.

---

# 2. Important STM32F103C8T6 Characteristics

## 2.1 Core Device Capabilities

| Item                            | STM32F103C8T6                               |
| ------------------------------- | ------------------------------------------- |
| CPU                             | Arm Cortex-M3                               |
| Maximum core frequency          | 72 MHz                                      |
| Flash memory                    | 64 KB                                       |
| SRAM                            | 20 KB                                       |
| GPIO count in LQFP48            | Up to 37 GPIOs                              |
| ADC                             | 2 × 12-bit ADC                              |
| External ADC channels in LQFP48 | 10                                          |
| Timers                          | TIM1, TIM2, TIM3, TIM4, SysTick, IWDG, WWDG |
| USART                           | USART1, USART2, USART3                      |
| SPI                             | SPI1, SPI2                                  |
| I2C                             | I2C1, I2C2                                  |
| USB                             | USB 2.0 full-speed device                   |
| CAN                             | bxCAN 2.0B active                           |
| DMA                             | DMA1, 7 channels                            |
| Debug                           | SWD and JTAG                                |
| Boot modes                      | Flash, system memory bootloader, SRAM       |

## 2.2 Practical Development Assumptions

Most STM32F103C8T6 projects use:

| Resource                  | Typical Choice                                        |
| ------------------------- | ----------------------------------------------------- |
| Core clock                | 72 MHz                                                |
| External high-speed clock | 8 MHz HSE crystal                                     |
| Debug interface           | SWD                                                   |
| Serial debug              | USART1 on PA9/PA10                                    |
| Board voltage             | 3.3 V                                                 |
| Programming tool          | ST-LINK                                               |
| Configuration tool        | STM32CubeMX or STM32CubeIDE Device Configuration Tool |
| Firmware library          | STM32Cube HAL or LL                                   |
| Build tool                | STM32CubeIDE, Makefile, CMake, or custom toolchain    |

---

# 3. STM32CubeMX Project Creation

## 3.1 Create a New Project

In STM32CubeMX:

1. Open **STM32CubeMX**.

2. Select **Access to MCU Selector**.

3. Search for:

   `STM32F103C8T6`

4. Select package:

   `LQFP48`

5. Start project.

The correct target should appear as:

`STM32F103C8Tx`

CubeMX often uses the suffix `x` to represent part-number variants under the same pinout and memory family.

## 3.2 Project Manager Settings

Go to:

`Project Manager → Project`

Recommended settings:

| Option                | Recommendation                                             |
| --------------------- | ---------------------------------------------------------- |
| Project Name          | Use a meaningful embedded project name                     |
| Project Location      | Put project under version control                          |
| Application Structure | Basic or Advanced; Basic is enough for most small projects |
| Toolchain / IDE       | STM32CubeIDE, Makefile, CMake, or other desired target     |
| Firmware Package      | STM32Cube FW_F1                                            |
| Code Generator        | Generate only required files if possible                   |
| Keep User Code        | Always keep user code in generated USER CODE blocks        |

## 3.3 Code Generator Settings

Go to:

`Project Manager → Code Generator`

Recommended options:

| Setting                                                   | Recommendation                                                     |
| --------------------------------------------------------- | ------------------------------------------------------------------ |
| Copy all used libraries into project folder               | Good for reproducibility                                           |
| Copy only necessary library files                         | Good for small project size                                        |
| Generate peripheral initialization as pair of .c/.h files | Recommended for medium projects                                    |
| Backup previously generated files                         | Recommended                                                        |
| Delete previously generated files when not re-generated   | Use carefully                                                      |
| Set all free pins as analog                               | Recommended for low-power and noise reduction, but review manually |

## 3.4 Version-Control Rules

Keep these files under version control:

1. `.ioc` file.
2. `Core/Inc`.
3. `Core/Src`.
4. Linker script.
5. Startup file.
6. Build files, if generated.
7. Custom drivers.
8. Board support files.
9. README and documentation.

Do not rely only on generated code. The `.ioc` file is the source of truth for CubeMX configuration.

---

# 4. Recommended CubeMX Configuration Workflow

A disciplined CubeMX workflow should follow this order:

1. Select MCU: `STM32F103C8Tx`.
2. Configure **SYS Debug** as **Serial Wire**.
3. Configure **RCC** according to the board oscillator.
4. Configure the clock tree.
5. Reserve boot, debug, oscillator, USB, and analog pins.
6. Assign mandatory peripherals.
7. Resolve pin conflicts.
8. Configure GPIO modes and labels.
9. Configure peripheral parameters.
10. Configure DMA.
11. Configure NVIC interrupt priorities.
12. Configure middleware if needed.
13. Generate code.
14. Build.
15. Flash.
16. Verify clock, GPIO, UART, and debug behavior before enabling complex peripherals.

This order prevents the most common problems: losing SWD, using wrong oscillator assumptions, assigning conflicting pins, or generating code with invalid clock settings.

---

# 5. System Core Configuration

In CubeMX, the most important early configuration area is:

`Pinout & Configuration → System Core`

## 5.1 SYS Configuration

Go to:

`System Core → SYS`

Recommended setting:

| Option          | Recommended Value           |
| --------------- | --------------------------- |
| Debug           | Serial Wire                 |
| Timebase Source | SysTick or a hardware timer |
| System Wake-Up  | Enable only if required     |

### 5.1.1 Debug Mode

For almost all projects:

`Debug = Serial Wire`

This reserves:

| Signal | Pin  |
| ------ | ---- |
| SWDIO  | PA13 |
| SWCLK  | PA14 |

This is critical. If debug is set to **No Debug**, CubeMX may allow PA13 and PA14 to be used as GPIO, but then ST-LINK debugging/programming can become difficult or impossible after firmware starts.

Recommended development rule:

**Always keep SWD enabled unless the firmware is final and there is another recovery method.**

### 5.1.2 JTAG vs SWD

STM32F103C8T6 supports both JTAG and SWD. In most modern projects, use SWD only.

Why:

1. SWD uses only PA13 and PA14.
2. JTAG consumes PA13, PA14, PA15, PB3, and PB4.
3. Disabling JTAG while keeping SWD frees PA15, PB3, and PB4.

In CubeMX:

`SYS → Debug → Serial Wire`

This is the preferred setting.

## 5.2 RCC Configuration

Go to:

`System Core → RCC`

Important RCC options:

| Clock Source | CubeMX Option             | Pins Used        |
| ------------ | ------------------------- | ---------------- |
| HSE          | Crystal/Ceramic Resonator | OSC_IN / OSC_OUT |
| HSE bypass   | BYPASS Clock Source       | OSC_IN           |
| LSE          | Crystal/Ceramic Resonator | PC14 / PC15      |
| LSE bypass   | BYPASS Clock Source       | PC14             |
| HSI          | Internal clock            | No external pin  |
| LSI          | Internal low-speed clock  | No external pin  |

### 5.2.1 HSE Configuration

If your board has an external crystal, commonly 8 MHz:

`RCC → High Speed Clock (HSE) → Crystal/Ceramic Resonator`

This consumes:

| Pin           | Function   |
| ------------- | ---------- |
| OSC_IN / PD0  | HSE input  |
| OSC_OUT / PD1 | HSE output |

If HSE is enabled, do not use PD0 or PD1 as GPIO.

### 5.2.2 HSE Bypass Mode

Use HSE bypass only if an external clock signal is fed into OSC_IN.

Use:

`RCC → HSE → BYPASS Clock Source`

Do not use bypass mode for a normal two-pin crystal.

### 5.2.3 LSE Configuration

If the project needs accurate RTC:

`RCC → Low Speed Clock (LSE) → Crystal/Ceramic Resonator`

This consumes:

| Pin  | Function   |
| ---- | ---------- |
| PC14 | LSE input  |
| PC15 | LSE output |

If LSE is used, PC14 and PC15 cannot be used as normal GPIO.

### 5.2.4 No External Crystal Design

If the board has no HSE crystal, use HSI. However:

1. USB requires accurate 48 MHz timing and should normally use HSE-derived PLL.
2. CAN and UART timing are more reliable with HSE.
3. HSI is acceptable for simple GPIO, timer, and basic UART tests, but not ideal for precision communication.

---

# 6. Clock-Tree Configuration

Go to:

`Clock Configuration`

## 6.1 Recommended 72 MHz HSE Configuration

For a standard STM32F103C8T6 board with an 8 MHz crystal:

| Clock Parameter | Value           |
| --------------- | --------------- |
| HSE input       | 8 MHz           |
| PLL source      | HSE             |
| PLL multiplier  | ×9              |
| SYSCLK          | 72 MHz          |
| AHB prescaler   | /1              |
| HCLK            | 72 MHz          |
| APB1 prescaler  | /2              |
| PCLK1           | 36 MHz          |
| APB2 prescaler  | /1              |
| PCLK2           | 72 MHz          |
| ADC prescaler   | /6 or /8        |
| ADC clock       | 12 MHz or 9 MHz |
| USB prescaler   | /1.5            |
| USB clock       | 48 MHz          |

This is the most common full-performance configuration.

## 6.2 Clock Limits

| Clock                | Maximum Recommended Limit                |
| -------------------- | ---------------------------------------- |
| SYSCLK               | 72 MHz                                   |
| HCLK                 | 72 MHz                                   |
| PCLK1 / APB1         | 36 MHz                                   |
| PCLK2 / APB2         | 72 MHz                                   |
| ADC clock            | 14 MHz maximum                           |
| USB clock            | Exactly 48 MHz                           |
| TIM1 clock           | Usually 72 MHz                           |
| TIM2/TIM3/TIM4 clock | Usually 72 MHz when APB1 prescaler is /2 |

## 6.3 APB Timer Clock Rule

On STM32F1, timer clocks require attention.

If an APB prescaler is set to 1:

`Timer clock = PCLK`

If an APB prescaler is greater than 1:

`Timer clock = 2 × PCLK`

Typical 72 MHz configuration:

| Timer | Bus  |   PCLK | Timer Clock |
| ----- | ---- | -----: | ----------: |
| TIM1  | APB2 | 72 MHz |      72 MHz |
| TIM2  | APB1 | 36 MHz |      72 MHz |
| TIM3  | APB1 | 36 MHz |      72 MHz |
| TIM4  | APB1 | 36 MHz |      72 MHz |

This is important for PWM, encoder mode, input capture, and periodic interrupts.

## 6.4 USB Clock

If USB is enabled, USB clock must be 48 MHz.

For 8 MHz HSE:

1. HSE = 8 MHz.
2. PLL multiplier = ×9.
3. PLLCLK = 72 MHz.
4. USB prescaler = /1.5.
5. USB clock = 48 MHz.

Do not enable USB with an inaccurate clock source unless the design has been validated.

## 6.5 ADC Clock

ADC clock must not exceed the device limit.

Typical safe values:

|  PCLK2 | ADC Prescaler | ADC Clock |
| -----: | ------------: | --------: |
| 72 MHz |            /6 |    12 MHz |
| 72 MHz |            /8 |     9 MHz |

Avoid:

|  PCLK2 | ADC Prescaler | ADC Clock |
| -----: | ------------: | --------: |
| 72 MHz |            /2 |    36 MHz |
| 72 MHz |            /4 |    18 MHz |

These are too high for the ADC.

## 6.6 HSI-Only Basic Configuration

For minimal testing without external crystal:

| Clock Parameter | Typical Value                                     |
| --------------- | ------------------------------------------------- |
| HSI             | 8 MHz                                             |
| PLL source      | HSI/2                                             |
| PLL multiplier  | ×16                                               |
| SYSCLK          | 64 MHz                                            |
| USB             | Not recommended                                   |
| UART            | Works, but baud accuracy depends on HSI tolerance |
| ADC             | Configure prescaler carefully                     |

Use this only when no HSE crystal is available.

## 6.7 MCO Clock Output for Debug

PA8 can be configured as MCO.

Use MCO to output:

1. SYSCLK.
2. HSE.
3. HSI.
4. PLL clock divided as available.

This is useful for measuring the configured clock using an oscilloscope or logic analyzer.

But PA8 is also TIM1_CH1 and USART1_CK, so do not use MCO if those functions are needed.

---

# 7. Full STM32F103C8T6 LQFP48 Pin Configuration Reference

The following table lists all pins and how they should be handled in CubeMX.

## 7.1 Complete Pin Table

| Pin No. | Pin Name        | CubeMX Function Options                             | Recommended Use / Warning                                                                    |
| ------: | --------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------- |
|       1 | VBAT            | Backup supply                                       | Connect to VDD if backup battery is not used. Not configurable as GPIO.                      |
|       2 | PC13-TAMPER-RTC | GPIO, RTC Tamper                                    | Low-speed, low-current GPIO. Common Blue Pill LED pin. Avoid high-speed or high-current use. |
|       3 | PC14-OSC32_IN   | GPIO, LSE input                                     | Use for LSE crystal input. If LSE is enabled, do not use as GPIO.                            |
|       4 | PC15-OSC32_OUT  | GPIO, LSE output                                    | Use for LSE crystal output. If LSE is enabled, do not use as GPIO.                           |
|       5 | OSC_IN / PD0    | HSE input, PD0 GPIO if HSE unused                   | If HSE crystal is used, reserve this pin for oscillator.                                     |
|       6 | OSC_OUT / PD1   | HSE output, PD1 GPIO if HSE unused                  | If HSE crystal is used, reserve this pin for oscillator.                                     |
|       7 | NRST            | Reset                                               | Connect to reset circuit and SWD header.                                                     |
|       8 | VSSA            | Analog ground                                       | Connect to ground. Not GPIO.                                                                 |
|       9 | VDDA            | Analog supply                                       | Connect to clean 3.3 V. Required even if ADC is unused.                                      |
|      10 | PA0-WKUP        | GPIO, ADC12_IN0, TIM2_CH1_ETR, USART2_CTS, WKUP     | Good for ADC, wakeup, timer input/output.                                                    |
|      11 | PA1             | GPIO, ADC12_IN1, TIM2_CH2, USART2_RTS               | Good for ADC or TIM2 PWM/input capture.                                                      |
|      12 | PA2             | GPIO, ADC12_IN2, TIM2_CH3, USART2_TX                | Common USART2 TX. Also ADC-capable.                                                          |
|      13 | PA3             | GPIO, ADC12_IN3, TIM2_CH4, USART2_RX                | Common USART2 RX. Also ADC-capable.                                                          |
|      14 | PA4             | GPIO, ADC12_IN4, SPI1_NSS, USART2_CK                | SPI1 chip-select or ADC input. Software CS is often better.                                  |
|      15 | PA5             | GPIO, ADC12_IN5, SPI1_SCK                           | Standard SPI1 SCK.                                                                           |
|      16 | PA6             | GPIO, ADC12_IN6, SPI1_MISO, TIM3_CH1, TIM1_BKIN     | SPI1 MISO, ADC, or TIM3 channel.                                                             |
|      17 | PA7             | GPIO, ADC12_IN7, SPI1_MOSI, TIM3_CH2, TIM1_CH1N     | SPI1 MOSI, ADC, or TIM3 channel.                                                             |
|      18 | PB0             | GPIO, ADC12_IN8, TIM3_CH3, TIM1_CH2N                | ADC input or TIM3 PWM.                                                                       |
|      19 | PB1             | GPIO, ADC12_IN9, TIM3_CH4, TIM1_CH3N                | ADC input or TIM3 PWM.                                                                       |
|      20 | PB2 / BOOT1     | GPIO, BOOT1 at reset                                | Boot mode pin at reset. Use carefully.                                                       |
|      21 | PB10            | GPIO, I2C2_SCL, USART3_TX, TIM2 remap               | Good for I2C2 SCL or USART3 TX.                                                              |
|      22 | PB11            | GPIO, I2C2_SDA, USART3_RX, TIM2 remap               | Good for I2C2 SDA or USART3 RX.                                                              |
|      23 | VSS_1           | Ground                                              | Connect to ground.                                                                           |
|      24 | VDD_1           | Digital supply                                      | Connect to 3.3 V and decouple.                                                               |
|      25 | PB12            | GPIO, SPI2_NSS, I2C2_SMBA, USART3_CK, TIM1_BKIN     | SPI2 NSS or USART3 clock.                                                                    |
|      26 | PB13            | GPIO, SPI2_SCK, USART3_CTS, TIM1_CH1N               | SPI2 SCK.                                                                                    |
|      27 | PB14            | GPIO, SPI2_MISO, USART3_RTS, TIM1_CH2N              | SPI2 MISO.                                                                                   |
|      28 | PB15            | GPIO, SPI2_MOSI, TIM1_CH3N                          | SPI2 MOSI.                                                                                   |
|      29 | PA8             | GPIO, TIM1_CH1, USART1_CK, MCO                      | PWM or MCO. MCO useful for clock verification.                                               |
|      30 | PA9             | GPIO, USART1_TX, TIM1_CH2                           | Standard USART1 TX.                                                                          |
|      31 | PA10            | GPIO, USART1_RX, TIM1_CH3                           | Standard USART1 RX.                                                                          |
|      32 | PA11            | GPIO, USB_DM, CAN_RX, USART1_CTS, TIM1_CH4          | USB and default CAN conflict.                                                                |
|      33 | PA12            | GPIO, USB_DP, CAN_TX, USART1_RTS, TIM1_ETR          | USB and default CAN conflict.                                                                |
|      34 | PA13            | SWDIO/JTMS, GPIO if debug disabled                  | Keep as SWDIO during development.                                                            |
|      35 | VSS_2           | Ground                                              | Connect to ground.                                                                           |
|      36 | VDD_2           | Digital supply                                      | Connect to 3.3 V and decouple.                                                               |
|      37 | PA14            | SWCLK/JTCK, GPIO if debug disabled                  | Keep as SWCLK during development.                                                            |
|      38 | PA15            | JTDI, GPIO, SPI1_NSS remap, TIM2_CH1 remap          | JTAG-related after reset. Disable JTAG if used.                                              |
|      39 | PB3             | JTDO/TRACESWO, GPIO, SPI1_SCK remap, TIM2_CH2 remap | JTAG/SWO-related after reset. Disable JTAG if used.                                          |
|      40 | PB4             | JNTRST, GPIO, SPI1_MISO remap, TIM3_CH1 remap       | JTAG-related after reset. Disable JTAG if used.                                              |
|      41 | PB5             | GPIO, SPI1_MOSI remap, I2C1_SMBA, TIM3_CH2 remap    | Useful GPIO or remapped SPI1 MOSI.                                                           |
|      42 | PB6             | GPIO, I2C1_SCL, TIM4_CH1, USART1_TX remap           | Standard I2C1 SCL.                                                                           |
|      43 | PB7             | GPIO, I2C1_SDA, TIM4_CH2, USART1_RX remap           | Standard I2C1 SDA.                                                                           |
|      44 | BOOT0           | Boot selection input                                | Pull down for normal Flash boot. Not normal GPIO.                                            |
|      45 | PB8             | GPIO, TIM4_CH3, I2C1_SCL remap, CAN_RX remap        | Useful for I2C1 remap or CAN remap.                                                          |
|      46 | PB9             | GPIO, TIM4_CH4, I2C1_SDA remap, CAN_TX remap        | Useful for I2C1 remap or CAN remap.                                                          |
|      47 | VSS_3           | Ground                                              | Connect to ground.                                                                           |
|      48 | VDD_3           | Digital supply                                      | Connect to 3.3 V and decouple.                                                               |

---

# 8. GPIO Configuration in CubeMX

## 8.1 GPIO Mode Options

CubeMX provides GPIO configuration through:

`System Core → GPIO`

Common modes:

| CubeMX GPIO Mode              | Practical Meaning                     |
| ----------------------------- | ------------------------------------- |
| GPIO_Input                    | Digital input                         |
| GPIO_Output                   | Digital output                        |
| Analog                        | Analog input / low-power unused state |
| External Interrupt Mode       | EXTI input                            |
| Alternate Function Push Pull  | Peripheral output, push-pull          |
| Alternate Function Open Drain | Peripheral open-drain function        |
| Event Mode                    | EXTI event without interrupt          |

## 8.2 Output Type

| Output Type | Use Case                                               |
| ----------- | ------------------------------------------------------ |
| Push-Pull   | LED, chip select, digital control, PWM, UART TX, SPI   |
| Open-Drain  | I2C, wired-OR logic, level-compatible open-drain buses |

## 8.3 Pull-Up and Pull-Down

| Pull Setting | Use Case                            |
| ------------ | ----------------------------------- |
| No Pull      | Externally driven signals           |
| Pull-Up      | Buttons to ground, idle-high inputs |
| Pull-Down    | Buttons to VDD, idle-low inputs     |

Do not leave input pins floating unless the external circuit guarantees a defined level.

## 8.4 GPIO Speed

STM32F1 GPIO speed values correspond approximately to:

| CubeMX Speed | STM32F1 Meaning | Use Case                                  |
| ------------ | --------------- | ----------------------------------------- |
| Low          | 2 MHz           | LED, slow GPIO, low EMI                   |
| Medium       | 10 MHz          | Moderate-speed signals                    |
| High         | 50 MHz          | SPI, fast PWM, high-speed peripheral pins |

Design rule:

**Use the lowest speed that still satisfies the signal requirement.**

Higher speed increases edge rate, ringing, EMI, and power consumption.

## 8.5 Unused Pins

Recommended CubeMX rule:

`Set unused pins to Analog`

Benefits:

1. Reduces leakage.
2. Prevents floating digital inputs.
3. Reduces noise.
4. Improves low-power behavior.

However, do not blindly set pins to analog if they are connected to external circuits requiring defined logic levels.

---

# 9. Pin Labeling Rules in CubeMX

Use GPIO labels consistently.

Examples:

| Pin  | Label           |
| ---- | --------------- |
| PC13 | LED_STATUS      |
| PA9  | UART1_TX        |
| PA10 | UART1_RX        |
| PB6  | I2C1_SCL        |
| PB7  | I2C1_SDA        |
| PA5  | SPI1_SCK        |
| PA6  | SPI1_MISO       |
| PA7  | SPI1_MOSI       |
| PA4  | SPI1_CS_DISPLAY |
| PA0  | ADC_BATTERY     |
| PB8  | CAN_RX          |
| PB9  | CAN_TX          |

CubeMX generates labels into `main.h`, making firmware more readable.

Example generated style:

`#define LED_STATUS_Pin GPIO_PIN_13`
`#define LED_STATUS_GPIO_Port GPIOC`

Design rule:

**Use board-level signal names, not only peripheral names.**

Good:

`MOTOR_PWM_A`
`IMU_INT1`
`FLASH_CS`
`BATTERY_ADC`

Poor:

`GPIO_OUTPUT1`
`PIN_A0`
`SIGNAL1`

---

# 10. System-Level Pin Planning Strategy

Before enabling peripherals, reserve pins in this order.

## 10.1 Mandatory Reserved Pins

| Function | Pins                       | Rule                                           |
| -------- | -------------------------- | ---------------------------------------------- |
| Power    | VDD, VSS, VDDA, VSSA, VBAT | Always connect correctly                       |
| Reset    | NRST                       | Keep accessible                                |
| Debug    | PA13, PA14                 | Reserve for SWD                                |
| Boot     | BOOT0, PB2/BOOT1           | Pull to known states                           |
| HSE      | OSC_IN, OSC_OUT            | Reserve if external high-speed crystal is used |
| LSE      | PC14, PC15                 | Reserve if RTC crystal is used                 |

## 10.2 Fixed-Function Priority Pins

Assign these next:

| Function          | Pins               | Reason                             |
| ----------------- | ------------------ | ---------------------------------- |
| USB               | PA11, PA12         | Fixed USB pins                     |
| ADC               | PA0–PA7, PB0, PB1  | Analog pins are limited            |
| CAN default       | PA11, PA12         | Conflicts with USB                 |
| CAN remap         | PB8, PB9           | Needed if USB is used              |
| I2C default/remap | PB6/PB7 or PB8/PB9 | Needs open-drain pins and pull-ups |

## 10.3 Flexible Peripheral Pins

Assign after fixed resources:

1. UART.
2. SPI.
3. PWM.
4. Timer input capture.
5. Encoder inputs.
6. General GPIO outputs.
7. Interrupt inputs.

---

# 11. Critical Pin Conflicts to Avoid

## 11.1 USB vs CAN

| Peripheral  | Pins                         |
| ----------- | ---------------------------- |
| USB FS      | PA11 = USB_DM, PA12 = USB_DP |
| CAN default | PA11 = CAN_RX, PA12 = CAN_TX |

Conflict:

**USB and default CAN cannot share PA11/PA12.**

Solution:

If using both USB and CAN:

1. Keep USB on PA11/PA12.
2. Remap CAN to PB8/PB9.

CubeMX configuration:

`Connectivity → CAN → Parameter Settings / GPIO Settings`
Select remapped CAN pins if available.

## 11.2 SWD/JTAG vs GPIO/SPI Remap

| Pin  | Debug Function  |
| ---- | --------------- |
| PA13 | SWDIO           |
| PA14 | SWCLK           |
| PA15 | JTDI            |
| PB3  | JTDO / TRACESWO |
| PB4  | JNTRST          |

Conflict:

1. PA13 and PA14 are needed for SWD.
2. PA15, PB3, PB4 are occupied by JTAG after reset unless JTAG is disabled.
3. SPI1 remap uses PA15/PB3/PB4/PB5, conflicting with JTAG.

Solution:

Use:

`SYS → Debug → Serial Wire`

This disables full JTAG but keeps SWD.

## 11.3 HSE vs PD0/PD1 GPIO

| Pin           | HSE Function |
| ------------- | ------------ |
| OSC_IN / PD0  | HSE input    |
| OSC_OUT / PD1 | HSE output   |

Conflict:

If HSE crystal is used, PD0 and PD1 cannot be used as GPIO.

Solution:

Only use PD0/PD1 as GPIO if the design does not use HSE.

## 11.4 LSE vs PC14/PC15 GPIO

| Pin  | LSE Function |
| ---- | ------------ |
| PC14 | LSE input    |
| PC15 | LSE output   |

Conflict:

If LSE crystal is used, PC14 and PC15 cannot be used as GPIO.

Solution:

Reserve PC14/PC15 for RTC crystal if RTC accuracy is needed.

## 11.5 I2C1 Default vs USART1 Remap

| Function     | Pins             |
| ------------ | ---------------- |
| I2C1 default | PB6 SCL, PB7 SDA |
| USART1 remap | PB6 TX, PB7 RX   |

Conflict:

I2C1 default pins conflict with USART1 remapped pins.

Solution:

Use USART1 default PA9/PA10 if I2C1 uses PB6/PB7.

## 11.6 I2C1 Remap vs CAN Remap

| Function     | Pins             |
| ------------ | ---------------- |
| I2C1 remap   | PB8 SCL, PB9 SDA |
| CAN remap    | PB8 RX, PB9 TX   |
| TIM4_CH3/CH4 | PB8, PB9         |

Conflict:

PB8/PB9 cannot simultaneously serve I2C1 remap, CAN remap, and TIM4 channels.

Solution:

Choose one:

1. I2C1 on PB6/PB7 and CAN on PB8/PB9.
2. I2C1 on PB8/PB9 and CAN on PA11/PA12.
3. Avoid CAN if USB and remapped I2C1 both need PB8/PB9.

## 11.7 SPI1 Default vs ADC

| Function | Pins                                |
| -------- | ----------------------------------- |
| SPI1     | PA4, PA5, PA6, PA7                  |
| ADC      | PA4, PA5, PA6, PA7 also support ADC |

Conflict:

Using SPI1 consumes four ADC-capable pins.

Solution:

If many ADC channels are required, consider:

1. Use SPI2 instead.
2. Use fewer ADC channels.
3. Use external ADC through SPI/I2C.
4. Use PA0–PA3 and PB0/PB1 for ADC, leaving PA4–PA7 for SPI1.

## 11.8 USART1 vs TIM1

| Pin  | USART1 | TIM1     |
| ---- | ------ | -------- |
| PA9  | TX     | TIM1_CH2 |
| PA10 | RX     | TIM1_CH3 |
| PA11 | CTS    | TIM1_CH4 |
| PA12 | RTS    | TIM1_ETR |

Conflict:

USART1 flow control and TIM1 share pins; USART1 TX/RX also overlap with TIM1 PWM channels.

Solution:

If TIM1 PWM is required on PA9/PA10, use USART2 or USART3 for serial communication.

## 11.9 PC13 LED vs RTC Tamper

| Pin  | Function                             |
| ---- | ------------------------------------ |
| PC13 | GPIO / Tamper / RTC-related function |

Conflict:

PC13 is often used as LED but is also related to tamper/RTC function.

Solution:

Use PC13 for low-speed status LED only if tamper is not required.

---

# 12. Recommended Default Pin Assignment for a General Project

A robust general-purpose STM32F103C8T6 CubeMX assignment is:

| Function         | Pins                         | CubeMX Mode                |
| ---------------- | ---------------------------- | -------------------------- |
| SWD              | PA13, PA14                   | SYS Serial Wire            |
| Reset            | NRST                         | Reset                      |
| HSE              | OSC_IN, OSC_OUT              | RCC HSE Crystal            |
| USART debug      | PA9, PA10                    | USART1 Asynchronous        |
| I2C sensors      | PB6, PB7                     | I2C1                       |
| SPI device       | PA5, PA6, PA7                | SPI1                       |
| SPI chip select  | PA4                          | GPIO Output                |
| ADC inputs       | PA0, PA1, PA2, PA3, PB0, PB1 | ADC Analog                 |
| Status LED       | PC13                         | GPIO Output                |
| USB device       | PA11, PA12                   | USB Device FS              |
| CAN, if USB used | PB8, PB9                     | CAN remap                  |
| BOOT0            | BOOT0                        | External pull-down         |
| BOOT1            | PB2                          | Pull-down or defined state |

This assignment avoids most severe conflicts.

---

# 13. GPIO Configuration Examples

## 13.1 PC13 Status LED

CubeMX:

`Pinout view → PC13 → GPIO_Output`

GPIO configuration:

| Setting                | Value            |
| ---------------------- | ---------------- |
| GPIO mode              | Output Push Pull |
| GPIO Pull-up/Pull-down | No pull          |
| Maximum output speed   | Low              |
| User label             | LED_STATUS       |

Notes:

1. On many Blue Pill boards, PC13 LED is active-low.
2. PC13 is not suitable for high-speed or high-current driving.
3. Use low speed.

## 13.2 Button Input with EXTI

Example:

`PA0 → GPIO_EXTI0`

GPIO configuration:

| Setting | Value                                            |
| ------- | ------------------------------------------------ |
| Mode    | External Interrupt Mode with Rising/Falling edge |
| Pull    | Pull-up or Pull-down depending on hardware       |
| NVIC    | Enable EXTI line interrupt                       |
| Label   | USER_BUTTON                                      |

Important EXTI rule:

Each EXTI line number can connect to only one port pin at a time.

Examples:

| Conflict                     | Explanation                |
| ---------------------------- | -------------------------- |
| PA0 and PB0 both as EXTI0    | Not allowed simultaneously |
| PA1 and PB1 both as EXTI1    | Not allowed simultaneously |
| PA13 and PB13 both as EXTI13 | Not allowed simultaneously |

## 13.3 Chip Select Output

Example:

`PA4 → GPIO_Output`

Settings:

| Setting       | Value                |
| ------------- | -------------------- |
| Mode          | Output Push Pull     |
| Pull          | No pull              |
| Speed         | Low or Medium        |
| Initial level | High for inactive CS |
| Label         | SPI1_CS              |

For most SPI projects, manual software CS through GPIO is preferable to hardware NSS.

---

# 14. ADC Configuration in CubeMX

Go to:

`Analog → ADC1`

## 14.1 ADC Pins

Available external ADC-capable pins:

| ADC Channel | Pin |
| ----------- | --- |
| ADC12_IN0   | PA0 |
| ADC12_IN1   | PA1 |
| ADC12_IN2   | PA2 |
| ADC12_IN3   | PA3 |
| ADC12_IN4   | PA4 |
| ADC12_IN5   | PA5 |
| ADC12_IN6   | PA6 |
| ADC12_IN7   | PA7 |
| ADC12_IN8   | PB0 |
| ADC12_IN9   | PB1 |

## 14.2 Single-Channel ADC Configuration

Example:

`PA0 → ADC1_IN0`

ADC1 settings:

| Parameter                          | Recommended Value                            |
| ---------------------------------- | -------------------------------------------- |
| Scan Conversion Mode               | Disabled                                     |
| Continuous Conversion Mode         | Disabled or Enabled depending on application |
| Discontinuous Conversion Mode      | Disabled                                     |
| External Trigger Conversion Source | Software Start                               |
| Data Alignment                     | Right                                        |
| Number of Conversion               | 1                                            |
| Sampling Time                      | Start with 55.5 cycles or longer for safety  |

Use longer sampling time for high-impedance signals.

## 14.3 Multi-Channel ADC with DMA

For multiple channels:

1. Enable ADC1.
2. Select multiple input channels.
3. Enable Scan Conversion Mode.
4. Set Number of Conversions.
5. Configure rank order.
6. Enable DMA.
7. Set DMA mode to Circular if continuous sampling is required.

Recommended DMA settings:

| DMA Parameter         | Value                            |
| --------------------- | -------------------------------- |
| Direction             | Peripheral to Memory             |
| Mode                  | Circular for continuous sampling |
| Peripheral increment  | Disabled                         |
| Memory increment      | Enabled                          |
| Peripheral data width | Half Word                        |
| Memory data width     | Half Word                        |
| Priority              | Medium or High                   |

Firmware design rule:

Use a `uint16_t adc_buffer[N]` for ADC DMA.

## 14.4 ADC Clock Rule

ADC clock must be no higher than the allowed maximum.

For 72 MHz PCLK2:

| ADC Prescaler | ADC Clock | Use                |
| ------------- | --------: | ------------------ |
| /6            |    12 MHz | Recommended        |
| /8            |     9 MHz | Safer, lower speed |
| /4            |    18 MHz | Avoid              |
| /2            |    36 MHz | Invalid            |

## 14.5 ADC Design Rules

1. Configure ADC pins as analog.
2. Do not apply voltage below VSSA or above VDDA.
3. Use VDDA filtering.
4. Increase sampling time for high source impedance.
5. Use RC filtering for noisy analog signals.
6. Calibrate ADC after initialization.
7. Avoid routing analog traces near PWM, SPI, clock, or USB signals.
8. Prefer ADC1 if using DMA.
9. Do not use the same pin for ADC and digital output.
10. Label ADC channels clearly in CubeMX.

---

# 15. USART Configuration in CubeMX

Go to:

`Connectivity → USARTx`

## 15.1 USART Resources

| USART  | Bus  | Default Pins     | Common Use           |
| ------ | ---- | ---------------- | -------------------- |
| USART1 | APB2 | PA9 TX, PA10 RX  | Debug console        |
| USART2 | APB1 | PA2 TX, PA3 RX   | Module communication |
| USART3 | APB1 | PB10 TX, PB11 RX | Module communication |

## 15.2 USART1 Debug Console

CubeMX:

`Connectivity → USART1 → Mode → Asynchronous`

Pins:

| Signal    | Pin  |
| --------- | ---- |
| USART1_TX | PA9  |
| USART1_RX | PA10 |

Parameter settings:

| Parameter             | Recommended Value    |
| --------------------- | -------------------- |
| Baud Rate             | 115200               |
| Word Length           | 8 Bits               |
| Parity                | None                 |
| Stop Bits             | 1                    |
| Direction             | Transmit and Receive |
| Hardware Flow Control | None                 |
| Oversampling          | 16                   |

GPIO modes:

| Pin | Mode                         |
| --- | ---------------------------- |
| TX  | Alternate Function Push Pull |
| RX  | Input Floating or Pull-Up    |

## 15.3 USART DMA

For high-throughput serial communication:

1. Enable USARTx.
2. Go to DMA Settings.
3. Add USARTx_RX DMA.
4. Add USARTx_TX DMA if needed.
5. Use circular DMA for RX ring buffer.
6. Use normal DMA for TX.

Recommended RX DMA:

| Parameter        | Value                |
| ---------------- | -------------------- |
| Direction        | Peripheral to Memory |
| Mode             | Circular             |
| Memory increment | Enabled              |
| Data width       | Byte                 |
| Priority         | Medium               |

## 15.4 USART Interrupts

Enable NVIC interrupt if using:

1. RXNE interrupt.
2. IDLE line interrupt.
3. Transmission complete interrupt.
4. Error interrupt.
5. HAL_UARTEx_ReceiveToIdle_DMA style workflows.

Design rule:

For robust variable-length UART reception, use DMA + IDLE detection.

## 15.5 USART Conflict Rules

| Conflict                        | Explanation                  |
| ------------------------------- | ---------------------------- |
| USART1 PA9/PA10 vs TIM1_CH2/CH3 | Cannot use both on same pins |
| USART1 remap PB6/PB7 vs I2C1    | Conflicts with I2C1 default  |
| USART2 PA2/PA3 vs ADC channels  | PA2/PA3 are ADC-capable      |
| USART3 PB10/PB11 vs I2C2        | Conflicts with I2C2          |

---

# 16. I2C Configuration in CubeMX

Go to:

`Connectivity → I2C1` or `Connectivity → I2C2`

## 16.1 I2C Pin Options

| I2C          | Pins               |
| ------------ | ------------------ |
| I2C1 default | PB6 SCL, PB7 SDA   |
| I2C1 remap   | PB8 SCL, PB9 SDA   |
| I2C2         | PB10 SCL, PB11 SDA |

## 16.2 I2C1 Default Configuration

CubeMX:

`Connectivity → I2C1 → I2C`

Pins:

| Signal   | Pin |
| -------- | --- |
| I2C1_SCL | PB6 |
| I2C1_SDA | PB7 |

Parameter settings:

| Parameter       | Typical Value                |
| --------------- | ---------------------------- |
| I2C Speed Mode  | Standard Mode or Fast Mode   |
| Clock Speed     | 100 kHz or 400 kHz           |
| Duty Cycle      | 2 for standard fast-mode use |
| Own Address     | 0 unless acting as slave     |
| Addressing Mode | 7-bit                        |
| Dual Address    | Disabled                     |
| General Call    | Disabled                     |
| No Stretch Mode | Disabled                     |

GPIO settings:

| Pin | Mode                          |
| --- | ----------------------------- |
| SCL | Alternate Function Open Drain |
| SDA | Alternate Function Open Drain |

## 16.3 External Pull-Up Resistors

I2C requires pull-ups.

Typical values:

| Bus Speed | Pull-Up Recommendation |
| --------- | ---------------------- |
| 100 kHz   | 4.7 kΩ to 10 kΩ        |
| 400 kHz   | 2.2 kΩ to 4.7 kΩ       |

Do not rely only on internal weak pull-ups.

## 16.4 I2C Design Rules

1. Use external pull-ups to 3.3 V.
2. Do not pull I2C to 5 V unless all pins and devices are verified 5 V tolerant in that mode.
3. Keep bus traces short.
4. Check total bus capacitance.
5. Avoid using PB6/PB7 for USART1 remap if I2C1 is needed.
6. Avoid using PB8/PB9 for I2C1 remap if CAN remap is needed.
7. Add bus recovery code if devices may hold SDA low.
8. Confirm 7-bit vs 8-bit address notation.

---

# 17. SPI Configuration in CubeMX

Go to:

`Connectivity → SPI1` or `Connectivity → SPI2`

## 17.1 SPI Pin Options

| SPI          | Pins                                     |
| ------------ | ---------------------------------------- |
| SPI1 default | PA4 NSS, PA5 SCK, PA6 MISO, PA7 MOSI     |
| SPI1 remap   | PA15 NSS, PB3 SCK, PB4 MISO, PB5 MOSI    |
| SPI2 default | PB12 NSS, PB13 SCK, PB14 MISO, PB15 MOSI |

## 17.2 SPI1 Master Configuration

CubeMX:

`Connectivity → SPI1 → Full-Duplex Master`

Recommended parameters:

| Parameter           | Typical Value                  |
| ------------------- | ------------------------------ |
| Mode                | Full-Duplex Master             |
| Hardware NSS Signal | Disable for software CS        |
| Data Size           | 8 Bits                         |
| First Bit           | MSB First                      |
| Prescaler           | Choose based on device maximum |
| Clock Polarity      | Match slave device             |
| Clock Phase         | Match slave device             |
| CRC Calculation     | Disabled unless needed         |

GPIO settings:

| Pin  | Mode                         |
| ---- | ---------------------------- |
| SCK  | Alternate Function Push Pull |
| MOSI | Alternate Function Push Pull |
| MISO | Input Floating or Pull-Up    |
| CS   | GPIO Output Push Pull        |

## 17.3 Software Chip Select

Recommended approach:

1. Do not use hardware NSS unless required.
2. Configure CS as normal GPIO output.
3. Set CS high at initialization.
4. Pull CS low before transfer.
5. Pull CS high after transfer.

Benefits:

1. Easier multi-device SPI.
2. Better transaction control.
3. Simpler driver design.
4. Avoids STM32F1 NSS mode complexity.

## 17.4 SPI DMA

For high-throughput SPI:

Enable DMA for:

1. SPIx_TX.
2. SPIx_RX.

Recommended settings:

| Parameter        | Value                                         |
| ---------------- | --------------------------------------------- |
| TX Direction     | Memory to Peripheral                          |
| RX Direction     | Peripheral to Memory                          |
| Mode             | Normal                                        |
| Data width       | Byte or Half Word, depending on SPI data size |
| Memory increment | Enabled                                       |
| Priority         | Medium or High                                |

## 17.5 SPI Conflict Rules

| Conflict                         | Explanation                              |
| -------------------------------- | ---------------------------------------- |
| SPI1 default vs ADC              | PA4–PA7 are also ADC pins                |
| SPI1 remap vs JTAG               | PA15/PB3/PB4 are JTAG-related            |
| SPI2 vs USART3 flow-control pins | PB12–PB14 overlap with USART3 CK/CTS/RTS |
| SPI2 vs TIM1 complementary pins  | PB13–PB15 overlap with TIM1_CHxN         |

---

# 18. Timer and PWM Configuration in CubeMX

Go to:

`Timers → TIMx`

## 18.1 Timer Overview

| Timer   | Bus  | Type             | Typical Use                               |
| ------- | ---- | ---------------- | ----------------------------------------- |
| TIM1    | APB2 | Advanced-control | Motor PWM, complementary PWM, break input |
| TIM2    | APB1 | General-purpose  | PWM, encoder, input capture               |
| TIM3    | APB1 | General-purpose  | PWM, encoder, input capture               |
| TIM4    | APB1 | General-purpose  | PWM, encoder, input capture               |
| SysTick | Core | System tick      | HAL timebase, RTOS tick                   |
| IWDG    | LSI  | Watchdog         | Independent reset watchdog                |
| WWDG    | APB1 | Watchdog         | Window watchdog                           |

## 18.2 PWM Pins

| Timer Channel | Default Pin |
| ------------- | ----------- |
| TIM1_CH1      | PA8         |
| TIM1_CH2      | PA9         |
| TIM1_CH3      | PA10        |
| TIM1_CH4      | PA11        |
| TIM2_CH1      | PA0         |
| TIM2_CH2      | PA1         |
| TIM2_CH3      | PA2         |
| TIM2_CH4      | PA3         |
| TIM3_CH1      | PA6         |
| TIM3_CH2      | PA7         |
| TIM3_CH3      | PB0         |
| TIM3_CH4      | PB1         |
| TIM4_CH1      | PB6         |
| TIM4_CH2      | PB7         |
| TIM4_CH3      | PB8         |
| TIM4_CH4      | PB9         |

## 18.3 Basic PWM Configuration

Example:

`TIM3 → PWM Generation CH1`

CubeMX settings:

| Parameter               | Example                          |
| ----------------------- | -------------------------------- |
| Prescaler               | Depends on desired PWM frequency |
| Counter Mode            | Up                               |
| Counter Period          | ARR value                        |
| Internal Clock Division | No Division                      |
| Auto-reload preload     | Enable                           |
| PWM Mode                | PWM mode 1                       |
| Pulse                   | Initial CCR value                |
| Output Compare Preload  | Enable                           |

Formula:

`PWM frequency = Timer clock / ((PSC + 1) × (ARR + 1))`

Duty cycle:

`Duty cycle = CCRx / (ARR + 1)`

## 18.4 Example PWM Calculation

Assume:

| Parameter               | Value  |
| ----------------------- | ------ |
| Timer clock             | 72 MHz |
| Desired PWM             | 1 kHz  |
| Prescaler               | 71     |
| Timer counter frequency | 1 MHz  |
| ARR                     | 999    |

Then:

`PWM = 72 MHz / ((71 + 1) × (999 + 1)) = 1 kHz`

For 50% duty:

`CCR = 500`

## 18.5 Encoder Mode

TIM2, TIM3, and TIM4 can be used for quadrature encoder input.

CubeMX:

`TIMx → Combined Channels → Encoder Mode`

Typical settings:

| Setting        | Value                            |
| -------------- | -------------------------------- |
| Encoder Mode   | TI1 and TI2                      |
| Input Filter   | Add filtering if signal is noisy |
| Polarity       | Rising                           |
| Counter Period | Maximum expected count           |
| Pull-up/down   | According to encoder output type |

Design rules:

1. Use pull-ups for open-collector encoders.
2. Add RC or digital filtering for noisy mechanical encoders.
3. Avoid sharing encoder pins with SPI/I2C/UART.
4. Use interrupt or periodic polling depending on speed.

## 18.6 TIM1 Advanced PWM

TIM1 supports:

1. Complementary outputs.
2. Dead-time insertion.
3. Break input.
4. Main Output Enable.
5. Motor-control PWM.

TIM1 pins include:

| Function  | Pin                                       |
| --------- | ----------------------------------------- |
| TIM1_CH1  | PA8                                       |
| TIM1_CH2  | PA9                                       |
| TIM1_CH3  | PA10                                      |
| TIM1_CH4  | PA11                                      |
| TIM1_CH1N | PB13 or PA7 depending on mapping/function |
| TIM1_CH2N | PB14 or PB0                               |
| TIM1_CH3N | PB15 or PB1                               |
| TIM1_BKIN | PB12 or PA6                               |

Design rules:

1. Use TIM1 for BLDC, PMSM, inverter, or half-bridge PWM.
2. Configure dead time carefully.
3. Configure break input for safety.
4. Ensure GPIO alternate-function output speed is adequate.
5. Do not drive MOSFET gates directly from MCU pins; use gate drivers.

---

# 19. USB Device Configuration in CubeMX

Go to:

`Connectivity → USB`

Then middleware:

`Middleware → USB_DEVICE`

## 19.1 USB Pins

| USB Signal | Pin  |
| ---------- | ---- |
| USB_DM     | PA11 |
| USB_DP     | PA12 |

## 19.2 USB Clock Requirement

USB requires a 48 MHz clock.

Recommended clock setup:

| Item          | Value  |
| ------------- | ------ |
| HSE           | 8 MHz  |
| PLL           | ×9     |
| SYSCLK        | 72 MHz |
| USB prescaler | /1.5   |
| USB clock     | 48 MHz |

## 19.3 USB CDC Configuration

CubeMX steps:

1. Enable `USB → Device FS`.
2. Enable `Middleware → USB_DEVICE`.
3. Select `Class For FS IP → Communication Device Class (Virtual Port Com)`.
4. Confirm USB clock is 48 MHz.
5. Generate code.
6. Implement CDC transmit/receive logic in `usbd_cdc_if.c`.

## 19.4 USB Hardware Rules

1. PA11 connects to USB D-.
2. PA12 connects to USB D+.
3. Use proper USB connector wiring.
4. Add ESD protection for robust hardware.
5. Use correct D+ pull-up design.
6. Keep D+/D- traces short and matched.
7. Avoid stubs and noisy routing.
8. Do not use PA11/PA12 for CAN if USB is enabled.

## 19.5 USB Flash/RAM Consideration

STM32F103C8T6 has only 64 KB Flash and 20 KB SRAM.

USB CDC with HAL can consume a meaningful amount of Flash/RAM. Keep firmware modular and avoid unnecessary middleware.

---

# 20. CAN Configuration in CubeMX

Go to:

`Connectivity → CAN`

## 20.1 CAN Pin Options

| CAN Mode | RX   | TX   |
| -------- | ---- | ---- |
| Default  | PA11 | PA12 |
| Remapped | PB8  | PB9  |

If USB is used, use CAN remap PB8/PB9.

## 20.2 CAN Hardware Requirement

STM32F103C8T6 contains a CAN controller, not a physical CAN transceiver.

Required external parts:

1. CAN transceiver.
2. CANH/CANL bus.
3. 120 Ω termination at each end of the bus.
4. Protection circuitry if used in harsh environments.
5. Proper grounding or isolation.

## 20.3 CAN Bit Timing Formula

CAN bitrate is determined by:

`CAN bitrate = PCLK1 / (Prescaler × (1 + BS1 + BS2))`

Where:

| Field     | Meaning               |
| --------- | --------------------- |
| PCLK1     | APB1 peripheral clock |
| Prescaler | CAN prescaler         |
| BS1       | Time segment 1        |
| BS2       | Time segment 2        |
| 1         | Sync segment          |

Typical APB1 clock:

`PCLK1 = 36 MHz`

Example 500 kbit/s:

| Parameter    | Value               |
| ------------ | ------------------- |
| PCLK1        | 36 MHz              |
| Prescaler    | 4                   |
| BS1          | 13 time quanta      |
| BS2          | 4 time quanta       |
| Total TQ     | 18                  |
| Bitrate      | 500 kbit/s          |
| Sample point | Approximately 77.8% |

Example 1 Mbit/s:

| Parameter | Value    |
| --------- | -------- |
| PCLK1     | 36 MHz   |
| Prescaler | 2        |
| BS1       | 13       |
| BS2       | 4        |
| Total TQ  | 18       |
| Bitrate   | 1 Mbit/s |

## 20.4 CAN Filter Configuration

In STM32 HAL, CAN reception usually requires filter configuration before starting CAN.

Design rules:

1. Configure at least one filter.
2. Assign filter to FIFO0 or FIFO1.
3. Start CAN using HAL_CAN_Start.
4. Activate notification if using interrupt receive.
5. Handle bus-off, error passive, and error warning states.

## 20.5 CAN Conflict Rules

| Conflict                  | Explanation        |
| ------------------------- | ------------------ |
| Default CAN vs USB        | Both use PA11/PA12 |
| CAN remap vs I2C1 remap   | Both use PB8/PB9   |
| CAN remap vs TIM4_CH3/CH4 | Both use PB8/PB9   |

---

# 21. DMA Configuration in CubeMX

Go to:

Peripheral configuration page → `DMA Settings`

## 21.1 Common DMA Use Cases

| Peripheral | DMA Use                           |
| ---------- | --------------------------------- |
| ADC1       | Continuous multi-channel sampling |
| USART RX   | Circular receive buffer           |
| USART TX   | Non-blocking transmit             |
| SPI RX/TX  | High-speed full-duplex transfer   |
| I2C RX/TX  | Buffer transfer                   |
| TIM        | PWM update, capture transfer      |

## 21.2 General DMA Settings

| Setting               | Recommendation                                 |
| --------------------- | ---------------------------------------------- |
| Peripheral increment  | Disabled                                       |
| Memory increment      | Enabled                                        |
| Peripheral data width | Match peripheral                               |
| Memory data width     | Match buffer                                   |
| Mode                  | Normal or Circular                             |
| Priority              | Medium by default; High for time-critical data |

## 21.3 DMA Design Rules

1. Use circular mode for continuous ADC or UART RX.
2. Use normal mode for finite SPI or UART TX transfers.
3. Use correct buffer data type.
4. Do not put DMA buffers on stack if they must persist.
5. Mark shared buffers as volatile if accessed in interrupts.
6. Use half-transfer and transfer-complete callbacks for streaming.
7. Check DMA channel conflicts in CubeMX.
8. Enable NVIC interrupt for DMA if callbacks are needed.

---

# 22. NVIC Configuration in CubeMX

Go to:

`System Core → NVIC`

## 22.1 Interrupt Priority Principles

STM32F103 uses Cortex-M3 NVIC.

Design rules:

1. Lower numerical value means higher priority.
2. Keep interrupt handlers short.
3. Avoid blocking HAL_Delay inside interrupts.
4. Do not perform long printf operations inside interrupts.
5. Use flags, queues, ring buffers, or DMA callbacks.
6. Give time-critical motor/control interrupts higher priority.
7. Keep USB and communication interrupts at reasonable priorities.
8. Configure priority grouping deliberately.

## 22.2 Typical Priority Scheme

For a simple project:

| Interrupt                    | Priority                               |
| ---------------------------- | -------------------------------------- |
| Hard real-time timer/control | 0 or 1                                 |
| DMA critical transfer        | 1 or 2                                 |
| USB / CAN                    | 2 or 3                                 |
| UART / SPI / I2C             | 3 or 4                                 |
| EXTI buttons                 | 5 or lower                             |
| SysTick                      | Default unless RTOS requires otherwise |

For HAL-only projects without RTOS, default priority settings are often acceptable. For RTOS projects, follow the RTOS interrupt priority rules carefully.

## 22.3 Common NVIC Mistakes

1. Enabling a peripheral interrupt without implementing the callback logic.
2. Using blocking HAL calls inside interrupt callbacks.
3. Setting all interrupts to the same priority in a complex system.
4. Ignoring DMA interrupts.
5. Misconfiguring USB interrupt priority.
6. Using SysTick incorrectly with an RTOS.

---

# 23. Watchdog Configuration

## 23.1 Independent Watchdog

Go to:

`System Core → IWDG`

IWDG uses LSI and continues running independently.

Use IWDG for:

1. Recovering from firmware lockup.
2. Production systems.
3. Remote embedded devices.

Design rules:

1. Enable IWDG only after firmware initialization is stable.
2. Refresh watchdog from main control flow, not from a high-priority interrupt.
3. Choose timeout longer than worst-case operation.
4. Avoid refreshing the watchdog if a critical task has failed.

## 23.2 Window Watchdog

Go to:

`System Core → WWDG`

WWDG is stricter and detects both late and too-early refresh.

Use WWDG only when timing supervision is required.

For beginner projects, IWDG is simpler and safer.

---

# 24. RTC Configuration

Go to:

`Timers → RTC`

## 24.1 RTC Clock Source

Recommended:

| Clock Source           | Accuracy              |
| ---------------------- | --------------------- |
| LSE 32.768 kHz crystal | Best                  |
| LSI internal RC        | Poorer                |
| HSE divided            | Depends on main clock |

For accurate RTC:

1. Enable LSE in RCC.
2. Use PC14 and PC15 for 32.768 kHz crystal.
3. Configure RTC clock source as LSE.
4. Connect VBAT correctly if backup is required.

## 24.2 RTC Pin Conflicts

| Pin  | Conflict                           |
| ---- | ---------------------------------- |
| PC14 | LSE input or GPIO                  |
| PC15 | LSE output or GPIO                 |
| PC13 | Tamper/RTC-related function or LED |

If LSE is enabled, PC14 and PC15 are not available for general GPIO.

---

# 25. Middleware Configuration

STM32F103C8T6 has limited Flash and RAM, so use middleware selectively.

## 25.1 USB Device Middleware

Common middleware:

| Middleware     | Use                                |
| -------------- | ---------------------------------- |
| USB_DEVICE CDC | Virtual COM port                   |
| USB_DEVICE HID | Keyboard/mouse/custom HID          |
| USB_DEVICE MSC | Mass storage, usually memory-heavy |

CDC is the most common practical USB class for STM32F103C8T6.

## 25.2 FreeRTOS

FreeRTOS can run on STM32F103C8T6, but memory is limited.

Design rules:

1. Keep task count small.
2. Reduce stack sizes carefully.
3. Monitor stack high-water marks.
4. Use a hardware timer as HAL timebase instead of SysTick if required.
5. Avoid large static buffers.
6. Be careful with USB + RTOS due to memory usage.

## 25.3 File Systems

A FATFS project is possible only if external storage is available, but RAM/Flash usage should be reviewed. STM32F103C8T6 is small for heavy middleware combinations.

---

# 26. Blue Pill Board Configuration Notes

Many STM32F103C8T6 projects use a Blue Pill-style board.

## 26.1 Typical Blue Pill Hardware

| Resource | Common Blue Pill Configuration          |
| -------- | --------------------------------------- |
| MCU      | STM32F103C8T6 or clone                  |
| HSE      | 8 MHz crystal                           |
| LSE      | 32.768 kHz crystal, sometimes populated |
| LED      | PC13, active-low                        |
| USB      | PA11/PA12                               |
| BOOT0    | Jumper                                  |
| SWD      | PA13/PA14 header pins                   |
| Voltage  | 3.3 V regulator from 5 V input          |

## 26.2 CubeMX Settings for Blue Pill

| CubeMX Item   | Setting                   |
| ------------- | ------------------------- |
| MCU           | STM32F103C8Tx             |
| SYS Debug     | Serial Wire               |
| RCC HSE       | Crystal/Ceramic Resonator |
| HSE frequency | 8 MHz                     |
| PLL           | ×9                        |
| SYSCLK        | 72 MHz                    |
| APB1          | 36 MHz                    |
| APB2          | 72 MHz                    |
| LED pin       | PC13 GPIO_Output          |
| USART debug   | USART1 PA9/PA10           |
| USB           | Device FS if required     |

## 26.3 Blue Pill Warnings

1. PC13 LED is usually active-low.
2. PC13 is low-current and not suitable for heavy loads.
3. Some Blue Pill boards have incorrect USB D+ pull-up value.
4. Some boards use clone MCUs.
5. Some C8 boards appear to expose more than 64 KB Flash, but official STM32F103C8 should be treated as 64 KB.
6. Always keep SWD available.
7. Use ST-LINK for reliable programming.

---

# 27. Recommended Complete CubeMX Profiles

## 27.1 Minimal Blink Profile

Purpose:

Basic hardware validation.

CubeMX configuration:

| Area       | Setting                   |
| ---------- | ------------------------- |
| SYS        | Serial Wire               |
| RCC        | HSI or HSE                |
| Clock      | Default HSI or 72 MHz HSE |
| GPIO       | PC13 Output               |
| Middleware | None                      |
| DMA        | None                      |
| NVIC       | Default                   |

Use this first to verify:

1. Power.
2. Reset.
3. SWD.
4. Clock startup.
5. GPIO output.

## 27.2 Debug Console Profile

Purpose:

Basic firmware development.

CubeMX configuration:

| Area   | Setting                   |
| ------ | ------------------------- |
| SYS    | Serial Wire               |
| RCC    | HSE 8 MHz                 |
| Clock  | 72 MHz                    |
| USART1 | Asynchronous, PA9/PA10    |
| Baud   | 115200                    |
| GPIO   | PC13 LED                  |
| DMA    | Optional                  |
| NVIC   | USART1 interrupt optional |

Use this for:

1. `printf` debug.
2. Command-line shell.
3. Boot logs.
4. Sensor debug.

## 27.3 Sensor Board Profile

Purpose:

I2C/SPI/ADC sensor acquisition.

CubeMX configuration:

| Function           | Configuration                  |
| ------------------ | ------------------------------ |
| Clock              | HSE 72 MHz                     |
| USART debug        | USART1 PA9/PA10                |
| I2C sensors        | I2C1 PB6/PB7                   |
| SPI sensor/display | SPI1 PA5/PA6/PA7               |
| SPI CS             | PA4 GPIO output                |
| ADC                | ADC1 channels PA0–PA3/PB0/PB1  |
| DMA                | ADC1 DMA circular              |
| Timer              | TIM3 periodic interrupt or PWM |
| Debug              | SWD                            |

Conflict note:

If SPI1 uses PA4–PA7, avoid assigning those pins to ADC.

## 27.4 USB CDC Profile

Purpose:

USB virtual COM device.

CubeMX configuration:

| Function   | Configuration                     |
| ---------- | --------------------------------- |
| Clock      | HSE 8 MHz, PLL 72 MHz, USB 48 MHz |
| USB        | Device FS                         |
| Middleware | USB_DEVICE CDC                    |
| Pins       | PA11 USB_DM, PA12 USB_DP          |
| Debug      | SWD                               |
| UART       | Optional                          |
| CAN        | Use PB8/PB9 remap if required     |

Conflict note:

Do not use default CAN PA11/PA12 when USB is enabled.

## 27.5 CAN Node Profile

Purpose:

CAN communication node.

CubeMX configuration:

| Function        | Configuration              |
| --------------- | -------------------------- |
| Clock           | HSE 72 MHz                 |
| CAN             | Enabled                    |
| CAN pins        | PA11/PA12 or PB8/PB9 remap |
| CAN transceiver | External                   |
| USART debug     | USART1 PA9/PA10            |
| Timer           | Optional periodic status   |
| NVIC            | CAN RX interrupt           |
| Filters         | Required in firmware       |

If USB is also needed:

| Peripheral | Pins          |
| ---------- | ------------- |
| USB        | PA11/PA12     |
| CAN        | PB8/PB9 remap |

---

# 28. Generated Code Rules

## 28.1 User Code Sections

CubeMX generated files contain blocks such as:

`/* USER CODE BEGIN 0 */`
`/* USER CODE END 0 */`

Only place user code inside these blocks unless you deliberately maintain modified generated files.

Safe locations:

1. `USER CODE BEGIN Includes`
2. `USER CODE BEGIN PV`
3. `USER CODE BEGIN 0`
4. `USER CODE BEGIN 2`
5. `USER CODE BEGIN WHILE`
6. `USER CODE BEGIN 4`

Unsafe practice:

1. Editing generated initialization code directly.
2. Editing HAL driver files directly.
3. Putting application logic outside USER CODE blocks.
4. Re-generating code without version control.

## 28.2 Initialization Order in Generated Code

Typical CubeMX HAL initialization order:

1. `HAL_Init()`
2. `SystemClock_Config()`
3. GPIO initialization
4. DMA initialization
5. Peripheral initialization
6. Application user code

Usually:

```c
int main(void)
{
    HAL_Init();
    SystemClock_Config();

    MX_GPIO_Init();
    MX_DMA_Init();
    MX_USART1_UART_Init();
    MX_ADC1_Init();
    MX_SPI1_Init();
    MX_I2C1_Init();

    while (1)
    {
    }
}
```

Design rule:

If a peripheral uses DMA, ensure DMA is initialized before the peripheral starts DMA transfers.

## 28.3 Retaining Custom Drivers

Recommended folder structure:

```text
Core/
  Inc/
  Src/
Drivers/
Middlewares/
User/
  app/
  bsp/
  drivers/
  protocol/
  utils/
```

Keep high-level application logic outside generated files when possible.

---

# 29. Hardware Design Rules Related to CubeMX

CubeMX validates logical pin and clock conflicts, but it does not fully validate hardware quality. The following rules must be checked manually.

## 29.1 Power

Required connections:

| Pin                 | Connection                   |
| ------------------- | ---------------------------- |
| VDD_1, VDD_2, VDD_3 | 3.3 V                        |
| VSS_1, VSS_2, VSS_3 | Ground                       |
| VDDA                | 3.3 V analog supply          |
| VSSA                | Analog ground                |
| VBAT                | VDD if backup battery unused |

Design rules:

1. Place 100 nF capacitors near each VDD/VSS pair.
2. Add bulk capacitance near MCU supply.
3. Filter VDDA if ADC accuracy matters.
4. Do not leave VBAT floating.
5. Use a stable 3.3 V regulator.
6. Check regulator current capacity.
7. Keep ground impedance low.

## 29.2 Reset and Boot

Recommended:

| Signal    | Hardware                                |
| --------- | --------------------------------------- |
| NRST      | Pull-up, reset button, SWD connection   |
| BOOT0     | 10 kΩ pull-down, optional jumper to VDD |
| PB2/BOOT1 | Defined state if boot modes matter      |

Normal boot:

| BOOT0 | BOOT1 | Boot Target |
| ----- | ----- | ----------- |
| 0     | X     | User Flash  |

System bootloader:

| BOOT0 | BOOT1 |
| ----- | ----- |
| 1     | 0     |

## 29.3 Oscillators

HSE design rules:

1. Use correct crystal load capacitors.
2. Keep crystal close to MCU.
3. Keep traces short and symmetric.
4. Avoid routing fast digital signals nearby.
5. Configure CubeMX HSE frequency to match actual crystal.

LSE design rules:

1. Use 32.768 kHz crystal if RTC accuracy is needed.
2. Use correct load capacitors.
3. Keep PC14/PC15 traces short.
4. Avoid using PC14/PC15 as GPIO if LSE is installed.

## 29.4 Analog Inputs

Design rules:

1. Do not exceed 0 V to VDDA input range.
2. Use resistor dividers for higher voltages.
3. Add RC filters if needed.
4. Keep source impedance compatible with ADC sampling time.
5. Avoid sharing analog pins with digital high-speed functions.
6. Calibrate ADC in firmware.

## 29.5 5 V Interfacing

Rules:

1. STM32F103C8T6 is a 3.3 V MCU.
2. Some digital pins may be 5 V tolerant in specific modes.
3. ADC pins are not 5 V tolerant in analog mode.
4. Outputs are 3.3 V only.
5. Use level shifters for uncertain 5 V interfaces.
6. Do not connect 5 V UART TX directly to ADC-capable pins unless verified safe for that mode.

## 29.6 High-Current Loads

Do not directly drive:

1. Motors.
2. Relays.
3. Solenoids.
4. High-power LEDs.
5. Buzzers requiring high current.
6. MOSFET gates with large gate charge at high frequency.

Use:

1. Transistors.
2. MOSFET drivers.
3. Relay drivers.
4. Flyback diodes.
5. Gate resistors.
6. External power stages.

---

# 30. CubeMX Conflict-Resolution Strategy

When CubeMX reports conflicts:

## 30.1 General Method

1. Identify fixed pins first.
2. Decide whether the function can be remapped.
3. Check whether another peripheral instance is available.
4. Move flexible GPIO first.
5. Avoid moving debug pins.
6. Avoid sacrificing HSE/LSE unless acceptable.
7. Regenerate code only after all warnings are understood.

## 30.2 Conflict Priority

Highest-priority pins to preserve:

| Priority | Resource                              |
| -------: | ------------------------------------- |
|        1 | Power, ground, reset                  |
|        2 | SWD debug                             |
|        3 | HSE if required                       |
|        4 | USB pins if USB is required           |
|        5 | ADC pins if analog inputs are limited |
|        6 | CAN remap if USB and CAN coexist      |
|        7 | I2C pins with pull-ups                |
|        8 | SPI/UART                              |
|        9 | Generic GPIO                          |

## 30.3 When to Use Remapping

Use remapping when:

1. USB conflicts with CAN.
2. I2C1 default pins conflict with other functions.
3. USART1 default pins are needed by TIM1.
4. SPI1 default pins are needed as ADC.
5. Timer channels need specific layout routing.

Avoid remapping when it consumes debug pins unless necessary.

---

# 31. Peripheral Conflict Matrix

| Peripheral A | Peripheral B        | Conflict Pins         | Recommended Solution                    |
| ------------ | ------------------- | --------------------- | --------------------------------------- |
| USB          | CAN default         | PA11, PA12            | Remap CAN to PB8/PB9                    |
| SWD          | GPIO                | PA13, PA14            | Keep SWD enabled                        |
| JTAG         | SPI1 remap          | PA15, PB3, PB4        | Use Serial Wire debug                   |
| HSE          | GPIO PD0/PD1        | OSC_IN, OSC_OUT       | Reserve for crystal                     |
| LSE          | GPIO PC14/PC15      | PC14, PC15            | Reserve for RTC crystal                 |
| I2C1 default | USART1 remap        | PB6, PB7              | Use USART1 PA9/PA10                     |
| I2C1 remap   | CAN remap           | PB8, PB9              | Use I2C1 default or CAN default         |
| SPI1 default | ADC                 | PA4–PA7               | Use SPI2 or fewer ADC channels          |
| USART1       | TIM1                | PA9, PA10, PA11, PA12 | Use USART2/3 or different timer         |
| SPI2         | USART3 flow control | PB12–PB14             | Disable flow control or use another SPI |
| TIM4         | I2C1                | PB6–PB9               | Choose timer or I2C function            |
| TIM3         | SPI1                | PA6, PA7              | Choose SPI or PWM/input capture         |
| PC13 LED     | RTC Tamper          | PC13                  | Avoid LED if tamper needed              |

---

# 32. Validation Checklist Before Code Generation

Before pressing **Generate Code**, verify:

## 32.1 Pinout

* [ ] PA13 and PA14 are still SWD.
* [ ] BOOT0 is not treated as GPIO.
* [ ] HSE pins are reserved if HSE is used.
* [ ] LSE pins are reserved if LSE is used.
* [ ] USB pins are not assigned to CAN at the same time.
* [ ] ADC pins are not accidentally assigned to digital outputs.
* [ ] I2C pins have external pull-ups in hardware.
* [ ] Chip-select pins are configured as GPIO output.
* [ ] GPIO labels are meaningful.
* [ ] Unused pins are configured safely.

## 32.2 Clock

* [ ] HSE frequency matches actual board crystal.
* [ ] SYSCLK does not exceed 72 MHz.
* [ ] APB1 does not exceed 36 MHz.
* [ ] APB2 does not exceed 72 MHz.
* [ ] ADC clock does not exceed the allowed limit.
* [ ] USB clock is exactly 48 MHz if USB is enabled.
* [ ] Timer clock values are understood.
* [ ] Flash latency is correctly handled.

## 32.3 Peripherals

* [ ] USART baud rate is correct.
* [ ] I2C speed is correct.
* [ ] SPI mode matches the slave device.
* [ ] ADC channel rank order is correct.
* [ ] Timer prescaler and period are correct.
* [ ] CAN bitrate and sample point are correct.
* [ ] DMA directions and widths are correct.
* [ ] Interrupts are enabled only when required.

## 32.4 Code Generation

* [ ] Toolchain is correct.
* [ ] Firmware package is installed.
* [ ] User code is inside USER CODE blocks.
* [ ] Generated file structure is acceptable.
* [ ] `.ioc` is saved.
* [ ] Project builds after generation.

---

# 33. Validation Checklist After Flashing

After generating, building, and flashing firmware:

## 33.1 Basic Hardware Validation

* [ ] ST-LINK connects reliably.
* [ ] Reset works.
* [ ] BOOT0 low boots user firmware.
* [ ] LED toggles.
* [ ] System clock is stable.
* [ ] USART debug output works.
* [ ] No unexpected reset occurs.

## 33.2 Clock Validation

* [ ] `SystemCoreClock` has expected value.
* [ ] UART baud rate is accurate.
* [ ] Timer interrupt period is correct.
* [ ] PWM frequency is correct.
* [ ] USB enumerates if enabled.
* [ ] MCO output matches expected clock if measured.

## 33.3 Peripheral Validation

* [ ] I2C bus scans expected devices.
* [ ] SPI device responds correctly.
* [ ] ADC reads expected voltage.
* [ ] DMA callbacks occur.
* [ ] CAN receives/transmits frames.
* [ ] USB CDC transmits/receives data.
* [ ] EXTI interrupts trigger correctly.

---

# 34. Common CubeMX Mistakes and Fixes

## 34.1 Losing SWD Access

Cause:

1. Debug set to No Debug.
2. PA13/PA14 used as GPIO.
3. Firmware reconfigures debug pins.

Fix:

1. Set `SYS → Debug → Serial Wire`.
2. Use ST-LINK connect under reset.
3. Pull BOOT0 high and erase firmware if necessary.

## 34.2 USB Not Working

Cause:

1. USB clock not 48 MHz.
2. HSE frequency wrong.
3. D+ pull-up hardware issue.
4. PA11/PA12 conflict.
5. USB middleware not enabled.

Fix:

1. Set HSE 8 MHz, PLL ×9, USB /1.5.
2. Enable USB Device FS.
3. Enable USB_DEVICE middleware.
4. Check board hardware.
5. Avoid CAN default pins.

## 34.3 I2C Not Working

Cause:

1. Missing pull-ups.
2. Wrong address format.
3. Pin conflict with USART1 remap.
4. SDA/SCL swapped.
5. Bus stuck low.

Fix:

1. Add 4.7 kΩ pull-ups.
2. Use 7-bit address.
3. Verify CubeMX pinout.
4. Use logic analyzer.
5. Add bus recovery logic.

## 34.4 ADC Reads Wrong Values

Cause:

1. Pin not configured as analog.
2. ADC clock too high.
3. Sampling time too short.
4. VDDA noisy.
5. Input voltage out of range.
6. Wrong channel rank.

Fix:

1. Set ADC pin analog mode.
2. Use ADC prescaler /6 or /8 at 72 MHz PCLK2.
3. Increase sampling time.
4. Filter analog supply.
5. Check voltage divider.
6. Verify rank sequence.

## 34.5 PWM Frequency Incorrect

Cause:

1. Wrong timer clock assumption.
2. APB timer clock multiplier ignored.
3. PSC/ARR calculation wrong.
4. Wrong channel pin selected.

Fix:

1. Check clock tree.
2. Remember APB prescaler timer multiplier rule.
3. Recalculate PSC/ARR.
4. Verify timer channel pin.

## 34.6 CAN Does Not Communicate

Cause:

1. No CAN transceiver.
2. Wrong bitrate.
3. Wrong sample point.
4. Missing termination.
5. No CAN filter configured.
6. USB/CAN pin conflict.

Fix:

1. Add transceiver.
2. Check PCLK1 and CAN timing.
3. Add 120 Ω termination at bus ends.
4. Configure CAN filters.
5. Use PB8/PB9 remap if USB is used.

---

# 35. Recommended Standard Configuration for STM32F103C8T6

For a general-purpose STM32F103C8T6 project, the following CubeMX configuration is recommended.

## 35.1 System Core

| Item          | Setting                              |
| ------------- | ------------------------------------ |
| SYS Debug     | Serial Wire                          |
| RCC HSE       | Crystal/Ceramic Resonator            |
| HSE frequency | 8 MHz                                |
| RCC LSE       | Enable only if RTC is needed         |
| Timebase      | SysTick for non-RTOS; timer for RTOS |

## 35.2 Clock Tree

| Item           | Setting               |
| -------------- | --------------------- |
| PLL source     | HSE                   |
| PLL multiplier | ×9                    |
| SYSCLK         | 72 MHz                |
| AHB            | 72 MHz                |
| APB1           | 36 MHz                |
| APB2           | 72 MHz                |
| ADC clock      | 12 MHz or 9 MHz       |
| USB clock      | 48 MHz if USB enabled |

## 35.3 Pins

| Function           | Pin                         |
| ------------------ | --------------------------- |
| SWDIO              | PA13                        |
| SWCLK              | PA14                        |
| USART1_TX          | PA9                         |
| USART1_RX          | PA10                        |
| I2C1_SCL           | PB6                         |
| I2C1_SDA           | PB7                         |
| SPI1_SCK           | PA5                         |
| SPI1_MISO          | PA6                         |
| SPI1_MOSI          | PA7                         |
| SPI1_CS            | PA4 GPIO                    |
| LED                | PC13                        |
| ADC                | PA0–PA3, PB0, PB1 as needed |
| USB_DM             | PA11                        |
| USB_DP             | PA12                        |
| CAN_RX if USB used | PB8                         |
| CAN_TX if USB used | PB9                         |

## 35.4 Generated Code Policy

| Item               | Rule                                    |
| ------------------ | --------------------------------------- |
| User code          | Only inside USER CODE blocks            |
| `.ioc`             | Always version-control                  |
| HAL drivers        | Do not edit directly                    |
| Peripheral drivers | Put custom code in separate files       |
| Regeneration       | Build immediately after each generation |

---

# 36. Final Engineering Recommendations

1. Start every project with SWD enabled.
2. Verify LED blink before enabling complex peripherals.
3. Use HSE for USB, CAN, and accurate timing.
4. Keep APB1 at or below 36 MHz.
5. Keep ADC clock at or below the allowed limit.
6. Use PB8/PB9 CAN remap when USB is enabled.
7. Use external pull-ups for I2C.
8. Use GPIO software chip-select for SPI.
9. Use DMA for high-rate ADC, UART, and SPI transfers.
10. Avoid using PA13/PA14 as GPIO.
11. Disable JTAG but keep SWD if PA15/PB3/PB4 are needed.
12. Do not use PC13 for high-current output.
13. Do not use PC14/PC15 as GPIO if LSE is required.
14. Do not use PD0/PD1 as GPIO if HSE is required.
15. Do not assume unofficial Flash size beyond 64 KB.
16. Check ST errata before production design.
17. Treat CubeMX as a configuration generator, not a complete hardware validator.
18. Always verify generated initialization code.
19. Always verify clock output and peripheral behavior on real hardware.
20. Keep the `.ioc` file synchronized with the actual PCB schematic.

---

# 37. Essential Official Documents to Consult

For formal engineering work, consult these ST documents:

1. **DS5319** — STM32F103x8 / STM32F103xB datasheet.
2. **RM0008** — STM32F101xx / STM32F102xx / STM32F103xx / STM32F105xx / STM32F107xx reference manual.
3. **ES096** — STM32F101x8/B, STM32F102x8/B and STM32F103x8/B medium-density device limitations.
4. **AN2586** — Getting started with STM32F10xxx hardware development.
5. **AN2606** — STM32 system memory boot mode.
6. **STM32CubeMX User Manual** — CubeMX configuration and initialization code generation.
7. **STM32CubeF1 HAL documentation** — HAL and LL driver behavior.
8. Target board schematic.
9. External device datasheets.
10. Power, oscillator, USB, CAN, and analog front-end reference designs.

---

# 38. Executive Summary

A robust STM32CubeMX configuration for STM32F103C8T6 should normally use:

1. **SYS Debug = Serial Wire**.
2. **HSE 8 MHz + PLL ×9 = 72 MHz SYSCLK**.
3. **APB1 = 36 MHz, APB2 = 72 MHz**.
4. **ADC clock = 12 MHz or 9 MHz**.
5. **USB clock = 48 MHz if USB is enabled**.
6. **USART1 PA9/PA10 for debug**.
7. **I2C1 PB6/PB7 for sensors**.
8. **SPI1 PA5/PA6/PA7 plus software CS for SPI devices**.
9. **ADC on PA0–PA7/PB0/PB1 as needed**.
10. **CAN remap to PB8/PB9 if USB uses PA11/PA12**.
11. **PC13 only for low-speed, low-current LED use**.
12. **Unused pins set to analog where safe**.
13. **All pin conflicts resolved before code generation**.
14. **All generated code changes kept inside USER CODE blocks**.

The main engineering principle is simple:

**Reserve debug, clock, boot, USB, and analog resources first; then assign flexible communication, timer, and GPIO resources around them.**
