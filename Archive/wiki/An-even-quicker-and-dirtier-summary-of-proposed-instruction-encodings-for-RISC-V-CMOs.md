This is pretty much gelled, pretty much what I think Ri5 should do, pending getting agreement from all of the people involved (me, Krste, Andrew, Google folks, Gernot Heiser, various RISC-V foundation working groups...)

Note that this does NOT describe the semantics. TBD elswhere.  This is only the instruction encodings requirements.

See
* [[Fixed Block Size Prefetches and CMOs]] - using encodings noted below, for a much more limited set.

# ---+ Small Summary

OBSOLETE: [[Fixed Block Size Prefetches and CMOs]] uses a much more limited set

Conventional, immediate need:
* Fixed Block Size Prefetches: 4 load-like rs1+imm encodings (I-format, no rd)
* Fixed Block Size Pushouts: 8 store-like rs1+imm encodings (S-format, no rs2)
* good enough for performance, special case SW coherence/persistence, but not good enough for security or general case SW coherence/persistence
* AW:

Variable Range CMOs
* at least 1 R-type encoding, 3 regs, srcdst ternary
* ? 12 R-type encodings, non-ternary
* not good enough for security, SW coherence, + persistence, but definition ready except for minor arguments

Eventually, for security, SW coherence, + persistence (i.e. important stuff after performance)
* at least one 2 reg encoding, rd srcdst
* ? non-srcdst R-type 3 reg encoding, R-type, CMO.UR(rd=rs1,rs2)
* ?? 12 R-type 3 reg encodings
* important long term, but last mature (i.e. I recommend, but expect arguments)

# ---+ Summary

## ==> DEFINITION READY, PENDING APPROVAL/TWEAKS
Nothing special, very similar to prior work dating back to 1980s:
* MINIMUM: Base: 4 load-like I-format prefetch instructions, fixed block size.
* MINIMUM: Base requirements:  8 store-like S-format pushouts/post-stores/block flushes
* OPTIONAL: more types always possible.  But they 12 above are a good start.

OBSOLETE: [[Fixed Block Size Prefetches and CMOs]] uses a much more limited set


USE CASES: Performance, special case SW coherence+persistence.

Not good enough for security/Spectre, general SW coherence, general persistence

POSSIBLE IMPLEMENTATIONS:
* simple enough that it should be doable by all except the most time pressed of projects

## ==> LESS URGENT, NEEDED EVENTUALLY, DEFINITION READY EXCEPT FOR MINOR ARGUMENTS
* MINIMUM: At least 1 R-type encoding, ternary srcdst  CMO.VAR(rd,rs1,rs2)
* IF SRCDST NOT ALLOWED:  12 non-ternary non-srcdst, with cmo type in instruction encoding/opcode/funct field, CMO.VAR.<typeX4+12>(rd,rs1,rs2)
* OPTIONAL: plus more, especially if ternary srcdst rejected.

USE CASES: special case SW coherence+persistence.
Not good enough for performance (too much overhead).
Not good enough for security/Spectre, general SW coherence, general persistence.

POSSIBLE IMPLEMENTATIONS:
* shortest term: trap
* medium term: HW that does a cache line at a time (wrap in a loop until done)
* eventually: HW state machine

## ==> MEDIUM URGENT, DEFINITION NEEDS TO BE REVIEWED
Cache scanning, non-address-range CMO.UR(rd,rs1)
* MINIMUM: at least one 2 reg encoding, rd srcdst
* IF SRCDST NOT ALLOWED: or 3 reg encoding, CMO.UR(rd=rs1,rs2)
* OPTIONAL: + at least 12 in-instruction cmo_types CMO.UR.<typeX4+12>(rd=rs1)

USE CASES: Good enough for security/Spectre, general SW coherence, general persistence

POSSIBLE IMPLEMENTATIONS:
* shortest term: trap
* medium term: HW that does a cache line at a time (wrap in a loop until done)
  * harder than variable address range, since may need to iterate over several caches
* eventually: HW state machine

# ---+ DETAIL

Prefetches Base Requirement, fixed block size PREFETCH.FSZ.<typeX4>(rs1,imm12), I-fornat
* 	Prefetch-R 64B  <-- doable   <-- AW: ORI
* 	Prefetch-W 64B  <-- doable   <-- AW: ANDI

 AW: wants to only implement one block size,
 AW: not uarch dependent
 AW: not very many I-formats
* 	Prefetch-R 256B
* 	Prefetch-W 256B

Then there is a long tail - other block sizes, "non-temporal hints", etc., fetch into L2 but not L1, etc. But 4 is a good start, assuming that the encodings are scarce.

==> MINIMUM: Base: 4 load-like I-format prefetch instructions, fixed block size.

 AW: ? only use fewer imm bits



 Push-outs Base requirements, fixed block size CMO.FSZ.<typeX8>(rs1,imm12'), S-format
Push-outs Base requirements, fixed block size CMO.FSZ.<typeX8>(rs1), S-format
* D1-to-L2
    * D1-Clean-to-L2 64B  <-- write dirty back, keep clean copy AND R-form, RS2 must be zero
    * D1-Flush-to-L2 64B  <-- write dirty back, leave invalid for all lines, both originally dirty and clean OR R-form,

  * where I say "D1" to emphasize that this cleans/flushes the data L1$.  No effect on I$.
    * D1-Clean-to-L2 64B
    * D1-Flush-to-L2 64B
    * D1-Clean-to-L2 256B  <-- no
    * D1-Flush-to-L2 256B  <-- no
* from-L2 forms
  * ideally, from all caches to memory, but CPU doesn't control that
  * ideally, from both D1 and L2 = from-L2 if inclusive, but not if non-inclusive
    * Clean-from-L2 64B
    * Flush-from-L2 64B
    * Clean-from-L2 256B <-- no
    * Flush-from-L2 256B

===> MINIMUM: Base requirements:  8 store-like S-format pushouts/post-stores/block flushes

Variable Address Range CMO.VAR(rd,rs1,rs2)
* MINIMUM: At least 1 R-type encoding, ternary srcdst  CMO.VAR(rd,rs1,rs2)
* IF SRCDST NOT ALLOWED:
  * 8 non-ternary non-srcdst, with cmo type in instruction encoding/opcode/funct field
    *  CMO.VAR.<typeX4+12>(rd,rs1,rs2)
* OPTIONAL: plus more, especially if ternary srcdst rejected.

Cache scanning, non-address-range CMO.UR(rd,rs1)
* MINIMUM: at least one 2 reg encoding, rd srcdst
* IF SRCDST NOT ALLOWED: or 3 reg encoding, CMO.UR(rd=rs1,rs2)
* OPTIONAL: + at least 12 in-instruction cmo_types CMO.UR.<typeX4+12>(rd=rs1)



# ---+ Even more detail

Start off with fixed block size.  Prefetches. Let's call these fixed block size, in the loop prefetches

Reasons:

1) it's what everyone else does (ARM, Intel, IBM), known to work, etc. RISC-V should be deploying well known ideas whenever possible, not inventing new stuff when it makes life harder

2) this is what you have to do in a high performance loop:  FOR i FROM 0 to N-1 DO access A[i], prefetch A[i+delta]. Prefetch instruction overhead is already bad; you don't want to make that worse by wrapping it in a loop.

3) Define a few block sizes that are "good enough":  our current cache line size, 54B, 256B, maybe 1K bytes...
  * Only implement the sizes that are easy - eg current line size.  NOP the other sizes.

Instruction format: this sort of prefetch should have a regular memory addressing mode, i.e. a prefetch=load. I.e. needs BaseReg+Imm12.  Reason: simple loop, compiler just wants to add delta to the offset. If not a regular addressing mode, more overhead.

Note: if we add more addressing modes, like regBase+regIndex<<scale, then ideally prefetches will need that same

## ---++ Prefetch
Prefetch looks like a load. EA = rs1+imm12.   I-type.

Prefetch does not need rd. 
 Q: why not just make loads that write r0 into prefetches?  That would give us 5 prefetch types...
 Q: if must have a new instruction, can we use rd to indicate the prefetch type?
 If not, then how many such encodings can you give over to prefetches:
* Base requirement
  * Prefetch-R 64B
  * Prefetch-W 64B
   * Prefetch-R 256B
   * Prefetch-W 256B

Then there is a long tail - other block sizes, "non-temporal hints", etc., fetch into L2 but not L1, etc. But 4 is a good start, assuming that the encodings are scarce.

==> Base: 4 load-like I-format prefetch instructions, fixed block size.

## ---++ Fixed Block Size Push-outs (CMO.FSZ)
The next important operation is a fixed block size push-out. AW calls them post-stores. The equivalent of Intel CLFLUSH.  (I can go on and list other companies, Intel, ARM, POWER)
Again, best if has ordinary memory addressing mode.  EA=rs1+imm12.
Reason: again, use in a loop that scans over array, pushing out data that is no longer needed.  (Ordinary addressing mode not as critical as for prefetches, but still good.)

Probably best if it looks like a store, since implementation likely to be an operation pushed into store pipe, then flowing like an uncombined but not serializing store out past external caches.   E.g. if there are separate load and store pipes, probably wants to go on store pipe. (But you may not care)

Base requirements:
* D1-to-L2
  * where I say "D1" to emphasize that this cleans/flushes the data L1$.  No effect on I$.
    * D1-Clean-to-L2 64B
    * D1-Flush-to-L2 64B
    * D1-Clean-to-L2 256B
    * D1-Flush-to-L2 256B
* from-L2 forms
  * ideally, from all caches to memory, but CPU doesn't control that
  * ideally, from both D1 and L2 = from-L2 if inclusive, but not if non-inclusive
    * Clean-from-L2 64B
    * Flush-from-L2 64B
    * Clean-from-L2 256B
    * Flush-from-L2 256B
----------------------------
Base requirements:  8 store-like S-format pushouts/post-stores/block flushes

But, as usual, many more flavors possible, including LRU-touch (make line(s) touched LRU rather than MRU, but leave data in cache, w/wo WB flush.

Bottom line: Fixed block
* Base requirement
  * 4 load-like I-format prefetch instructions, fixed block size; no rd (rd=r0)
  * 8 store-like S-format pushouts/post-stores/block flushes; no rs2 needed; or use I-format if you don't care about simplified decoding


## ---+ Variable address range CMOs (CMO.VAR)

OK, what about more general CMOs? Variable address ranges rather than fixed block.

Most general:
	CMO.VAR rd, rs1, rs2
There is definitely at least one 3 register form, R-type.
* Q: no problem using an R-type for memory, right?

Disagreement about exactly what for each register.
* Another RISC-V WG member and I are arguing over exactly what values are associated with which register
  * I (Ag) want:
    * rd = nbytes_to_be_copied, srcdst, value changed on each pass or if interrupted
    * rs1 = start_address
    * rs2 = cache_flush_type
  * He wants
    * rd=nbytes_left,
    * rs1=nbytes_to_be_copied
    * rs2=start_address

He and I pretty much agree on the tradeoffs; we disagree on the relative importance we ascribe to them:
* My version (ternary, srcdst rd)
  * exactly same behavior on interrupts as normal, or when done a cache line at a time
  * only needs one R-type encoding (although can use more)
* His version
  * needs multiple I-type encodings, since no register freee e.g. at least for prefetch/pushout types above
  * complicates exceptions - either HW changes RS1 and RS2 on an exception, or SW must decode instruction
  * ==> from ISA/SW point of view, SW must assume that RS1 and RS2 are destroyed
    * even though main HW only writes RD, xceptions must write RS1 and RS2
  * virtualization leak
His version may save an adder, although I think the AGU adder is available.
-------------
Bottom line: CMO.VAR
* At least 1 R-type encoding, ternary srcdst
* 8 non-ternary non-srcdst, with cmo type in instruction encoding/opcode/funct field
* plus more, especially if ternary srcdst rejected.


### Meta-observation:

If you want to make an instruction resumeable on an interrupt/exception from ordinary register state (no stack puke or special CSRs or SW decode in exception handler)) it must be srcdst - i.e. all input values that change must be written.  We can get away with making only RD srcdst.

We could do `rd<--INSTRUCTION(rs1,rs2)`, and require that the register numbers rd and rs1 are identical.  Ideally trap if not identical, or at least say undefined if rd!=rs1.

## ---+ Non-address range, cache scan invalidates

What's left?    Whole cache invalidates, for when address ranges are not enough (i.e. for security).
Again, ideally it is srcdst, changing an index number (roughly (set,way), but abstracted).

This is also where we will hang block invalidates for security, such as branch predictor flushes


Instruction
* CMO.UR rd, rs1
  * rd:      input = starting index
    * output = place stopped on interrupt
  * rs2:    input = type of CMO

This is really only needs two register fields, one of which can be srcdst rd.

There are a few similar 2-register instructions, e.g. C-extension BMATFLIP.

But no standard 2-reg format AFAICT.
If not, then can be three reg IR-type, either ignoring rs2, or requiring rs2=rd, as above.

Ideally reserve at least 12 such encodings to specify CMO type in the instruction directly, as opposed to from register value.
