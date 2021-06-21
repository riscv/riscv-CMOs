Some traditional RISC ISAs instructions that invalidate by (set,way).
[[if bound to an instruction]]  we call this CBO.UX.?? -- CBO  standing for "Cache Block Operation", UX standing for " microarchitecture index" e.g. (set,way), ?? being  other fields such as  the actual operation (CLEAN, DISCARD, INVALIDATE, INVALIDATE-S), and cache(s) involved.

Problems with CBO.UX include:

* exposing microarchitecture details to code that might otherwise be portable
* inability to take advantage of hardware optimizations like bulk invalidates and state machines

Nevertheless, this is in many ways simplest possible approach

Code that uses this operation to invalidate an entire cache looks like

         nEntries := read # of entries from config ...
         FOR n FROM 0 to nEntries DO
              CBO.UX rs1:nEntries

Code that uses this operation to invalidate a single cacxhe line, e.g. as read from a machine check error report
      
         numEntry := read error CSR
         CBO.UX rs1:numEntry







Many machines have FSMs that iterate over  the entire cache specified, and/or bulk invalidates  that "instantaneously"  invalidate a cache for some operations and/or some entries. [[If bound to an instruction]]  we call this CMO.ALL.$id.  

Problems with CMO.ALL include

*  interruptability/restartability with partial progress
**  frequently CMO.ALL  implementations are not interruptible.
***  This is not acceptable for many systems, especially real-time.
**  if interruptible,  issues with restartability
***  CMO.ALL  can be made restart with partial progress if there is state like a CSR from which it resumes on return from an interrupt.
****  but we dislike adding new state
***  or, CMO.ALL  may be interruptible but may have to resume from the beginning on return from interrupt
****   forward progress problems =>  highly undesirable


This proposal defines a CMO.UR  instruction in such a way that allows <<possible_implementations_ranging_from_cache_line_at_a_time_to_full_cache>>,
with a loop such as that below:

include::microarchitecture-range-loop.asciidoc[]

