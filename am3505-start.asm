M0    DEFINE     0                 ;режим мультиплексора пина
M1    DEFINE     1
M2    DEFINE     2
M3    DEFINE     3
M4    DEFINE     4
M5    DEFINE     5
M6    DEFINE     6
M7    DEFINE     7
IEN   DEFINE    (1 << 8)           ;включить вход
IDIS  DEFINE    (0 << 8)           ;отключить вход
PTU   DEFINE    (1 << 4)           ;подтяжка к питанию
PTD   DEFINE    (0 << 4)           ;подтяжка к земле
EN    DEFINE    (1 << 3)           ;включить подтяжку
DIS   DEFINE    (0 << 3)           ;отключить подтяжку

StartVector:
    B       SitaraStartUp

WKUP_CM_BASE:
    DCD     0x48004C00
;базовый адрес управления сторожевым таймером 2
WDT2_BASE:
    DCD     0x48314000
;микрокод для отключения сторожевого таймера
WSPR_VALUE_1:
    DCD     0x0000AAAA
WSPR_VALUE_2:
    DCD     0x00005555
;КОНТРОЛЛЕР ДОМЕНОВ ЭНЕРГОПОТРЕБЛЕНИЯ
;регистр состояния и контроля домена энергопотребления ядра
PM_PWSTCTRL_CORE:
    DCD     0x48306AE0
;регистр состояния и контроля домена энергопотребления MPU
PM_PWSTCTRL_MPU:
    DCD     0x483069E0
;базовый регистр OCP_System_Reg_PRM
PM_PWSTCTRL_OCP:
    DCD     0x483068E0
;регистр домена энергопотребления переферийных модулей
PM_PWSTCTRL_PER:
    DCD     0x483070E0
;регистр домена EMU
PM_PWSTCTRL_EMU:
    DCD     0x483071E0
;базовый регистр домена Clock_Control_Reg_PRM
CLOCK_CONTROL_BASE:
    DCD     0x48306D00
;базовый регистр домена GLOBAL_PRM
CONTROL_GLOBAL_BASE:
    DCD     0x48307200
;КОНТРОЛЛЕР УПРАВЛЕНИЯ ТАКТИРОВАНИЕМ И ФАПЧ DLL
VAL_CONST_1:
    DCD     0xFFFFFFFF

SitaraStartUp:
    ;отключить сторожевой таймер
    LDR     r0, WKUP_CM_BASE        ;загрузить в r0 базовый адрес управления WKUP_CM_BASE 0x48004C00
    MOV     r1, #0x20               ;загрузить байт в r1 и включить тактирование WDT
    STR     r1, [r0, #0x10]         ;r1 -> 0x48004C10
    STR     r1, [r0]                ;r1 -> 0x48004C00
    ;отключение сторожевого таймера 1
loop1:
    LDR     r1, [r0, #0x20]         ;r2 <- 0x48004C20
    TST     r1, #0x00000020         ;ждать пока модуль не подключится
    BNE     loop1
    LDR     r0, WDT2_BASE           ;загрузить в r0 базовый адрес управления WDT2
loop2:
    LDR     r1, [r0, #0x14]         ;r2 <- 0x48314014
    TST     r1, #0x01               ;ждать пока не проинициализируется
    BEQ     loop2
    LDR     r1, WSPR_VALUE_1        ;отключить 32кГц сторожевой таймер
    STR     r1, [r0, #0x48]         ;r2 -> 0x48314048
loop3:
    LDR     r1, [r0, #0x34]         ;r2 <- 0x48314034
    TST     r1, #0x10               ;ждать пока не отключится
    BNE     loop3
    LDR     r1, WSPR_VALUE_2        ;отключить 32кГц сторожевой таймер
    STR     r1, [r0, #0x48]         ;r2 -> 0x48314048
loop4:
    LDR     r1, [r0, #0x34]         ;r2 <- 0x48314034
    TST     r1, #0x00000010         ;ждать пока не отключится
    BNE     loop4
    ;____Инициализация контроллера доменов энергопотребления
    ;инициализировать домен ядра
    LDR     r0, PM_PWSTCTRL_CORE
    LDR     r1, [r0]                ;r1 <- 0x48306AE0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0]                ;r1 -> 0x48306AE0
    ;инициализировать домен управляющего модуля
    LDR     r0, PM_PWSTCTRL_MPU
    LDR     r1, [r0]                ;r1 <- 0x483069E0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0]                ;r1 -> 0x483069E0
    ;инициализировать домен OCP_SYSTEM
    LDR     r0, PM_PWSTCTRL_OCP
    LDR     r1, [r0]                ;r1 <- 0x483068E0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0]                ;r1 -> 0x483068E0
    ;инициализировать домен CLOCK_CONTROL
    LDR     r0, CLOCK_CONTROL_BASE
    LDR     r1, [r0,#0xE0]          ;r1 <- 0x48306DE0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0,#0xE0]          ;r1 -> 0x48306DE0
    ;инициализировать домен переферийной шины
    LDR     r0, PM_PWSTCTRL_PER
    LDR     r1, [r0]                ;r1 <- 0x483070E0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0]                ;r1 -> 0x483070E0
    ;инициализировать домен EMU
    LDR     r0, PM_PWSTCTRL_EMU
    LDR     r1, [r0]                ;r1 <- 0x483071E0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0]                ;r1 -> 0x483071E0
    ;инициализировать домен EMU
    LDR     r0, CONTROL_GLOBAL_BASE
    LDR     r1, [r0,#0xE0]          ;r1 <- 0x483072E0
    ORR     r1, r1, #0x00000003
    STR     r1, [r0,#0xE0]          ;r1 -> 0x483072E0
    ;______Инициализация тактирования и ФАПЧ DLL
    ;r0 = CM_PLL_BASE = 0x48004D00 - базовый регистр контроля PLL
    ;r1 = MPU_CM_BASE = 0x48004900
    MOV     r0, #0x48000000         ;r0 = 0x48004D00
    ORR     r0, r0, #0x4D00
    ;перевести периферийные CORES в режим пониженного энергопотребления (DPLL3)
    LDR     r2, [r0]                ;r2 <- 0x48004D00
    BIC     r2, r2, #0x7
    ORR     r2, r2, #0x5
    STR     r2, [r0]                ;r2 -> 0x48004D00
    ;ждать, пока не измениться режим ядра
loop5:
    LDR     r2, [r0, #0x20]         ; r2 <- 0x48004D20
    TST     r2, #0x00000001         ;while( REG(0x48004D20) & 0x00000001 == 1);
    BNE     loop5
    ;перевести MPU в режим пониженного энергопотребления (DPLL1)
    ;r1 = 0x48004900 = MPU_CM_BASE - базовый регистр контроля PLL основного ядра
    MOV     r1, #0x48000000         ;r1 = 0x48004900 = MPU_CM_BASE
    ORR     r1, r1, #0x4900
    LDR     r2, [r1, #0x04]         ;r2 <- 0x48004904
    BIC     r2, r2, #0x7            ; &= ~(0x7 << 0)
    ORR     r2, r2, #0x5            ; |= 0x5 << 0;
    STR     r2, [r1, #0x04]         ;r2 -> 0x48004904
    ;ждать пока не изменится режим
loop6:
    LDR     r2, [r1, #0x24]         ;r2 <- 0x48004924
    TST     r2,  #0x00000001        ;while( REG(0x48004924) & 0x00000001 == 1);
    BNE     loop6
    ;остановить работу первого контроллера переферийной шины (DPLL4)
    LDR     r2, [r0]                ;r2 <- 0x48004D00
    BIC     r2, r2, #(0x7 << 16)    ; &= ~(0x7 << 16)
    ORR     r2, r2, #(0x1 << 16)    ; |= 0x1 << 16
    STR     r2, [r0]                ;r2 -> 0x48004D00
    ;ждать пока не остановится
loop7:
    LDR     r2, [r0, #0x20]         ;r2 <- 0x48004D20
    TST     r2, #0x00000002        ;while( REG(0x48004D20) & 0x00000002 == 1);
    BNE     loop7
    ;остановить работу первого контроллера переферийной шины (DPLL5)
    LDR     r2, [r0]               ;r2 <- 0x48004D00
    BIC     r2, r2, #0x7           ; &= ~(0x7 << 0);
    ORR     r2, r2, #0x1           ; |= 0x1 << 0;
    STR     r2, [r0]               ;r2 -> 0x48004D00
    ;ждать пока не остановится
loop8:
    LDR     r2, [r0, #0x24]        ;r2 <- 0x48004D24
    TST     r2, #0x00000001        ;while( REG(0x48004D24) & 0x00000001 == 1);
    BNE     loop8
    ;сконфигурировать генератор для сигнала входной частоты в 26.00 МГц
    LDR     r2, CLOCK_CONTROL_BASE ;r2 = 0x48306D00
    MOV     r3, #0x3               ;r3 = 0x3
    STR     r3, [r2, #0x40]        ;r3 -> 0x48306D40
    ;установить системный делитель частоты = 1
    LDR     r2,CONTROL_GLOBAL_BASE ;r2 = 0x48307200
    LDR     r3, [r2, #0x70]        ;r3 <- 0x48307270
    BIC     r3, r3, #(0x3 << 6)    ;&= ~(0x3 << 6)
    ORR     r3, r3, #(0x1 << 6)    ;|=  (0x1 << 6)
    STR     r3, [r2, #0x70]        ;r3 -> 0x48307270
    ;разрешить тактирование внутренних шин L3 и L4
    ;r2 = CORE_CM_BASE = 0x48004A00
    MOV     r2, #0x48000000        ;r2 = 0x48000000
    ORR     r2, r2, #0x4A00        ;r2 = 0x48004A00
    MOV     r3, #0x2A              ;r3 = 0x002A
    ORR     r3, r3, #(3 << 8)      ;r3 = 0x032A
    STR     r3, [r2, #0x40]        ;r3 -> 0x48004A40
    ;конфигурирование контроллера DPLL1 тактирования ядра
    ;(26 Mhz * 250)/(12 + 1) = 500 Mhz
    LDR     r2, [r1, #0x40]        ;r2 <- 0x48004940
    BIC     r2, r2, #0x7F
    ORR     r2, r2, #12
    BIC     r2, r2, #(0xFF << 8)
    BIC     r2, r2, #(0x700 << 8)
    ORR     r2, r2, #(250 << 8)
    STR     r2, [r1, #0x40]        ;r2 -> 0x48004940
    ;M2 - MPU_DPLL_CLKOUT (DPLL1 CLKOUTX2): 1000 Mhz
    LDR     r2, [r1, #0x44]        ;r2 <- 0x48004944
    BIC     r2, r2, #0x1F
    ORR     r2, r2, #1
    STR     r2, [r1, #0x44]        ;r2 -> 0x48004944
    ;установить частоту
    LDR     r2, [r1, #0x04]        ;r2 <- 0x48004904
    BIC     r2, r2, #(0xF << 4)
    ORR     r2, r2, #(7 << 4)
    STR     r2, [r1, #0x04]        ;r2 -> 0x48004904
    ;конфигурирование контроллера DPLL3 тактирования переферийных модулей
    ;REF = 26 / 2 = 13 MGz(REF * 166)/(12 + 1) = 166 Mhz
    LDR     r2, [r0,#0x40]         ;r2 <- 0x48004D40
    BIC     r2, r2, #(0x1F << 27)
    ORR     r2, r2, #(1 << 27)
    BIC     r2, r2, #(0xFF << 16)
    BIC     r2, r2, #(0x700 << 16)
    ORR     r2, r2, #(166 << 16)
    BIC     r2, r2, #(0x7F << 8)
    ORR     r2, r2, #(12 << 8)
    STR     r2, [r0,#0x40]         ;r2 -> 0x48004D40
    ;установить частоту
    LDR     r2, [r0]               ;r2 <- 0x48004D00
    BIC     r2, r2, #(0xF << 4)
    ORR     r2, r2, #(7 << 4)
    LDR     r2, [r0]               ;r2 <- 0x48004D00
    ;EMU_CORE_ALWON_CLK -> 83 Mhz
    ;r2 = EMU_CM = 0x48005100
    MOV     r2, #0x48000000        ;r2 = 0x48000000
    ORR     r2, r2, #0x5100        ;r2 = 0x48005100
    LDR     r3,[r2, #0x40]         ;r3 <- 0x48005140
    BIC     r3, r3, #(0x1F << 16)
    ORR     r3, r3, #(2 << 16)
    STR     r3,[r2, #0x40]         ;r3 -> 0x48005140
    ;конфигурирование контроллера DPLL 4
    ;тактирование переферейной шины
    ;(52 Mhz * 216)/(12 + 1) = 864 Mhz
    LDR     r3, [r0, #0x44]        ;r3 <- 0x48004D44
    BIC     r3, r3, #(0xFF << 8)
    BIC     r3, r3, #(0x700 << 8)
    ORR     r3, r3, #(216 << 8)
    BIC     r3, r3, #0x7F
    ORR     r3, r3, #12
    STR     r3, [r0, #0x44]        ;r3 -> 0x48004D44
    ;установить частоту
    LDR     r3, [r0]               ;r3 <- 0x48004D00
    BIC     r3, r3, #(0xF << 20)
    ORR     r3, r3, #(7 << 20)
    STR     r3, [r0]               ;r3 -> 0x48004D00
    ;установить опору в 96 Mhz
    LDR     r3, [r0, #0x48]        ;r3 <- 0x48004D48
    BIC     r3, r3, #0x1F
    ORR     r3, r3, #9
    STR     r3, [r0, #0x48]        ;r3 -> 0x48004D48
    ;установить опору тактирования функций TV в 54 Mhz
    ; r3 = DSS_CM_BASE = 0x48004E00 - базовый регистр видеопроцессора дисплея
    MOV     r3, #0x48000000        ;r3 = 0x48000000
    ORR     r3, r3, #0x4E00        ;r3 = 0x48004E00
    LDR     r4, [r3, #0x40]        ;r4 <- 0x48004E40
    BIC     r4, r4, #(0x1F << 8)
    ORR     r4, r4, #(16 << 8)
    STR     r4, [r3, #0x40]        ;r4 -> 0x48004E40
    ;EMU_PER_ALWON_CLK -> 288 Mhz
    ;r3 как рабочий регистр
    LDR     r3, [r2, #0x40]        ;r3 <- 0x48005140
    BIC     r4, r4, #(0x1F << 24)
    ORR     r4, r4, #(3 << 24)
    STR     r3, [r2, #0x40]        ;r3 -> 0x48005140
    ;заблокировать доступ к контроллеру DPLL3 переф. модулей
    LDR     r3, [r0]               ;r3 <- 0x48004D00
    BIC     r3, r3, #0x7
    ORR     r3, r3, #0x7
    STR     r3, [r0]               ;r3 -> 0x48004D00
    ; r2 как рабочий
    ;ждать пока не перейдет в режим блокировки
loop9:
    LDR     r2, [r0, #0x20]        ;r2 <- 0x48004D20
    TST     r2, #0x00000001        ;while( REG(0x48004D20) & 0x00000001 == 0)
    BEQ     loop9
    ;заблокировать доступ к контроллеру DPLL1 ядра
    LDR     r2, [r1, #0x04]        ;r2 <- 0x48004904
    BIC     r2, r2, #0x7
    ORR     r2, r2, #0x7
    STR     r2, [r1, #0x04]        ;r2 -> 0x48004904
    ;ждать пока не перейдет в режим блокировки
loop10:
    LDR     r2, [r1, #0x24]        ;r2 <- 0x48004924
    TST     r2, #0x00000001        ;while( REG(0x48004924) & 0x00000001 == 0)
    BEQ     loop10
    ;заблокировать доступ к контроллеру DPLL4 переферийной шины и мостов
    LDR     r2, [r0]               ;r2 <- 0x48004D00
    BIC     r2, r2, #(0x7 << 16)
    ORR     r2, r2, #(0x7 << 16)
    STR     r2, [r0]               ;r2 -> 0x48004D00
    ;ждать пока не заблокируется
loop11:
    ;разрешить тактирование всех систем
    LDR     r2, [r0, #0x20]        ;r2 <- 0x48004D20
    TST     r2, #0x00000002        ;while( REG(0x48004D20) & 0x00000002 == 0)
    BEQ     loop11
    LDR     r2, VAL_CONST_1        ;r2 = 0xFFFFFFFF
    MOV     r1, #0x48000000        ;r1 = CORE_CM_BASE = 0x48004A00
    ORR     r1, r1, #0x4A00
    STR     r2, [r1]               ;r2 -> 0x48004A00
    STR     r2, [r1, #0x10]        ;r2 -> 0x48004A10
    STR     r2, [r1, #0x14]        ;r2 -> 0x48004A14
    LDR     r1, WKUP_CM_BASE       ;r1 = 0x48004C00
    STR     r2, [r1]               ;r2 -> 0x48004C00
    STR     r2, [r1, #0x10]        ;r2 -> 0x48004C10
    MOV     r1, #0x48000000
    ORR     r1, r1, #0x5000        ;r1 = 0x48005000 = PER_CM_BASE
    STR     r2, [r1]               ;r2 -> 0x48005000
    STR     r2, [r1, #0x10]        ;r2 -> 0x48005010
    ;r1 = DSS_CM_BASE = 0x48004E00 - базовый регистр видеопроцессора дисплея
    MOV     r1, #0x48000000        ;r1 = 0x48000000
    ORR     r1, r1, #0x4E00        ;r1 = 0x48004E00
    MOV     r2, #0x00000007        ;r1 = 0x00000007
    STR     r2, [r1]               ;r2 -> 0x48004E00
    MOV     r2, #0x00000001        ;r1 = 0x00000001
    STR     r2, [r1,#0x10]         ;r2 -> 0x48004E10
    ;_____Конфигурирование мильтиплексируемых функциональных портов
    ;r0 = CONTROL_PADCONF_BASE = 0x48002000
    MOV     r0, #0x48000000        ;r0 = 0x48000000
    ORR     r0, r0, #0x2000        ;r0 = 0x48002000
    MOV     r1, #(IEN|PTD|DIS|M0)  ;r1 = (1 << 8)|(0 << 4)|(0 << 3)|0
    STRH    r1, [r0, #0x30]        ;SDRC_D0 (r1 -> 0x48002030)
    STRH    r1, [r0, #0x32]        ;SDRC_D1 (r1 -> 0x48002032)
    STRH    r1, [r0, #0x34]        ;SDRC_D2 (r1 -> 0x48002034)
    STRH    r1, [r0, #0x36]        ;SDRC_D3 (r1 -> 0x48002036)
    STRH    r1, [r0, #0x38]        ;SDRC_D4 (r1 -> 0x48002038)
    STRH    r1, [r0, #0x3A]        ;SDRC_D5 (r1 -> 0x4800203A)
    STRH    r1, [r0, #0x3C]        ;SDRC_D6 (r1 -> 0x4800203C)
    STRH    r1, [r0, #0x3E]        ;SDRC_D7 (r1 -> 0x4800203E)
    STRH    r1, [r0, #0x40]        ;SDRC_D8 (r1 -> 0x48002040)
    STRH    r1, [r0, #0x42]        ;SDRC_D9 (r1 -> 0x48002042)
    STRH    r1, [r0, #0x44]        ;SDRC_D10(r1 -> 0x48002044)
    STRH    r1, [r0, #0x46]        ;SDRC_D11(r1 -> 0x48002046)
    STRH    r1, [r0, #0x48]        ;SDRC_D12(r1 -> 0x48002048)
    STRH    r1, [r0, #0x4A]        ;SDRC_D13(r1 -> 0x4800204A)
    STRH    r1, [r0, #0x4C]        ;SDRC_D14(r1 -> 0x4800204C)
    STRH    r1, [r0, #0x4E]        ;SDRC_D15(r1 -> 0x4800204E)
    STRH    r1, [r0, #0x50]        ;SDRC_D16(r1 -> 0x48002050)
    STRH    r1, [r0, #0x52]        ;SDRC_D17(r1 -> 0x48002052)
    STRH    r1, [r0, #0x54]        ;SDRC_D18(r1 -> 0x48002054)
    STRH    r1, [r0, #0x56]        ;SDRC_D19(r1 -> 0x48002056)
    STRH    r1, [r0, #0x58]        ;SDRC_D20(r1 -> 0x48002058)
    STRH    r1, [r0, #0x5A]        ;SDRC_D21(r1 -> 0x4800205A)
    STRH    r1, [r0, #0x5C]        ;SDRC_D22(r1 -> 0x4800205C)
    STRH    r1, [r0, #0x5E]        ;SDRC_D23(r1 -> 0x4800205E)
    STRH    r1, [r0, #0x60]        ;SDRC_D24(r1 -> 0x48002060)
    STRH    r1, [r0, #0x62]        ;SDRC_D25(r1 -> 0x48002062)
    STRH    r1, [r0, #0x64]        ;SDRC_D26(r1 -> 0x48002064)
    STRH    r1, [r0, #0x66]        ;SDRC_D27(r1 -> 0x48002066)
    STRH    r1, [r0, #0x68]        ;SDRC_D28(r1 -> 0x48002068)
    STRH    r1, [r0, #0x6A]        ;SDRC_D29(r1 -> 0x4800206A)
    STRH    r1, [r0, #0x6C]        ;SDRC_D30(r1 -> 0x4800206C)
    STRH    r1, [r0, #0x6E]        ;SDRC_D31(r1 -> 0x4800206E)
    STRH    r1, [r0, #0x70]        ;SDRC_CLK(r1 -> 0x48002070)
    STRH    r1, [r0, #0x72]        ;SDRC_DQS0(r1 -> 0x48002072)
    STRH    r1, [r0, #0x74]        ;SDRC_DQS1(r1 -> 0x48002074)
    STRH    r1, [r0, #0x76]        ;SDRC_DQS2(r1 -> 0x48002076)
    STRH    r1, [r0, #0x78]        ;SDRC_DQS3(r1 -> 0x48002078)
    ;(IDIS | PTD | DIS | M0) = (0 << 8) | (0 << 4) | (0 << 3) | 0
    MOV     r2, #(IDIS|PTD|DIS|M0) ;r2 = 0
    ORR     r0, r0, #0x200         ;r0 = 0x48002200 = CONTROL_PADCONF_CKE
    STRH    r2, [r0, #0x62]        ;r2 -> 0x48002262
    STRH    r2, [r0, #0x64]        ;r2 -> 0x48002262
    BIC     r0, r0, #0x200         ;r0 = 0x48002000 = CONTROL_PADCONF_BASE
    STRH    r2, [r0, #0x7A]        ;GPMC_A1   (r2 -> 0x4800207A)
    STRH    r2, [r0, #0x7C]        ;GPMC_A2   (r2 -> 0x4800207C)
    STRH    r2, [r0, #0x7E]        ;GPMC_A3   (r2 -> 0x4800207E)
    STRH    r2, [r0, #0x80]        ;GPMC_A4   (r2 -> 0x48002080)
    STRH    r2, [r0, #0x82]        ;GPMC_A5   (r2 -> 0x48002082)
    STRH    r2, [r0, #0x84]        ;GPMC_A6   (r2 -> 0x48002084)
    STRH    r2, [r0, #0x86]        ;GPMC_A7   (r2 -> 0x48002086)
    STRH    r2, [r0, #0x88]        ;GPMC_A8   (r2 -> 0x48002088)
    STRH    r2, [r0, #0x8A]        ;GPMC_A9   (r2 -> 0x4800208A)
    STRH    r2, [r0, #0x8C]        ;GPMC_A10  (r2 -> 0x4800208C)
    ; r1 = (IEN | PTD | DIS | M0) = (1 << 8)|(0 << 4)|(0 << 3)|0
    STRH    r1, [r0, #0x8E]        ;GPMC_D0   (r1 -> 0x4800208E)
    STRH    r1, [r0, #0x90]        ;GPMC_D1   (r1 -> 0x48002090)
    STRH    r1, [r0, #0x92]        ;GPMC_D2   (r1 -> 0x48002092)
    STRH    r1, [r0, #0x94]        ;GPMC_D3   (r1 -> 0x48002094)
    STRH    r1, [r0, #0x96]        ;GPMC_D4   (r1 -> 0x48002096)
    STRH    r1, [r0, #0x98]        ;GPMC_D5   (r1 -> 0x48002098)
    STRH    r1, [r0, #0x9A]        ;GPMC_D6   (r1 -> 0x4800209A)
    STRH    r1, [r0, #0x9C]        ;GPMC_D7   (r1 -> 0x4800209C)
    STRH    r1, [r0, #0x9E]        ;GPMC_D8   (r1 -> 0x4800209E)
    STRH    r1, [r0, #0xA0]        ;GPMC_D9   (r1 -> 0x480020A0)
    STRH    r1, [r0, #0xA2]        ;GPMC_D10  (r1 -> 0x480020A2)
    STRH    r1, [r0, #0xA4]        ;GPMC_D11  (r1 -> 0x480020A4)
    STRH    r1, [r0, #0xA6]        ;GPMC_D12  (r1 -> 0x480020A6)
    STRH    r1, [r0, #0xA8]        ;GPMC_D13  (r1 -> 0x480020A8)
    STRH    r1, [r0, #0xAA]        ;GPMC_D14  (r1 -> 0x480020AA)
    STRH    r1, [r0, #0xAC]        ;GPMC_D15  (r1 -> 0x480020AC)
    ORR     r2, r2, #(PTU|EN)      ;r2 = (IDIS|PTU|EN|M0)
    ;(IDIS | PTU | EN | M0) = (0 << 8) | (1 << 4) | (1 << 3) | 0
    STRH    r2, [r0, #0xAE]        ;GPMC_nCS0  (r2 -> 0x480020AE)
    STRH    r2, [r0, #0xB0]        ;GPMC_nCS1  (r2 -> 0x480020B0)
    STRH    r2, [r0, #0xB2]        ;GPMC_nCS2  (r2 -> 0x480020B2)
    STRH    r2, [r0, #0xB4]        ;GPMC_nCS3  (r2 -> 0x480020B4)
    STRH    r2, [r0, #0xB6]        ;GPMC_nCS4  (r2 -> 0x480020B6)
    STRH    r2, [r0, #0xB8]        ;GPMC_nCS5  (r2 -> 0x480020B8)
    STRH    r2, [r0, #0xBA]        ;GPMC_nCS6  (r2 -> 0x480020BA)
    STRH    r2, [r0, #0xBC]        ;GPMC_nCS7  (r2 -> 0x480020BC)
    BIC     r2, r2, #(PTU|EN)      ;r2 = (IDIS|PTD|DIS|M0)
    ;(IDIS | PTD | DIS | M0) = (0 << 8) | (0 << 4) | (0 << 3) | 0
    STRH    r2, [r0, #0xBE]        ;GPMC_CLK      (r2 -> 0x480020BE)
    STRH    r2, [r0, #0xC0]        ;GPMC_nADV_ALE (r2 -> 0x480020C0)
    STRH    r2, [r0, #0xC2]        ;GPMC_nOE      (r2 -> 0x480020C2)
    STRH    r2, [r0, #0xC4]        ;GPMC_nWE      (r2 -> 0x480020C4)
    STRH    r2, [r0, #0xC6]        ;GPMC_nBE0_CLE (r2 -> 0x480020C6)
    STRH    r2, [r0, #0xC8]        ;GPMC_nBE1     (r2 -> 0x480020C8)
    ; r1 = (IEN | PTD | DIS | M0) = (1 << 8)|(0 << 4)|(0 << 3)|0
    STRH    r1, [r0, #0xCA]        ;GPMC_nWP      (r1 -> 0x480020CA)
    ORR     r1, r1, #(PTU|EN)
    ; r1 = (IEN | PTU | EN | M0) = (1 << 8)|(1 << 4)|(1 << 3)|0
    STRH    r1, [r0, #0xCC]        ;GPMC_WAIT0    (r1 -> 0x480020CC)
    STRH    r1, [r0, #0xCE]        ;GPMC_WAIT1    (r1 -> 0x480020CC)
    STRH    r1, [r0, #0xD0]        ;GPMC_WAIT2    (r1 -> 0x480020D0)
    STRH    r1, [r0, #0xD2]        ;GPMC_WAIT3    (r1 -> 0x480020D2)
    ;Здесь инициализировать DSS, если требуется (0x480020D4-0x48002108)
    ;дополнить инициализацию UART!
    ;____Инициализация контроллера DDR для доступа к DDR2 SDRAM
    ;r0 = EMIF4_BASE = 0x6D000000 - Configuration registers SMS address space 3
    MOV     r0, #0x6D000000        ;r0 = 0x6D000000
    MOV     r1, #0x8000
    ORR     r1, r1, #0x46          ;r1 = 0x8046
    STR     r1, [r0, #0xE4]        ;EMIF_DDR_PHY_CTRL_1 (r1 -> 0x6D0000E4)
    STR     r1, [r0, #0xE8]        ;EMIF_DDR_PHY_CTRL_1_SHDW (r1 -> 0x6D0000E8)
    MOV     r1, #0                 ;r1 = 0x0000
    STR     r1, [r0, #0xEC]        ;EMIF_DDR_PHY_CTRL_2 (r1 -> 0x6D0000EC)
    ;OFFSET = 0x60 - 0IODFT Test Logic Global Control Register
    LDR     r1, [r0, #0x60]        ;r1 <- 0x6D000060
    ORR     r1, r1, #0x400
    STR     r1, [r0, #0x60]        ;r1 -> 0x6D000060
loop12:
    LDR     r1, [r0, #0x04]        ;r1 <- 0x6D000004
    TST     r1, #4                 ;while( REG(0x6D000004) & 4 == 0)
    BEQ     loop12
    ;VRD - Debug Normal Mode
    LDR     r1, [r0, #0x60]        ;r1 <- 0x6D000060
    ORR     r1, r1, #1
    STR     r1, [r0, #0x60]        ;r1 -> 0x6D000060
    ;EMIF настройка контроллера - DDR, физики, PLL готово
    ;конфигурируем SDRAM Timing 1 Register
    LDR     r1, EMIF_TIM1_VAL      ;r1 = 0x04448279
    STR     r1, [r0, #0x18]        ;r1 -> 0x6D000018 (EMIF_SDRAM_TIM_1)
    STR     r1, [r0, #0x1C]        ;r1 -> 0x6D00001C (EMIF_SDRAM_TIM_1_SHDW)
    LDR     r1, EMIF_TIM2_VAL      ;r1 = 0x342231CB
    STR     r1, [r0, #0x20]        ;r1 -> 0x6D000020 (EMIF_SDRAM_TIM_2)
    STR     r1, [r0, #0x24]        ;r1 -> 0x6D000024 (EMIF_SDRAM_TIM_2_SHDW)
    MOV     r1, #0x0200
    ORR     r1, r1, #0x17          ;r1 = 0x00000217
    STR     r1, [r0, #0x28]        ;r1 -> 0x6D000028 (EMIF_SDRAM_TIM_3)
    STR     r1, [r0, #0x2C]        ;r1 -> 0x6D00002C (EMIF_SDRAM_TIM_3_SHDW)
    MOV     r1, #0x80000000        ;r1 = 0x80000000
    STR     r1, [r0, #0x38]        ;r1 -> 0x6D000038 (EMIF_PWR_MGMT_CTRL)
    STR     r1, [r0, #0x3C]        ;r1 -> 0x6D00003C (EMIF_PWR_MGMT_CTRL_SHDW)
    MOV     r1, #0x00000500
    ORR     r1, r1, #0xF           ;r1 = 0x0000050F
    STR     r1, [r0, #0x10]        ;r1 -> 0x6D000010 (EMIF_SDRAM_REF_CTRL)
    STR     r1, [r0, #0x14]        ;r1 -> 0x6D000014 (EMIF_SDRAM_REF_CTRL_SHDW)
    LDR     r1, EMIF_CONFIG_VAL    ;r1 = 0x43801432
    STR     r1, [r0, #0x08]        ;r1 -> 0x6D000008 (EMIF_SDRAM_CONFIG)
    ;Вызвать процедуру загрузчика ядра стартовой системы ввода - вывода
    B       BootLoaderSys

EMIF_TIM1_VAL:
    DCD     0x04448279
EMIF_TIM2_VAL:
    DCD     0x342231CB
EMIF_CONFIG_VAL:
    DCD     0x43801432

BootLoaderSys:
    ;Базовый адрес контроллера внешней переферийной шины
    ;r0 = GPMC_BASE = 0x6E000000
    MOV     r0, #0x6E000000        ;r0 = 0x6E000000
    MOV     r1, #0x00000002        ;r1 = 0x00000002
	;Сбросить контрллер
    STR     r1, [r0, #0x10]        ;r1 -> 0x6E000010
    MOV     r1, #12                ;r1 = 12
    ;сформировать задержку в 12 тактов
loop13:
    SUBS    r1, r1, #1
    BNE     loop13
    ;настроить контроллер. Установить тактирование контроллера
    ;отключить счетчик времени ожидания и прерывания
    MOV     r1, #0x00000010        ;r1 = 0x00000010
    STR     r1, [r0, #0x10]        ;r1 -> 0x6E000010
    MOV     r2, #0                 ;r2 = 0
    STR     r2, [r0, #0x40]        ;r2 -> 0x6E000040
    STR     r2, [r0, #0x1C]        ;r2 -> 0x6E00001C
    STR     r1, [r0, #0x50]        ;r1 -> 0x6E000050
    ;сконфигурировать контроллер для работы
    ;с 8 - битной шиной на частоте 166 МГц
    MOV     r1, #(1 << 23)         ;длина страницы 8 байт
    ORR     r1, r1, #(1 << 11)     ;стартовая загрузка с Nand flash
    STR     r1, [r0, #60]          ;GPMC_CONFIG1_CS0 (r1 -> 0x6E000060)
    ;задержка доступа 8 циклов частоты GPMC_FCLK
    MOV     r1, #0x80000           ;r1 = 0x80000
    ORR     r1, r1, #0x800         ;r1 = 0x00080800
    STR     r1, [r0, #0x64]        ;GPMC_CONFIG2_CS0 (r1 -> 0x6E000064)
    ;задержка сигнала nADV 8 циклов частоты GPMC_FCLK
    STR     r1, [r0, #0x68]        ;GPMC_CONFIG3_CS0 (r1 -> 0x6E000068)
    ;задержка сигнала nADV 6 циклов частоты GPMC_FCLK
    MOV     r2, #0x06000000        ;r2 = 0x06000000
    ORR     r2, r2, #0x00000600    ;r2 = 0x06000600
    STR     r2, [r0, #0x6C]        ;GPMC_CONFIG3_CS0 (r2 -> 0x6E00006C)
    ;время цикла чтения = 8 GPMC_FCLK, время цикла записи = 8 GPMC_FCLK
    ORR     r1, r1, #0x8           ;r1 = 0x00080808
    STR     r1, [r0, #0x70]        ;GPMC_CONFIG4_CS0 (r1 -> 0x6E000070)
    ;конфигурирование WrAccessTime, WrDataOnADmuxBus, Cycle2Cycle и BusTurnAround
    MOV     r1, #0x000000cf        ;r1 = 0x000000cf
    ORR     r1, r1, #0x00000300    ;r1 = 0x000003cf
    STR     r1, [r0, #0x74]        ;GPMC_CONFIG5_CS0 (r1 -> 0x6E000074)
    ;конфигурирование карты внешенй памяти и маски декодирования
    MOV     r1, #0x0000005F        ;r1 = 0x0000005F
    ORR     r1, r1, #0x00000F00    ;r1 = 0x00000F5F
    STR     r1, [r0, #0x78]        ;GPMC_CONFIG6_CS0 (r1 -> 0x6E000074)
    MOV     r1, #0x00000010        ;r1 = 0x00000010
    STR     r1, [r0, #0x50]        ;GPMC_CONFIG(r1 -> 0x6E000050)
endloop:
    B       endloop

    END
