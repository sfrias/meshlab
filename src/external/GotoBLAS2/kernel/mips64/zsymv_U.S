/*********************************************************************/
/*                                                                   */
/*             Optimized BLAS libraries                              */
/*                     By Kazushige Goto <kgoto@tacc.utexas.edu>     */
/*                                                                   */
/* Copyright (c) The University of Texas, 2009. All rights reserved. */
/* UNIVERSITY EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES CONCERNING  */
/* THIS SOFTWARE AND DOCUMENTATION, INCLUDING ANY WARRANTIES OF      */
/* MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE,              */
/* NON-INFRINGEMENT AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY  */
/* THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF     */
/* TRADE. NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO   */
/* THE USE OF THE SOFTWARE OR DOCUMENTATION.                         */
/* Under no circumstances shall University be liable for incidental, */
/* special, indirect, direct or consequential damages or loss of     */
/* profits, interruption of business, or related expenses which may  */
/* arise from use of Software or Documentation, including but not    */
/* limited to those resulting from defects in Software and/or        */
/* Documentation, or loss or inaccuracy of data of any kind.         */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"

#define M	$4
#define A	$7
#define LDA	$8
#define X	$9
#define INCX	$10
#define Y	$11
#define INCY	$5
#define BUFFER	$6

#define XX	$12
#define YY	$13

#define I	$14
#define IS	$15

#define AO1	$16
#define AO2	$17

#define Y1	$18
#define TEMP	$19

#define ALPHA_R	$f13
#define ALPHA_I	$f14

#define a1	$f0
#define a2	$f1
#define a3	$f2
#define a4	$f3
#define a5	$f4
#define a6	$f5
#define a7	$f6
#define a8	$f7

#define alpha1	$f8
#define alpha2	$f9
#define alpha3	$f10
#define alpha4	$f11

#define x1	$f12
#define x2	$f15
#define x3	$f16
#define x4	$f17

#define xsum1	$f18
#define xsum2	$f19
#define xsum3	$f20
#define xsum4	$f21

#define ysum1	$f22
#define ysum2	$f23
#define ysum3	$f24
#define ysum4	$f25

#ifndef HEMV
#define ADD1	NMSUB
#define ADD2	MADD
#else
#define ADD1	MADD
#define ADD2	NMSUB
#endif
	
	PROLOGUE
	
	LDARG	INCY,    0($sp)
	LDARG	BUFFER,  8($sp)
#ifdef __64BIT__
	daddiu	$sp, $sp, -64
#else
	daddiu	$sp, $sp, -80
#endif

	SDARG	$16,   0($sp)
	dsll	LDA,  LDA,  ZBASE_SHIFT
	SDARG	$17,   8($sp)
	dsll	INCX, INCX, ZBASE_SHIFT
	SDARG	$18,  16($sp)
	dsll	INCY, INCY, ZBASE_SHIFT
	SDARG	$19,  24($sp)
	nop

	sdc1	$f24, 32($sp)
	sdc1	$f25, 40($sp)

#ifndef __64BIT__
	sdc1	$f20, 48($sp)
	sdc1	$f21, 56($sp)
	sdc1	$f22, 64($sp)
	sdc1	$f23, 72($sp)
#endif

	blez	M, .L999
	li	IS, 2 * SIZE

	beq	IS, INCX, .L05
	move	Y1, Y

	dsra	I,  M, 2
	move	XX, X

	blez	I, .L02
	move	X,  BUFFER
	.align 3

.L01:
	LD	a1, 0 * SIZE(XX)
	LD	a2, 1 * SIZE(XX)
	daddu	XX, XX, INCX
	LD	a3, 0 * SIZE(XX)
	LD	a4, 1 * SIZE(XX)
	daddu	XX, XX, INCX
	LD	a5, 0 * SIZE(XX)
	LD	a6, 1 * SIZE(XX)
	daddu	XX, XX, INCX
	LD	a7, 0 * SIZE(XX)
	LD	a8, 1 * SIZE(XX)
	daddu	XX, XX, INCX

	ST	a1, 0 * SIZE(BUFFER)
	ST	a2, 1 * SIZE(BUFFER)
	ST	a3, 2 * SIZE(BUFFER)
	ST	a4, 3 * SIZE(BUFFER)
	ST	a5, 4 * SIZE(BUFFER)
	ST	a6, 5 * SIZE(BUFFER)
	ST	a7, 6 * SIZE(BUFFER)
	ST	a8, 7 * SIZE(BUFFER)

	daddiu	I, I, -1

	bgtz	I, .L01
	daddiu	BUFFER, BUFFER, 8 * SIZE
	.align 3

.L02:
	andi	I,  M, 3
	blez	I, .L05
	NOP
	.align 3

.L03:
	LD	a1, 0 * SIZE(XX)
	LD	a2, 1 * SIZE(XX)
	daddu	XX, XX, INCX

	ST	a1, 0 * SIZE(BUFFER)
	ST	a2, 1 * SIZE(BUFFER)
	daddiu	I, I, -1

	bgtz	I, .L03
	daddiu	BUFFER, BUFFER, 2 * SIZE
	.align 3

.L05:
	beq	IS, INCY, .L10
	daddiu	BUFFER, BUFFER, 255

	li	TEMP, -256
	and	BUFFER, BUFFER, TEMP

	dsra	I,  M, 2
	move	Y1, BUFFER

	blez	I, .L07
	move	YY, Y
	.align 3

.L06:
	LD	a1, 0 * SIZE(YY)
	LD	a2, 1 * SIZE(YY)
	daddu	YY, YY, INCY
	LD	a3, 0 * SIZE(YY)
	LD	a4, 1 * SIZE(YY)
	daddu	YY, YY, INCY
	LD	a5, 0 * SIZE(YY)
	LD	a6, 1 * SIZE(YY)
	daddu	YY, YY, INCY
	LD	a7, 0 * SIZE(YY)
	LD	a8, 1 * SIZE(YY)
	daddu	YY, YY, INCY

	ST	a1, 0 * SIZE(BUFFER)
	ST	a2, 1 * SIZE(BUFFER)
	ST	a3, 2 * SIZE(BUFFER)
	ST	a4, 3 * SIZE(BUFFER)
	ST	a5, 4 * SIZE(BUFFER)
	ST	a6, 5 * SIZE(BUFFER)
	ST	a7, 6 * SIZE(BUFFER)
	ST	a8, 7 * SIZE(BUFFER)
	daddiu	I, I, -1

	bgtz	I, .L06
	daddiu	BUFFER, BUFFER, 8 * SIZE
	.align 3

.L07:
	andi	I,  M, 3
	blez	I, .L10
	NOP
	.align 3

.L08:
	LD	a1, 0 * SIZE(YY)
	LD	a2, 1 * SIZE(YY)
	daddu	YY, YY, INCY

	ST	a1, 0 * SIZE(BUFFER)
	ST	a2, 1 * SIZE(BUFFER)
	daddiu	I, I, -1

	bgtz	I, .L08
	daddiu	BUFFER, BUFFER, 2 * SIZE
	.align 3

.L10:
	slti	TEMP, M, 2
	nop

	bgtz	TEMP, .L20
	li	IS, 0
	.align 3

.L11:
	dsll	TEMP,  IS,  ZBASE_SHIFT
	daddu	TEMP, X, TEMP

	LD	x1, 0 * SIZE(TEMP)
	LD	x2, 1 * SIZE(TEMP)
	LD	x3, 2 * SIZE(TEMP)
	LD	x4, 3 * SIZE(TEMP)

	MTC	$0,  xsum1
	MTC	$0,  xsum2
	MTC	$0,  xsum3
	MTC	$0,  xsum4

	MUL	alpha1, ALPHA_R, x1
	move	AO1, A
	MUL	alpha2, ALPHA_I, x1
	dsra	I,  IS, 1
	MUL	alpha3, ALPHA_R, x3
	daddu	AO2, A,   LDA
	MUL	alpha4, ALPHA_I, x3
	daddu	A,   AO2, LDA

	NMSUB	alpha1, alpha1, ALPHA_I, x2
	move	XX, X
	MADD	alpha2, alpha2, ALPHA_R, x2
	move	YY, Y1
	NMSUB	alpha3, alpha3, ALPHA_I, x4
	MADD	alpha4, alpha4, ALPHA_R, x4

	blez	I, .L15
	daddiu	I, I, -1

	LD	x1, 0 * SIZE(XX)
	LD	x2, 1 * SIZE(XX)
	LD	x4, 3 * SIZE(XX)

	LD	a1, 0 * SIZE(AO1)
	LD	a2, 1 * SIZE(AO1)
	LD	a3, 2 * SIZE(AO1)
	LD	a4, 3 * SIZE(AO1)

	LD	a5, 0 * SIZE(AO2)
	LD	a6, 1 * SIZE(AO2)
	LD	a7, 2 * SIZE(AO2)
	LD	a8, 3 * SIZE(AO2)

	LD	ysum1, 0 * SIZE(YY)

	blez	I, .L13
	LD	ysum2, 1 * SIZE(YY)
	.align	3

.L12:
	MADD	ysum1, ysum1, alpha1, a1
	LD	ysum3, 2 * SIZE(YY)
	MADD	ysum2, ysum2, alpha2, a1
	LD	ysum4, 3 * SIZE(YY)
	MADD	xsum1, xsum1, x1, a1
	LD	a8, 3 * SIZE(AO2)
	MADD	xsum2, xsum2, x2, a1
	LD	a1, 4 * SIZE(AO1)

	MADD	ysum3, ysum3, alpha1, a3
	LD	x3, 2 * SIZE(XX)
	MADD	ysum4, ysum4, alpha2, a3
	daddiu	I, I, -1
	MADD	xsum3, xsum3, x1, a5
	MADD	xsum4, xsum4, x2, a5

	NMSUB	ysum1, ysum1, alpha2, a2
	MADD	ysum2, ysum2, alpha1, a2
	ADD1	xsum1, xsum1, x2, a2
	daddiu	AO2, AO2, 4 * SIZE
	ADD2	xsum2, xsum2, x1, a2
	LD	a2, 5 * SIZE(AO1)

	NMSUB	ysum3, ysum3, alpha2, a4
	MADD	ysum4, ysum4, alpha1, a4
	ADD1	xsum3, xsum3, x2, a6
	LD	x2, 5 * SIZE(XX)
	ADD2	xsum4, xsum4, x1, a6
	LD	x1, 4 * SIZE(XX)

	MADD	ysum1, ysum1, alpha3, a5
	MADD	ysum2, ysum2, alpha4, a5
	MADD	xsum1, xsum1, x3, a3
	LD	a5, 0 * SIZE(AO2)
	MADD	xsum2, xsum2, x4, a3
	LD	a3, 6 * SIZE(AO1)

	MADD	ysum3, ysum3, alpha3, a7
	MADD	ysum4, ysum4, alpha4, a7
	MADD	xsum3, xsum3, x3, a7
	daddiu	AO1, AO1, 4 * SIZE
	MADD	xsum4, xsum4, x4, a7
	LD	a7, 2 * SIZE(AO2)

	NMSUB	ysum1, ysum1, alpha4, a6
	daddiu	XX,  XX,  4 * SIZE
	MADD	ysum2, ysum2, alpha3, a6
	LD	a6, 1 * SIZE(AO2)
	ADD1	xsum1, xsum1, x4, a4
	daddiu	YY,  YY,  4 * SIZE
	ADD2	xsum2, xsum2, x3, a4
	LD	a4, 3 * SIZE(AO1)

	NMSUB	ysum3, ysum3, alpha4, a8
	ST	ysum1,-4 * SIZE(YY)
	MADD	ysum4, ysum4, alpha3, a8
	ST	ysum2,-3 * SIZE(YY)

	LD	ysum1, 0 * SIZE(YY)
	LD	ysum2, 1 * SIZE(YY)

	ADD1	xsum3, xsum3, x4, a8
	LD	x4, 3 * SIZE(XX)
	ADD2	xsum4, xsum4, x3, a8

	ST	ysum3,-2 * SIZE(YY)
	bgtz	I, .L12
	ST	ysum4,-1 * SIZE(YY)
	.align 3

.L13:
	MADD	ysum1, ysum1, alpha1, a1
	LD	ysum3, 2 * SIZE(YY)
	MADD	ysum2, ysum2, alpha2, a1
	LD	ysum4, 3 * SIZE(YY)
	MADD	xsum1, xsum1, x1, a1
	LD	a8, 3 * SIZE(AO2)
	MADD	xsum2, xsum2, x2, a1
	LD	x3, 2 * SIZE(XX)

	MADD	ysum3, ysum3, alpha1, a3
	MADD	ysum4, ysum4, alpha2, a3
	MADD	xsum3, xsum3, x1, a5
	MADD	xsum4, xsum4, x2, a5

	NMSUB	ysum1, ysum1, alpha2, a2
	MADD	ysum2, ysum2, alpha1, a2
	ADD1	xsum1, xsum1, x2, a2
	ADD2	xsum2, xsum2, x1, a2

	NMSUB	ysum3, ysum3, alpha2, a4
	MADD	ysum4, ysum4, alpha1, a4
	ADD1	xsum3, xsum3, x2, a6
	ADD2	xsum4, xsum4, x1, a6

	MADD	ysum1, ysum1, alpha3, a5
	MADD	ysum2, ysum2, alpha4, a5
	MADD	xsum1, xsum1, x3, a3
	MADD	xsum2, xsum2, x4, a3

	MADD	ysum3, ysum3, alpha3, a7
	MADD	ysum4, ysum4, alpha4, a7
	MADD	xsum3, xsum3, x3, a7
	MADD	xsum4, xsum4, x4, a7

	NMSUB	ysum1, ysum1, alpha4, a6
	MADD	ysum2, ysum2, alpha3, a6
	ADD1	xsum1, xsum1, x4, a4
	ADD2	xsum2, xsum2, x3, a4

	NMSUB	ysum3, ysum3, alpha4, a8
	daddiu	XX,  XX,  4 * SIZE
	MADD	ysum4, ysum4, alpha3, a8
	daddiu	YY,  YY,  4 * SIZE
	ADD1	xsum3, xsum3, x4, a8
	daddiu	AO1, AO1, 4 * SIZE
	ADD2	xsum4, xsum4, x3, a8
	daddiu	AO2, AO2, 4 * SIZE

	ST	ysum1, -4 * SIZE(YY)
	ST	ysum2, -3 * SIZE(YY)
	ST	ysum3, -2 * SIZE(YY)
	ST	ysum4, -1 * SIZE(YY)
	.align 3

.L15:
	dsll	TEMP,  IS,  ZBASE_SHIFT
	daddu	TEMP, Y1, TEMP

	LD	ysum1, 0 * SIZE(TEMP)
	LD	ysum2, 1 * SIZE(TEMP)
	LD	ysum3, 2 * SIZE(TEMP)
	LD	ysum4, 3 * SIZE(TEMP)

	LD	a1, 0 * SIZE(AO1)
	LD	a2, 1 * SIZE(AO1)
	LD	a3, 2 * SIZE(AO1)
	LD	a4, 3 * SIZE(AO1)

	LD	a5, 0 * SIZE(AO2)
	LD	a6, 1 * SIZE(AO2)
	LD	a7, 2 * SIZE(AO2)
	LD	a8, 3 * SIZE(AO2)

	MOV	x1, xsum1
	MOV	x2, xsum2
	MOV	x3, xsum3
	MOV	x4, xsum4

	MUL	xsum1, ALPHA_R, xsum1
	MUL	xsum2, ALPHA_R, xsum2
	MUL	xsum3, ALPHA_R, xsum3
	MUL	xsum4, ALPHA_R, xsum4

	NMSUB	xsum1, xsum1, ALPHA_I, x2
	MADD	xsum2, xsum2, ALPHA_I, x1
	NMSUB	xsum3, xsum3, ALPHA_I, x4
	MADD	xsum4, xsum4, ALPHA_I, x3

	MADD	xsum1, xsum1, alpha1, a1
	MADD	xsum2, xsum2, alpha2, a1
	MADD	xsum3, xsum3, alpha1, a5
	MADD	xsum4, xsum4, alpha2, a5

#ifndef HEMV
	ADD1	xsum1, xsum1, alpha2, a2
	ADD2	xsum2, xsum2, alpha1, a2
#endif
	ADD1	xsum3, xsum3, alpha2, a6
	ADD2	xsum4, xsum4, alpha1, a6

	MADD	xsum1, xsum1, alpha3, a5
	MADD	xsum2, xsum2, alpha4, a5
	MADD	xsum3, xsum3, alpha3, a7
	MADD	xsum4, xsum4, alpha4, a7

	NMSUB	xsum1, xsum1, alpha4, a6
	MADD	xsum2, xsum2, alpha3, a6
#ifndef HEMV
	ADD1	xsum3, xsum3, alpha4, a8
	ADD2	xsum4, xsum4, alpha3, a8
#endif

	ADD	ysum1, ysum1, xsum1
	ADD	ysum2, ysum2, xsum2
	ADD	ysum3, ysum3, xsum3
	ADD	ysum4, ysum4, xsum4

	ST	ysum1, 0 * SIZE(TEMP)
	ST	ysum2, 1 * SIZE(TEMP)
	ST	ysum3, 2 * SIZE(TEMP)
	ST	ysum4, 3 * SIZE(TEMP)

	daddiu	TEMP, IS, 4
	slt	TEMP, M, TEMP

	beqz	TEMP, .L11
	daddiu	IS, IS, 2
	.align 3

.L20:
	andi	TEMP, M, 1
	nop
	blez	TEMP, .L900
	nop

	dsll	TEMP,  IS,  ZBASE_SHIFT
	daddu	TEMP, X, TEMP

	LD	x1, 0 * SIZE(TEMP)
	LD	x2, 1 * SIZE(TEMP)

	MTC	$0,  xsum1
	MTC	$0,  xsum2

	MUL	alpha1, ALPHA_R, x1
	move	AO1, A
	MUL	alpha2, ALPHA_I, x1
	move	I,  IS
	daddu	A,   AO1, LDA

	NMSUB	alpha1, alpha1, ALPHA_I, x2
	move	XX, X
	MADD	alpha2, alpha2, ALPHA_R, x2
	move	YY, Y1

	blez	I, .L25
	daddiu	I, I, -1

	LD	x1, 0 * SIZE(XX)
	LD	x2, 1 * SIZE(XX)

	LD	a1, 0 * SIZE(AO1)
	LD	a2, 1 * SIZE(AO1)

	LD	ysum1, 0 * SIZE(YY)
	blez	I, .L23
	LD	ysum2, 1 * SIZE(YY)
	.align	3

.L22:
	MADD	ysum1, ysum1, alpha1, a1
	daddiu	XX,  XX,  2 * SIZE
	MADD	ysum2, ysum2, alpha2, a1
	daddiu	YY,  YY,  2 * SIZE
	MADD	xsum1, xsum1, x1, a1
	daddiu	AO1, AO1, 2 * SIZE
	MADD	xsum2, xsum2, x2, a1
	daddiu	I, I, -1

	NMSUB	ysum1, ysum1, alpha2, a2
	MADD	ysum2, ysum2, alpha1, a2
	ADD1	xsum1, xsum1, x2, a2
	LD	x2, 1 * SIZE(XX)
	ADD2	xsum2, xsum2, x1, a2
	LD	x1, 0 * SIZE(XX)

	LD	a1, 0 * SIZE(AO1)
	LD	a2, 1 * SIZE(AO1)

	ST	ysum1, -2 * SIZE(YY)
	LD	ysum1, 0 * SIZE(YY)
	ST	ysum2, -1 * SIZE(YY)
	bgtz	I, .L22
	LD	ysum2, 1 * SIZE(YY)
	.align 3

.L23:
	MADD	ysum1, ysum1, alpha1, a1
	MADD	ysum2, ysum2, alpha2, a1
	MADD	xsum1, xsum1, x1, a1
	MADD	xsum2, xsum2, x2, a1

	NMSUB	ysum1, ysum1, alpha2, a2
	daddiu	XX,  XX,  2 * SIZE
	MADD	ysum2, ysum2, alpha1, a2
	daddiu	YY,  YY,  2 * SIZE
	ADD1	xsum1, xsum1, x2, a2
	daddiu	AO1, AO1, 2 * SIZE
	ADD2	xsum2, xsum2, x1, a2
	nop

	ST	ysum1, -2 * SIZE(YY)
	ST	ysum2, -1 * SIZE(YY)
	.align 3

.L25:
	dsll	TEMP,  IS,  ZBASE_SHIFT
	daddu	TEMP, Y1, TEMP

	LD	ysum1, 0 * SIZE(TEMP)
	LD	ysum2, 1 * SIZE(TEMP)

	LD	a1, 0 * SIZE(AO1)
	LD	a2, 1 * SIZE(AO1)

	MOV	x1, xsum1
	MOV	x2, xsum2

	MUL	xsum1, ALPHA_R, xsum1
	MUL	xsum2, ALPHA_R, xsum2

	NMSUB	xsum1, xsum1, ALPHA_I, x2
	MADD	xsum2, xsum2, ALPHA_I, x1

	MADD	xsum1, xsum1, alpha1, a1
	MADD	xsum2, xsum2, alpha2, a1

#ifndef HEMV
	NMSUB	xsum1, xsum1, alpha2, a2
	MADD	xsum2, xsum2, alpha1, a2
#endif

	ADD	ysum1, ysum1, xsum1
	ADD	ysum2, ysum2, xsum2

	ST	ysum1, 0 * SIZE(TEMP)
	ST	ysum2, 1 * SIZE(TEMP)
	.align 3

.L900:
	li	IS, 2 * SIZE

	beq	INCY, IS, .L999
	NOP

	dsra	I,  M, 2
	blez	I, .L905
	NOP
	.align 3

.L902:
	LD	a1, 0 * SIZE(Y1)
	LD	a2, 1 * SIZE(Y1)
	LD	a3, 2 * SIZE(Y1)
	LD	a4, 3 * SIZE(Y1)
	LD	a5, 4 * SIZE(Y1)
	LD	a6, 5 * SIZE(Y1)
	LD	a7, 6 * SIZE(Y1)
	LD	a8, 7 * SIZE(Y1)

	ST	a1, 0 * SIZE(Y)
	ST	a2, 1 * SIZE(Y)
	daddu	Y, Y, INCY
	ST	a3, 0 * SIZE(Y)
	ST	a4, 1 * SIZE(Y)
	daddu	Y, Y, INCY
	ST	a5, 0 * SIZE(Y)
	ST	a6, 1 * SIZE(Y)
	daddu	Y, Y, INCY
	ST	a7, 0 * SIZE(Y)
	ST	a8, 1 * SIZE(Y)
	daddu	Y, Y, INCY

	daddiu	I, I, -1

	bgtz	I, .L902
	daddiu	Y1, Y1, 8 * SIZE
	.align 3

.L905:
	andi	I,  M, 3
	blez	I, .L999
	NOP
	.align 3

.L906:
	LD	a1, 0 * SIZE(Y1)
	LD	a2, 1 * SIZE(Y1)
	daddiu	Y1, Y1, 2 * SIZE

	ST	a1, 0 * SIZE(Y)
	ST	a2, 1 * SIZE(Y)
	daddiu	I, I, -1

	bgtz	I, .L906
	daddu	Y, Y, INCY
	.align 3

.L999:
	LDARG	$16,   0($sp)
	LDARG	$17,   8($sp)
	LDARG	$18,  16($sp)
	LDARG	$19,  24($sp)
	ldc1	$f24, 32($sp)
	ldc1	$f25, 40($sp)

#ifndef __64BIT__
	ldc1	$f20, 48($sp)
	ldc1	$f21, 56($sp)
	ldc1	$f22, 64($sp)
	ldc1	$f23, 72($sp)
#endif

	j	$31
#ifdef __64BIT__
	daddiu	$sp, $sp, 64
#else
	daddiu	$sp, $sp, 80
#endif

	EPILOGUE
