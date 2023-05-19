/*
 * File:   This file is the first example of the course.     
	    You can use it as a template if necessary  
	    The progam makes blink a light emiter diode (LED) at 1Hz
     
 * Author: René Jiménez
 *
 * Created on February, 2019
 */

    .include "p30F4013.inc"
;---------------------------------------------------------------------------    
    
    ;Clock Switching Operation and 
    ;the Fail-Safe Clock Monitor (FSCM) are disabled.
    ;FSCM allows the device to continue to operate even in the event of 
    ;an oscillator failure.    
    ;FRC 7.37 MHz internal Fast RC oscillator. Enabled
    
    #pragma config __FOSC, CSW_FSCM_OFF & FRC
    
;---------------------------------------------------------------------------    
    
    ;Watchdog Timer is disabled
    ;The primary function of the Watchdog Timer (WDT) is to reset the processor
    ;in the event of a software malfunction
    #pragma config __FWDT, WDT_OFF 
    
;---------------------------------------------------------------------------    
    
    ;The BOR and POR Configuration bits found in the FBORPOR Configuration 
    ;register are used to set the Brown-out Reset voltage for the device, 
    ;enable the Brown-out Reset circuit, and set the Power-up Timer delay time.
    ;For more information on these Configuration bits, please refer to 
    ;Section 8. "Reset?.
    
;    POR: Power-on Reset
;   There are two threshold voltages associated with a Power-on Reset (POR). 
;    The first voltage is the device threshold voltage, V POR . The device 
;    threshold voltage is the voltage at which the device logic circuits become 
;    operable. The second voltage associated with a POR event is the POR circuit 
;    threshold voltage which is nominally 1.85V.
    
;    Brown-out Reset (BOR) module is based on an internal voltage reference 
    ;circuit. The main purpose of the BOR module is to generate a device Reset
    ;when a brown-out condition occurs. Brown-out conditions are generally 
    ;caused by glitches on the AC mains (i.e., missing waveform portions of the 
    ;AC cycles due to bad power transmission lines), or voltage sags due to 
    ;excessive current draw when a large load is energized.
    
;    TPWRT = Additional ?power-up? delay as determined by the FPWRT<1:0>
;   configuration bits. This delay is 0 ms, 4 ms, 16 ms or 64 ms nominal.
    
;    EXTR: External Reset (MCLR) Pin bit enabled
    ;RCON: Reset Control Register
    
    #pragma config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
    
;---------------------------------------------------------------------------      
    
;    General Code Segment Configuration Bits
;The general code segment Configuration bits in the FGS Configuration register 
;    are used to code-protect or write-protect the user program memory space. 
;    The general code segment includes all user program memory with the exception
;    of the interrupt vector table space (0x000000-0x0000FE).
;If the general code segment is code-protected by programming the GCP 
;    Configuration bit (FGS<1>) to a ?0?, the device program memory cannot be 
;    read from the device using In-Circuit Serial Programming (ICSP), or the 
;    device programmer. Additionally, further code cannot be programmed into the 
;    device without first erasing the entire general code segment.
;    When the general segment is code-protected, user code can still access the 
;    program memory data via table read instructions, or Program Space Visibility
;    (PSV) accesses from data space. 
;    If the GWRP (FGS<0>) Configuration bit is programmed, all writes to the 
;    user program memory space are disabled.    
    
    #pragma config __FGS, CODE_PROT_OFF & GWRP_OFF

;..............................................................................
;Program Specific Constants (literals used in code)
;..............................................................................

    .equ SAMPLES, 64         ;Number of samples



;..............................................................................
;Global Declarations:
;..............................................................................

    .global _wreg_init       ;Provide global scope to _wreg_init routine
                                 ;In order to call this routine from a C file,
                                 ;place "wreg_init" in an "extern" declaration
                                 ;in the C file.

    .global __reset          ;The label for the first line of code.

;..............................................................................
;Constants stored in Program space
;..............................................................................

    .section .myconstbuffer, code
    .palign 2                ;Align next word stored in Program space to an
                                 ;address that is a multiple of 2
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A




;..............................................................................
;Uninitialized variables in X-space in data memory
;..............................................................................

    .section .xbss, bss, xmemory
x_input: .space 2*SAMPLES        ;Allocating space (in bytes) to variable.



;..............................................................................
;Uninitialized variables in Y-space in data memory
;..............................................................................

    .section .ybss, bss, ymemory
y_input:  .space 2*SAMPLES




;..............................................................................
;Uninitialized variables in Near data memory (Lower 8Kb of RAM)
;..............................................................................

    .section .nbss, bss, near
var1:     .space 2               ;Example of allocating 1 word of space for
                                 ;variable "var1".




;..............................................................................
;Code Section in Program Memory
;..............................................................................

.text                             ;Start of Code section
__reset:
    MOV #__SP_init, W15       ;Initalize the Stack Pointer
    MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
    MOV W0, SPLIM
    NOP                       ;Add NOP to follow SPLIM initialization

    CALL _wreg_init           ;Call _wreg_init subroutine
                                  ;Optionally use RCALL instead of CALL




        ;<<insert more user code here>>

    CALL INI_PERIPHERALS	

done:
    
    MOV PORTD, W0
    
    CP0 W0
    BRA Z, KNIGHT_RIDER
    
    CP W0, #1
    BRA Z, BLINK_200ms
    
    CP W0, #2
    BRA Z, BLINK_500ms
    
    CP W0, #3
    BRA Z, ROTATE_RIGHT
    
    CP W0, #4
    BRA Z, ROTATE_LEFT
    
    CP W0, #5
    BRA Z, SHIFT_FROM_CENTER
   
    BRA     done              ;Place holder for last line of executed code



;..............................................................................
;Subroutine: Initialization of W registers to 0x0000
;..............................................................................

_wreg_init:
    CLR W0
    MOV W0, W14
    REPEAT #12
    MOV W0, [++W14]
    CLR W14
    RETURN
    
    
KNIGHT_RIDER:
    PUSH    W0
    PUSH    W1
    PUSH    W2
    
    CLR   PORTB
    
    MOV	    #100,   W0
    MOV	    #7,	    W2
    
    MOV	    #1,	    W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    
KNIGHT_RIDER_LEFT_CYCLE:
    SL	  W1,#1,    W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    DEC	    W2,	    W2
    BRA	    NZ, KNIGHT_RIDER_LEFT_CYCLE
    
    MOV	    #7,	    W2
    
KNIGHT_RIDER_RIGHT_CYCLE:
    LSR	    W1, #1, W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    DEC	    W2,	    W2
    BRA	    NZ, KNIGHT_RIDER_RIGHT_CYCLE
    
    POP W2
    POP W1
    POP W0
    
    CLR PORTB
    
    ;RETURN
    BRA done
    
    
BLINK_200ms:
    
    PUSH W0
    
    MOV #200, W0
    
    CLR PORTB
    COM PORTB
    
    CALL    DELAY_msn
    
    COM PORTB
    CLR PORTB
    
    CALL    DELAY_msn
    
    POP W0
    
    ;RETURN
    BRA done
   
    
BLINK_500ms:
    
    PUSH W0
    
    MOV #500, W0
    
    CLR PORTB
    COM PORTB
    
    CALL    DELAY_msn
    
    COM PORTB
    CLR PORTB
    
    CALL    DELAY_msn
    
    POP W0
    
    ;RETURN
    BRA done 
    
    
ROTATE_LEFT:
    PUSH    W0
    PUSH    W1
    PUSH    W2
    
    CLR   PORTB
    
    MOV	    #100,   W0
    MOV	    #7,	    W2
    
    MOV	    #1,	    W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    
ROTATE_LEFT_CYCLE:
    SL	  W1,#1,    W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    DEC	    W2,	    W2
    BRA	    NZ, ROTATE_LEFT_CYCLE
    
    POP W2
    POP W1
    POP W0
    
    CLR PORTB
    
    ;RETURN
    BRA done
    
    
ROTATE_RIGHT:
    PUSH    W0
    PUSH    W1
    PUSH    W2
    
    CLR   PORTB
    
    MOV	    #100,   W0
    MOV	    #7,	    W2
    
    MOV	    #128,	    W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    
ROTATE_RIGHT_CYCLE:
    LSR	  W1, #1, W1
    MOV	    W1,	    PORTB
    CALL    DELAY_msn
    DEC	    W2,	    W2
    BRA	    NZ, ROTATE_RIGHT_CYCLE
    
    POP W2
    POP W1
    POP W0
    
    CLR PORTB
    
    ;RETURN
    BRA done
    
    
SHIFT_FROM_CENTER:
    
    PUSH    W0
    PUSH    W1
    PUSH    W2
    PUSH    W3
    PUSH    W4
    
    CLR   PORTB
    
    MOV	    #350,   W0
    MOV	    #3,	    W2
    
    MOV	    #16,	    W1
    MOV	    #8,		    W3
    IOR	    W1, W3, W4
    MOV	    W4, PORTB
    CALL    DELAY_msn
    
SHIFT_FROM_CENTER_CYCLE:
    SL	  W1, #1, W1
    LSR	  W3, #1, W3
    IOR	    W1, W3, W4
    MOV	    W4, PORTB
    CALL    DELAY_msn
    DEC	    W2,	    W2
    BRA	    NZ, SHIFT_FROM_CENTER_CYCLE
    
    POP W4
    POP W3
    POP W2
    POP W1
    POP W0
    
    CLR PORTB
    
    ;RETURN
    BRA done
    
    
    
    

    
    
;**************************
;DESCRIPTION:	SECTION OF CODE FOR A 1ms * N DELAY
;PARAMETER: 	THE AMOUNT OF 1ms DELAY IN WREG0
;RETURN: 	NINGUNO
;**************************
    
;FCY = FOSC/4 = 1.8432 MHz or cycles p/sec.
;T(FCY) = 542.53 ns. This is the time for an internal instruction cycle clock (FCY).
    
;CALL instruction will take 2 cycles to execute
;PUSH, MOV, DEC, ADD, NOP, will take 1 cycle to execute
;RETURN instruction will take 3 cycles to execute
    
;"CYCLE_DELAY_1ms1" will repeat 655 times
;DEC(1) + BRA(2) = 3 pulses in total
;(BRA uses 2 CLK pulses when it jumps and just one if it does not)

;655 * 3 cycles * 542 ns = 0.001066s
;Thus, "CYCLE_DELAY_1ms1" must be repeated N times to delay 1ms * N
DELAY_msn:
    PUSH	    W2
    PUSH	    W1	
	
    MOV	    W0,		    W1 
CYCLE_DELAY_1ms2:	
    ;CLR	    W2
    MOV	    #615,	    W2;655
	
CYCLE_DELAY_1ms1:		
    DEC	    W2,		    W2
    BRA	    NZ,		    CYCLE_DELAY_1ms1
	
    DEC	    W1,		    W1
    BRA	    NZ,		    CYCLE_DELAY_1ms2
	
    POP		   W1
    POP		   W2
    RETURN	
  
    
;**************************
;DESCRIPTION:	Initialize peripherals and determine whether each pin associated
		;with the I/O port is an input or an output
;PARAMETER: 	NINGUNO
;RETURN: 	NINGUNO
;**************************		
INI_PERIPHERALS:
    CLR         PORTB
    NOP
    CLR         LATB
    NOP
    CLR         TRISB		    ;PORTB AS OUTPUT
    NOP       			
    SETM	ADPCFG		    ;Disable analogic inputs
	
    CLR         PORTC
    NOP
    CLR         LATC
    NOP
    SETM        TRISC		    ;PORTC AS INPUT
    NOP       
	
    CLR         PORTD
    NOP
    CLR         LATD
    NOP 
    SETM        TRISD		    ;PORTD AS INPUT
    NOP

    CLR         PORTF
    NOP
    CLR         LATF
    NOP
    SETM        TRISF		    ;PORTF AS INPUT
    NOP       		
    
    RETURN    

;--------End of All Code Sections ---------------------------------------------   

.end                               ;End of program code in this file