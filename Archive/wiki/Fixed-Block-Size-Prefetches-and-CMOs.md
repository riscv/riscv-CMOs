# SUMMARY: Fixed Block Size Prefetches and CMOs

[[STATUS: almost done -maybe]] - not really. This refers to the technical concepts, but NOT to this wiki page. Which as of 2020-01-23_Thursday_17h01 is just random clippings from two pages where meeting notes were taken, that have not yet been organized.

WIP: converting to actual proposal asciidoc: [[draft Fixed Block Size Prefetches and CMOs]]


## Fixed Block Size Prefetches

Proposed name: PREFETCH.64B.R
* encoding: ORI with RD=R0, i.e. M[rs1+offset12]
* affects cache line containing virtual address M[rs1+offset12]
* see [[Mnemonics and Names]] for a discussion of proposed mnemonics and names

Proposed name: PREFETCH.64B.W [^mnemonics]
* encoding: ANDI with RD=R0, i.e. M[rs1+offset12]
* affects cache line containing virtual address M[rs1+offset12]
* see [[Mnemonics and Names]] for a discussion of proposed mnemonics and names

## Fixed Block Size Clean and Flush CMOs

Proposed name: CMO.64B.CLEAN.toL2
* more descriptive name: D1-Clean-to-L2 64B
* OR format with RD=R0, RS2=R0
* affects cache line containing virtual address M[rs1]
* "clean"
  * write dirty back,
  * keep clean copy of all lines in cache, both originally dirty and clean
* see [[Mnemonics and Names]] for a discussion of proposed mnemonics and names

Proposed name: CMO.64B.FLUSH.toL2
* more descriptive name: D1-Flush-to-L2 64B
* AND format with RD=R0, RS2=R0
* affects cache line containing virtual address M[rs1]
* "flush"
  * write dirty back,
  * invalidate all lines in cache, both originally dirty and clean
* see [[Mnemonics and Names]] for a discussion of proposed mnemonics and names


The more descriptive names "D1-Clean-to-L2" and "D1-Flush-to-L2" are more descriptive of the implementation & intent on a typical system at the time this is being written. The proposed names such as CMO.64B.FLUSH.toL2 are more generic, and may apply when the cache hierarchy is different. (Obviously "toL2" is microarchitecture specific, and should be replaced by something like "SHARED-LEVEL".) See [[Mnemonics and Names]] for a discussion of proposed mnemonics and names.


The intent is that dirty data be flushed to some cache level common or shared between all or most processors of interest. E.g. if all processors share the L2, flush their L1s to the L2. If all processors share and L3, then flush their L1s and L2s to the L3. And so on. Obviously, exactly what level flushes done to depends on the cache hierarchy and platform.

(More precise control is found in the variable address range CMOs. We do not want to spend all of the increasingly scarce instruction encodings to encode all hypothetically desirable prefetches and CMOs in the instruction format that touches Mem[reg+imm12]. Some other instructions use register operands to allow more prefetch and CMO types.)


# DETAILS

## Fixed minimum block size - NOT cache line size

These instructions are defined to be associated with a a fixed block size - actually a minimum fixed block size.

NOT the microarchitecture specific cache line size.

Currently the fixed block size is only defined to be 64 bytes.  Instruction encodings are reserves for other block sizes, e.g. 256 bytes. However, there is unlikely to be room to support all possible cache line sizes in these instructions.

The fixed block size of these instructions is NOT a cache line size. The intention is to hide the microarchitecture cache line size, which may even be different on different cache levels in the same machine, while allowing reasonably good performance across machines with different cache line sizes.

The fixed minimum block size (FSZ) is essentially a contract that tells software that it does not need to prefetch more often than that size.  Implementations are permitted to "round up" FSZ: e.g. on a machine with 256 byte cache lines, each PREFETCH.64B.[RW] and CMO.64B.{CLEAN,FLUSH} may apply to an entire 256 byte cache line. Conversely, on a machine with 32 byte cache lines, it is recommended that implementations of these instructions to address A apply similar operations to cache lines containing address A and A+32. "It is recommended" because it is permissible for all of these operations defined on this page to be ignored, treated as NOPs or hints.

The intent of the fixed minimum block size is to set an upper bound on prefetch instruction overhead. E.g. if standing an array of 32 byte items `LOOP A[i] ENDLOOP`, one might prefetch at every iteration of the loop `LOOP A[i]; prefetch A[i+delta] ENDLOOP`. However, prefetch instruction overhead often outweighs the memory latency benefit of prefetch instructions. If one knows that the cache line size is 256 bytes, i.e. once every 256/4=64 iterations of the loop, one might unroll the loop 64 times `LOOP A[i+0]; ... A[i+63]; prefetch A[i+63+delta] ENDLOOP`, thereby reducing the prefetch instruction overhead to 1/64.  But if the cache line size is 64 bytes you only need to enroll 64/4=16 times: `LOOP A[i+0]; ... A[i+15]; prefetch A[i+15+delta] ENDLOOP`.  The prefetches are relatively more important, but the overhead of unrolling code to exactly match the line size is greatly reduced.

The fixed minimum block size is an indication that the user does not need to place prefetches any closer together to get the benefit of prefetching all of a contiguous memory region.


## The usual details

* Page Fault: NOT taken for PREFETCH
  * The intent is that loops may access data right up to a page boundary beyond which they are not allowed, and may contain prefetches that are an arbitrary stride past the current ordinary memory access. Therefore, such address range prefetches should be ignored.
    * => Not useful for initiating virtual memory swaps from disk, copy-on-write, and prefetches in some "Two Level Memory" systems, e.g. with NVRAM, etc., which may involve OS page table management in a deferred manner. (TBD: link to paper (CW))

* Page Fault: NOT taken for CMO.CLEAN/FLUSH
  * again, the intent is that the CMOs defined on this page may be treated as NOPs or hints by an implementation. I.e. they are for performance only.
  * Note that this implies that these CMOs /may/ not be suitable for cache flushing related to software consistency or persistence.
    * Some OSs treat the hardware page tables as a cache for a larger data structure that translates virtual to physical memory address translation
    * This means that physical addresses in the cache may be present even the translations from their virtual address those physical addresses are no longer present in the page tables. In such a situation a true guaranteed flush might require taking page faults.
    * Obviously this is OS specific. Software with knowledge of the OS behavior may use these instructions for guaranteed flushes. However, it is not possible for the instruction set architecture to make this guarantee.



* Debug exceptions, e.g. data address breakpoints: YES taken.

Note that page table protections are sometimes used as part of a debugging strategy. Therefore, ignoring page table faults is inconsistent with permitting debug exceptions


* ECC and other machine check exceptions: taken?
  * In the interest of finding bugs earlier.
  * Although this is somewhat incompatible with allowing these prefetches and CMOs to become NOPs

## Options, Options, All around! - JUST SAY NO

Above we have mentioned three arbitrary decisions:
* take/don't take page faults
* take/don't take debug exceptions
* take/don't take ECC or other machine check error exceptions

While the policies we suggest seem reasonable, cases can be made for taking each of the other alternatives.

At this time we do NOT suggest making global CSR bits for these policies.  I.e., not global CSR bits for these policies that apply to all prefetches and CMOs. But policies that apply to particular prefetches and CMOs.



## Alternatives

Other block sizes, "non-temporal hints", etc., fetch into L2 but not L1, etc. But 4 is a good start, assuming that the encodings are scarce.

CMO clean/flushes with full addressing mode. Nice to have, but consumes opcode space.
