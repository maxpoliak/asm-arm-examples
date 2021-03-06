
	;деление содержимого регистра r0 на 16
	MOV	r0, r0, ASR #4


	;суммирование переменных, находящихся в памяти
	SECTION .Test:CODE:NOROOT(5)
	ARM

sub2:
	LDR	r1, =i1			;Загрузить в регистры r1 и r2 ардеса переменных i1 и i2
	LDR	r2, =i2			;загрузить содержимое переменных по адресам r1 и r2 в эти регистры
	LDR	r1, [r1]
	LDR	r2, [r2]
	SUB	r0, r1, r2		;вычесть из одного другое
	LDR	r3, =myData		;результат поместить в массив myData
	STR	r0, [r3, #4]
	BX	lr

	DATA

i1	DCD	72
i2	DCD	19
myData	SPACE	8

	END


	;Пример процедуры, позволяющей установить заданный бит в 32 разрядном слове
	;принимает 2 параметра: число и номер бита, который должет быть установлен в 1
	;возвращает результат операции ИЛИ

	SECTION .Test:CODE:NOROOT(5)
	ARM

;WORD __asmSetBit( WORD val, BYTE bitnum )

__asmSetBit:
	MOV	r2, #1
	MOV	r2, r2, LSL r1		;поместить в регистр r2 его содержимое, сдвинутое влево на значение в r1
	ORR	r0, r0, r2
	BX	lr

;WORD __asmClrBit( WORD val, BYTE bitnum )

__asmClrBit:
	MOV	r2, #1
	MOV	r2, r2, LSL r1		;поместить в регистр r2 его содержимое, сдвинутое влево на значение в r1
	BIC	r0, r0, r2
	BX	lr

;WORD __asmRegSetBit( pWORD* addrReg, BYTE bitnum )

__asmRegSetBit:
	MOV	r2, #1
	MOV	r2, r2, LSL r1		;поместить в регистр r2 его содержимое, сдвинутое влево на значение в r1
	LDR	r3, [r0]		;загрузить в r3 значения регистра или ячейки памяти по адресу в r0
	ORR	r3, r3, r2		;побитовое или
	STR	r3, [r0]		;загрузить полученное значение по адресу r0
	LDR	r0, [r0]		;загрузить в r0 значение по адресу в r0 для проверки его значения
					;и возвратить это значение как результат процедуры
	BX	lr

;WORD __asmRegClrBit( pWORD* addrReg, BYTE bitnum )

__asmClrBit:
	MOV	r2, #1
	MOV	r2, r2, LSL r1		;поместить в регистр r2 его содержимое, сдвинутое влево на значение в r1
	LDR	r3, [r0]		;загрузить в r3 значения регистра или ячейки памяти по адресу в r0
	BIC	r3, r3, r2		;побитовое или-не
	STR	r3, [r0]		;загрузить полученное значение по адресу r0
	LDR	r0, [r0]		;загрузить в r0 значение по адресу в r0 для проверки его значения
					;и возвратить это значение как результат процедуры
	BX	lr

; void __asmSetBitsMask( pWORD* addrVal, WORD bitMask )

__asmSetBitsMask:
	LDR	r2, [r0]
	ORR	r2, r2, r1
	STR	r2, [r0]
	BX	lr

; void __asmClrBitsMask( pWORD* addrVal, WORD bitMask )

__asmClrBitsMask:
	LDR	r2, [r0]
	BIC	r2, r2, r1
	STR	r2, [r0]
	BX	lr

	END


	;процедура, возвращающая значение одного бита в данном слове

	SECTION .Test:CODE:NOROOT(5)
	ARM

; WORD __asmCheckBit( WORD val, BYTE bit)

__asmCheckBit:
	MOV	r2, #1
	MOV	r2, r2, LSL r1
	TST	r0, r2			;Установка флагов N Z в результате операции AND между R0 и R2 (Z = R0 AND R2)
	MOVEQ	r0, #0			;выполнится, если предыдущей командой флаг Z установлен в 0
	MOVNE	r0, #1			;выполнится, если предыдущей командой флаг Z установлен в 1
	BX lr

	;пример процедуры, возвращающей значение одного бита в слове по адресу addrReg
; WORD __asmRegCheckBit( pWORD* addrReg, BYTE bit)

__asmRegCheckBit:
	MOV	r2, #1
	MOV	r2, r2, LSL r1
	LDR	r0, [r0]		;Загрузить в r0 значение, которое хранится по адресу в нем
	TST	r0, r2			;Установка флагов N Z в результате операции
	MOVEQ	r0, #0			;выполнится, если предыдущей командой флаг Z установлен в 1
	MOVNE	r0, #1			;выполнится, если предыдущей командой флаг Z установлен в 0
	BX lr

	END


	;Процедура SetArray позволяет проинициализировать каждый элемент массива целых чисел
	;определенным значением, которое может определяться какой-либо формулой. Первому элементу
	;массива присваивается 0, а каждый последующий элемент примнимает значение на 3 больше предыдущего

	SECTION .Test:CODE:NOROOT(5)
	ARM

; pDWORD* SetArray(void)

SetArray:
	LDR 	r0, =i1			;Сохранить в r0 адрес массива i1
	STMFD 	sp!, {r0}		;Сохранить в стеке r0
	MOV	r1, #32			;Сохранить в r1 количество циклов
	MOV	r3, #0			;Записать начальное значение массива
loopSetArray:
	STR	r3, [r0], #4		;Постиндексация. Сначала r3 загружается по адресу в r0, затем r0 инкр. на #4
	SUBS	r1, r1, #1		;декрементировать счетчик циклов, установив флаг в регистре состояния
	BEQ	exitSetArray		;перейти к метке выхода из подпрограммы	SetArray, если Z = 1
	ADD	r3, r3, #3		;добавить к r3 #3 и результат вернуть в r3
	B	loopSetArray		;перейти в начало цикла
exitSetArray:
	LDMFD	sp!, {r0}
	BX	lr

	DATA
i1	SPACE	128			;выделить 128 байт

	END


	;Процедура, строящая таблицу заданных значений.
	;Параметры: r0 = Addr - стартовый адрес формирования
	;r1 = size - размер массива
	;r2 = val - значение всех слов в массиве
	;возвращает значение последного адреса слова в массиве

	SECTION .Test:CODE:NOROOT(5)
	ARM

;__asm	pDWORD* SetTable ( pDWORD* addr, DWORD size, DWORD val )

SetTable:
loopSetTable:
	STR	r2, [r0], #4		;Загрузить val по адресу в r0, затем получить в r0 адрес следующего лова в таблице
	SUBS	r1, r1, #1		;декрементировать счетчик циклов, установив флаг в регистре состояния
	BEQ	exitSetTable		;выйти из цикла подпрограммы SetTable, если Z = 1 (r1 = 0)
	B	loopSetTable		;перейти в начало подпрограммы
exitSetTable:
	BX	lr

	END




	;_____________________________________________________________________________________________
	;Процедура позоляет выполнить поиск макисмального значения в массиве целых чисел

	SECTION .Test:CODE:NOROOT(5)
	ARM

MaxIntArray:
	LDR 	r0, =i1			;Загрузить в r0 адрес массива i1
	LDR 	r1, =i2			;Загрузить в r1 адрес массива i2 (последнее значение массива)
	SUB	r1, r1, r0		;Вычесть из r0 r1, получив тем самым размер массива в байтах
	MOV	r1, r1, LSR #2		;разделить полученное значение на 4 - количество целых чисел
	SUB	r1, r1, #1		;декрементировать счетчик цикла сравнений
	LDR	r2, [r0]		;Загрузить зачение первого слова массива
nextInt:
	LDR	r3, [r0, #4]!		;Прединдексация. Если стоит в конце !, то изменяется и сам адрес в r0
					;{!} - Признак постфиксной модификации базового регистра. Если присутствует,
					;то значение Rn в конце операции увеличивается или уменьшается  на величину (количество_регистров_в_операции * 4).
	CMP	r2, r3			;выполнить операцию r2 - r3 и выставить флаги N Z C V в соответствии с этой операцией
	MOVLT	r2, r3			;поместить значение r3 в r2, если результат операции CMP - отрицательный, т.е. LT - меньше, чем со знаком
					;N != V ( Минус/отрицательное N = 1 и Нет переполнения V = 0)
	SUBS	r1, r1, #1		;Декрементировать счетчик цикла, если = 0, то выставить флаг Z = 1
	BNE	nextInt			;Выполнить переход, если флаг Z = 0
	MOV	r0, r2			;Возвратить как результат процедуры максимальное число в данном массиве
	BX	lr			;перейти к основной программе

	DATA				;Задать массив
i1	DCD -42, -33, -5, -12, -9, -4, -34, -62
i2	EQU i1 + 32			;задать размер массива

	END


	;Процедура выбирает максимальное значение слова в массиве, заданного по адресу addr

	SECTION .Test:CODE:NOROOT(5)
	ARM

;WORD __MaxWordArray( pWORD* addr, WORD size )

__MaxWordArray:
	SUB	r1, r1, #1		;декрементировать счетчик цикла сравнений
	LDR	r2, [r0]		;Загрузить зачение первого слова массива
loopMaxWordArray:
	LDR	r3, [r0, #4]!		;Загрузить в r3 значение следующего слова в массиве
	CMP	r2, r3			;сравнить r2 и r3 (r2 - r3)
	MOVLT	r2, r3			;поместить значение r3 в r2, если r2 < r3
	SUBS	r1, r1, #1		;Декрементировать счетчик цикла, если = 0, то Z = 1
	BNE	loopMaxWordArray	;Выполнить переход, если флаг Z = 0
	MOV	r0, r2			;Возвратить максимальное число в данном массиве
	BX	lr			;перейти к основной программе

	;Процедура, инвертирующая отрицательные значения массива

;void __RevWordArray( pWORD* addr, WORD size )

__RevWordArray:
startRevWord:
	SUBS	r1, r1, #1		;декрементировать счетчик цикла сравнений
	BEQ	exitRevWord		;если установился 0, то перейти к завершению подпрограммы
	LDR	r2, [r0], #4		;Загрузить зачение первого слова массива, изменив базовый адрес
	CMP	r2, #0			;сравнить r2 и 0 (r2 - 0)
	BGE	startRevWord		;если r2 >= 0,то перейти к проверке следующего значения
	MVN	r2, r2			;выполнить инверсию элемента
	ADD	r2, r2, #1
	STR	r2, [r0, #-4]		;сохранить значение по предыдущему адресу, не меняя базовый
	B	startRevWord		;перейти к проверке следующего значения
exitRevWord:
	BX	lr			;вернуться к основной подпрограмме


	;Процедура, подсчитывающая количаство отрицательных слов

;WORD __CountNegativeWords( pWORD* addr, WORD size )

__CountNegativeWords:
	MOV	r3, #0
startCountNegative:
	SUBS	r1, r1, #1		;декрементировать счетчик цикла сравнений
	BEQ	exitCountNegative	;если установился 0, то перейти к завершению подпрограммы
	LDR	r2, [r0], #4		;Загрузить зачение первого слова массива, изменив базовый адрес
	CMP	r2, #0			;сравнить r2 и 0 (r2 - 0), выставить флаги
	ADDLT	r3, r3, #1		;инкрементировать счетчик отрицательных значений, если r2 < 0
	B	startCountNegative	;перейти к проверке следующего значения
exitCountNegative:
	MOV 	r0, r3			;возвратить количество отрицательных значений
	BX	lr			;вернуться к основной подпрограмме


	;Процедура, инвертирующая отрицательные слова

;void __RevNegativeWord( pWORD* addr )

__RevNegativeWord:
	LDR	r1, [r0]
	CMP	r1, #0
	BGE	exitRevNegative		;если r1 >= 0, то переходим по метке
	MVN	r1, r1			;выполнить инверсию элемента
	ADD	r1, r1, #1
	STR	r1, [r0]		;загрузить по исходному адресу новое значение
exitRevNegative:
	BX	lr

	;Процедура подсчитывающая значения больше заданного

;WORD __CountWordsComp( pWORD* addr, WORD size, WORD comp )

__CountWordsComp:
	STMFD	sp!, {r4}		;сохранить в памяти стека значение r4
loopWordsComp:
	LDR	r3, [r0], #4		;загрузить в регистр r3 значение по адресу r0
	CMP	r3, r2			;сравнить значения и выставить флаги
	ADDGT	r4, r4, #1		;инкрементировать счетчик, если r3 > r2
	SUBS	r1, r1, #1		;декрементировать счетчик цикла сравнений
	BNE	loopWordsComp		;если не 0, то перейти в начало
	MOV	r0, r4			;вернуть значение счетчика r4
	LDMFD	sp!, {r4}		;восстановить памяти стека значение r4
	BX	lr			;вернуться в основную програму

	END


	;Примеры процедур чтения и записи значения регистров

	SECTION .Test:CODE:NOROOT(5)
	ARM

; void __StoreWordReg( WORD addr, WORD val )

__StoreWordReg:
	STR	r1, [r0]	;Сохранить значение слова в регистре r1 по адресу r0 в памяти
	BX	lr		;вернуться к основной программе


; void __StoreHalfWord( WORD addr, HWORD val )

__StoreHalfWord:
	STRH	r1, [r0]	;Сохранить значение полуслова в регистре r1 по адресу r0 в памяти
	BX	lr		;вернуться к основной программе

; void __StoreByte( WORD addr, BYTE val )

__StoreByte:
	STRB	r1, [r0]	;Сохранить значение полуслова в регистре r1 по адресу r0 в памяти
	BX	lr		;вернуться к основной программе

; WORD __LoadWordReg( WORD addr )

__LoadWordReg:
	LDR	r0, [r0]	;загрузить в r0 значение по адресу, который был записан в r0 до этого
	BX	lr		;вернуться к основной программе

; HWORD __LoadHalfWord( WORD addr )

__LoadHalfWord:
	LDRH	r0, [r0]	;загрузить в r0 значение по адресу, который был записан в r0 до этого
	BX	lr		;вернуться к основной программе

; BYTE __LoadByte( WORD addr )

__LoadByte:
	LDRH	r0, [r0]	;загрузить в r0 значение по адресу, который был записан в r0 до этого
	BX	lr		;вернуться к основной программе

	END


	;Пример. Функция, подсчитывающая количество чисел массива, попадающих в заданный диапазон

	SECTION .Test:CODE:NOROOT(5)
	ARM

	;процедура подсчитывает количество значений, попадающих в заданный диапазон
	;параметры: r0 = pArray - указатель на массив данных, r1 = min - нижняя граница поиска
	;r2 = max - верхняя граница поиска, r3 = size - размер массива
	;Возвращает количество найденных значений
; __asm WORD __SeekRange( WORD * pArray, WORD min, WORD max, BYTE size )

__SeekRange:
	STMFD	sp!, {r4 - r5}		;сохранить в стеке регистры осн. программы r4 и r5
	MOV	r5, #0		;обнулить значение найденных элементов
nextWord:
	LDR	r4, [r0], #4	;загрузить с постинкр. значение очередного элемента массива
	CMP 	r4, r1			;сравнить значения в r4 и r1 (r4 - r1) и выставить флаги сост.
	BGE	nextComp	;перейти к nextComp, если число больше или равно, со знаком
decCountSize:
	SUBS	r3, r3, #1		;декрементировать счетчик элементов массива, выставить флаги
	BEQ	exitSeekRange	;если r3 = 0, перейти к exitSeekRange - завершению процедуры
	B 	nextWord
nextComp:
	CMP 	r4, r2			;сравнить зачения в r4 и r1 (r4 - r1) и выставить флаги сост.
	BLE	foundWord	;перейти к foundWord, если число менше или равно, со знаком
	B	decCountSize
foundWord:
	ADD	r5, r5, #1	;если найдено значение, то инкрементировать количество совпадений
	B	decCountSize
exitSeekRange:
	MOV	r0, r5		;вернуть количество найденных элементов
	LDMFD	sp!, {r4 - r5}		;восстановить из стека регистры осн. программы r4 и r5
	BX	lr		;перейти к основной программе



	;пример процедуры, подсчитывающей количество значений, попадающих в заданный диапазон
	;если условия отбора выполняюся, то найденные значения копируются в буфер
	;параметры: r0 = pArray - указатель на массив данных,
	;r1 = pBuf - адрес буфера,
	;r2 = min - нижняя гданица поиска
	;r3 = max - верхняя граница поиска,
	;*sp = size - размер массива.
	;Возвращает количество найденных значений


; __asm WORD __SeekRangeArray( WORD * pArray, WORD * pBuf, WORD min, WORD max, BYTE size )

__SeekRangeArray:
	STMFD	sp!, {r4}			;сохранить в стек регистр r4
						;при сохранении в стек FD = DB, при восстан. FD = IA
	LRD	r4, [sp, #4]		;восстановить из стека в r4 параметр size
	STMFD	sp!, {r5 - r6}			;сохранить в стек регистр r5 и r6
	MOV	r6, #0			;обнулить значение счетной переменной
minRangeArray:
	SUBS	r4, r4, #1			;декрементировать счетчик цикла, выставить флаги
	BEQ	exitRangeArray		;при r4 = 0, выходим из цикла
	LRD	r5, [r0], #4		;загрузить в r5 первое значение массива с постинкрементом
	CMP 	r5, r2				;сравнить зачения в r5 и r2 (r5 - r2) и выставить флаги сост.
	BGE	maxRangeArray		;перейти к nextComp, если число больше или равно, со знаком
maxRangeArray:
	CMP 	r5, r3				;сравнить зачения в r5 и r3 (r5 - r3) и выставить флаги сост.
	ADDLE	r6, r6, #1			;инкрементировать счетчик, если число менше или равно, со знаком
	STRLE	r5, [r1], #4			;сохранить r5 в буферный массив по адресу r1 с постинкрементом
	B	minRangeArray
exitRangeArray:
	MOV	r0, r5				;Возвратить количество совпадений
	LDMFD	sp!, {r4 - r6}			;восстановить из стека раннее сохраненны регистры
	LDMFD	sp!, {r1}			;восстановить из стека в r1 значение size
						;последнее делается, чтобы инкрементировать sp до начального состояния

	;можно использовать и asm(" ADD	    sp, sp, #4 ");



	BX	lr		;вернуться в основную программу


	;Тестовая программа. Позволяет определить, как компилятор распределяет
	;параметры для функции calling convention ARM
	;r0 = param - номер параметра, который должна вернуть функция
	;i1-i8 - параметры
	;процедура возвращает один из параметров i.


; __asm WORD __TestCallProcedure( BYTE param, WORD i1, WORD i2, WORD i3, WORD i4, WORD i5, WORD i6, WORD i7, WORD i8, );

TestCallProcedure:
	CMP	r0, #1			;сравнить значение param с 1, установить флаги
	MOVEQ	r0, r1			;в случае совпадения вернуть i1
	BEQ	exitTestCall

	CMP	r0, #2			;сравнить значение param с 2, установить флаги
	MOVEQ	r0, r2			;в случае совпадения вернуть i2
	BEQ	exitTestCall

	CMP	r0, #3			;сравнить значение param с 3, установить флаги
	MOVEQ	r0, r3			;в случае совпадения вернуть i3
	BEQ	exitTestCall

	CMP	r0, #4			;сравнить значение param с 4, установить флаги
	LDREQ	r0, [sp, #16]		;восстановить из стека i4 в r0
	BEQ	exitTestCall

	CMP	r0, #5			;сравнить значение param с 5, установить флаги
	LDREQ	r0, [sp, #12]		;восстановить из стека i5 в r0
	BEQ	exitTestCall

	CMP	r0, #6			;сравнить значение param с 6, установить флаги
	LDREQ	r0, [sp, #8]		;восстановить из стека i6 в r0
	BEQ	exitTestCall

	CMP	r0, #7			;сравнить значение param с 7, установить флаги
	LDREQ	r0, [sp, #4]		;восстановить из стека i7 в r0
	BEQ	exitTestCall

	CMP	r0, #8			;сравнить значение param с 8, установить флаги
	LDREQ	r0, [sp]		;восстановить из стека i8 в r0
	BEQ	exitTestCall

	MOV	r0, #0			;Вернуть 0, если непрвильно задан param
exitTestCall:
	BX	lr			;Выйти из процедуры теста в основную программу



	;Пример реализации оператора switch на низком уровне
	;принимает параметр сравнения val = r0
	;возвращает адрес строчной константы

	SECTION .Test:CODE:NOROOT(5)
	ARM

; __asm WORD __switch( WORD val );

__switch:
	CMP		r0, #1			;case 1:
	BEQ		label_1			;если содержимое r0 = 1 перейти к label_1.
	CMP		r0, #2			;Сравнить содержимое r0 c val = 2, case 2:
	BEQ		label_2			;если содержимое r0 = 2 перейти к label_2.
	CMP		r0, #3			;Сравнить содержимое r0 c val = 3, case 3:
	BEQ		label_3			;если содержимое r0 = 3 перейти к label_3.
	LDR		r0, = data4		;в случае отсутствия совпадений - default:
	B		exitswitch
label_1:
	LDR		r0, = data1		;возвратить адрес строковой константы
label_2:
	LDR		r0, = data2
label_3:
	LDR	r0, = data3
exitswitch:
	BX	lr

	DATA
data1	DCB	" select 1 ",  0
data2	DCB	" select 2 ",  0
data3	DCB	" select 3 ",  0
data4	DCB	" nothing select ",  0

	END


	;В программах используем команду STR с модификаторами
	;IA - (increment after). В качестве первого адреса берется значение из базового
	;регистра Rn. Последующие адреса получаются увеличением предыдущего на  четыре.
	;Таким образом формируются адреса для всех загружаемых или сохраняемых регистров.
	;IB - (increment before). В качестве первого адреса берется значение Rn+4.
	;Последующие адреса получаются увеличением предыдущего на  четыре.
	;DA - (decrement after). В качестве первого адреса берется значение из базового
	;регистра Rn. Последующие адреса получаются уменьшением предыдущего на  четыре.
	;DB - (decrement before). В качестве первого адреса берется значение Rn-4.
	;Последующие адреса получаются уменьшением предыдущего на  четыре.
	;FD - сохраниение регистров в стек сдвигом указателя стека вниз или вверх, в
	;зависимости от операции (либо копирование в стек, либо восстановление из него)

	;Процедура выполняет сравнения строковой константы
	;полученного сообщения с системным и, в случае совпадения,
	;возвращает 1, в ином случае 0
	; принимает параметры: r0 = pmessage - указатель на проверяемое сообщение
	; r1 = pcontrol - указатель на системное, контрольное сообщение

	SECTION .Test:CODE:NOROOT(5)
	ARM

;__asm WORD MessageAnalyse ( MESSAGE * pmessage, MESSAGE * pcontrol) nextByteAnalyse:

__MessageAnalyse:
	PUSH	{r3}
	LDRB	r2,	[r0], #1		; загрузить в r2 значение байта проверяемой строки
	LDRB	r3,	[r1], #1		; загрузить в r3 значение байта контрольной строки
	CMP	r3, r2			; сравнить байты строк, если != - errMessageAnalyse
	BNE	errMessageAnalyse
	CMP	r3, #0			; сравнить значение с 0, если =, завершить процедуру
	BEQ	exitMessageAnalyse
	B	__MessageAnalyse	; переход в начало цикла
errMessageAnalyse:
	MOV	r0, #0			; если != - вернуть ошибку и завершить процедуру
	POP	{r3}
	BX	lr
exitMessage Analyse:
	MOV	r0, #1			; вернуть 1 и перейти к основной программе
	POP	{r3}
	BX	lr


	;Процедура, работающая со структурой данных:
	;typedef struct
	;{
	;	WORD	 size;
	;	WORD	 arraytest[SIZE];
	;	WORD	 arrayresult[SIZE];
	;} TESTARRAY;
	; Процедура обрабатывает массив в соответствии с параметром mode
	; pArray - указатель на структуру с тегом TESTARRAY
	; mode = 1 - копирует в массив значение выше max
	; mode = 2 - копирует в массив значение ниже min

; __asm MESSAGE * ProcessingTestArray( WORD mode, TESTARRAY * pArray, WORD min, WORD max);

__ProcessingTestArray:
	PUSH	{r4 - r7}			;сохранить в стеке r4 - r7
	LDR	r4, [r1], #4		;загрузить в	r2 	pArray -> size
	MOV	r5, r4, LSL #2		;копируем содержимое r2 в r3, умножив на 4.
	ADD	r5, r5, r1		;вычислить адрес pArray -> arrayresult[0]
	CMP	r0, #1			;Сравнить с 1 параметр типа операции mode
	BEQ	maxTestArray		;если r0 = 1, то переходим к подпроцедуре maxTestArray
	CMP	r0, #2			;Сравнить с 1 параметр типа операции mode
	BEQ	minTestArray		;если r0 = 1, то переходим к подпроцедуре maxTestArray
	LDR	r0, =errMaxTest		;вернуть адрес строковой переменной ОШИБОЧНОГО ПАРАМЕТРА

endProcessingTestArray:
	POP	{r4 - r7}		;восстановить из стека r4 - r7
	BX	lr

maxTestArray:
	PUSH	{r0,r4}				;скопировать адрес масива и его размер в стек
	MOV	r0, r5			;скопировать в r0 адресс pArray -> arrayresult[0]
	MOV	r1, r4			;размер массива в r1
	BL	__nullTestArray		;вызвать процедуру очистки значений массива arrayresult[SIZE]
	POP	{r0,r4}			;восстановить регистры из стека
	LDR	r6, [r1], #4		;загрузить значение pArray -> arraytest в r4
	CMP	r6, r3			;сравнить r6 с r3, выставить флаги состояния
	STRGT	r6, [r5], #4		;если удовлетворяет заданным условиям, записать по pArray -> arrayresult
	SUBS	r4, r4, #1		;декрементируем переменную цикла, если r4 = 0, завершить процедуру
	LDREQ	r0, =stringMaxTest	;Вернуть сообщение о завершении соответствующей процедуры
	BEQ	endProcessingTestArray
	B	maxTestArray
minTestArray:
	PUSH	{r0,r4}			;скопировать адрес масива и его размер в стек
	MOV	r0, r5			;скопировать в r0 адресс pArray -> arrayresult[0]
	MOV	r1, r4			;размер массива в r1
	BL	__nullTestArray		;вызвать процедуру очистки значений массива arrayresult[SIZE]
	POP	{r0,r4}			;восстановить регистры из стека
	LDR	r6, [r1], #4		;загрузить значение pArray -> arraytest в r4
	CMP	r6, r3			;сравнить r6 с r3, выставить флаги состояния
	STRLT	r6, [r5], #4		;если удовлетворяет заданным условиям, записать по pArray -> arrayresult
	SUBS	r4, r4, #1		;декрементируем переменную цикла, если r4 = 0, завершить процедуру
	LDREQ	r0, =stringMinTest	;Вернуть сообщение о завершении соответствующей процедуры
	BEQ	endProcessingTestArray
	B	minTestArray		;перейти в начало цикла

; __asm void __NullTestArray( pWORD * pArrayResult, WORD size)

__NullTestArray:
	PUSH	{r2}			;сохранить в стеке r2
	MOV	r2, #0			;записать в r2 нулевое значение

loopNullTest:
	STR	r2, [r0], #4		;очистить очередное слово в массиве
	SUBS	r1, r1, #1		;декрементировать счетчик цикла
	BEQ	endNullTest		;если r1 = 0, завершаем процедуру
	B 	loopNullTest		;если нет, перейти в начало цикла

endNullTest:
	POP	{r2}			;восстановить из стека r2
	BX	lr			;вернуться в основную программу

	DATA

errMaxTest	DCB		"Parametrs error" , 0
stringMaxTest	DCB		"Array of maximum words" , 0
stringMinTest	DCB		"Array of minimum words" , 0

	END
