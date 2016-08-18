### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	ORBITAL_INTEGRATION_PROGRAM.agc
# Purpose:	Part of the source code for Solarium build 55. This
#		is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), for Apollo 6.
# Assembler:	yaYUL --block1
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
# Mod history:	2009-09-22 JL	Created.

## Page 296

		BANK	23

#   *** SCALING FACTORS AND ARGUMENTS ***

DEL		=	2
DEL+E		=	2
2DEL		=	4
2DEL+E		=	4
E		=	0
RSCALE		=	16D
VSCALE		=	6
TSCALE		=	27D
2VSCALE		=	12D
4RSCALE		=	64D
R+VSCALE	=	22D

#	FBR3 SETS UP A TIMESTEP CALL TO KEPLER.

FBR3		TSRT	1
		ROUND	DAD
			H
			TSCALE -18D
			TC
		STORE	TAU

		DMP	2
		TSRT	ROUND
		DAD
			EARTHTAB
			DT/2
			12D
			TET
		STORE	TET

		ITC	0
			KEPLER

		ITC	0
			KEPLER2

GETKTIME	ITC	0
			KTIMEN+1

		ITC	0
			KEPLER3

## Page 297

#	THIS ORBITAL KEPLER SUBROUTINE FINDS THE POSITION AND VELOCITY OF THE VEHICLE AFTER TIME FOUND IN
# GIVENT  SINCE RECTIFICATION TO POSITION  RRECT  AND VELOCITY  VRECT  . THE RESULTING POSITION AND VELOCITY ARE
# LEFT IN  FOUNDR  AND  FOUNDV  , RESPECTIVELY.

KEPLER		LXA,1	1		# UNIT OF RECTIFICATION POSITION TO 0
		SXA,1	UNIT
			FIXLOC
			PUSHLOC
			RRECT

		TSLT	0		# AND LENGTH OF ORIGINAL IN 6.
			30D
			1

		VSQ	3		# A4 TO REGISTER 8.
		ROUND	DMP
		TSLT	DSU
		TSLT	ROUND
			VRECT
			6		# LENGTH OF POSITION AT RECTIFICATION.
			2DEL+E -1
			DP1/2
			1

		NOLOD	3		# ALPHA TO REGISTER 10.
		TSRT	COMP
		DAD	TSRT
		DDV
			1
			DP1/2
			2DEL+E -1
			6

		DOT	1		# A1 TO REGISTER 12.
		TSLT	ROUND
			RRECT
			VRECT
			DEL+E

		ITCQ	0

## Page 298

KEPLER2		UNIT	1
		AXT,2	DOT
			RCV
			10D		# SET MAXIMUM ITERATION COUNT TO 10.
			VCV		IR/2 . VC IN 14

		TSLT	0
			30D
			1
		STORE	ALPHAM		# RC IN ALPHAM.

		TSRT	1
		ROUND	DDV
			DT/2
			TSCALE -18D
			ALPHAM		# Q IN 16.

		TSRT	4
		DDV	DSU
		DMPR	DMPR
		DMPR	AST,2
		TSLT
			DP1/2
			2DEL+E -1
			ALPHAM
			10D		# 1/4RC - ALPHA
			16D		# Q (  )
			16D		# Q Q (  )
			DP1/3
			1
			2DEL +4

		DMPR	1
		TSLT
			14D
			16D
			DEL +3

		NOLOD	4
		BDSU	DMPR
		BDSU	DSU
		DMP	TSLT
		ROUND	DAD
			DP1/2
			-		# 20
			DP1/2
			-		# 18
			-		# 16
			1
			XKEP
## Page 299
		STORE	XKEP

		ITCQ	0

## Page 300

# ITERATING EQUATIONS - GIVEN X IN MPAC AND 14D, FIND TIME OF FLIGHT.



KTIMEN+1	NOLOD	5		# FORM ALPHA X-SQUARED AND CALL S AND C.
		DSQ	ROUND
		DMP	TSLT
		ROUND	LXA,1		# AND SET PD INDICATOR TO 16 AS WELL.
		INCR,1	SXA,1
		ITA	ITC
			10D		# ALPHA
			2DEL
			FIXLOC
			16D
			PUSHLOC
			GMODE
			S(X)C(X)

		NOLOD	4		# S RETURNS IN MPAC, C ON TOP OF PDL.
		DMP	TSLT
		DMP	TSLT
		DMP	TSLT
		ROUND
			XKEP
			4
			XKEP
			E +1
			XKEP
			1
		STORE	23D		# A3.

		NOLOD	1
		DMPR
			8D

		DMP	2
		TSLT	DMP
		TSLT	ROUND
			XKEP
			16D		# VALUE OF C.
			5
			XKEP
			E +2
		STORE	21D		# A2.

		NOLOD	2
		DMP	TSRT
		ROUND	DAD
			12D		# A1.
			2
## Page 301
		DMPR	1
		DAD
			6
			XKEP		# COMPUTED TIME TO PD+18.

		ITCI	0
			GMODE

KEPLER3		NOLOD	1		# COMPARE COMPUTED TIME WITH GIVEN TIME.
		BDSU
			GIVENT
		STORE	16D		# DIFFERENCE TO REGISTER 16.

		EXIT	0		# FOR DUMP ONLY  **************
DUMPDUMP	TC	INTPRET

		NOLOD	3
		ABS	DSU
		BMN	TIX,2
		ITC
			KEPSILON	# SEE IF WITHIN EPSILON OF GIVEN TIME.
			GETRANDV	# IF SO, GET R AND V AND EXIT.

			GETNEWX
			GETRANDV

GETNEWX		DMP	4
		TSLT	ROUND
		BDSU	DMP
		AXC,1	TSLT*
		ROUND
			10D		# ALPHA
			23D		# A3
			2DEL+E
			XKEP
			12D		# A1
			E -3
			0,1
		STORE	18D

		DMP	2
		TSLT	ROUND
		DAD	DAD
			21D		# A2
			8D		# A4
			1
			-
			6		# R0

		DDV	1
## Page 302
		DAD
			16D
			18D
			XKEP
		STORE	XKEP

		ITC	0
			GETKTIME

## Page 303

# CONSTANTS.

KEPSILON	OCT	00000
		OCT	00002
THREE/8		2DEC	.375
DP1/4		2DEC	.25
DP1/3		2DEC	.333333333
DQUARTER	EQUALS	DP1/4
POS1/16		2DEC	.0625
POS1/4		EQUALS	DP1/4
3/8		EQUALS	THREE/8

## Page 304

#	SUBROUTINE FOR COMPUTING THE UNIVERSAL CONIC FUNCTIONS S(X) AND C(X). THE ACTUAL OUTPUT OF THIS ROUTINE
# CONSISTS OF SCALED VEWRSIONS DEFINED AS FOLLOWS:
#
#			S (X) = S(64X)			C (X) = C(64X)/4
#			 S				 S
#
#	IT IS ASSUMED THAT THE INPUT ARRIVES IN MPAC,MPAC+1, AND THAT IT LIES BETWEEN -30/64 AND 40/64. UPON
# EXIT, S(X) WILL BE LEFT IN MPAC,MPAC+1 AND C(X) ON TOP OF THE PUSHDOWN LIST.



S(X)C(X)	NOLOD	0		# SAVE ARGUMENT
		STORE	XSTOREX

		NOLOD	2		#          2
		RTB	DSQ		# COMPUTE A (X)
		ROUND
			A(X)
		STORE	ASQ

		NOLOD	3		#        2          2
		DMP	TSLT		# C (X)=A (.25 - 2XA ) TO PUSHDOWN LIST
		ROUND	BDSU		#  S
		DMPR
			XSTOREX
			1
			POS1/4
			ASQ

		TSRT	1		#  2
		ROUND			# A /4 TO PUSHDOWN LIST
			ASQ
			2

		DMOVE	2		#  2
		RTB	DSQ		# B  TO PUSHDOWN LIST
		ROUND
			XSTOREX
			B(X)

		DMPR	2		#              2        2    2
		BDSU	DMPR		# LEAVE S (X)=B (.0625-A X)+A /4 IN MPAC
		DAD	ITCQ		#        S
			XSTOREX
			ASQ
			POS1/16

XSTOREX		=	26D
ASQ		=	24D
		OCT	70707		# THIS HAS TO BE NEGATIVE TO TERMINATE EQN

## Page 305

A(X)		TC	POLY			# A AND B POLYNOMIALS WHOSE COEFFICI-

		DEC	10			#   ENTS WERE OBTAINED WITH THE *AUTO-

		2DEC	 7.071067810 E-1	#   CURVEFIT* PROGRAM
		2DEC	-4.714045180 E-1
		2DEC	 9.42808914  E-2
		2DEC	-8.9791893   E-3
		2DEC	 4.989987    E-4
		2DEC	-1.79357     E-5

		TC	DANZIG		# RE-ENTER INTERPRETER



B(X)		TC	POLY

		DEC	10

		2DEC	 8.164965793 E-1
		2DEC	-3.265986572 E-1
		2DEC	 5.90988980  E-2
		2DEC	-4.0085592   E-3
		2DEC	 2.781528    E-4
		2DEC	-1.25610     E-5

		TC	DANZIG		# RETURN AS BEFORE

## Page 306

# ROUTINE FOR OBTAINING R AND V, NOW THAT THE PROPER X HAS BEEN FOUND.



GETRANDV	LXA,1	2
		INCR,1	SXA,1
		COMP	VXSC
			FIXLOC
			25D
			PUSHLOC
			21D		# AZ FROM LAST ITERATION.
			0		# UNIT OF GIVEN POSITION VECTOR.

		DSU	2
		TSLT	VXSC
		VAD	VSLT
			18D		# LAST VALUE OF T.
			23D		# LAST VALUE OF A3.
			DEL +1
			VRECT
			-
			1

		NOLOD	1		# ADDITION MUST BE DONE IN THIS ORDER.
		VAD	VAD
			RRECT
		STORE	FOUNDR		# RESULTING CONIC POSITION.

		NOLOD	1		# LENGTH OF ABOVE TO PD+16.
		ABVAL	TSLT
			1
		STORE	16D

		DMP	4
		TSLT	ROUND
		DSU	TSRT
		DDV	VXSC
		VSLT
			10D		# ALPHA.
			23D		# A3
			2DEL+E
			XKEP
			DEL+E
			16D		# LENGTH OF FOUND POSITION.
			0		# UNIT OF RECTIFICATION POSITION.
			3
		TSRT	3
		DSU	DDV
		VXSC	VAD
		VSLT
## Page 307
			16D
			1
			21D
			16D
			VRECT
			-
			1
		STORE	FOUNDV		# THIS COMPLETES THE CALCULATION.

		ITCI	0
			HBRANCH

## Page 308

#	THE POSTRUE ROUTINES SET UP THE BETA VECTOR AND OTHER INITIAL CONDITIONS FOR THE NEXT ACCOMP.



POSTRUE		LXA,1	3
		SXA,1	VSRT
		VAD	LXA,2
		LXA,1	SXA,1
			SCALDELT	# SETS UP SCALE A.
			SCALEA
			ALPHAV
			RSCALE -4
			RCV		# POSITION OUTPUT OF KEPLER.
			DIFEQCNT
			SCALER
			SCALEB		# SET UP SCALE B AND G MODE.
		STORE	BETAV

		BHIZ	0
			WMATFLAG	# TEST W MATRIX FLAG.
			ACCOMP

		VMOVE	0
			BETAV
		STORE	VECTAB,2	# SAVE R/PV IN VECTAB FOR W MATRIX UPDATE.

## Page 309

# AGC ROUTINE TO COMPUTE ACCELERATION COMPONENTS.



ACCOMP		UNIT	0		# UNITIZE ALPHA VECTOR
			ALPHAV
		STORE	ALPHAV

		DMOVE	0		# SAVE LENGTH OF ALPHA VECTOR
			30D
		STORE	ALPHAM

		STZ	0
			OVFIND

ACCOMP2		VSRT	3		#         2
		VSQ	LXA,1		# NORMED B  TO PD.
		SXA,1	TSLC
		ROUND
			BETAV
			1
			FIXLOC
			PUSHLOC
			S1

		TSLC	1		# NORMALIZE (LESS ONE) LENGTH OF ALPHA
		TSRT			#   SAVING NORM. SCALE FACTOR IN X1
			ALPHAM
			X1
			1		#  C(PDL+2)= ALMOST NORMED ALPHAM

		UNIT	0		# SAME PROCEDURE FOR BETA VECTOR
			BETAV
		STORE	BETAV

		DMOVE	0
			30D
		STORE	BETAM

		NOLOD	2
		TSLC	BDDV		# FORM NORMALIZED QUOTIENT ALPHAM/BETAM
		TSRT	ROUND
			X2
			-
			1		# C(PDL +2) = ALMOST NORMALIZED RHO.
## Page 310
		LXC,2	3		# C(X2) = -SCALE(RHO) + 1.
		XAD,2	XAD,2		#       = -S(B)-N(B)+S(A)+N(A)+1
		XSU,2	INCR,2
		NOLOD	TSRT*
			X2
			SCALEA
			X1
			SCALEB
			2
			0,2

		NOLOD	1		# RHO/4 PD +6
		TSRT	ROUND
			2

		DOT	2
		TSLT	ROUND		#  (RHO/4)- 2 (ALPHAV/2.BETAV/2)
		BDSU			#              TO PDL +6
			ALPHAV
			BETAV
			1

		NOLOD	1		# Q/4 = RHO(C(PDL +4)) TO PD +8D
		DMPR
			4

		NOLOD	1		# (Q + 1)/4 TO PD +10D.
		DAD
			DQUARTER

		NOLOD	1		#            3/2
		SQRT	DMPR		# ((Q + 1)/4)    TO PD +12D.
			10D

		NOLOD	1		#                     3/2
		TSLT	DAD		# (1/4) + 2((Q + 1)/4)    TO PD +14D.
			1
			DQUARTER
## Page 311
		DAD	3		#                -
		DMPR	TSLT		# (Q/2)(C(PD +4))B/2 TO PD +16D.
		DAD	DDV
		DMPR	VXSC
			10D
			DP1/2
			8D
			1
			THREE/8
			14D
			6
			BETAV

		VSRT	1		# A12 + C(PD +16D) TO PD +16D.
		VAD
			ALPHAV
			3

		DMP	5		# -
		TSLC	ROUND		# GAMMA TO PD +22D, -SCALE(GAMMA)-1 TO
		BDDV	LXC,1		# X1.
		XAD,1	XAD,1
		XAD,1	XAD,1
		COMP	VXSC
			0
			12D
			S2
			2
			X2		# C(X2) = SCALE (RHO).
			S2		# C(S2) = N((B.B/4)(...)3/2)
			S1		# C(S1) = N(B.B/4)
			SCALEB
			SCALEB
			16D		# RESULT OF PRECEDING EQUATION.

		NOLOD	1		# -SCALE(GAMMA)-1 IS LEFT IN X1.
		VSLT*			# ADJUST GAMMA TO SCALE OF -32.
			31D,1
		STORE	FV

		VMOVE	0
			BETAV
		STORE	ALPHAV		# BETA VECTOR INTO ALPHA FOR NEXT ACCOMP.

		DMOVE	0
			BETAM
		STORE	ALPHAM
## Page 312

#	THE  OBLATE  ROUTINE COMPUTES THE ACCELERATION DUE TO THE EARTHS OBLATENESS. IT USES THE UNIT OF THE
# VEHICLE POSITION VECTOR FOUND IN ALPHAV AND THE DISTANCE TO THE CENTER OF THE EARTH IN ALPHAM. THIS IS ADDED TO
# THE SUM OF THE DISTURBING ACCELERATIONS IN FV AND THE PROPER DIFEQ STAGE IS CALLED VIA X1.



OBLATE		LXA,1	1
		SXA,1	TSLT
			FIXLOC		# SET PUSH-DOWN COUNTER TO ZERO.
			PUSHLOC
			ALPHAM
			1
		STORE	ALPHAM

		DMPR	0		# P2'/8 TO REGISTER 0.'
			ALPHAV +4	# Z COMPONENT OF POSITION IS COS PHI.
			3/4

		DSQ	2		# P3'/4 TO REGISTER 2.
		TSLT	DMPR
		DSU
			ALPHAV +4
			3
			15/16
			3/8

		NOLOD	2		# P4'/16 TO REGISTER 4.
		DMPR	DMPR
		TSLT
			ALPHAV +4
			7/12
			1		# TO STACK.

		DMPR	1		# FINISH P4'/16.
		BDSU
			P2'/8
			2/3

		NOLOD	1		# BEGIN COMPUTING P5'/128.
		DMPR	DMPR
			ALPHAV +4
			9/16
## Page 313
		DMPR	6		# FINISH P5'/128 AND TERM USING UNIT
		BDSU	DMP		# POSITION VECTOR AT ALPHA.
		TSLT	TSRT
		DDV	DAD
		DMPR	TSRT
		DDV	DAD
		VXSC
			P3'/4
			5/128
			-
			J4REQ/J3
			2
			RSCALE -14D
			ALPHAM
			P4'/16
			2J3RE/J2
			RSCALE -14D
			ALPHAM
			P3'/4
			ALPHAV
		STORE	ALPHAV

		DMP	2		# COMPUTE TERM USING IZ.
		TSLT	TSRT
		DDV	DAD
			J4REQ/J3
			-
			1
			RSCALE -14D
			ALPHAM
## Page 314
		TSRT	2
		DMPR	DDV
		DAD	BDSU
			2J3RE/J2
			RSCALE -11D
			-
			ALPHAM
			-
			ALPHAV +4
		STORE	ALPHAV +4

		DSQ	4
		DSQ	TSLC
		BDDV	VXSC
		INCR,1	VSLT*		# SHIFTS LEFT ON+, RIGHT ON -.
		VAD
			ALPHAM
			X1
			J2REQSQ
			ALPHAV
			4RSCALE -52D
			0,1
			FV
		STORE	FV
## Page 315

#	THE DRAG ROUTINE IS AN INSERTION TO THE OBLATE ROUTINE. IT USES
# THE VEHICLE POSITION VECTOR FOUND IN RCV. THE DISTANCE TO THE CENTER OF
# THE EARTH IN ALPHAM, AND THE VEHICLE VELOCITY VECTOR IN VCV. 
#
#	IT APPROXIMATES THE U.S. STD ATMOSPHERE 1962 (OVER THE RANGE OF
# 100 TO 300 KM ABOVE SEA LEVEL) WITH AN EQUATION OF THE FORM
#		                              2      3      4  4
#		RHO = BASERHO /((1 +C1 X +C2 X  +C3 X  +C4 X )  ).
#
#	IT ASSUMES THE VEHICLE MASS TO BE THAT EXPECTED AFTER THE 
# FIFTH SPS BURN.


DENSITY		TSRT	2		# IF THE ALTITUDE IS GREATER THAN THE
		DSU	BPL		#	CEILING ALTITUDE, DENCEIL (300 KM),
		ITC			#	SKIP THE DRAG CALCULATIONS AND GO
			DENCEIL		#	TO NBRANCH.
			RSCALE -14D
			ALPHAM
			DENSITY1
			NRBANCH

DENSITY1	TSRT	2		# NORMALIZE ALTITUDE FOR AIR DENSITY
		BDSU	TSLT		# 	FUNCTION SO THAT IT RANGES FROM
		DDV	TSLT		#	0 TO 1 OVER THE ALTITUDES OF 100 KM
			DENBASE		#	TO 300 KM RELATIVE TO THE REFERENCE
			RSCALE -14D	#	SPHERE AND STORE IN DENALT.
			ALPHAM
			6
			DENFACT
			RSCALE -14D
		STORE	DENALT

DRAG1		NOLOD	7		# CALCULATE SCALAR PART OF DRAG, I.E., 
		DMP	DAD		# 	((RHO)(AREA)(DRAG COEFF))/MASS.
		DMP	DAD
		DMP	DAD		#	LEAVE IN PDL AS D. P. NUMBER
		DMP	DAD
		TSLT	DSQ
		DSQ	TSLT
		BDDV
			DEN4
			DEN3
			DENALT
			DEN2
			DENALT
			DEN1
			DENALT
			DEN0
			1
## Page 316
			2
			PACD/M
DRAG2		VXV	2
		AXT,1	VSLT*
		VSU
			OMEGA
			RCV
			23D
			R+VSCALE,1
			VCV
		NOLOD	3
		ABVAL	VXSC
		VXSC	AXT,1
		VSLT*	VAD
			-		# (-1/2)(ABVAL(-V))(V)
			-		#                           -   -
			1		# (-1/2)(RHO A CD/M)(ABVAL(-V))(V)
			2VSCALE -12D,1
			FV
		STORE	FV		# SUM OF PERTURB ACCELERATIONS
NBRANCH		LXA,1	1
		ITC*
			DIFEQCNT
			DIFEQ,1

## Page 317

#	BEGIN INTEGRATION STEP WITH RECTIFICATION TEST.



TIMESTEP	ABVAL	2		# RECTIFICATION REQUIRED IF THE LENGTH OF
		DSU	BMN		# DELTA IS GREATER THAN .5 (8 KM).
		ITC
			YV
			DP1/4
			INTGRATE
			RECTIFY		# CALL RECTIFICATION SUBROUTINE.

INTGRATE	AXT,1	3		# INITIALIZE INDEXES AND SWITCHES.
		SXA,1	AXT,1
		SXA,1	TEST
		SWITCH
			FBR3
			FBRANCH		# EXIT FROM DIFEQCOM
			POSTRUE
			HBRANCH		# EXIT FROM KEPLER.
			JSWITCH		# 0 FOR STATE VECTOR, 1 FOR W MATRIX.
			+2		# TURN IT OFF HERE.
			JSWITCH

## Page 318

DIFEQ0		VMOVE	0		# POSITION DEVIATION INTO ALPHA.
			YV
		STORE	ALPHAV

		DMOVE	0		# START H AT 0.
			DPZERO
		STORE	H		# GOES 0(DELT/2)DELT.

		NOLOD	0		# ZERO DIFEQCNT AND REGISTER FOLLOWING.
		STORE	DIFEQCNT	# GOES 0(-12D)(-24D).

		ITCI	0		# BEGIN AT ADDRESS IN HBRANCH.
			HBRANCH

## Page 319

#	THE RECTIFY SUBROUTINE IS ACLLED BY THE INTEGRATION PROGRAM (AND OCCAISONALLY BY THE MEASUREMENT
# INCORPORATION ROUTINES) TO ESTABLISH A NEW CONIC. 



RECTIFY		VSRT	1		# RECTIFY - FORM TOTAL POSITION AND VEL.
		VAD			# ADJUST SCALE DIFFERENCE (ASSUMED
			TDELTAV
			RSCALE -4
			RCV
		STORE	RRECT

		NOLOD	0		# SET UP CONIC 'ANSWER' FOR TIMESTEP.
		STORE	RCV

		AXT,1	2
		VMOVE	VSLT*
		VAD
			VSCALE -14D
			TNUV
			0,1
			VCV
		STORE	VRECT

		NOLOD	0
		STORE	VCV

		AXT,1	1		# ZERO DELTA, NU, AND TIME SINCE RECTIFI-
		AST,1	DMOVE
			12D
			2
			DPZERO
		STORE	TC

		NOLOD	0
		STORE	XKEP		# ZERO X.

ZEROLOOP	NOLOD	0		# INDEXES CAUSE LOOP TO ZERO 6 CONSECUTIVE
		STORE	YV +12D,1	# DP NUMBERS (DELTA AND NU ARE ADJACENT).

		TIX,1	1		# LOOP OR START INTEGRATION STEP IF DONE.
		ITCQ
			ZEROLOOP

## Page 320

#	THE THREE DIFEQ ROUTINES - DIFEQ+0, DIFEQ+12, AND DIFEQ+24 - ARE ENTERED TO PROCESS THE CONTRIBUTIONS
# AT THE BEGINNING, MIDDLE, AND END OF THE TIME STEP, RESPECTIVELY. THE UPDATING IS DONE BY THE NYSTROM METHOD.



DIFEQ+0		VSRT	0
			FV
			3
		STORE	PHIV

		ITC	0
			DIFEQCOM

7/12		2DEC	.5833333333	# ENTRIES MUST BE 12 WORDS APART SO FILL
9/16		2DEC	9 B-4		# HOLES WITH CONSTANTS
5/128		2DEC	5 B-7

DIFEQ+12	VSRT	1
		VAD
			FV
			1
			PHIV
		STORE	PSIV

		ITC	0
			DIFEQCOM -6

DIFEQ+24	VXSC	3		# DO FINAL CALCULATION FOR Y AND Z.
		VXSC	VSLT
		VAD	VXSC
		VAD
			PHIV
			H
			DP2/3
			1
			ZV
			H
			YV
		STORE	YV
## Page 321
		VSRT	4
		VAD	VXSC
		VXSC	VSLT
		VAD	TEST		# SEE IF THIS IS STATE VECTOR OR W COLUMN.
		AXT,1
			FV
			3
			PSIV
			H
			DP2/3
			1
			ZV
			JSWITCH
			ENDSTATE
			0
		STORE	W +72D,2	# VELOCITY COLUMN VECTOR.

		VMOVE	0
			YV
		STORE	W +36D,2	# POSITION COLUMN VECTOR.

		TIX,2	0
			NEXTCOL

		VMOVE	0
			DELTAV
		STORE	TDELTAV

		VMOVE	0
			NUV
		STORE	TNUV

		ITCI	0
			STEPEXIT

NEXTCOL		VMOVE*	0		# SET UP NEXT COLUMNS OF W MATRIX.
			W +36D,2
		STORE	YV

		VMOVE*	0
			W +72D,2
		STORE	ZV

		ITC	0
			DIFEQ0

ENDSTATE	NOLOD	0
		STORE	TNUV
## Page 322
		TSRT	1		# UPDATE TIME SINCE RECTIFICATION.
		ROUND	DAD
			H
			TSCALE -18D
			TC
		STORE	TC

		BHIZ	0
			WMATFLAG
			NEXTCOL -2

		ITC	0
			SETWINT		# FOR NOW
SETWINT		AXT,2	4		# SET UP W MATRIX EXTRAPOLATION ROUTINES.
		AST,2	AXT,1		# PROGRAM DESCRIPTION IS AT  DOW..  .
		SXA,1	SXA,1
		SWITCH	AXT,1
		ITC
			36D
			6
			DOW..
			FBRANCH
			HBRANCH
			JSWITCH
			0
			NEXTCOL

## Page 323

#	COMES HERE TO FINISH FIRST TWO DIFEQ COMPUTATIONS.



 -6		VSRT	1		# ENTERS HERE FROM DIFEQ+12 MIDPOINT
		VAD			# COMPUTATION.
			FV
			2
			PHIV
		STORE	PHIV

DIFEQCOM	DAD	1		# INCREMEMNT H AND DIFEQCNT.
		INCR,1	SXA,1
			DT/2
			H
			-12D
			DIFEQCNT	# DIFEQCNT SET FOR NEXT ENTRY.
		STORE	H

		VXSC	2
		VSRT	VAD
		VXSC	VAD
			FV
			H
			1
			ZV
			H
			YV
		STORE	ALPHAV

		ITCI	0		# EXIT VIA FBRANCH.
			FBRANCH

DIFEQ		EQUALS	DIFEQ+0

## Page 324

#	ORBITAL ROUTINE FOR EXTRAPOLATING THE W MATRIX. IT COMPUTES THE
# SECOND DERIVATIVE OF EACH COLUMN POSITION VECTOR OF THE MATRIX AND CALLS
# THE NYSTOM INTEGRATION ROUTINES TO SOLVE THE DIFFERENTIAL EQUATIONS. THE
# PROGRAM USES A TABLE OF VEHICLE POSITION VECTORS COMPUTED DURING THE
# INTEGRATION OF THE VEHICLES POSITION AND VELOCITY. 

DOW..		VSRT	0
			ALPHAV
			4

		UNIT*	2		# X1 REFERENCES THE TABLE OF POSITION
		VPROJ	VXSC		# VECTORS AND CALLS THE CORRECT DIFEQ PROG
		VSU
			VECTAB,1
			ALPHAV
			3/4

		DMP	4		# CUBE OF LENGTH OF POSITION VECTOR
		TSLC	ROUND		# DIVIDES VECTOR IN PUSH-DOWN LIST TO
		BDDV	VXSC		# FORM FINAL RESULT.
		XCHX,2	INCR,2		# INCREMENT COMPENSATES FOR .5 R IN 30D
		VSLT*	LXA,2
			28D
			30D
			S1
			DP1/4
			-
			S1
			3
			0,2
			S1
		STORE	FV

		ITC*	0		# CALL NYSTROM ROUTINES ACCORDING TO X1.
			DIFEQ,1

## Page 325

EARTHTAB	2DEC	.6335627	# 400 / SQRT(MU).
15/16		2DEC	15. B-4
3/4		2DEC	3.0 B-2
J2REQSQ		2DEC	.335914874
2J3RE/J2	2DEC	-.003309146
J4REQ/J3	2DEC	.60932709
2/3		EQUALS	DP2/3
P2'/8		EQUALS	0
P3'/4		EQUALS	2
P4'/16		EQUALS	4

DP1/2		2DEC	.5
DENBASE		2DEC	6455 B-14	# EARTHRAD +100 KM SCALED AT 2 TO THE (14)
DENFACT		2DEC	0.781250	# 200/256
DEN4		2DEC	-7.55161127 B-5	# CONSTANTS FOR DENSITY FUNCTION SCALED AT
DEN3		2DEC	21.2523654 B-5	#	2 TO THE (5)
DEN2		2DEC	-19.9253572 B-5
DEN1		2DEC	16.0533069 B-5
DEN0		2DEC	1.0 B-5
PACD/M		2DEC	0.0000363648	# (RHO AREA CD)/MASS AT 100KM
OMEGA		2DEC	0		# EARTH ROT VECTOR/SQRT(MU) SCALED
		2DEC	0		#	AT 2 TO THE (-23) KM TO (-3/2)
		2DEC	0.968892208
DENALT		=	26D		# TEMPORARY STORAGE FOR ALTITUDE
DENCEIL		2DEC	6655 B-14	# EARTHRAD +300 KM SCALED AT 2(14)
