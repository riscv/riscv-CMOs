There are more possible configurations of caches than are conceived of by computer architecture textbooks. E.g. number of I/D/unified levels, inclusive/exclusive/neither, virtual/physical, etc.  Let alone prefetchers, victim choosers (LRU), etc.

In general portable software does not want to need to know about cache microarchitecture details.
But sometimes software needs to, or benefits from, knowing microarchitecture details.
* performance:
  * "I probably don't need this data again, so you might as well get it out of the cache"
  * vs "this loop nest has one operand that fits in a 32K L1$, and one that doesn't fit in a 4MB cache,
        so use LRU for the first and MRU for the second"
* power management:
  * "I am putting the whole system to sleep and will not be retaining data in the caches, so flush all data to battery backed up DRAM"
   * vs "I am powering off CPU core #1 but not #2, so flush all dirty data in the caches that will be powered off"
   * vs "I happen to know that I can power off the L2$ and still operate the L1$ and the L3$, so do that"
* security
   * "flush/invalidate/reset all possible microarchitecture state that might be a timing channel"
   * vs "I am using way partitioning to isolate users in the large L2$, so flush the L1$ completely but do not topuch the L2$"
* SW coherence
   * flush/invalidate all caches between me and DRAM"
   * vs "I am only trying to synchronize with threads/processes running on other harts/CPUs with which I share an L3$, so flush/invalidate the L1$, L2$, and everything all the way to the L3$, but don't flush the L3$ or L4$.
     * how might SW know this?  Not on a general purpose OS with process migration.  But perhaps in an embedded/HPC system, or via processor affinity.

Many more examples are not just possible, but have been built in the real world, requested of CPU vendors, or proposed by academics.


This proposal does NOT try to comprehend or represent all possible such CMO types.


This proposal places a small number of such possibilities in the instruction encoding.

WARNING: terminology confusion: Intel and IBM define "flush" oppositely.  In Intel x86, "flush" means "evict dirty data", maybe/maybe not leaving clean data behind. In IBM POWER, "flush" means invalidate data without writing it back. What Intel calls a flush IBM calls a clean. What IBM calls a flush Intel calls an invalidate.  TBD: what terminology should RISC-V use? Until determined, I will write out verbosely

* Flush - write out dirty data
   * what is left behind
       * leaving clean data behind, e.g. in S state
       * leaving invalid cache lines behind
   * depth
       * to "[[Point of Unification]]"
       * to DRAM
       * to battery backed up DRAM
       * to non-volatile storage (NVRAM)
   * which: data and/or instruction [see note 2]
* Prefetch [see note 3]
  * prefetch type
    * prefetch data to read
    * prefetch data to write
    * prefetch instructions
  * prefetch bias
     * place in LRU, i.e. expect temporal locality
     * place in MRU, i.e. expect non-temporal locality

Even the list above expands to 2*4*2 + 4*2 = 24 possibilities. Probably more that we want to spend opcode space on.

Enumerating by priority
  1. D, writeout dirty, leave clean behind, to [[Point of Unification]]
     * use: performance
  1. D, writeout dirty, invalidate all, to [[Point of Unification]]
     * use: SW coherence
  1. D, writeout dirty, leave clean behind, to [[Point of Long Term Persistence]] (NVRAM)
     * use: persistence
  1. D, writeout dirty, leave clean behind, to [[Point of Short Term Persistence]] (e.g. battery backed up DRAM in a phone)
      * use: power management

  1. Prefetch D to read, LRU
  1. Prefetch D to write, LRU
  1. Prefetch D to read, MRU
  1. Prefetch I, LRU

==> 8 encodings.

Actually, I would prefer to have 1 or 2 less than a power of two in-instruction encodings.

In general, for all of the <cmo_type> that cannot pe represented in that small set, I propose to reserve encodings and/or instruction formats for [[<extended_cmo_types>|Extended CMO types]]





TBD: compare to a [[Survey of CMOs in Modern Computer Architectures]]

Note 1: in this small in-instruction-encoding set we are NOT including destructive and security damaging operations like "invalidate cache line even if dirty", as in Intel's INVD instruction or IBM's DCBA.  Nor are we including operations like "allocate zero filled cache line without read-for-ownership", as in IBM's DCBZ, which are secure, but which may expose the cache line size.  (However, I expect that customers will strongly request DCBZ, so I consider it wise to reserve instruction encoding space.)

Note 2: the EXPORT.I instruction proposed by the J extension WG essentially is equivalent to
    CMO.VAR.VA.<cmo_type=Instruction,to Point of Unification>.
in general, this CMO proposal defers to that EXPORT.I proposal, and will not provide any instruction related CMOs. I am listing them here only to ensure coverage.

Note 3: it is TBD whether cache prefetches will be part of the CMO proposal.  Prefetch instructions usually want to have addressing modes comparable to normal memory reference instructions, e.g. Memory[reg+offset], where the prefetch offset is increased by a fetch-ahead delta.   Therefore, if prefetches are included, the CMO.FSZ.* format should be extended to have a memory addressing mode.  There may not be enough instruction encoding space in ILEN=32 to allow this.  For that matter, certain
