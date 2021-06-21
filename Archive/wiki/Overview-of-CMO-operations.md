
RISC-V systems need cache management operations, aka CMOs. As far as I know, so far such operations have been defined in an implementation specific manner. Other computer architectures define cache management operations, often via a mixture of user level instructions, privileged instructions, and platform specific operations accessed via MMIO control registers. See [[Survey of CMOs in Modern Computer Architectures]].

Purposes of CMOs include:
* performance tuning
* security, e.g. mitigating Spectre-like information leak security vulnerabilities
* persistence, e.g. nonvolatile RAM in the memory hierarchy
* power management, e.g. flushing caches before removing their power
* software managed cache coherence, e.g. non-coherent I and D caches
* bank switching of physical memory, e.g. HP's "Machine"
* reset, hot plug (not necessarily current high priority)

These use cases have different needs.
* User level access to these CMOs are desirable in some cases, but not required for all
* Some affect only data and/or instruction caches and related parts of the memory system
* Others, e.g. security, need to influence other microarchitectures state like branch predictors
* Some need to interact with other CPUs, not necessarily RISC-V or from the same vendor, and possibly non-CPU devices
* Some CMOs may be ignored (performance), while others are required for correctness (SW coherency, power management, security)
* Scope
 * Some CMOs affect only a smallish excise block like a cache line
 * Others affect a range of physical or virtual addresses
 * Others want to affect an entire cache, or a partition thereof
* some CMOs may be optimized, e.g. performed in the background
* whereas other CMO use cases may require control over timing

The biggest problem with CMOs in general is that cache architectures in particular, and microarchitectures state in general, can be highly diverse.   
* Cache architecture 
 * How many levels of I and D? Are I and D unified at some level?
 * How many levels, and how big?  
 * Associativity, skewed
 * LRU policy...
 * What caches are shared between separate CPUs/harts/other smart devices?
 * Mesh versus hierarchical?
 * Virtual versus physical
 * inclusive versus exclusive versus neither inclusive nor exclusive
 * clean/write-through vs dirty/write-back
 * does hardware support "flash invalidate", or is it necessary to scan the cache either in software or hardware?
* other microarchitecture
 * there are more forms of microarchitecture state, branch predictors, prefetchers, etc. than are imagined by any computer architecture textbook
 * security timing channel mitigation requires the ability to flush or reset nearly all such microarchitecture state that influences execution timing.
 * Most other applications do not

The term "CMO (Cache Management Operation)" may be too specific. A more generic term may describe the needs of security and performance management - "microarchitecture state management operations (uSMO)"? Unfortunately, I do not have a good more generic term. For that matter, it is not clear that non-cash state

This CMO proposal
* defines a small standard set of targeted cache operations
* but also provides a standard way to invoke nonstandard implementation specific cache operations
 * e.g. figure out what your application needs to do, which may require knowledge of the CPU and platform architecture
 * if nonstandard asked the OS for permission to do these actions 
 * use the standard CMO instructions defined here to invoke the nonstandard actions described and encoded above


