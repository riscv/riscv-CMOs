# CMOs are a superset of PREFETCH and CPH instructions
[[At the time of writing pages in this document (wiki)]] related to [[CMOs (Cache Management Operations)]] use the term "CMO" (Cache Management Operation) generically for cache operations that have mandatory semantics  and also for operations that have optional semantics.

The term "CMO" is also currently also used for invalidations of other [[Performance Related Hardware Data Structures]] such as predictors and prefetchers and their associated histories.

According to this usage CMOs are a superset of PREFETCH CPH instructions and operations.

(Note: other documents may insist that CMOs, PREFETCHes, and CPHs are non-overlapping.
See [[Mandatory versus Optional CMOs, PREFETCHES, and CPHs]], which explains that this distinction is fuzzy.)

CMOs with optional or ignorable behavior include
* [[PREFETCH instructions]]
* [[CPH (Cache Performance Hints) instructions]]
CMOs with mandatory behavior include invalidations/flushes for purposes such as
* security timing channel mitigation
* SW managed cache consistency
* Non-coherent I/O, DMA, and other non-coherent devices
* Power management, e.g. flush to batter backed DRAM.
* Persistence, e.g. flush to non-volatile storage like NVRAM

CMO operations are performed by CMO instructions (CMO.VAR and CMO.UR), but also by PREFETCH instructions with distinct mnemonics, encodings, instruction formats, and operands. CPH instructions may also have distinct mnemonics, encodings. However, some CPH operations and some prefetch operations may be performed by the CMO.* instructions.
* Specific CMO.* instructions
   * Some class of instructions have mnemonics of the form CMO.*:
   * E.g. CMO.VAR (variable address range CMOs),
   * E.g. CMO.UR (uarch range CMOs, e.g. flushing a large cache by (set,way) entry number
   * These CMO.* instructions are R-format, with up to 3 register fields.
* *PREFETCH _instructions_* are a _CMO operation_ as defined above, but have instruction encodings and mnemonics separate from the CMO.* _instructions_
   * E.g. PREFETCH.64B.R and PREFETCH.64B.R differ from the CMO.* instructions in instruction format (I-format vs R-format), different encodings, mnemonics, and operands. In particular these prefetch instructions form memory addresses in the same way as load and store instructions, e.g. Memory[rs1+imm12].
* CPH (Cache Prefetch Hint) _operations_
   * Some CPH operations have their own CPH _instruction_ encodings and mnemonics
   * Other _CPH (Cache Prefetch Hint) _operations_ do not have separate instructions with their own mnemonics,  but are be performed by passing certain arguments to the CMO.* instructions in GPR or CSR.



# The term "CMO (Cache Management Operation)" is unsatisfactory for predictors and prefetchers

The term "CMO" is unsatisfactory, since the term "cache" is often considered to apply only to hardware data structures that contain instructions or data. Although in some sense some other hardware data structures are also caches, e.g. [[TLB]]s and [[BTB]]s, (a) use of the term cache may lead to confusion; (b) it is arguable whether a hardware data structure such as a [[branch predictor stew|https://patents.google.com/patent/US7143273B2/en]] history is a cache, even if the view is taken that the PHTs (Pattern History Tables) that the stew indexes is a cache; (c) similarly, it is unclear whether the term "cache" should apply to a prefetcher.

However, [[at the time of writing]], no satisfactory alternate term has been found.

## Alternate terms for CMO?

The term "[[HWDS (Hardware Data Structure)]]" is a candidate generalization for "cache" that applies to all or at least most of the structures of interest - instruction and data caches, branch predictor structures such as BTBs and history SKUs, prefetchers - but it might be too general, since one can also consider instruction decode, scheduling, and execution hardware to be hardware data structures.

The best candidate more generic term for "cache" identified so far so far is [[Performance Related Hardware Data Structure]], possibly abbreviated [[pHWDS]].

But replacing "CMO (Cache Management Operation)" by something like "pHWDSMO (Performance Related Hardware Data Structure Management Operation)" seems excessively verbose.

Other candidate generic terms include
* "pHWMO (Performance Hardware Management Operation)"
* "USMO (Microarchitecture State Management Operation)"
* "PUSMO (Performance Microarchitecture State Management Operation)" (sounds disgusting)
* "CPPMO (Cache Prefetcher and Predictor Management Operation)" (prediction: something will be found that needs to be flushed by these operations that is not a cache, prefetcher, or predictor)

## Mandatory versus Advisory: CMO vs prefetch versus CPH

See also [[Mandatory versus Optional CMOs, PREFETCHES, and CPHs]]

[[At the time of writing pages in this document (wiki)]] related to [[CMOs-(Cache-Management-Operations)]] use the term "CMO" (Cache Management Operation) generically for operations that have
* mandatory semantics (like cache flushes for purposes of software managed consistency or security timing channel mitigation)
but also for operations that have
* optional semantics (such as prefetch instructions as well as hints that a cache line is no longer needed).

The difference being that a program should still execute correctly if the operations with optional semantics are ignored, i.e. treated like a no-op. Whereas workloads that need to use instructions with mandatory semantics would fail to execute correctly if the mandatory operations were ignored. Examples of the latter include (a) software managed cache coherence, (b) persistence and power management, flushing state to battery backed up DRAM and/or NVRAM; and (c) cache, predictor, and prefetcher state invalidations to mitigate microarchitecture timing channels for purposes of security.

Some people prefer to use the term "CMO (Cache Management Operation)" only for operations that have mandatory semantics. They prefer to use terms such as "prefetch" or "CPH (Cache Performance Hint)" for operations that are optional.

This writer prefers to apply adjectives to a common term, to show the relation between concepts, rather than to use completely different terms that do not exhibit the relationship.

I.e. as written now
* CMO (Cache Management Operation) includes
  * optional operations
    * software prefetch instructions such as PREFETCH.R and PREFETCH.W
    * [[CPH (Cache Performance Hints)]] such as "push this cache line out of the L1 to the L2"
       * sometimes called [[cache push out or post-store]]
  * mandatory operations
       * [[clean or flush]]: write back dirty data from cache, to point of consistency
       * invalidate stale data from cache (to point of consistency)
       * reset LRU state
       * reset cache prefetcher state
       * reset branch predictor state

(See [[List of optional versus mandatory CMOs]], which is more but by no means 100% complete. Which also maps the various flushes and invalidates to particular usage models.)

However, in this page use of the term "CMO (Cache Management Operation)" overlaps with but is not necessarily a superset of certain cache performance hints.

For example, load and store instructions may contain a hint indication in the instruction encoding. Examples include
* non-temporal load (which may be interpreted as making the cache line LRU rather than MRU)
* store-and-forget (after this store the data no longer has temporal locality, and may be marked LRU or even evicted)

The distinction is made as follows:
* a **CMO instruction** is a freestanding instruction, that does not perform a load or store,
  * some such "CMO instructions" do not modify architectural state such as registers or memory, although they may produce cache fills, evictions, or invalidations, but the CMOs proposed in this document/wiki may perform register state modifications in order to allow [[partial instruction completion|Instructions-that-Support-Partial-Progress]]
    * ISSUE: verify that the recommended [[partial instruction completion loop constructs]] operate correctly if optional prefetches or hints are treated as NOPs.
  * a **CPH instruction** or a **prefetch instruction** are CMO instructions, therefore freestanding, and does not perform a load or store.
* load instructions that modify registers and/or store instructions that modify memory, either of which may have MMIO side effects, may have "cache directives"
   * typically such cache directives is attached to instructions are performance hints, [[optional prefetches or post-store]]
   * although mandatory cache directives are possible, at this point in time none are proposed for RISC-V
i.e. the distinction is between instructions whose sole purpose is to perform a cache management operation, or other performance related hardware data structure operation,

## Optional, Advisory, Discretionary
The terms "advisory" and "discretionary"
may be synonymous with "optional" as used in this document.
All refer to instructions whose effect wrt the caches is non mandatory.
