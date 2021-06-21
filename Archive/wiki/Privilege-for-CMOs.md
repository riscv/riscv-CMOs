Aside: I apologize for [[voice typos editing this wiki]]

Actual proposal/draft [[draft-Privilege-for-CMOs]]
forked from discussion [[Privilege-for-CMOs]]


# PROPOSAL:

Each CMO.VAR.* and CMO.UR.* is mapped to a number 0..Ncmo-1, where Ncmo is the Number of CMO instruction  encodings.

(Note:  the encodings do not necessarily have a contiguous field that corresponds to  these values.)

CSR [[CMO_Privilege]] contains Ncmo 2-bit fields where bitfield CMO_Privilege.2b[J] indicates the privilege required to perform the corresponding CMO operation J.

The 2-bit fields are encoded as follows:
* 00 =>  disabled.
* 01 => traps to M mode
* 10 => reserved
* 11 => can execute in any mode, including user mode

The disabled behavior is as follows:

CMO_Privilege.2[J] => CMO.#J
   * the  instruction does not actually perform any cache maintenance operation.
   * but it returns a value such that the [[canonical range CMO loop]] exits
       * CMO.VAR rd:next_addr, rs1=rd:start_addr, rs2:stop_addr
          * sets RD to stop_addr
       * CMO.UR rd:next_entry, rs1:start_entry
          * sets RD to -1

# RATIONALE:

Requirement:  in some CPU implementations  all or some CMOs *must* be trapped to M-mode and emulated.  E.g. caches that  require MMIOs or CSR actions to flush,  which are not directly connected to

Requirement:  in some platform configurations some CMOs may *optionally* be trapped to M-mode and emulated. E.g. [[CMOs involving idiosyncratic external caches and devices]],  devices that use MMIOs or CSRs  to perform CMOs,  and which are not (yet?)  directly connected to whatever

Requirement: it  is highly desirable to  be able to perform CMOs in user mode. E.g. for performance. But also for security,  persistence,   since everywhere the [[Principle of Least Privilege]]   should apply:  e.g.  the cache management may be performed by a privileged user process, i.e. a process that is part of the operating system but which is running at reduced privilege.   In  such a system the operating system or hypervisor may choose to context switch the CSR_Privilege CSR, or  bitfields therein.

Requirement:  even though it is highly desirable to be able to perform CMOs in user mode, in some situations allowing arbitrary user mode code to perform CMOs is a security vulnerability.  vulnerability possibilities include:  information leaks, denial of service, and facilitating RowHammer attacks.

Requirement: many CMOs  should be permitted to user code, e.g. flush dirty data,  since they do nothing that  user code cannot itself do  using ordinary load and store instructions.   Such CMOs are typically advisory or performance related.   note that doing this using ordinary load and store instructions might require detailed microarchitecture knowledge,  or might be unreliable in the presence of speculation that can affect things like LRU bits.

Requirement: some CMOs should *not*  be permitted to user code. E.g. discard or forget  dirty data without writing it back. This is  a security vulnerability in most situations. (But not all -  although the situations in which it is not a security vulnerability are quite rare, e.g. certain varieties of supercomputers, although possibly also privileged software,  parts of the OS, running in user mode.)

Requirement:  some CMOs may usefully be disabled.
* Typically performance related CMOs, such as flushing to a shared cache level, or prefetching using the range CMOs Software is notorious for thinking that it knows the best thing to do,
* Also  possibly software based on assumptions  that do not apply to the current system
   *  e.g. system software may be written so that it can work with incoherent MMIO
      but may be running on a system that has coherent MMIO
   *  e.g.  persistence software written so that it can work with limited nonvolatile storage
       running on a system where all memory is nonvolatile

Requirement: Sometimes there needs to be a mapping between  the CMO that a user wants and the CMOs that hardware provides,  where the mapping is not known to CPU hardware,  not known to user code, but depends on the operating system and/or runtime, and might <i>dynamically</i> depend on the operating system and/or runtime.
* e.g. For performance related CMOs, the user may only know that she wants to flush whatever caches are smaller than a particular size like 32K.  The user does not know which caches those  are on a particular system.
* e.g. in software coherence all dirty data written by the sending process P_producer  may need to be flushed to a shared cache level so that it can be read by the consuming process P_consumer
  *  consider if the sending process P_producer is part of a HW coherent  cache consistency domain,  but the receiving process P_consumer is  part of a different such domain
     *  if the hardware cache  consistency domain  permits cache-to-cache  migration of dirty data, then all  caches in that  dirty domain  be flushed.
     *  however,  if the hardware cache consistency domain does NOT permit cache-to-cache migration, then
         *  if the system software  performs thread or process migration between CPUs that do not share caches
             * without cache flushes => THEN  this SW dirty domain must be flushed
             *  but if the system software performs cache flushes  on thread migration,
                => THEN only the local processor cache need be flushed.
         *  if the system software does not perform thread or process migration,  t
            hen only the local processor cache be flushed.
            Other processor caches in the HW clean consistency domain do not need to be flushed.

     Optionally trapping  such CMOs allows the system or runtime software to choose the most appropriate  hardware CMO for the users' need.

WHINING:
* I had  originally planned to define CSR operands for the CMO instructions,  both to  provide the privilege modulation (trapping, disabling)  and mapping functionalitiess of the requirements listed above.
*  key reviewers reject this possibility, and/or suggest providing it only later if the need is proven
*  however,  thesse key reviiewers CANNOT  deny the requirements of enabling or disabling CMOs listed above
*  therefore, providing this compact privilege mechanism.
*  I am actually just as happy  not to defiine the CSR operand to coontain an encoding of CMO  operations desired,  since I can easily imagine that in some circumstances more than one CSR will be required. E.g. a CSR that might contain a way mask.  Therefore, this " permission vector"  approach allows the actual CSR is to be defined later,  while enabling [[privilege modulation]] today.
