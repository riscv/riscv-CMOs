[[OBSOLETE]]: this page is largely obsolete, no longer the current proposal, which is referenced elsewhere in pages marked as POR.
* I am not changing the name of this page yet because the GitHub/Gollum wiki does not handle page renaming nicely. (TBD: do the renaming via a global edit in a clone, not online).
* but I want to keep this information around, because some of the stuff in this page and pages it references has not yet been moved into the POR.

[[CMO goals]]

In general, CMO operations have the following parameters:
* what the operation is - flush dirty data, invalidate
* what caches are affected - flush L1 data to L2, to point of unification, flush all to NVRAM
* what range of addresses or cache entries are affected
  * by physical or virtual address: individual cache lines, address ranges
  * by location within cache: individual line by (set,way), entire cache, all of one set, all of one way...

The instructions proposed here differ mostly in how these parameters are provided to the CMO operation:
* implied by the instruction coding, e.g. via the opcode or field within the instruction
* implied by register operands (scalar X registers, possibly one or a few CSRs)

And also according to how instruction restart/resumeability is supported. Observation: [[Transparent Resumeability Prefers SrcDst Register Operands]].


Now, on to the instructions:


This proposal does not have "single cache line" instructions. Certain RISC-V architects wish to not expose the cache line size of any implementation in the instruction set.

This proposal has fixed size and variable address range CMO instructions.


CMOs based on virtual or physical addresses, whether fixed size or variable ranges, are easy to express in a portable manner. The big problem with memory address range based CMOs is that they are often significantly less efficient than [[CMOs based on cache microarchitecture]]. For example, it is horribly wasteful to have to scan and address range of size 4 GB when you know that the largest cache of concern is only 4 MB in size. However, it is TBD whether we can architect a reasonably portable solution [[CMOs based on cache microarchitecture]], which I might call [[CMOs proportional to cache size rather than address range]]. See that last page for a tentative proposal.


## Variable Range CMOs

The generic variable range CMO instruction definition is

CMO.VAR.<cmo_inst_type>.<virtual/physical> rd, rs1

Instruction flavors:
* [[<virtual/physical>|Virtual or Physical CMO instruction flavor]] - addresses virtual (0) or physical (1)
* [[<cmo_type>|cmo_type CMO instruction flavor]] - type of CMO, e.g. flush/invalidate, cache levels involved


Instruction operands:
* rd = nbytes
  * at start of instruction, rd contains nbytes, the number of bytes to be transferred
  * when the instruction terminates, or is interrupted, e.g. by a page fault, rd is updated to contain the number of bytes to which the operation has not yet been applied
* rs1 = hi_address
  * rs1 contains the highest address requested to be affected

Note: there is no rs2 operand, but rd is both a source and destination operand, nbytes.

I.e. the variable address range is  [rs1-rd+1,rs1], i.e. [high_address-nbytes+1,high_address].
Yes, it may seem strange to define address range.
Yes, it is unusual or a RISC-V instruction to both read and write the RD register.
Suffice it to say that many of the [[CMO variable address range alternatives]],
such as placing the low address in rs1 or rs2, and returning the number of bytes done in RD,
the problem such as non-resumability exceptions or virtualization holes. Or they require SW to assume that more than one register will be modified - even though hardware may only modify rd, resumability would require rs1 and/or rs2 to be modified by a page fault handler.

GLEW NOTE: I expect to be overruled. Nevertheless right, and I'm going to present what is in my opinion the best solution first, and I will keep the IMHO unsatisfactory alternatives in [[CMO variable address range alternatives]] along with rationale, until I am forced to revive them.

This choice should not impede discussion of other aspects of the proposal, like the actual cache flush types and levels, and the privilege model. (Except insofar as transparency/interruptability/resumability affects the privilege model.)

rd:nbytes_done <--- CMO.VAR( rs1:start_addr, rs2:nbytes )
* SW exception decode move rd-->rs2
   * AW: new exception cause, SW cost
   * Ag: virtualization
* HW - no exception just write rd
   * exception clobber

rd:nbytes_left <--- CMO.VAR( rs1:start_addr, rd:nbytes )
* exceptions work simply

CMO.VAR( rs1:start_addr, in/out rd:nbytes )

CMO.VAR( rd/rs1:lo_addr, rs2:hi_addr )


CMO.VAR( rd:lo_addr, rs:hi_addr, rs2:cmo_type )





## Fixed Size CMOs

The generic fixed size CMO instruction definition is

CMO.FSZ.<fixed_size>.<cmo_type>.<virtual/physical> rs1

Instruction flavors:
* [[<virtual/physical>|Virtual or Physical CMO instruction flavor]] - addresses virtual (0) or physical (1)
* [[<cmo_type>|cmo_type CMO instruction flavor]] - type of CMO, e.g. flush/invalidate, cache levels involved
* <fixed_size> - {64B,512B,4KB} - see below


Instruction operands:
* rs1=addr contains a virtual or physical address within the fixed size block to which the operation will be performed.
   * TBD: many uses want a [[full memory addressing mode rs1+imm12 for prefetches and CMOs]], but we will specify the minimum requirement

The memory block requested to be affected is defined to be the power of 2 naturally aligned block whose size is specified.  TBD: encoding - e.g. if there are 2 orthogonal bits 00-64B, 01-512B, 10-4KB, 11-reserved.

<fixed_size>

The fixed address range instructions are defined to "work" on a small number of memory regions, which are power of two sized and aligned, denominated in bytes. The exact number of such sizes is TBD, but is probably something like 64B, 512B, 4KB - i.e. typical cache line and virtual memory page sizes.  "Work" is placed within sardonic quotes, because implementations are allowed to ignore the CMO if the size requested is inconvenient. Because this permission to ignore or treat as a hint would not be good for security, security is not recommended to use these operations, unless it can otherwise determine which sizes are actually implemented.

## [[CMOs based on cache microarchitecture]]

CMOs based on virtual or physical addresses, whether fixed size or variable ranges, are easy to express in a portable manner. The big problem with memory address range based CMOs is that they are often significantly less efficient than [[CMOs based on cache microarchitecture]]. For example, it is horribly wasteful to have to scan and address range of size 4 GB when you know that the largest cache of concern is only 4 MB in size. However, it is TBD whether we can architect a reasonably portable solution [[CMOs based on cache microarchitecture]], which I might call [[CMOs proportional to cache size rather than address range]]. See that last page for a tentative proposal.

IMHO the need is obvious. The problem is satisfying this need in a reasonably portable manner.

2020-01-22 Wednesday January 22: I believe that I have a good proposal on how to do these [[CMOs based on cache microarchitecture]] in a portable and secure manner.  It also solutions together [[CMOs proportional to cache size rather than address range]] and [[Instantaneous Flushes of Predictor and Cache State]] into the same instruction. Please follow the link: [[CMOs Not Based on Memory Address]].
