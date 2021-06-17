When I sent out the first broadcast email about   a CMO working group, I went through the master list of all RISC-V mailing list groups.
It is interesting to note here why I think such and such a group will be interested in CMOs.
Many,  certainly majority, nearly all, groups I have an interest in CMOs.
Enough that if I haven't indicated a reason why the group is interested in CMOs, it causes me to wonder if I've missed something.




* Privileged Architecture	tech-privileged@lists.riscv.org
  *  CMO privilege
     *   it is desirable to have at least some CMOs be available to  unprivileged code
     *  but certain CMOs  might be security holes if certain software rules are not followed
     *  also, all CMOs interact with security timing channels
     *  hence it should be possible to modulate or delegate CMOs,  so that they can be available to unprivileged code when acceptable, and not in other situations
  * performance
     * OS code itself  can often take advantage of CMOs
  *  incoherent I/O
     *  many I/O devices and subsystems are not hardware cache coherent, and it usually falls to the OS to manage cache flushes related to such devices
  * TLBs

* UNIX-Class Platform Specification	tech-unixplatformspec@lists.riscv.org
  *  the default use case for privileged architecture -  but  by no means the only
  *  UNIX class OSes commonly have to deal with non-coherent I/O
     *  although we can dream of the day
  *  power management


* Unprivileged Architecture	tech-unprivileged@lists.riscv.org
     *   it is desirable to have at least some CMOs be available to  unprivileged code
         * performance
	 *  but also to allow the principle of least privilege to be applied, e.g. so that some persistence or liability software can execute outside of  operating system S  privilege mode
     *  but it must always be possible


* J(IT) (Java, C#, etc) Extension 	tech-j-ext@lists.riscv.org
  *  dynamic on-the-fly compilation requires I/D coherence
     *  although the J extension group already has a proposal for I/D coherence
     *  we have been trying to maintain  coherence by minimizing overlap between  CMO proposals and I/D coherence
 *  the J extension working group also is interested in runtimes,  sandboxing,  webasm etc.
     *  but runtimes often execute in user mode
     *  and therefore will require CMOs within user mode when transitioning between code in a sandbox and the user level runtime to mitigate timing channels

* Memory Model	tech-memory-model@lists.riscv.org
  *  the interaction of CMOs and prefetches with the memory model must be defined
  *  CMOs for persistence require " completion fences"


* Virtual Memory	tech-virt-mem@lists.riscv.org
  *  while  virtual memory and caches might seem to be nonoverlapping...
  *  virtual memory is definitely discussing placing  memory types for cacheability in PTEs
  *  TLBs are really just a specialized cache
     *  one might argue that TLB flushes should be done by something like CMO.VAR.TLB...
     * although we are trying to  leave that out of scope for the moment
  * CMOs  and virtual caches

* Configuration Structure	tech-config@lists.riscv.org
  *  GLEW OPINION:  we are deceiving ourselves if we believe that software can manage caches without being aware of the cache hierarchy
     * Well,  perhaps software can do worst case cache flushing...
     * but if you want to do cache management for performance, software or at least the programmer needs to be aware of the cache hierarchy
  * GLEW OPINION:  my original and still preferred concepts for CMOs  interact with configuration/discovery
     *  there are too  possible system cache architectures, and too many possible different types of CMOs and prefetches
        *  it is ridiculous to provide the combinatoric explosion of CMO instruction set encodings
     *  any particular piece of software probably only uses a few CMO types, maybe two or four
     *  my original concept, hosted widely to newsgroups and other places before I got involved with RISC-V, was
        * only a few CMO instructions, say 2-4
	*  each having a CSR  that indicates what  caches that CMO should flush
	*  software uses config/discover,  probably a system call,  to populate the CMO CSRs  that it wants to use
  *  However, this approach has been rejected
     * adds CSRs to process context switch state (for processes using non-standard CMOs)
     * couples SW using CMOs to OS => less portable
  *  nevertheless, the sort of programmer wants to use CMOs and prefetches in any highly tuned way will of  necessity need to know how to discover the cache hierarchy
     *  ideally without running lmbench
  *  furthermore, certain cache hierarchies  cannot make guarantees of correctness without features that are not currently within the CMO proposal scope
     *  ideally software should have a way of determining this
  * BOTTOM LINE:
     * we don't want the CMOs to *depend* on config/discovery
     * but we expect CMOs and config/discovery to interact closely





Safety, Reliability, Real Time

* Reliability
  * e.g.  check pointing for forward progress in the presence of  uncollectible errors on HPC systems
  *  surviving failures of units
  * redundant NVRAM
  * Q:  I don't see a reliability working group for RISC-V

* Functional Safety	sig-safety@lists.riscv.org
  *  functional safety overlaps greatly with reliability
  *  but many reliability techniques do not work for functional safety in something like an automobile, where real-time reliability is needed

* Real Time
  * Q:  again, I do not see a  working group that obviously manages hard real time,  although it may well be subsumed under functional safety
  *  the hardest of hard real-time does not use caches at all
  *  but most practical real-time systems have caches, and use mechanisms such as cache locking, CMOs, prefetches,
     *  either to define a subset of code as part real-time
     * or to  provide "hard enough" (i.e. soft) real-time

* Fast Interrupt	tech-fast-int@lists.riscv.org
  * People often want interrupt handler's locked into cache ( for any particular level of cache)
  * it would be natural to instructions like CMO.VAR.FETCH_and_LOCK or CMO.VAR.ZALLOC_andLOCK
      *  cache locking ( whether of individual lines or entire ways)
         is  currently beyond the  expected scope for the CMO working group
      *  but it would be natural to use CMO-like  instructions if we ever get around to doing
  *  similarly, if cache locking is available, how it interacts with CMO instructions needs to be defined
     *



Performance

* HPC	sig-hpc@lists.riscv.org
   * HPC (supercomputers to an old fogey like me)  care about CMOs  because
   * many HPC systems  are not globally cache coherent.
       * often to save hardware
       * Sometimes because there is no known cache protocol it can scale to the size of supercomputer involved
       * Indeed, they may have hierarchies of nodes that are hardware coherent, nodes that share caches or memories that can be software coherent, and an even larger scale they may not even be shared memory at all.
   * performance
       *  HPC applications are often highly tuned to specific machines. Hence CMOs and prefetches...
   * check pointing
       *  large HPC applications  often run for days or weeks, well past the point at which uncorrected errors become probable over the entire app
       *  check pointing, so that forward progress can be made even  in the presence of  uncorrected errors is required in many if not most HPC systems
       *  check pointing necessarily requires flushing to some level of persistent storage (DRAM, NVRAM,  file system...)
       *  CMOs do not solve the entire problem for check pointing. Other techniques such as COW  may be  needed as well. But CMOs are arguably necessary but not sufficient.
   * Glew anecdote:  I learned many of the more aggressive forms of cache management and prefetch from involvement with HPC systems.

* Vector Extension	tech-vector-ext@lists.riscv.org
  *  vectors  are closely entwined with HPC, and HPC likes prefetching and CMOs
  *  furthermore
     *  the CMO instructions in the current proposal might be suitable for unit stride or other uniform stride vectors
     *  however, vector prefetch instructions might be desirable for
        * strides > cache line
	* scatter/gather vector accesses (RISC-V "indexed" vector  memory access instructions)




Security
* Security	tech-security@lists.riscv.org
  *  timing channels:  e.g. Spectre
      *  caches are shared microarchitecture state. enough said
         *  mitigating such timing channels requires  either physical or temporal partitioning.  temporal partitioning requires cache flushes
      *  other microarchitectures state such as branch predictors, prefetch engines, LRU bits, must also be flushed or cleared in order to fully mitigate microarchitectures timing channels
  * errors - e.g. RowHammer
      *  if nothing else, CMO and prefetch instructions can be used by attackers
  * remanence
      *  beyond timing channels, some secure systems try to prevent  secrets from being stored  where externally visible to attackers who have hardware access
          *   e.g.  the RAM memory remanence attacks -  pickpocket a cell phone and  freeze it (CO2 or N2),  and then access the surviving bits...
          *    cache flushes are necessary to ensure that memory zeroing has actually been pushed to the necessary levels of storage

* Trusted Execution Environment	tech-tee@lists.riscv.org
   * ... some flavors of TEE may require cache flushes

* Cryptographic Extensions	tech-crypto-ext@lists.riscv.org
  *  cryptographic  instructions per se do not interact with  CMOs and prefetches
  *  but there is a great overlap between the security community and the cryptography community
  *  and CMOs are important for mitigating attacks on cryptographic systems



Debug

* Trace & Debug	trace-debug@lists.riscv.org
* Debug	tech-debug@lists.riscv.org
   *  debuggers often need to write instructions or data
      *  external hardware debuggers may use the system bus directly or otherwise be incoherent with the CPU
         *  especially on  embedded systems that do not have hardware  coherence
   *  sometimes it is necessary to allow the user to debug CMOs and prefetches
      *  usually a prefetch should have no semantic content, i.e. be a hint NOP
      *  but if prefetches are performed MMIO reegions  as a result of accidental misconfiguration of PMAs or PMPs or PTEs  it is desirable to be able to debug these
         * Anecdote
	    * "This  could never happen!  it can only happen because of a software bug misconfiguring the PMAs..."
	    * "Right.  that's why we want to be able to debug it"
	    * "Oh, right."
   *  performance debugging:   obviously CMOs and prefetches affect performance...

* Processor Trace	tech-trace@lists.riscv.org
  *  just like  non-trace debug:  correctness and performance
  *  trace messages suitable  for CMOs and prefetches may be required


* Nexus	tech-nexus@lists.riscv.org




Compliance
* Compliance	tech-compliance@lists.riscv.org
   *  compliance interacts with everything!!
* Compliance Tests	tech-compliance@lists.riscv.org



Plus of course...

* Software	software@lists.riscv.org
  * Q:  is  the software group where compilers are dealt with?
  *  ideally it should be possible to generate CMOs and prefetches by suitably sophisticated compilers

* Formal Specification	tech-formalspec@lists.riscv.org
  *  formal specification is even more crosscutting than CMOs
  *  but formal specification has problems with non-determinism, which CMOs have in spades
  *  I expect that we will have formal specifications of CMOs and prefetches at the most primitive level
     *  e.g. does this instruction exist? Can it be configured to take a debug exception?
     *  But  complete formal specification may in fact be a research problem
     *  nevertheless, there has been a lot of work in formal specification demonstrating timing channels litigation

Groups that may not be interested in CMOs

* Zfinx	tech-zfinx@lists.riscv.org

* Soft CPU	sig-soft-cpu@lists.riscv.org

* Bitmanip	tech-bitmanip@lists.riscv.org

* Packed SIMD Extension	tech-p-ext@lists.riscv.org

* Base ISA Ratification	tech-base-isa@lists.riscv.org
   *  GLEW OPINION: IMHO  CMOs should not be part of the base ISA.
      *  it should be possible to build  an extremely tiny uniprocessor system that does not worry about CMOs
      *  ditto simple multiprocessor systems with no caches whatsoever
