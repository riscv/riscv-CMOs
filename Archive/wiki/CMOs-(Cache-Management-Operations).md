## Recent

Soon: RISC-V Foundation Working Group TBD

[[Ri5-CMOs-proposal]]
* See [[generated HTML and PDF for CMOs proposal]]

### History

This history section it is very much out of date, see instead that within [[Ri5-CMOs-proposal]].

Wednesday, May 6, 2020-05-06:
* switching to use asciidoc for actual proposal: [[CMOs-proposal]] links to [[Ri5-CMOs-proposal]]
  * See [[generated HTML and PDF for CMOs proposal]]
* actual proposal WIP: [[Ri5-CMOs-proposal]]
* files converted from wiki to asciidoc ("draft" prefix distinguishes)
   * [[draft Privilege for CMOs]] <-- [[Privilege for CMOs]]
   * [[draft-Fixed-Block-Size-Prefetches-and-CMOs]] <-- [[Fixed-Block-Size-Prefetches-and-CMOs]]


Finished stuff? - to be converted to asciidoc / draft

* [[Privilege for CMOs]]
* finish the [[Actual CMO operations]] list
* finish the [[Semi-formal Abstract Model for CMOs]]
   * TBD:  transcribe to wiki from the OneNote notebook and email where this was written up.
   * needs: How don cache flushes on non-inclusive caches wArm
* lots of rationale and explanation


## Terminology

Briefly: this document, at this time, uses the term "CMO" (Cache Management Operation) generically for operations that have mandatory semantics (like cache flushes for purposes of software managed consistency or security timing channel mitigation) but also operations that have optional semantics (such as prefetch instructions as well as hints that a cache line is no longer needed).  See [[Terminology for instructions that manage microarchitecture state such as caches, prefetchers and predictors]].


## Converging on Proposals

It is eventually necessary to converge on a single proposal. While this proposal may not be final, and different parts may be at different stages of maturity, the links here are to what I believe are the latest and greatest.


## CMO Instruction Formats

* [[Fixed Block Size Prefetches and CMOs]]
  * [[STATUS: almost done - maybe]]
    * AW OK, most reviewers so far okay
    * Instruction encodings chosen
    * [[Instruction Name Choice]] - my suggestions, but I expect to be overruled
  * SUMMARY:
    * 64 byte fixed size block
    * PREFETCH.64B.R and PREFETCH.64B.W: Memory[reg+imm12], i.e. I–format with RD=0
    * CMO.64B.CLEAN, CMO.64B.FLUSH: Memory[reg], e.g. R–format, but only need one register

* [[Variable Address Range CMOs]]
  * STATUS: converging, expect arguments
    * 01-23-2020: reviewers have accepted explanation of register definitions suitable for interruptability, but still think the 2 acceptable definitions are "strange". I am trying to guess which one will be most acceptable.
  * ISSUE: [[CMO-types issue]]: abstraction, efficiency, extensibility

* [[Microarchitecture Structure Range CMOs]]
  * STATUS:
    * Recent
      * 03-02-2020: changes after AW discussion
      * 01-16-2020: reviewers rejected overloading address range CMOs for efficiency :-(
      * 01-20-2020: new proposal [[Non-Address Based CMOs for Abstraction and Efficiency]]
      * 01-22-2020: first SW/OS reviewer okay on concept, hardware reviewer interested but questioning
  * ISSUE: [[CMO-types issue]]: abstraction, efficiency, extensibility

## [[Actual CMO Operations]]

The section and linked pages above discusses the CMO instruction formats

The page [[Actual CMO Operations]] discusses the actual cache management operations such as:
* CLEAN: write back dirty data, but leave clean data behind in structure
* FLUSH: writeback dirty data, and invalidate all data in structure
* Invalidate Branch Predictors and Prefetchers: e.g. for timing channel mitigation

## [[Privilege for CMOs]]

Actual proposal:  [[Privilege for CMOs]]

Further discussion and/or rationale
    * [[I am frustrated that we are going around in circles  with respect to  modulation of CMOs]] - I hope the new subproposal [[Privilege for CMOs]]  breaks us out of this nonproductivee spin loop
    * [[interception and modulation of CMOs]]

## [[Semi-formal Abstract Model for CMOs]]

TBD:  transcribed to wiki from the OneNote notebook and email where this was written up.

Overview:
*  most abstract: the operations a user wishes to perform
*  implementation dependent:  the operations that HW provides.  including, e.g.,  arbitrary numbers and levels of caches
*  intermediate level of abstraction between the above: abstract HW CMO operations
   * restricting  levels of the memory hierarchy
   ...


## Stuff along the way

Some of this stuff along the way will be rejected alternatives, nevertheless preserved, e.g. in case they need to be revived.  Other of this stuff along the way constitutes rationales and explanations, which may be used, rewritten, or reorganized in support of the converged proposal.

TBD: eliminate obviously dated and obsolete stuff, which can always be obtained from the get history, or at least tag it as dated and obsolete with references to the up-to-date stuff. TBD: separate final or near final from historical stuff.

[[Overview of CMO operations]] - why needed, goals, etc.

[[Quick and Dirty Proposal for RISC-V CMOs]]

* [[An even quicker and dirtier summary of proposed instruction encodings for RISC-V CMOs]]
