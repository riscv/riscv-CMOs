#

The spreadsheet [CMOs.xlsx](https://github.com/riscv/riscv-CMOs/commits/master/CMOs.xlsx)
is a list of some of the desired CMO operation. It is by no means a complete list.

The version uploaded as of 2020-04-30_08.04.31 (TBD: provide link to GitHub version) counts these.
These counts suggest the regular format In the next [section](#Regular-format)

# Regular format

| por | bits | name | description |
| --- | --- | --- | --- |
| n?   | 1 | LG | 0=>local, 1=> global |
| y   | 3 | scope | e.g. cache level to flush to <br/> although sometimes not strictly a level<br/> (8 encodings used) |
| y   | 4 | cmop | operation type<br/>?? encodings used |
| n   | 1 | sec | security related, 0=no, 1=> flush predictors and  prefetchers |

Issue:
* LG: should we just assume that all CMOs must be "shoot down", applicabe to all of a coherence domain?
    * saves one bit, at the cost of performance for some "advanced" cases (like some supercomputers)
* sec: do we need the sec bit for address range CMO.VAR, or only for "whole cache"?
    * this saves one bit for the most expensive CMO.VAR instruction format

Bottom line: we can fit into 7 bits by making compromises, 8 bits fairly easily, although 9 bits is all rows abocve, and I would prefer 10 bits.

Not orthogonal: a very few operations require write permission, but not enough to warrant an orthogonal bit.

## Scope  encodings

We get away with "only" eight encodings, three bits, by overloading -  using the same encoding to indicate slightly different things for outbound operations (pulls/flushes) and inbound operations.

| for push CMOs | for pull CMOs (prefetchesd) |
| --| -- |
| to pou(I$,D$) | to I$ |
| to pou  coherent processor caches | to L1 D$
| to pou non-coherent processor caches | to L2$ pou(I,D )
| to pou non-coherent I/O | to L3$
| to ordinary DRAM | from NVRAM to DRAM
|  to battery backed up DRAM
|  to NVRAM ( first point of persistence)
| to all NVRAM (full persistence) |

we can of course argue about details,  to try to reduce the count
*  do we need to have  two points of NVRAM persistence, first and all?
   * e.g. Keith Packard
   * e.g. HP "Machine" (TBD: ref)
*  do we need to distinguish DRAM from battery backed DRAM
   *  there are existence proofs, but we don't necessarily need to order them
*  do we need to distinguish processor coherence from I/O coherence?
*  could I/O coherence be just DRAM

But at the very least,  I am sure that most people agree that we need  at least four scopes,  and probably more. => 3 bits.   My biggest concern is that  we should probably provide four bits rather than three.

NOT HANDLED:
* Prefetch operations might want to "skip" certain cache levels
   * e.g. fetch into L1 but no other levels
   * e.g. fetch into L1 and L3 but not L2
* Prefetch operations that want to stop - may want only to prefetch from into L1 from L2 or L3,
  but not from DRAM if missing L3 (to avoid saturating DRAM bus)
* CMOs that specify remote caches
   * e.g. P1 executes a CMO to prefetch/flush into some other processor P2's cache
      * like ARM stashing


## [[CMO operation list for encodings]]

Placing this into a separate wiki page to make the table easier to edit.
* too hard to edit in long page
* would use section editing, except that GitHub wiki does not have that
* would use transclusion, except GitHub wiki does not have that

The table uses B+x? syntax to indicate priority classes

| Count | Priority / Extension
| --- | --- |
| 5 | Base
| 1 | +xIO | invalidate clean <br> better / more secure way for noncoherent I/O
| 2 | + xD+ | safer discards - easier to secure <br/> safest discard is ZALLOC/DCBZ without a cache target and bus support
| 1 | +xLRU |
| 1 | +xPE | PREFETCH-E
| 2 | +xL | fetch and lock
| 2 | +xxLP | private RAM/ROM versions of fetch and lock
| 1 | +xA | no-fill ALLOC, like DCBA (security hole, but some still want speed)
| 2 | +xZ | ZALLOC<br/>... + LOCK  | zero allocate, e.g. DCBZ
| 1 | +xW | way locking ...

Bottom line: 5 base CMO types => 3 bits.

17 with all of the above => 5 bits (i.e. more than 4)

B+xZ+xL+xLRU gets us to 9 encodings => highly likely that we will need more than 3 bits.

# Excel spreadsheet "CMOS.xlsx"
Thursday, April 9, 2020-04-09:
   * originally (2020-04-09) in personal in GitHub repo at https://github.com/AndyGlew/Ri5-stuff/blob/master/CMOs.xlsx
   * now (2020-08-12) in official location https://github.com/riscv/riscv-CMOs/blob/master/CMOs.xlsx
   * (probably has more recent copies elsewhere, e.g. personal machine or cloud Drive)
is a "list" of CMOs. Not exactly a list, more like a table from which the actual list can be generated.
Many rows  of the table can be expanded into several different CMO operations
with different privilege requirements, caches affected, etc.

TBD: actually generate a "flat" list. Preferably by script, so that I can automatically go back between the expanded list and a compact form that is folded with common sub expressions that is easier to understand.

[[Why CMOs.xlsx was written in Excel]]


# OLD, Obsolete
[[Quick and dirty list of Actual CMOs]]