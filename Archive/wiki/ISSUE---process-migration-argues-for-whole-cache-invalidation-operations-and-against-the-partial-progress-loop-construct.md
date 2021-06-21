// TBD: BUG: the filename with a colon in it seems to cause some tools problem, like emacs tags-queruy-replace
// next-file: Opening input file: No such file or directory, /cygdrive/c/Users/glew/Documents/GitHub/Ri5-stuff/Ri5-stuff.wiki/ISSUE!-process-migration-argues-for-whole-cache-invalidation-operations-and-against-the-partial-progress-loop-construct.md
// TBD: rename

The [[parent page||Non-Address-Based-CMOs-for-Abstraction-and-Efficiency]]
from which this issue was created
said:

> A thread might migrate from one CPU to another while the CMO loop construct is in progress. If this is done it is the responsibility of the system performing the migration to ensure that the desired semantics are obtained. For example, the code that is being migrated might be restricted to only apply to cache levels common to all processors migrated across. Or similarly the runtime performing the migration might be required to ensure that all necessary caches are consistent.

Referring to the [[CMO.UR loop construct]]:

~~~~~~
   reg_for_cmo_index := 1<<(XLEN-1)-1
   LOOP
      CMO.UR RD:reg_for_cmo_index, RS1:reg_for_cmo_descriptor
   UNTIL reg_for_cmo_index <= 0
~~~~~~

The definition of the CMO.UR instruction in the parent page, with RD as a source/destination register holding the CMO UR index, allows the CMO.UR instruction to be interruptible and restartable. Interruptability and restartability does not depend on the loop construct above.

What the loop construct gives us is that it permits non-state machine implementations.  E.g. CMO.UR might touch one and only one cache line on each invocation.

In many situations this CMO.UR loop construct will be executed by privileged code. Probably locked onto a single processor. Not subject to process migration. If this is the case, the loop construct causes no problems.

However, it is desirable that such cache management operations be performed by code that has the least privilege possible. For example, a user level web browser implementation of a sandbox might wish to flush L1 I cache and D cache timing channels when transitioning between code inside the sandbox and code outside the sandbox. Obviously this would be simplest if the caches involved had no dirty data, e.g. if the L1 data cache were write through, and if there were bulk invalidates. But even caches that contain no dirty data sometimes have no bulk invalidates, and need to sequence over the entries in the cache.

The possibility of a thread migration while user code is executing the CMO.UR loop construct raises some issues.
(Or, equivalently, a guest OS being migrated by a hypervisor.)

If the thread that is performing the CMO loop construct is migrated, and if it is invalidating or flushing a cache that is local to its original processor, and not shared, then the semantics are completely ambiguous. Half of the cache flush might be performed on the first processor, half on the second.

(Note that Derek Williams of IBM has resolved similar issues for the export.I and import.I instruction sequences related to dynamic codegeneration for the J extension. However, as far as I can tell this resolution depends on nonlocal effects for the export.I instruction. That might not be possible for CMOs in general.)

This page does not propose to resolve this problem.

This page only wishes to point out that the partial completion loop construct is itself part of the problem.

If the CMO.UR instruction did not need to be wrapped in the partial completion loop construct then it might be possible for the runtime code that is performing the thread migration to observe the program counter at which the thread that is being migrated lies, determine that it is a CMO.UR instruction, and take the necessary steps. This is because, if the CMO.UR instruction were "whole cache", the PC at the time of migration would unambiguously indicate that a cache management operation is in flight.

Note that "whole cache" does not mean non-interruptible. The interruptability of the CMO.UR instruction is not at all related to the loop. The interruptability is based on actually being interruptible, and also having source/dest operands so that no special treatment is needed by the interrupt handler. All the loop construct provides is the ability for an implementation not to have a sequencer.

If the CMO.UR instruction is embedded in the loop construct, it may be difficult for the runtime that is performing the thread migration to determine that a cache management operation is in flight. Certainly the PC does not necessarily point to the CMO.UR instruction. It might be possible to require that the loop be very specific, potentially only the CMO.UR instruction and the end of loop branch. If that were the case, the runtime might be able to detect the CMO loop construct. However, we are on a slippery slope. The CMO loop construct might be very compact, but there could be other operations interleaved in the middle of the loop. Indeed, the CMO loop construct might be compact, but a binary rewriting tool may heavens are inserted other instructions, e.g. for timing, between the instructions. Any deviations make it more and more difficult for the runtime to detect that a cache management operation is in flight.

If the runtime can detect the cache management operation is in flight, and if that operation semantics is affected by the migration, the runtime has several options
1. Perhaps the runtime could defer the migration until after the CMOs completed
2. Perhaps the runtime could complete the operation itself on behalf of of the thread, before the thread is migrated (e.g. a hypervisor might complete the operation before migrating a guest OS)
3. The runtime could complete the operation, but still let the migrated code also think that it is completing the operation. That would lead to redundant invalidations or flushes.

These options are not available if the runtime cannot easily detect the cache management operation is in flight.

MORAL: the partial completion loop, a.k.a. the CMO.UR loop construct, can make things more difficult, compared to a sequencer that does a "whole cache operation".


--

Similar problems occur for variable address range based CMOs, CMO.VAR.  And indeed, for loops wrapping around fixed block size CMO.FSZ.   However, the microarchitecture based invalidations of CMO.UR are inherently more subject to local interpretations than are the address based invalidations of CMO.VAR and CMO.FSZ.
