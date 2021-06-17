One motivation for address range instructions would be to enable efficient implementations of block operations such as [[C library block memory operations]], with include memset, memcpy (defined if overlap), memmove (defined for overlap), memcmp.

# Possible ISA designs
Such an efficient implementation might be
* a hardware state machine that iterates over the entire range
* a loop around instructions that operate a cache line or other fixed size memory block at a time

# Possible hardware optimizations
Hardware optimizations that apply to both or either the state machine or cache line block loop include
* performing the operations with the largest possible transfer sizes.
   * e.g. on an XLEN=32 machine, a state machine might have access to a few temporary registers that approach a cache line in size
* cache protocol optimizations
   * e.g. avoiding unnecessary RFOs
      * e.g. using operations such as ZALLOC/DCBZ, allocate a cache line obtaining ownership but not fetching data, filling it with zeros
      * e.g. not using RFOs since the operation knows that it is going to completely overwrite any data fetched by an RSO
* Possibly implemented by non-CPU copy engines
   * without blocking the processor that invoked the block operation
      * possibly by switching to a different hardware thread
Many other hardware optimizations for block memory operations are possible. Many are described in the literature.

# Terminology, suggested mnemonics

## Mnemonics for address range instructions
For address range instructions, e.g. those that might be implemented by state machines - arguably classic CISC, non-RIS instructions

Consider a single instruction that implements such a block memory operation.
We will use mnemonics such as those below.
Note that MEMZERO and MEMCOPY are the highest priority,
and much of this discussion will assume that only these are being implemented.


| Priority | mnemonic | C library | other |
|----------|----------|-----------|-------|
| medium   | MEMSET   | memset    |       |
| high     | MEMZERO  |           | bzero |
| high     | MEMCOPY  | memcpy    | bcopy |
| low      |          | memmove   |       |
| low      | MEMCMP   | memcmp    |       |

MEMCOPY differs only in minor spelling from memcpy.

The C library function memmove is not proposed for a hypothetical MEMMOVE instruction, since it's overlap semantics can be difficult.

MEMZERO is higher priority than MEMSET, because page zeroing is increasingly common in secure operating systems.  MEMZERO corresponds to memset with a zero fill. There is no standard C library function that specifically zero fills, although the legacy instruction library function bzero does zero fills. MEMSET/memset with a nonzero fill patternsuch as 0xDEADBEEF is common, but not as common as filling by zeros. (TBD: reference?) Moreover there are quite a few hardware optimizations that specifically apply to MEMZERO that do not necessarily apply to MEMSET with an arbitrary bit pattern (TBD: reference/describe).



# Cache line / fixed size memory block instructions.

I will not propose mnemonic for such cache line/fixed size memory block instructions here, except to mention in passing some that had been used in the literature and other instruction sets..

Zero fill without RFO: ZALLOC, IBM POWER DCBZ

CLMOVE: cache line from one location to another  (TBD: which ISA did this? Some HP ISA IIRC?)


# Instruction design: Register operand bindings suitable for state machine versus cache line loop implementations

Note that these mnemonics may apply both to instructions that are designed to be implemented by only a state machine, as well as to hybrid instructions that allow both state machine and cache line/fixed size memory block implementations.

* MEMZERO
  * RD: nbytes_left := MEMZERO( RS1: address, RS2: nbytes)
    * both RS1 and RS2/RD must be source/destination
  * MEMZERO( input/output RS1: address, input/output RS2: nbytes)
    * this is transparent to exceptions
    * both RD and RS1 must be source/destination
  * MEMZERO( input/output RS1: lo_address, input/output RS2: hi_address)
    * this is transparent to exceptions
    * only RS1 must be source/destination
  * RD: nbytes_left := MEMZERO( RS1: hi_address, RD: nbytes)
    * transparent to exceptions
    * only RD must be source destination
       * AFAIK only form that requires only a single source/destination operand, which goes from low to high
       * this is enabled by the strange seeming hi_address input

* MEMCOPY
  * MEMCOPY( RS1:nbytes, RS1: from_address, RS3: to_address )
    * all register operands RS1, RS2, RS3 must be source/dest to get exception transparency
  * MEMCOPY( RS1:nbytes, RS1: hi_from_address, RS3: hi_to_address )
    * only RS1 (which might be RD) must be source destination to get exception transparency
       * AFAIK only form that requires only a single source/destination operand, which goes from low to high
       * this is enabled by the strange seeming hi_address input

When these instructions are implemented as if by a state machine, exception transparency requires that some of the register operands be source/dest, both input and output. Classic risk instruction sets disapprove of source/dest register operands.

It is easy to implement MEMZERO as a cache line oriented instruction, wrapped in the loop for the full address range:
~~~~
   rs1 := address
   rs2 := nbytes
   LOOP
      rd:nbytes_left  :=MEMZERO(rs1,rs2)
      rs1 := rd
   ENDLOOP
~~~~
Slightly different definitions, e.g. returning nbytes_done versus nbytes_left, may require different amounts of hardware, e.g. fullwidth adders.

When defined only as a cache line oriented instruction, the exception transparency source/destination constraint on register operands does not need to be satisfied. So long as all exceptions are considered to be delivered before anything has been done, i.e. at the start of any instruction invocation. Such a cache line definition is an instruction that does not accomplish [[partial completion]], although the loop construct does.

It is possible to define this sort of instruction so that it can be implemented by either a state machine or a cache line loop, in different microarchitectures. Such a definition requires the exception transparency source/destination constraint, since it is trying to obtain [[partial completion]] in the state machine case.

# RECOMMENDATION

I think it would be cool to permit state machine implementations. I am confident that a state machine implementation can be significantly more efficient than a cache line oriented implementation for MEMCOPY.

I have figured out how to define the instruction so that it is suitable for both a state machine implementation and a cache line loop implementation. This requires the source/destination constraint of the state machine implementation, but has the loop instruction overhead of the cache line loop implementation. That is regrettable.

I believe that [[exception transparency for instructions with partial completion]] is an absolute requirement. Exception transparency simplifies exception handling, which is otherwise complicated either in hardware or in the software exception handler. Not having exception transparency for the hybrid form is essentially a virtualization hole, informing the code being executed where page fault*. Potentially informing malware that it is being run in malware detection environment.

I believe that forms that only have a single source/destination register are much more likely to be implemented and forms that require two or more source/destination registers.

The form MEMCOPY( RD:nbytes, RS1: hi_from_address, RS2: hi_to_address )
AFAIK is the only register binding form for MEMCOPY that requires only a single source/destination operand to achieve exception transparency,
which allows progress from low to high addresses.
Passing the high address of the memory blocks seem strange, but it is necessary to permit only RSD to be source/destination.

For symmetry I therefore prefer MEMCOPY( RD:nbytes, RS1: hi_address ).

IMHO correctness with respect to exception transparency and only requiring a single source/destination operand makes it most likely that instructions like MEMZERO and MEMCOPY will be acceptable for implementation in any given microarchitecture.

IMHO requiring multiple source/destinations, whether implemented in hardware at the instruction or at entry to exception handler, or in software in the exception handler, is quite possibly the kiss of death with respect to implementing this sort of instruction. For that matter, I suspect that requiring the cache line loop also highly decreases the likelihood of getting a state machine implementation, since any code size opera advantage is almost lost.

Let us look at the code size

In pseudocode
~~~~
memzero:
   rd := nbytes
   rs1 := lo_address + nbytes
   LOOP
      MEMZERO rd,rs1
   ENDLOOP
~~~~

~~~~
memcpy:
   rd := nbytes
   rs1 := lo_from_address + nbytes
   rs2 := lo_to_address + nbytes
   LOOP
      MEMCOPY rd,rs1,rs2
   ENDLOOP
~~~~

In assembly:
~~~~
memzero:
   rd := nbytes
   rs1 := lo_address + nbytes
L: MEMZERO rd,rs1
   BGE rd, 0, L
~~~~

~~~~
memcpy:
   rd := nbytes
   rs1 := lo_from_address + nbytes
   rs2 := lo_to_address + nbytes
L: MEMCOPY rd,rs1,rs2
   BGE rd, 0, L
~~~~

Of course, the pure state machine does not require the endloop branch BGE instruction.

The cost of supporting exception transparency for a state machine version while only requiring a single source/dest register RD is no more than one instruction per memory block. If multiple source/destination registers are provided, and registers already contain the start of the appropriate memory blocks, those instructions are not required. Similarly for a cache line block loop, although it obviously requires the end of loop. Conversely it is possible that compiler optimizations may be able to implement the low_address + nbytes calculations, although I think that might not be common because it would require code to be repeatedly zeroing or copying the same memory block, which seems unlikely.

Comparing

| operation | designed for                 | total instructions | <-- operand set up | loop branch | time |
| memzero   | state machine 1 srcdst        | 2                  | 1                  | 0           | 1 + size/?? |
|           | state machine 2 srcdst        | 1                  | 0                  | 0           | 0 + size/?? |
|           | state machine hybrid 1 srcdst | 3                  | 1                  | 1           | 2 + size/?? |
|           | state machine hybrid 2 srcdst | 2                  | 0                  | 1           | 1 + size/?? |
|           | cache loop                    | 2                  | 0                  | 1           | 0 + 2*size/CLsz |
| memcpy    | state machine 1 srcdst        | 3                  | 2                  | 0           | 2 + size/?? |
|           | state machine 2 srcdst        | 1                  | 0                  | 0           | 0 + size/?? |
|           | state machine hybrid 1 srcdst | 3                  | 2                  | 1           | 3 + size/?? |
|           | state machine hybrid 2 srcdst | 2                  | 0                  | 1           | 1 + 2*size/?? |
|           | cache loop                    | 2                  | 0                  | 1           | 0 + 2*size/CLsz |

The main difference between cache loop and the versions that permit the state machine is that the efficiency for the cache line loop is the block size divided by the cache line size, whereas that efficiency may be higher for the state machine implementations.

TBD: the terms 2*size/CLsz are not quite accurate. Implicitly assumes that one cache line can be read and written per cycle. As is possible on some high-end machines, but not so much on low-end machines. Nevertheless, I think they give a feeling for the time complexity. Essentially there is slightly more overhead for the one source dest forms, whether implemented in a state machine or in the hybrid. But the state machine may arguably provide a significant performance boost. Furthermore MEMZERO can benefit from other zero value optimizations, such as special bus transactions. Similarly, MEMCOPY state machine can use bit bit/funnel shift optimizations not available to a cache line loop.

OVERALL: IMHO the cache line loop implementations of MEMCOPY are not very attractive. They only apply to extremely aligned data, and/or on systems that support misaligned cache line transfers, e.g. into a write combining buffer. It might arguably be better just to provide one or a few explicit cache line size registers as an alternative to MEMCOPY for memcpy.  Such cache line size registers would also be available for other operations that scan over blocks of memory, such as MEMCMP/memcmp. Arguably this would amount to providing one or a few cache line sized vector registers. But this would begin the slippery slope to including much of the vector architecture. It would be highly desirable to subset the vector architecture.















