Some use cases require or prefer CMOs that apply to a set of memory addresses, typically a contiguous range.

CMOs are just one type of instruction that might wish to apply to a
set of memory addresses. See the generic discussion in [[Variable
Address Range Instructions like CMOs, MEMSET, MEMZERO, and
MEMCOPY]]. If there are variable address range CMOs as well as other
variable address range instructions like MEMZERO, then it would be
nice if they used similar design principles.

[[POR]]
[[STATUS: almost done - maybe]] - well, as much as can be done before we actually have a RISC-V working group

# SUMMARY: Fixed Block Size Prefetches and CMOs

## Variable Address Range CMOs

Proposed name: CMO.VAR.\<cmo-specifier>

Encoding: R-format
   * 3 registers: RD, RS1, RS2
      * Register numbers in RD and RS1 are required to be the same
         * If the register numbers in RD and RS1 are not the same an illegal instruction exception is raised
	   (unless such encodings have been reused for other instructions in the future).
         * The term RD/RS1 will refer to this register number

Assembly Syntax:
* CMO.VAR.\<cmo-specifier> rd,rs1,rs2

But, since register numbers in RD and RS1 are required to be the same, assemblers may choose to provide the to register operand version
* CMO.VAR.\<cmo-specifier> rd_and_rs1,rs2



Operands:
  * Input:
     * memory address range:
       * RS1 (RD/RS1) contains `lwb`, the lower bound, the address at which the CMO will start
       * RS2 contains `upb`, the upper bound of the range
     * type of operation
       * .[[\<cmo-specifier>]]: i.e. specified by the encoding of the particular CMO.VAR instruction
  * Output
     * RD (RSD/RS1) contains `stop_address`, the memory address at which the CMO operation stopped
        * if RD >= `upb`, the operation was completed
	* if RD = `lwb`, the operation stopped immediately, e.g. an exception such as a page fault or a data address breakpoint at lwb
	* if `lwb` < RD < `upb`, the operation has been partially completed
	    * e.g. at an exception such as

The range to which the CMO is applied is conceptually [RS1,RS2),
but is not allowed to be empty so is pedantically [ RS1:`lwb`, `upb`:max(RS1+1,RS2) ),
rounded below and above to whatever memory block size ( e.g. cache line size) is appropriate for the CMO.

The name "CMO.VAR.\<cmo-specifier> is just a placeholder. See [[Mnemonics and Names]] for a discussion of proposed mnemonics and names, including possibilities such as "COP (Cache Op)".

This instruction family is [[restartable after partial completion]]. E.g. on an exception such as a page fault or debug address breakpoint the output register RD is set to the data address of the exception,
and since the instruction is [[source/dest]], with the register numbers in RD and RS1 required to be the same, returning from the exception to the CMO.VAR instruction will pick up execution where it left off.

Similarly, implementations may only process part of the range specified by [RS1,RS2), e.g. only the 1st cache line, setting RD/RS1 to an address _within_ the next cache line.
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

## In Detail

### Range Definition [RS1:`lwb`,RS2:`upb`)
The CMO is applied to the range [RS1,RS2), i.e. to all memory addresses A such that RS1 <= A < RS2.
In other words, the range [`lwb`,`upb`), i.e. to all memory addresses A such that `lwb` <= A < `upb`.
[[Address comparisons are assumed to be unsigned]].
CMO.VAR is defined to always apply to at least one memory address, i.e. the range cannot be empty.
Therefore, the range may be specified more precisely as [ RS1:`lwb`, `upb`:max(RS1+1,RS2) ).

Pedantically, RS1 contains `lwb`, but RS2 only contains `upb?`, a candidate upperbound. The actual upper bound `upb`=max(RS1+1,RS2)=max(`lwb`+1,`upb?`).
I.e. strictly speaking we should write RS2:`upb?` rather than RS2:`upb`, but we will not always make this distinction.

CMOs (Cache Maintenance Operations) operate on [[NAPOT]] memory blocks such as cache lines, e.g. 64B, that are  implementation specific, and which may be different for different caches in the system.

CMO.VAR is defined to always apply to at least such memory block, even if RS1 >= RS2.

The range's upper and lower bounds, RS1:`lwb` and `upb` are _not_ required to be aligned to the relevant block size.
Therefore RS1:`lwb` is an address _within_ the first memory block to which the operation will apply.
Similarly, `upb`, the highest address in the range specified by the user, may lie within such a memory block, so the operation may include and apply beyond `upb` to the next block boundary.

As described in [[Advisory vs Mandatory CMOs]]:
* Some CMOs are optional or advisory: they may or may not be performed,
  * Such advisory CMOs may be performed beyond the range [`lwb`,`upb`)
* However, some CMOs are mandatory, and may affect the values observed by [[timing independent code]].
  * if `upb` lies in a memory block that does not overlap any of the blocks in [`lwb`,`upb`)
    then the implementation must guarantee that the mandatory or destructive CML has not been applied to the memory block starting at address `upb`.

Security timing channel related CMOs are mandatory but do not affect the values observed by [[timing independent code]].
TBD: are such CMOs required not to apply beyond the [[address range rounded to block granularity]]?
POR: it is permitted for any non-value changing operations to apply beyond the range.

NOTE: there is much disagreement with respect to terminology, whether
operations that directly affect values (such as [[DISCARD cache
line]]) are to be considered CMOs at all, or whether they might be
specified by the CMO instructions such as CMO.VAR. For the purposes of
this discussion we will assume that they could be specified by these
instructions.

#### Issues with Range Specification

The range is defined as [RS1:`lwb`,RS2:`upb`)
using unsigned comparisons,
and an exclusive upper bound.

Consequently, there is no way to define a range that includes the maximum possible unsigned number, ~0 or -1 or all 1s, 11..111.
Although that address will nearly always be within the same cache line as 11..110, -2.

Similarly, one cannot define a range that crosses the -1 to 0 boundary,
even though RISC-V permits DRAM to be placed at both sides.

RATIONALE:

The ranges defined using RS1:`lwb` and RS2:`upb`
rather than RS1:`lwb`,RS2:`nbytes`, `upb=lwb+nbytes`
because the latter would require both RS1 and RS2 to be [[source/dest]] operands
if addresses are scanned in ascending order.

Exclusive upper bound [RS1:`lwb`,RS2:`upb`)
is motivated mainly to permit `upb = lwb + nbytes` in code setting up the instruction.

Unsigned address comparisons are familiar to most people, but require forbidding the -1 to 0 crossing.
Signed address comparisons forbid only the maximum positive to minimum negative crossing, which usually is not populated by DRAM or devices.

See more [[Issues with Range Specification]]


### Possible implementations ranging from cache line at a time to full address range

The CMO.VAR instruction family permits implementations that include
1. operating a cache line at a time
2. trapping and emulating (e.g. in M-mode)
3 HW state machines that can operate on the full range
   * albeit stopping at the first page fault or exception.

First: Cache line at a time implementations are typical of many other ISAs, RISC and otherwise.

Second: On some implementations the actual cache management interface is
non-standard, e.g. containing sequences of CSRs or MMIO accesses to control
external caches. Such implementations may trap the CMO instruction,
and emulate it using the idiosyncratic mechanisms.
Such trap and emulation would have a high-performance cost if performed a cache line at a time.
Hence, the address range semantics.

Third: While hardware state machines have some advantages, it is not
acceptable to block interrupts for a long time while cache flushes are
applied to every cache line in address range. Furthermore, address range CMOs
may be subject to address related exceptions such as page-faults and debug breakpoints.


#### [[Source/dest]] to support [[exception transparency]]

This instruction family is [[restartable after partial completion]]. E.g. on an exception such as a page fault or debug address breakpoint the output register RD is set to the data address of the exception,
and since the instruction is [[source/dest]], with the register numbers in RD and RS1 required to be the same, returning from the exception to the CMO.VAR instruction will pick up execution where it left off.

RATIONALE: This proposal has chosen to implement [[source/dest]] by requiring separate register fields RD and RS1 to contain the same value. An alternative was to make register field RD both an input and an output, allowing RS1 and RS2 to be used for other inputs. Separate RD=RS1 source/dest is more natural for a RISC instruction decoder, and detecting RD=RS1 has already been performed for other RISC-V instructions, e.g. in the V extension. However separate RD=RS1 "wastes" instruction encodings by making RD!=RS1 illegal,, and leaves no register free for any 3rd operand such as the CMO type, hence requiring .\<cmo-specifier> in the instruction encoding.

TBD: see [[who cares about RD=RS1 source/dest?]]


#### Loops to support cacheline at a time implementations

The CMO.VAR instruction is intended to be used in a software loop such as that below

In pseudocode:
~~~
x11 := lwb
x12 := upb
LOOP
   CMO.VAR.<> x11,x11,x12
UNTIL x1 >= x12
~~~
In assembly code:
~~~
    x11 := lwb
    x12 := upb
L:  CMO.VAR.<> x11,x11,x12
    bltu x11,x12,L
~~~
Note that the closing comparison BLTU is unsigned, which is required to match the semantics of the instruction itself.

#### Discussion

The software loop around the CMO range instructions is required only to support cache line at a time implementations.
If this proposal only wanted to support hardware state machines or trap and emulate, the software loop would not be needed.

Similarly, the upper bound operand RS2:`upb?`, is only required to support address range aware implementations,
such as trap and emulate or hardware state machines.
Cache line at a time implementations may ignore the RS2 operand.
Therefore, the operation is always applied to at least one memory address.

To guarantee that the loop wrapped around the CMO range instructions makes forward progress
in the absence of an exception the value output to RD must always be greater than the value input from RS1,
recalling that register numbers RD and RS1 are required to be the same.
(On an exception output RD may be unchanged from input RS1.)

Although some CMOs may be optional or advisory, that refers to their effect upon memory or cache.
The range oriented CMOs like CMO.VAR cannot simply be made into NOPs, because the loops above would never terminate.
The cache management operation may be dropped or ignored,
but RD must always be returned greater than RS1.
(TBD: is it acceptable to always return all 1s, the largest possible unsigned number?
See [[Issues With Range Specification]].)

Cache line at a time implementations may find it convenient to set RD to the starting address of the next cache line,
but this is not required and cannot be relied on by software.
It would also be acceptable to increment RS1 by the cache line size,
to return only an random address within the next cache line that is not guaranteed to be the beginning of the next cache line.
I.e. software should *not* use this instruction to determine the cache line or any other memory block size.

Implementations are NOT required to output an address in RD that is in the next memory block.
They are only required to return an address in RD that is monotonically increasing.
For example: system may have multiple cache line sizes, e.g. 64B and 128B, and may always increment by the smaller block size.
Therefore, cache lines may be flushed multiple times.
Although obviously implementations will try to avoid is for performance reasons.



### Exceptions

* Illegal Instruction Exceptions: taken, if the CMO.VAR.\<cmo-specifier> is not supported.

* Permission Exception: for CMO not permitted
   * Certain CMO (Cache Management Operayions) may be permitted to a high privilege level such as M-mode, but may be forbidden to lower privilege lebels such as S-mode or U-mode.
   * TBD: exactly how this is reported. Probably like a read/write permission exception. Possibly requiring a new exception because identifier

* Page Faults: taken
* Other memory permissions exceptions (e.g. PMP violations): taken
* Debug exceptions, e.g. data address breakpoints: taken.

* ECC and other machine checks: taken?
   * see below

### ECC and other machine check exceptions during CMOs

Note: the term "machine check" refers to an error reporting mechanism for errors such as ECC or lockstep execution mismatches. TBD: determine and use the appropriate RISC-V terminology for "machine checks".

Machine checks may be reported as exceptions or recorded in logging registers or counters without producing exceptions.

In general, machine checks should be reported if enabled and if an error is detected that might produce loss of data. This consideration applies to CMOs: e.g. if a CMO tries to flush a dirty cache line that contains an uncorrectable error, a machine check should be reported.
However, an uncorrectable error in a clean cache line may be ignorable since it is about to be invalidated and will never be used in the future.

Similarly, a DISCARD cache line CMO may invalidate dirty cache line data without writing it back. In which case, even an uncorrectable error might be ignored, or might be reported without causing an exception.

Such machine check behavior is implementation dependent.


### Permissions for CMOs

#### Memory address based permissions for CMOs

The CMO.VAR.\<cmo-specifier> instructions affect one or more memory addresses,
and therefore are subject to memory access permissions.

Most CMO (Cache Management Ops) require only read permission:
* CLEAN (write out dirty data, leaving clean data in cache)
* FLUSH (Write out dirty data, invalidate all lines)

Even though "clean" and "flush" may seem to be like write operations, and the dirty data can only have occurred as result of write operations,
the dirty cache lines may have been written by a previous mode that shares memory with the current mode that has only read access.

The overall principal is, if software could have accomplished the same operation e.g. flushing dirty data or evicting lines, using ordinary loads and stores, then only read permissions are required.

If the operation is performed read permissions are required to all bytes in the range.

(If an optional or advisory operation is not performed, no read permissions checks or exceptions are required.)


Some CMOs affect values, and therefore require at least write permission:
* ZALLOC (Allocate Zero Filled Cache Line without RFO)
   * e.g. IBM POWER DCBZ

Some CMOs not only affect value, but might also affect the cache protocol and/or expose data from other privileged domains.
If implemented, these require privileges beyond those specified for memory addresses.
Such operations include:
* CLALLOC (Allocate Cache Line with neither RFO nor zero fill)
   * e.g. IBM POWER DCBA
* DISCARD cache line
   * discard dirty data without writing back

Similarly, while it might be possible for an ordinary user to arrange to flush a line out of a particular level of the cache hierarchy,
doing so with ordinary loads and stores might be a very slow process,
whereas doing so with a CMO instruction would be much more efficient, possibly leading to DOS (Denial of Service) attacks.
Therefore, even CMOs that might otherwise require only read permission
may be "modulated" by privileged software.

#### [[Permissions by CMO type]]

See section [[Permissions by CMO type]]
which applies to both address range CMO.VAR.\<cmo-specifier> and microarchitecture entry range CMO.UR.\<cmo-specifier>
CMOs, as well as to [[Fixed Block Size CMOs]].
