# TOP RANKED PROPOSAL

This is my, Andy Glew's, preferred proposal as of Monday, January 27, 2020-01-27. I prefer it, because it is both the most abstract animals flexible. However, I expect resistance, so have fallback proposals.

# CMO.UR - microarchitecture range CMO

Some use cases require or prefer CMOs that apply to a set of memory addresses, typically a contiguous range.

# Microarchitecture Structure Range CMOs

Proposed name: CMO.UR.\<cmo-specifier>

Encoding: R-format
   * 2 registers: RD, RS1
      * abbreviated CMO.UR.$id rd==rs1
      * R format actually has three registers: unused register RS2 is required to be zero
      * Register numbers in RD and RS1 are required to be the same
         * Why?: restartability
         * If the register numbers in RD and RS1 are not the same an illegal instruction exception is raised
	   (unless such encodings have been reused for other instructions in the future).
         * The term RD/RS1 will refer to this register number

Assembly Syntax:
* CMO.UR.\<cmo-specifier> rd,rs1,x0

But, since register numbers in RD and RS1 are required to be the same, and RS2 is required X0, assemblers are encouraged to provide the single register operand version
* CMO.UR.\<cmo-specifier> rd_and_rs1


Operands:
  * Input:
     * memory address range:
       * RS1 (RD/RS1) contains `start_entry`, the [[microarchitecture entry number]] for the specified cache at which the CMO will start
          * RS1 = zero is the first entry
     * type of operation
       * .[[\<cmo-specifier>]]: i.e. specified by the encoding of the particular CMO.UR instruction
  * Output
     * RD (RSD/RS1) contains `stop_entry`, the microarchitecture entry number at which the CMO operation stopped
        * if RD is negative the operation has completed
           * IF RD=-1 (all 1s unsigned, ~0) the operation completed successfully
           * Other negative values of RD are reserved

The name "CMO.UR.\<cmo-specifier> is just a placeholder. See [[Mnemonics and Names]] for a discussion of proposed mnemonics and names, including possibilities such as "COP (Cache Op)".

This instruction family is [[restartable after partial completion]]. E.g. on and exception such as a [[machine check error]] or a debug address breakpoint the output register RD is to the microarchitecture entry number where the exception was incurred.
Since the instruction is [[source/dest]], with the register numbers in RD and RS1 required to be the same, returning from the exception to the CMO.VAR instruction will pick up execution where it left off.

Similarly, implementations may only process part of the range specified by microarchitecture entry numbers [0,num_entries),
e.g. only the 1st cache line, setting RD/RS1 to an address _within_ the next cache line.
Software using this instruction is required to wrap it in a loop to process the entire range.

The .\<cmo-specifier> derived from the instruction encoding (not a general-purpose register operand) specifies operations such as
* CLEAN (write back dirty data, leaving clean data in cache)
* FLUSH (writeback dirty data, leaving invalid data in cache)
and other operations, as well as the caches involved. See [[CMO (Cache Management Operation) Types]].
(TBD: I expect that one or more of the .\<cmo-specifier> will be something like a number identifying a group of CSRs loaded with an extended CMO type specification.)

In assembly code certain CMO specifiers will be hardlined, and others may be indicated by the group number:
* CMO.VAR.CLEAN
* CMO.VAR.FLUSH
* CMO.VAR.0
* CMO.VAR.1

#### Loops to support cacheline at a time implementations

The CMO.VAR instruction is intended to be used in a software loop such as that below

In pseudocode:
~~~
// Possibly set up CMO type in CSR(s) specified by CMO.UR.<> instruction
x11 := x0
LOOP
   CMO.UR.<> x11,x11
UNTIL X11 < 0
~~~
In assembly code:
~~~
    MOV x11,x0
L:  CMO.UR.<> x11,x11
    BGEZ x11,L
~~~


## In Detail

### Microarchitecture Entry Range

When used in a loop such as `X11:=0; LOOP CMO.UR X1; UNTIL X11 < 0`
the cache management operation is applied to a range of microarchitecture entry numbers
for the cache specified by the .<cmo-type> field of the CMO.UR instruction.

Such microarchitecture entry ranges are defined to start at entry zero
and extended to some maximum entry number.
The maximum entry number is not needed by this instruction, although it may be possible to obtain from some [[system description]] mechanism such as [[CPUID]].

Typical cache entries have have (set,way) coordinates.
The microarchitecture entry number may be a simple transformation such as
`e = set*nways+way`
or `e = way*nsets+set`,
and the iteration may simply increment by one for every cache line affected until the maximum number of entries  is reached.

When the maximum number of entries is reached the CMO.UR instruction sets RD=-1 (all 1s unsigned).
i.e. the instruction is required to skip from the maximum microarchitecture entry number to -1.

(Other negative final values of RD are reserved for possible error indications. However, at this moment all errors are expected to cause traps.)

An implementation may simply increment by want every cache line affected until the maximum number of entries is reached, and then terminate with -1.
However, implementations perform different arbitrary mappings, and may perform nonmonotonic iterations of the microarchitecture entry number, so long as the sequence `i1=successor(0), i2=successor(i1), ...`
eventually enumerates all valid entry numbers in the specified cache,
and is strictly positive, i.e. nonzero.
This sequence is not guaranteed monotonic. (Such a "twisted" sequence might be used to hide microarchitecture details and mitigate information leaks.)
This sequence may contain numbers that do not map to actual cache lines, so long as those invalid mappings do not cause exceptions. (E.g. [[Way Locking and CMO.UR]] or [[Multiple Caches and CMO.UR]].) Such implementations should not, however, "waste too much time" on invalid entries.

TBD: tighten specification to discourage "out of thin air"

### [[Advisory vs Mandatory CMOs]]

As described in [[Advisory vs Mandatory CMOs]]:
* Some CMOs are optional or advisory: they may or may not be performed,
  * Such advisory CMOs may be performed beyond the range of microarchitecture entry numbers specified
* However, some CMOs are mandatory, and may affect the values observed by [[timing independent code]].
  * Such architectural CMOs are guaranteed not to be performed beyond the range of microarchitecture entry numbers specified (?? TBD: is this possible, if cache line size is very ??)

Security timing channel related CMOs are mandatory but do not affect the values observed by [[timing independent code]].
POR: it is permitted for any non-value changing operations to apply beyond the range.

NOTE: there is much disagreement with respect to terminology, whether
operations that directly affect values (such as [[DISCARD cache
line]]) are to be considered CMOs at all, or whether they might be
specified by the CMO instructions such as CMO.VAR. For the purposes of
this discussion we will assume that they could be specified by these
instructions.


### Possible implementations ranging from cache line at a time to cache

The CMO.UR instruction family permits implementations that include
1. operating a cache line at a time
2. trapping and emulating (e.g. in M-mode)
3 HW state machines that can operate on the full range
   * albeit stopping at the first page fault or exception.

First: Cache line at a time implementations are typical of many other ISAs, RISC and otherwise.

Second: On some implementations the actual cache management interface is
non-standard, e.g. containing sequences of CSRs or MMIO accesses to control
external caches. Such implementations may trap the CMO instruction,
and emulate it using the idiosyncratic mechanisms.
Such trap and emulation would have high performance cost if performed a cache line at a time.
Hence, the address range semantics.

Third: While hardware state machines have some advantages, it is not
acceptable to block interrupts for a long time while cache flushes are
applied to every cache line in address range. Furthermore, address range CMOs
may be subject to address related exceptions such as page-faults and debug breakpoints.
The definition of this instruction permits range implementations that are [[restartable after partial completion]].


#### [[Source/dest]] to support [[exception transparency]]

This instruction family is [[restartable after partial completion]]. E.g. on an exception such as a page fault or debug address breakpoint the output register RD is set to the data address of the exception,
and since the instruction is [[source/dest]], with the register numbers in RD and RS1 required to be the same, returning from the exception to the CMO.VAR instruction will pick up execution where it left off.

RATIONALE: This proposal has chosen to implement [[source/dest]] by requiring separate register fields RD and RS1 to contain the same value. An alternative was to make register field RD both an input and an output, allowing RS1 and RS2 to be used for other inputs. Separate RD=RS1 source/dest is more natural for a RISC instruction decoder, and detecting RD=RS1 has already been performed for other RISC-V instructions, e.g. in the V extension. However separate RD=RS1 "wastes" instruction encodings by making RD!=RS1 illegal,, and leaves no register free for any 3rd operand such as the CMO type, hence requiring .\<cmo-specifier> in the instruction encoding.

TBD: see [[who cares about RD=RS1 source/dest?]]

###[[Actual CMO Operations]]

#### Discussion

The software loop around the CMO range instructions is required only to support cache line at a time implementations.
If this proposal only wanted to support hardware state machines or trap and emulate, the software loop would not be needed.

Although some CMOs may be optional or advisory, that refers to their effect upon memory or cache.
The range oriented CMOs like CMO.VAR cannot simply be made into NOPs, because the loops above would never terminate.
The cache management operation may be dropped or ignored,
But RD must be set in such a way that the sequence beginning with zeros will eventually touch all cache lines necessary and terminate with -1. (TBD: link the text above.)

### Exceptions

* Illegal Instruction Exceptions: taken, if the CMO.VAR.\<cmo-specifier> is not supported.

* Permission Exception: for CMO not permitted
   * Certain CMO (Cache Management Operations) may be permitted to a high privilege level such as M-mode, but may be forbidden to lower privilege lebels such as S-mode or U-mode.
   * TBD: exactly how this is reported. Probably like a read/write permission exception. Possibly requiring a new exception because identifier

* Page Faults:
   * most cache hierarchies cannot receive page-faults on CMO.UR instructions, since the virtual the physical address translation has been performed before the data has been placed in the cache
   * however, there do exist microarchitectures (not necessarily RISC-V microarchitectures as of the time of writing)
     whose caches use virtual addresses, and which perform the virtual the physical address translation on eviction from the cache
      * such implementations _might_ receive page-faults, e.g. evicting dirty data for which there is no longer a valid virtual to physical translation in TLB or page table
      * although we recommend that system SW on such systems arrange so that dirty data is flushed before translations are invalidated
* Other memory permissions exceptions (e.g. PMP violations): taken
* Debug exceptions, e.g. data address breakpoints: taken.

* ECC and other machine checks: taken


### ECC and other machine check exceptions during CMOs

Note: the term "machine check" refers to an error reporting mechanism for errors such as ECC or lockstep execution mismatches. TBD: determine and use the appropriate RISC-V terminology for "machine checks".

Machine checks may be reported as exceptions or recorded in logging registers or counters without producing exceptions.

In general, machine checks should be reported if enabled and if an error is detected that might produce loss of data. This consideration applies to CMOs: e.g. if a CMO tries to flush a dirty cache line that contains an uncorrectable error, a machine check should be reported.
However, an uncorrectable error in a clean cache line may be ignorable since it is about to be invalidated and will never be used in the future.

Similarly, a DISCARD cache line CMO may invalidate dirty cache line data without writing it back. In which case, even an uncorrectable error might be ignored, or might be reported without causing an exception.

Such machine check behavior is implementation dependent.


### Permissions for CMOs

#### Memory address based permissions for CMOs
Most CMO.UR.<> implementations do not need to use address based permissions.
CMO.UR for the most part are controlled by [[Permissions by CMO type]].

Special cases for memory address based permissions for CMO.UR include:

E.g. virtual address translation permissions
* do not apply to most implementations
* might apply to implementations that perform page table lookup when evicting dirty data from the cache.
   * are not required to invalidate cache lines in such implementations

E.g. PMP based permissions
* TBD: what should be done if CMO.UR is evicting a dirty line a memory region whose PMP indicates not writable in the current mode?
   * this may be implementation specific
   * most implementations will allow this
      * assuming that privileged SW will have flushed the cache
        before entering the less privilege mode
        in order to prevent any problems that might arise
        (e.g. physical DRAM bank switching)




#### [[Permissions by CMO type]]

See section [[Permissions by CMO type]]
which applies to both address range CMO.VAR.\<cmo-specifier> and microarchitecture entry range CMO.UR.\<cmo-specifier>
CMOs, as well as to [[Fixed Block Size CMOs]].

### Multiple Caches and CMO.UR

Cache management operations may affect multiple caches in a system. E.g. flushing data from a shared L2 may invalidate data in multiple processors' L1 I and D-caches, in addition to writing back dirty data from the L2, while traversing and invalidating an L3 before eventually being sent to memory. However, often the invalidation of multiple peer caches, the L1 I and D caches, is accomplished by cache inclusion mechanisms such as backwards and validate.

However, sometimes it is necessary to flush multiple caches without relying on hardware coherence cache inclusion. This could be achieved by mapping several different caches's (set,way) or other physical location into the same microarchitecture entry number space. However, this is by no means required



## [[CMO descriptor]] - what is affected

See [[CMO descriptor]] for an explanation of how the CMO instructions, and this instruction CMO.UR in particular, specify which caches and branch predictors and other microarchitecture state should be managed.

Suffice it to say that a single CMO.UR instruction is able to perform invalidations and/or cache flushes of multiple caches in the same CMO.UR loop construct. This is accomplished by the [[CMO UR descriptor operand]]

## [[CMO UR index]]

### Traditional microarchitecture cache invalidation loops in the past

Many computer architectures can invalidate a cache in time proportional to the number of entries within the cache using a code construct that looks like the following:

~~~~~~
   FOR S OVER ALL sets in cache C
      FOR W OVER ALL ways in cache C
           INVALIDATE (cache C, set S, way W)
~~~~~~

Note that not all microarchitecture data structures have the associative (set,way) structure. We might generalize the above as

~~~~~~
 FOR E OVER ALL entries in hardware data structure HDS
     INVALIDATE (hardware data structure HDS, entry E)
~~~~~~

If multiple hardware data structures need to be flushed or invalidated one might do something like the following

~~~~~~
  FOR H OVER ALL hardware data structures that we wish to invalidate
    FOR E OVER ALL entries in hardware data structure HDS
       INVALIDATE (hardware data structure H, entry E)
~~~~~~

Without loss of generality we will assume that if a hardware data structure has an O(1) bulk invalidate, that it is handle as above, e.g. that the "entry" for the purposes of invalidation will be the entire hardware data structure.  Similarly, some hardware data structures might invalidate for entries, e.g. all of the lines in a cache set, at once.

Portable code might be able to determine what hardware data structures it needs to invalidate by inspecting a [[system description such as CPUID or config string]]. However, it may be necessary to invalidate the hardware data structures e.g. caches in a particular order. E.g. on a system with no cache coherence, not even hierarchical, it may be necessary to flush dirty data first from the L1 to the L2, then from the L2 to the L3, ... ultimately to memory.

### CMO.UR abstracts and unifies microarchitecture cache invalidation loops

CMO.UR and the [[CMO UR index]] abstract such microarchitecture dependencies as follows:

There is no need to loop over various caches and other hardware data structures.  The [[CMO.UR loop construct]] loops over all hardware data structures and all entries in those hardware data structures as needed.

~~~~~~
   reg_for_cmo_index := 0   // maximum positive signed integer
   LOOP
      CMO.UR RD:reg_for_cmo_index, RS1:reg_for_cmo_handle
   UNTIL reg_for_cmo_index < 0
~~~~~~

For any particular CMO (as specified by a [[CMO descriptor]]) all of the various hardware data structures, caches are combined into the same [[CMO UR index]] space, which is a subset of the positive integers of length XLEN.

TBD: move this example into a separate page.


For example:

| CMO UR index  | Description |
| ------------- | ------------ |
| 1<<(XLEN-1)-1 | maximum positive integer, RD input value at start of CMO loop construct |
| | unused - CMO.UR skips over |
| ** L2$ ** | 16-way 64M L2 D$ / 64B lines => 2^20 = 1M entries
| 1FFFFF | L2$ entry #1M-1, i.e. set #16K-1, way #15
| ... | ... other L2$ entries ... |
| 1.0000 | L2$ entry #0, i.e. set #0, way #0
|  | unused - CMO.UR skips over |
| ** L1 D$ ** | 8-way 32K L1 D$ / 64B lines => 2^9 = 512 entries
| 21FF | D$ entry #511, i.e. set #63, way #7
| ... | ... other D$ entries ... |
| 2001 | D$ entry #1, i.e. set #0, way #1
| 2000 | D$ entry #0, i.e. set #0, way #0
|  | unused - CMO.UR skips over |
| ** L1 I$ ** | 4-way 16K L1 I$ / 64B lines => 2^8 = 256 entries 1000H
| 10FF | I$ entry #255, i.e. set #63, way #3
| ... | ... other I$ entries ... |
| 1001 | I$ entry #1, i.e. set #0, way #1
| 1000 | I$ entry #0, i.e. set #0, way #0
|  | unused - CMO.UR skips over |
| 0 | final value if CMO.UR completes successfully |
| <0 | reserved for error reporting |

I.e. each hardware data structure is allocated a range of indexes in the [[CMO UR index]] space. The [[CMO.UR loop construct]] loops over the indexes from largest possible to smallest. Therefore, the order of the flushes or invalidations is implied by the index range allocation.

~~~~~~
   reg_for_cmo_index := 0
   LOOP
      CMO.UR RD:reg_for_cmo_index, RS1:reg_for_cmo_handle
   UNTIL reg_for_cmo_index < 0
~~~~~~

The mapping of hardware data structures and their entries into the [[CMO UR index]] space is microarchitecture and implementation specific. Portable software should not rely on any such mapping.

The invalidation or flushes desired by any particular cache management operation, as specified by its [[CMO descriptor]], will probably not involve touching all possible [[CMO UR index]].  Therefore, the [[CMO UR index]] traversal for any particular [[CMO descriptor]] may skip - e.g. in the above example, if one desires only to invalidate the instruction cache, one would skip the ranges for the L2 in the L1 data cache. An alternate implementation would be to create a different mappings of CMO UR indexes to hardware data structure entries for different CMOs.

At the very least, CMO.UR will skip from the starting value 1<<(XLEN-1)-1 to the largest [[CMO UR index]] value defined for the requested operation. It is also expected to skip CMO UR index values when the hardware data structures are not allocated contiguously within the CMO UR index space.

## CMO UR indexes should not be created out of thin air

Software invoking CMO.UR should not create arbitrary CMO UR indexes "out of thin air".

The index values should only be as obtained from the [[CMO.UR loop construct]]

   reg_for_cmo_index := 1<<(XLEN-1) - 1   // maximum positive signed integer
   LOOP
      CMO.UR RD:reg_for_cmo_index, RS1:reg_for_cmo_handle
   UNTIL reg_for_cmo_index <= 0

Invoking CMO.UR with input register (RD) index values that were not as obtained from the sequence above is undefined.
* Obviously, if invoked from user code there must be no security flaw. Similarly, if executed by a guest OS on top of a hypervisor.
* It is permissible for an implementation to ignore CMO UR index values that are incompatible with the [[CMO descriptor]]

If the software executing the [[CMO loop construct]] performs its own skipping of CMO UR indexes, the effect is undefined (although obviously required to remain secure).  In particular, it cannot be guaranteed that any or all of the work required to be done by the [[CMO.UR loop construct]] will have been completed.

Note: the loop construct can be interrupted and restarted from scratch. There is no requirement that the loop construct be completed.

A thread might migrate from one CPU to another while the CMO loop construct is in progress. If this is done it is the responsibility of the system performing the migration to ensure that the desired semantics are obtained. For example, the code that is being migrated might be restricted to only apply to cache levels common to all processors migrated across. Or similarly the runtime performing the migration might be required to ensure that all necessary caches are consistent. [[(see issue)|ISSUE - process migration argues for whole cache invalidation operations and against the partial progress loop construct]].

ISSUE: should it be legal for software to save the indexes from a first traversal of this loop and replay them later?
* Certainly not if the operation as specified by the [[CMO descriptor]] is different from that for which the indexes were obtained.
* I would like to make it illegal overall, but I can't CNP practical way to do this.


## Errors during CMO.UR

CMO.UR's output register RD is set to zero on successful completion of the operation.

Negative values for CMO.UR's output register RD are reserved to indicate possible errors. At this point in time (Monday, January 27, 2020-01-27), no such errors are defined. Any errors encountered while performing CMO.UR (e.g. on correctable errors in a cache tag) should be reported using normal [[RISC-V hardware error reporting]] mechanisms (e.g. [[machine check]] exceptions).

Rationale: it is probably best for CMO.UR to use normal [[RISC-V hardware error reporting]] mechanisms, such as immediate and/or deferred machine check exceptions, and/or recording error status in CSRs.  However, it is possible that some CMOs may be used in situations where normal error reporting is either not available or is inconvenient. It is straightforward to reserve negative values to indicate possible errors when the instruction is created. It would not be possible to retroactively change the definition of the CMO.UR instruction to do such error reporting if there were no such reserved values.

Note: unfortunately, such error reporting can not be performed for the memory address range based CMOs, CMO.FR, since there RD return value can assume all permissible values as it is an excellent address.
