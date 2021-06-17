[[Examples of other Working Group charters]]
- CMO group charter modelled on ...
* [[Example: Config WG charter]]


The following proposed charter is probably too long for the Technical steering committee.

Some, but probably not all, of these details, explanations, and requirements about what is and is not in scope for the CMO working group may be worked out once the CMO working group has started.


# CMO Task Group Charter

Acronym: CMOs = Cache Management Operations

The CMO Task Group will:
* define instructions (and CSRs if necessary) performing cache management operations


Requirement:
* CMO instructions may be executed by user mode (if system software permits)
  * however, system software must have the ability to prevent less privileged software from executing CMO instructions

Therefore, it is proposed that the CMO working group will be a subgroup reporting to the RISC-V Privileged Architecture task group.


Use cases for CMO instructions include:
* security
   * e.g. flushing microarchitecture state to mitigate timing channel security vulnerabilities such as Spectre
      * hence "CMOs" will be extended to cover branch predictors, prefetchers, and other microarchitecture state that affects performance
* software managed cache coherence when hardware cache coherence is not available or incomplete
   * e.g. incoherent I/O DMAs
   * e.g. multiprocessor systems where cache coherence is not available between all nodes
   * e.g. interaction with external hardware accelerators that may not implement hardware cache coherence
* performance tuning
   * e.g. evicting data no longer needed between program phases, to avoid thrashing data that is needed across program phases
   * *possibly* cache prefetch instructions and/or cache usage pattern hints
* power management
   * e.g. flushing caches to battery backed-up DRAM, or NVRAM
* persistence for reliability
   * e.g. flushing caches to RAID NVRAM and/or remote state
   * e.g. cache flushes for checkpointing of long-running applications in HPC systems
* debugging
   * e.g. external hardware debuggers may need to write instructions or memory in systems lacking cache coherence

CMOs cut cross many domains, ranging from simple microcontroller systems with no hardware cache coherency, 
through cache coherent application and server processors, through HPC systems.
The CMO working group will coordinate with the task groups and working groups and standing committees for these areas of overlap.

The goal of any CMO ISA extension proposals will be to permit portable software in all or most of the above use cases.
The CMO task group will only define a set of CMO instructions that can reasonably be expected to be portable.
If not applicable to an implementation such CMO instructions will do nothing. (e.g. flushing dirty data in a system that does not have writeback caches).

It is expected that implementations may have cache microarchitecture and hence cache flushes that will not be part of the standard CMO instruction set.
However, there will be worst-case maximally conservative CMO instructions that can flush all caches including such implementation specific caches.
Implementations are expected to have less conservative more precise cache flushes that are not part of the standard CMO instruction set.


The CMO working group will not:
* define the instruction/data coherence instructions necessary for on-the-fly code generation, e.g. in the J extension
   * however, the CMO working group  will coordinate with the working groups defining instruction/data coherence
   * certain CMO instructions will probably overlap, e.g. flushing the instruction caches
* the CMO working group will NOT address TLB shootdown or ASID coherency
* the CMO working group will NOT define config/discovery mechanisms to allow software (system or user) to determine the cache microarchitecture
* the CMO working group will NOT define cache protocols
   * e.g. CMOs will assume that caches can contain clean and/or dirty data, but no more states than that
* the CMO working group will *probably NOT* define cache modes such as no-fill, which may be required to perform reliable hardware reset

Requirement: CMO instructions *must* work with the most common cache microarchitectures, including
* strictly inclusive and exclusive
* non-strictly inclusive and exclusive hierarchies
  * 

Requirement: implementations of varying levels of sophistication
* it *must* be possible to implement  CMO instructions a cache line at a time
* it must be possible (and reasonably good performance) to implement CMO instructions by trapping to M mode
* desirable: bulk flush, e.g. invalidating clean data without writing back
* desirable: implementations using hardware state machines

It is expected that the CPU will not necessarily know in advance all of the caches in a system. Requirement: it must be reasonable to interface CPU CMO instructions to control external caches (e.g. so that portable software can reliably do things like mitigate cache timing channels for security). Example of such an interface: Trapping the CMO instructions to M mode and emulating them via system specific mechanisms to flush external caches.