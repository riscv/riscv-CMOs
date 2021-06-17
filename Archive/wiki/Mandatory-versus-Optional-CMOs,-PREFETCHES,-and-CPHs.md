NOTE: in my terminology CMO is a generic term, that includes both optional or advisory operations such as PREFETCH instructions and CPH (Cache Prefetch Hint) such as posts store/push out instructions, but also includes mandatory operations such as cache flushes and invalidations for security timing channels mitigation, software manage coherence, and persistence.

If you use an alternate terminology where PREFETCH and CMO and CPH instructions are mutually exclusive categories, the concern still arises

It is traditional that it should be possible to treat performance-related instructions such as PREFETCH and CPH instructions as NOPs. They are optional, and only influence timing, not time free program semantics. However, mandatory CMOs such as cache flushes for software manage coherence cannot be treated as NOPs. Arguably, on a machine that does not implement the CMOs, they should be trapped as a legal instructions. Better to trap, and possibly emulate, than to not accomplish what they are supposed to do, and have the program break, although possibly not in obvious ways. 

Unfortunately there is a middle ground: software coherence.   On a system that truly lacks some if not all hardware coherence features, the cache flush's and other CMOs required to enable software coherence absolutely must be performed. However, it has happened more than once that such a system was created long ago, and that eventually hardware cache coherence was implemented. In which case such CMOs might be ignored.  I.e. whether a CMO is mandatory or optional may depend on the platform configuration e.g. whether hardware cache coherence is implanted or not. (Note: this applies to software coherence, and possibly some forms of power management. It probably does not apply to persistence to NVRAM.)

A case in point is the EXPORT.I instruction proposed to support dynamic code generation on RISC-V.  Some, traditional RISC instruction sets do not support I cache consistency with the data cache. On these instructions EXPORT.I is required to perform a cache action, essentially invalidating I cache lines. (Complementary instruction IMPORT.I might flush post cache instruction pipelines). However, some CPUs have decided that it is just plain easier to support I cache consistency. On such machines it may not be necessary for EXPORT.I to invalidate I cache lines. Arguably, EXPORT.I might still need to do stuff related to data stores and instruction fetch pipeline consistency, in conjunction with IMPORT.I. However still other systems have made both EXPORT.I and IMPORT.I unnecessary, and can treat both as NOPs.

The point here is that there are both instruction set architecture and microarchitecture considerations relevant to mandatory.

E.g. the EXPORT.I and IMPORT.I functionality is mandatory from an instruction set architecture point of view. But some microarchitectures might make it unnecessary.

--

Also, similar cache invalidate and flush operations may be optional for some purposes and mandatory for others.

For example, cache flushes when treated as CPH (Cache Performance Hints) may be ignored on a system that is hardware consistent. After all, they should only influence performance. In fact, it is probably desirable to have a control that allows them to be enabled or disabled, since quite often cache performance hints and prefetches turn out to be less effective than the predictors and prefetchers of an advanced microarchitecture. However, cache flushes should never be disabled for security related timing channel mitigation.

I have considered having a mandatory/optional bit in any <Extended CMO type> that is passed to CMO instructions, and possibly also PREFETCH instructions and CPH instructions. (But probably only if in a general-purpose register, or a CSR implicit input operand, for such instructions. It is unlikely that we have enough instruction encoding space to provide such an orthogonal bit if the [[<cmo_type>]] is encoded in the instruction itself.)

Considerations such as the above - the fact that on some microarchitectures CMO optional/mandatory depends on both usage and microarchitecture - suggest that a single mandatory/optional bit is not insufficient. There probably need to be more types of discretion.

Possibly:
* optional, for performance only. Can always be made into a no-op
* mandatory if no hardware cache coherence, optional (possibly always disabled) if hardware cache coherence
   * although note: computer architects often delude themselves into thinking that their system is 100% hardware cache coherent, when in reality the platform in which it is embedded may make it not always hardware cache coherent
* mandatory, e.g. for a cache push out or flush, if the CPU or whatever caches the data is being pushed out from are not retained in the power saving mode. Optional if they are retained.
   * note: this is of questionable value, since many systems have multiple power saving modes, some of which retain state in devices such as CPUs, some of which do not.
* always mandatory
   * I suspect that security related timing channel mitigation flushes will always be mandatory. Although they may be selective, only applying to certain levels of the cache. And they will probably apply to hardware data structures such as branch predictors as well as to caches.





