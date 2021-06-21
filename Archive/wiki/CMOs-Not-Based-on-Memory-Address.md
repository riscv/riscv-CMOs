Some applications only need to flush known addresses or address ranges out of their caches.

* E.g. a JIT code generator may know precisely what instructions it has generated, and conversely which old instructions it has zeroed or overwritten, so it knows precisely what address range needs to be invalidated from a noncoherent I cache.

Other applications don't know the address ranges.

* E.g. security code targeting timing channels may not know what addresses the user program it is switching between has touched. It is unrealistic to flush all possible addresses, O(size of address space).  Such security code only really needs to touch the caches that it is worried about. E.g. in the seL4 example from Gernot Heiser, the microkernel only needs to flush all of the L1 I$ and D$, not the L2.
  * E.g. even security code that is doing its own flushes, e.g. of a lookup table and memory that might provide a cache residency channel, while it might know the size of the lookup table, it also has to flush all other addresses that map to the same sets in the cache as its own data. This suggests a hybrid... That I will go into right now.

* E.g. software coherency management by the operating system for user processes that touch a lot of memory. As in HPC systems.

Reviewers of the early versions of this CMO proposal emphasized that it was important to have such "whole cache invalidates" as well as address range invalidates. In fact, for security, they said address range invalidates were useless.

I had hoped that an address range invalidate that was larger than an entire cache might be optimized to invalidate the cache, not every cache line in the address space. However, other reviewers prefer not to have that optimization.

---

Briefly: the possibility of monolithic instructions like Intel x86 WBINVD and INVD
* WBINVD is typically a microcode scan, and inherently O(number of dirty lines) if not O(number of lines in cache)
* INVD may be O(number of lines in cache), or it may be O(1) complexity if there is a [[bulk invalidate]] operation
O(N) scans that are not interruptible or a problem.


The traditional way of doing efficient, interruptible, non-address range cache invalidates is to do something like

LOOP over caches and predictors
   Read the particular cache parameters, number of sets, number of ways, from something like CPUID
   FOR s FROM 0 TO number of sets
      FOR w FROM 0 TO number of ways
         flush or invalidate (set,way)

Obviously this has many issues:
* it exposes the microarchitecture
  * you may need to do this for multiple caches, and all software may not be aware of new caches
  * the very concept of way associativity is questionable in some modern computer architecture work, e.g. skewed associativity
    * skewed associativity does not break things if a loop such as the above is used to invalidate the entire cache
    * but skewed associativity breaks things if the user assumes that it understands the function that hashes address lines to sets within the cache, and tries to be smart and save work by only invalidating particular sets.
* Privilege issues
  * we want to be able to do invalidates in user mode. The above cannot be allowed in general. ... TBD: I must be faster
  * set/way locking

---

# My proposal for non-address range CMOs

  Early in time, near boot
     OS is assumed to have investigated the CPUID cache configuration
     (especially if it were in some format like XML the way I would prefer to be in order to be extensible)

  Early in program, or near boot time
     cmo_handle <-- syscall by user to OS saying "this is what I want to invalidate"
              user may have inspected cache configuration from CPUID
              or OS may have done so, and have heuristics that give user more abstraction


  At point where the CMO is needed
     ...
     t0 <-- read _time
     regCmoIndex := maximum positive signed integer, E.g. 0x7FFF.FFFF on RV32
     LOOP
         CMO.UR( src regH:=cmo_handle, src_dst regIndex )
         BAD: rd: regIndex_end  <--- CMO.UR( rs1 src regH:=cmo_handle, src rs2 regIndex_start )
     UNTIL regIndex <= 0

     GH: FENCE here until all done

     WAIT until t0+delta



CMO.UR( src regH:=cmo_handle, rd:start_addr rs1:end_addr )

CMO.UR.<cmo_types>( src regH:=cmo_handle, rd:start_addr rs1:end_addr )

* 1 flush/clean
* 1 mandatory/advisory
* bitmask
  * I1, I0, D1, BP, BTB, RSI
  * on chui predictors
  * exteernal

O(1)





Expect: e.g. if invalidated a cache with 256 entries

CMO.UR called with regIndex = 0x7F...
    => map to 255
    => then decrement

GH: I asked Gernot about exposing the index space



Multiple Caches / predictors ...


Index space

0-255 L1$ I cache

256-512 D$

1G-1G+256M  => outermost



GH: initiate WB












GH: flush D-ccahe concurrently with any others.











GH: I asked if final regIndex < 0 ==> errors  is a piotebtial hole
GH: doesn't want user
GH:




cmo_handle
    bit 0 = 0  => abstract as above
          =1 hardwired parameter
                   bitmap of which caches and predictors


defaults?
    r0 => a reasonable default
