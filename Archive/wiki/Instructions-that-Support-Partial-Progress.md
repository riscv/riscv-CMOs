# Resume vs Restart

The instructions of most modern computers are "all or nothing".  They either execute completely, or if they cannot complete they are stopped, the problem is cleared up, and the instructions are **restarted** as if from the very beginning.

This has not always been the case. E.g. the Motorola 68000 family of microprocessors had some relatively CISCy instructions, implemented using not just microcode but also nano code, and famously could receive an exception, e.g. a page fault, in the middle of one of these microcode operations. The microcode/microarchitecture state was saved, including in a not publicly documented "stack puke" area on the processor stack. The exception handler could do its job, and then return to the partially completed instruction, picking up where it had left off from the "stack puke" area.

(I (Ag) vividly remember meeting a Motorola kernel developer when Motorola acquired the OS group that I was then working at. This Motorola kernel developer was adamant that the most reliable way to program an exception handler was to only reliant information in the stack puke area - which was documented to Motorola internal developers, although not to the outside world. He said that there were so many errors in the control and status registers of devices such as the I/O MMU that they could not be relied on.)

TBD: other examples of resumable instructions.

# Partial Progress is not necessarily "resume from microcode puke"

This topic page discusses instructions that are not "all or nothing". Instructions that can support partial progress, permanently commit as much work as possible, and then save state in a form such that the instruction can be resumed without having to repeat any extra work already completed.

This is not necessarily "resume from microcode or microarchitecture" state. For the purposes of this topic page it is emphatically not.

In fact, for the purposes of this page the distinction between resume and restart is blurred. The instructions discussed here accomplish their "partial progress" by modifying architectural state. On an exception or other circumstance in which the instruction execution is interrupted, ordinary registers are written. On exception return ordinary registers are read. In some circumstances the registers involved are source/destination; in some circumstances, the instruction is "restarted as if from the beginning", however the starting point, the initial state for the instruction, has been modified, so that it does not need to repeat work already done. Therefore the term "partial progress" as in "instructions that support partial progress" is used rather than "resumable". "Partial progress" instructions may be considered to be either restarted or resumed, or something in between.

Moreover, this is not an issue of RISC versus CISC.  Some of the instructions described here are arguably RISC instructions.

# Examples of "Partial Progress" - x86 REP STOS and REP MOVS

Probably the most familiar modern examples (in 2020) of instructions that make partial progress are the x86 block memory operations, REP MOVS and REP STOS. REP STOS fills a block of memory with a value from a register. REP MOVS copies one memory block to another.

STOS and MOVS are the most prominent members of a family of x86 "string" operations that include CMPS (compare), SCAS (scan), and LODS (load). These "string" operations are composed with repeat prefixes REP (repeat well count not zero), REPE/REPZ and REPNE/REPZ (repeat until equal/zero or not-equal/non-zero). The string operations are provided in flavors of different sizes - 8-bit byte, 16-bit word, 32-bit double word.

Architecturally, the string operations such as STOS and MOVS are simple instructions, that are repeated automatically by the REP repeat instruction.

STOSB performs the following operation
~~~~~~
    STORE.BYTE Memory[ DI ] := AL
    DI := DI + (1 IF DF == 0 ELSE -1)
~~~~~~

MOVSB performs the following operation
~~~~~~
    tmp := LOAD.BYTE Memory[ SI ] 
    STORE.BYTE Memory[ DI ] := AL
    SI := SI + (1 IF DF == 0 ELSE -1)
    DI := DI + (1 IF DF == 0 ELSE -1)
~~~~~~

The repeat prefix REP repeats the string operation to which it is applied, e.h. STOSB or MOVSB, decrements a counter (in register CX/ECX/RCX), and repeats until the counter reaches zero. The conditional versions REP[EZ] and REPN[EZ] can terminate early if a condition is met.

STOSx and MOVSx can be used as independent instructions.

REP STOSx and REP MOVSx can be viewed as loops around the "simple" instructions STOSx and MOVSx.

But most modern x86 systems use "fast strings", and implement REP STOSx and REP MOVSx as if they were combined or fused into a single instruction that performs many simple operations. E.g. instead of REP STOSx storing a byte at a time, the optimize version can store 16, 32 or more bits at a time. The optimized version may use cache protocol operations not available to ordinary instructions. The optimized version behaves as if it were a loop around the simple version, but is optimized to be efficient as possible. The optimizations may be accomplished by microcode, or by hardware state machines, or by a combination of both.


 

