CMOs based on virtual or physical addresses, whether fixed size or variable ranges, are easy to express in a portable manner. It is also easy to make such memory address based CMOs available to user code - perform the permission checks implied by page tables virtual addresses and/or physical memory permission structures like the RISC-V  PMPs/sPMPs.

The big problem with memory address range based CMOs is that they are often significantly less efficient than CMOs based on cache microarchitecture. For example, it is horribly wasteful to have to scan an address range of size 4 GB when you know that the largest cache of concern is only 4 MB in size. If we assume that an operation has to be done for every 64B cache line, the address based scan touches 2^26 cache lines, where is the cache size based scan touches only 2^16 cache lines.

However, it is TBD whether we can architect a reasonably portable solution CMOs based on cache microarchitecture, which I might call CMOs proportional to cache size rather than address range. See that last page for a tentative proposal.

# Optimizing large address range CMOs into efficient cache size proportional CMOs

One possible approach is to allowing an implementation of a variable range CMO.VAR.* over [lo,hi) to perform an efficient cache size based scan

* e.g. if hi-lo, the size of the region, is less than the size of the cache
* i.e. if we can guarantee that there are no lines that need to be flushed that are not in the cache
   * although this might fail for some noninclusive cache architectures (such as Intel L1 and L2 (or MLC) caches; although modern Intel LLCs or snoop filters are inclusive)
   * and for "funky" mappings of memory addresses to cache (set,way) locations

Reviewers of this CMO proposal were surprisingly resistant to allowing this optimization.  Partly because of justifiable FUD of unanticipated consequences.  Partly because some such reviewers anticipated implementing the variable range CMO.VAR.* In terms of per cache line CMO operations, so would not have the opportunity to perform these "physical cache parameter optimizations".  Indeed, the possibility of such optimizations is one of the big motivations for implementing variable address range CMOs by a state machine (or equivalently by smart software aware of the cache structure).

# [[CMOs based on cache microarchitecture]]

... TBD ... loop based on (set,way) structure,
i.e. addressing cache lines directly

Obviously exposes microarchitecture.  Probably not desirable to expose to user mode.

Problematic when there are multiple levels of cache:

May need to loop over cach and within each cache over all possible lines within the cache es

inclusive cache architectures with backwards and validate can illuminate some but not all of that complexity


# Abstracting Efficient Cache Size Proportional CMOs

... I think we can do this. But I know that I'm going to be crucified for "complexity".  Although that just might be my Intel PTSD speaking.
