# BRIEF

IMHO the best way to design instructions that operate on variable address ranges is
* single address range like MEMZERO or various cache flush is
   * SINGLE_ADDRESS_RANGE( src/dest RD, src RS1, ... )
      * RS1 contains the highest address of the range
      * RD contains the number of bytes in the range
         * RD is a source/dest register, both input and output
      * i.e. the range is [RS1-RD,RS1)
         * yes, this seem strange
* double address range like MEMCOPY
   * DOUBLE_ADDRESS_RANGE( src/dest RD, src RS1, src RS2 ... )
      * RS1 contains the highest address of the first range
      * RS2 contains the highest address of the second range
      * RD contains the number of bytes in both ranges, which is assumed to be equal
         * RD is a source/dest register, both input and output
      * i.e. the two ranges are [RS1-RD,RS1), [RS2-RD,RS2)

Yes, it seems strange that the ranges are defined [hi-size,hi), rather than [lo,lo+size) or [lo,hi).
But AFAIK this is the only way to obtain
* [[exception transparency]] for a state machine implementation of a two address range instruction
* while allowing the memory range to be processed from low address the high address
   * [lo,lo+size) would require processing from high address to low address, which is often not desirable
* and requiring only a single register to be written by such an instruction
   * Albeit a source/dest register, which is unavoidable for a state machine implementation with exception transparency.

If you are willing to tolerate inconsistency between single address and double address forms,
then a slightly more pol laughable version is possible, but only for single address forms
   * SINGLE_ADDRESS_RANGE( src/dest RD, src RS1, ... )
      * RS1 contains the highest address of the range
      * RD contains the low address of the range
         * RD is a source/dest register, both input and output
      * i.e. the range is [RD,RS1)

Me, I like consistency, and I hope to see a to address MEMCOPY instruction eventually defined for RISC-V.

# Why consider variable address range instructions for RISC-V? Aren't they CISCy?

Classic  RISC instruction sets are load/store. They do not have  instructions that scan over or copy memory regions. CISCs, on the other hand, have such instructions, like Intel REP STOS and REP MOVS, IBM mainframe MVC (Move Characters).

A classic RISC approach to instruction set design is to define cache line oriented instructions, e.g. that might fetch, evict, or even zero and entire cache line  at a time. If you want to apply this to a range, iterate. However, this exposes the cache line size, and is particularly important when zeroing memory.

However, sometimes range oriented instructions can be more efficient than doing things a cache line at a time. Sometimes people will build efficient state machines or external copy engines. Sometimes these range operations can use cache protocol features that would be unsafe to expose as arbitrary user instructions (e.g. Intel's "fast strings").

Moreover, frequently there are caches both inside and outside of a given CPU/processor/hart. often built by different vendors. While caches inside a CPU can be expected to respond to instructions defined by that CPU, caches outside the CPU may be accessed by idiosyncratic CSRs or MMIO accesses, which are not necessarily standardized. we may want to have portable code, but it may be necessary to trap and emulate such portable code to interface to these idiosyncratic mechanisms. it is better to trap only once for an entire range and to trap for every cache line in the range.

Note: this discussion does not compare which is better for any particular use case, variable address range instructions or fixed block size/cache line instructions or instructions that access the cache structure directly, e.g. invalidating an entire cache in a flash, or invalidating line by line using (set,way) numbers rather than  and address range.   Obviously, it is faster to flush an entire cache than it is to scan over a 32 or 40 bit virtual address range.

TBD:  Link to pages on fixed address and microarchitecture range CMOs.

# Three different implementations for variable address range instructions

Yes: I mean implementations, microarchitectures. In the sense that we want to define and instruction set architecture facility that permits at least these three reasonable implementations.

1) enable per address per cache line stuff - Like IBM  POWER DCBZ

2) allow people who already have CMOs in their system, using custom CSRs or MMIO, who want to trap and emulate, but don't want to have to trap every cache line

3) possibly allow state machine-based implementations 
    *probably more important for MEMZERO/MEMSET and MEMCOPY than for CMOs

I don't think hardware state machines need to be implemented right away. I just think that it would be unfortunate to rule out the possibility of ever doing a state machine implementation, or to make it much more expensive than it needs to be. It would be nice if the choice of implementation were microarchitecture, not architecture. However, some features of the architectural design of such memory address range operations need to be compatible with the different microarchitectures.

For a long time I thought it was just per cache line versus address range. But #2 and #3 have different needs.

Implementation #2 and #3 are address ranges, so require single instructions that define an interval either [lo,hi) or [lo,lo+size).  That’s two inputs, almost certainly register inputs. If you want to have third operand which is a CMO type, it either needs another register, a CSR implicit operand, or it needs to fit in the instruction encoding.  

Implementation #1 doesn't need to be address range, but could be address range if it is allowed to just take off the first cache line.  This is what leads to the loop:

~~~~
               LOOP
                               something := CMO( lo, hi_or_count, cmo_type )
                               lo := next_cache_line ( something, lo, hi_or_count )
                               hi_or_count := I just_if_necessary ( something, lo, hi_or_count )
                                              // It has been pointed out that “something” might just need the actual next cache line 
               UNTIL f_finished(  hi_or_count, … )
~~~~

Implementation #1 (per address per cache line) is naturally unblocking. #1 will always take exceptions like page faults before it has done anything.  

* The CMO must return "something" that allows the loop to calculate the next cache line
* The loop must update the interval, lo and/or hi_or_count, as necessary
  * above I have suggested that lo always needs to be updated to the next_cache_line, but elsewhere I have proposed ways that mean that only the count these to be updated
  * i.e. the loop may need to update
     * only the low address (a cache line version, my [lo, hi) version
     * only the count (my original [hi-nbytes,hi) version
     * both address and count (the original   [lo,lo+nbytes) version, assuming starting at low address)

Implementation #2 (trap and emulate), will take exceptions and interrupts inside the kernel trap handler that is performing the emulation, inside whatever emulation loop is doing the work. So it doesn't really need to be resumable or restartable.  The exception PC will be a PC inside the trap & emulate handler. (unless the OS wants to do funky things like user level page handlers without down calls. Which amounts to #2 emulating #3.)

For implementation #3 (state machine) exceptions and interrupts will go to the normal kernel exception handler, but the exception PC will be the PC of the address range CMO.  The exception handler will return to that instruction, and will want to pick up where it left off.

* There is one big consequence:  anything that needs to be updated so that the instruction can pick up where left off must be source/dest.
* Which basically means that anything that the loop in #1 needs to update must be considered a source/dest operand if a state machine implementation is to be enabled

I would definitely like to enable #3 state machine implementations. Perhaps not right now, but perhaps in the future. Perhaps not for CMOs, but perhaps for ZALLOC/MEMZERO and possibly for MEMCOPY.

I mention MEMCOPY, which involve two address ranges of the same size, as well as the single address range CMOs and MEMZERO, because maintaining "compatibility" between single address MEMZERO and double address range MEMCOPY motivates a particular binding of register operands.  Many people seem to dislike this design of address range instructions, although I hope it is just unfamiliarity, and wishing for an imaginary and impossible alternative

I would like to enable #3 state machine implementations as cheaply as possible. Which, to me, means that it would be nice for them to stay in the RISC mentality of only having a single destination register.  As far as I know there are two definitions of single address range operations, but only one definition of double address range operations like MEMSET:

* single address range like CMOs or MEMSET/MEMZERO
   * 1. SINGLE_ADDRESS_RANGE( src/dest LO_reg, HI_reg )
     * i.e. SINGLE_ADDRESS_RANGE rd, rs1, rs2
       * input: the address range is [RD, RS1)
       * output: RD is updated next lo_address to start at
       * rs2 is available for other inputs, like CMO type or memset value
   * 2. SINGLE_ADDRESS_RANGE( src/dest nbytes, HI_reg )
      * i.e. SINGLE_ADDRESS_RANGE rd, rs1, rs2
        * input: the address range is [RS1-RD, RS1)
        * output: RD is updated to number of bytes remaining
          * RS2 is available for other inputs, like CMO type or memset value

* double address range like MEMCOPY
   * DOUBLE_ADDRESS_RANGE( src/dest nbytes, FROM_HI_reg, TO_HI,reg )
     * i.e. SINGLE_ADDRESS_RANGE rd, rs1, rs2
       * input: 
         * RD =nbytes
         * RS2 = start of memory regions to copy from
         * RS2 = start of memory region to copy to
       * i.e. the intervals are from[RS1-RD, RS1) to[RS2-RD,RS2)
         * output: RD is updated to number of bytes remaining

Any double address range form that starts off with the low addresses must update both of those low addresses if the copy is desired to go from low to high address. 

But I recognize that #3 state machine implementations are deprecated by many in the current RISC-V community.


# COMPROMISE #1: Single Address Range [lo,hi), incompatible with double address range
This suggests COMPROMISE #1, which I repeat

* single address range like CMOs or MEMSET/MEMZERO
   * 1. SINGLE_ADDRESS_RANGE( src/dest LO_reg, HI_reg )
     * i.e. SINGLE_ADDRESS_RANGE rd, rs1, rs2
       * input: the address range is [RD, RS1)
       * output: RD is updated next lo_address to start at
       * RS2 is available for other inputs, like CMO type or memset value

As of the time of writing (February 3, 2020), we are not currently defining two address range forms like MEMCOPY. 

The above [lo,hi) form seems to be acceptable to many people. Perhaps not their favorite, but a reasonable compromise on which consensus can be obtained.

The main ugliness with this single address form is that RD is both a source and destination.
But this is inherent: any instruction that is supposed to permit a state machine implementation with [[exception transparency]] must have at least one operand that is both a source and destination.

Some will complain about the need for an adder, particularly from the per cache line

There is a minor ugliness in that this approach cannot be used for two address range instructions like MEMCOPY, not without having to update two source/destination registers.  But I can live with that. I like consistency, but it would be better to get consensus about an inconsistent approach than for me to stand up for consistency and get nothing.

But mostly I think this makes all of #1, #2, and #3 happy.



# BAD COMPROMISE

I mentioned this bad compromise mainly to head it off, because I expect people to propose it again in the future. It can be made to work. But it is fragile.

There is also a possible "COMPROMISE" #2

* next_cache_line := SINGLE_ADDRESS_RANGE( LO_reg, NBYTES_reg )
   * i.e. SINGLE_ADDRESS_RANGE rd, rs1, rs2
     * input: the address range is [RS1,RS1+RS2)
       * per cache line implementations do whatever they want to do on the address the contains RS1
     * output: RD is updated next lo_address to start at 
       * the per cache line implementation need only write RD in the instruction
          * the per cache line loop will just set aside new values RS1 and RS2 as appropriate the next time around 
       * HOWEVER, because we want to permit #3 state machine implementations, 
          * which would require both RS1 and RS2 to be updated
          * we might say that ARCHITECTURALLY RS1 and RS2 may be modified, and should not be relied on
          * although in state machine implementations they would be updated appropriately so that exceptions can return transparently
      * implementation #2, trap and emulate, might deliberately destroy RS1 and RS2, in a manner compatible with implementation #3,

I put quotes around "COMPROMISE" because it isn't really a compromise. 
* It is basically giving in to #1. 
   * IMHO it makes implementation #3 state machines much less likely to be built, because it would require them to have to source dest operands.  
* It is basically using architectural specification craftsmanship and pedantic terminology to try to allow all of #1, #2 and #3.

Furthermore
* Because #1 per address implementations are likely to be among the earliest, it is extremely likely that compilers and programmers will ignore the part of the spec that says ARCHITECTURALLY RS1 and RS2 may be modified, and should not be relied on, because after all it's always nice to have two more registers available.
* I.e. de facto implementation #1 that writes only RD and leaves RS1 and RS2 unaffected will probably override any architectural definitions

Therefore I cannot really in good faith recommend "COMPROMISE" #2.


Furthermore, although perhaps not unfortunately, in “COMPROMISE” #2 RS2 is not available for other inputs. So if there are more types of CMO than you want to assign specific opcodes or instruction fields to, you need an implicit operand like a CSR. Since I think it is better to have the CMO type in one or a few CSR fields than to have the CMO type in a general-purpose register, this may not be a bad thing. And I recommend having such a CSR (or a few fields) in any case.


# Should address ranges be ~closed~ or *half open*?

Above we have discussed defining ranges as various half open above intervals.
* [lo,hi)
* [lo,lo+size)
* [hi-size,hi)

These formulations are pleasant because they allow definition of empty intervals/ranges, and avoid gratuitous -1s.

However, various minor tweaks make these intervals inclusive of both endpoints, i.e. closed.

Without loss of generality we will assume the half open forms.


