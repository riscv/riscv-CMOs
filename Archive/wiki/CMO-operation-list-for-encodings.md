(This page [[CMO operation list for encodings]]
extracted from parent [[Actual CMO Operations]]
because GitHub wiki doesn't have section editing 
(but also lacks transclusion :-( ) )


The list below ... + annotated according to priority / possible extensions (trying to diet, reduce to <= 8, 3 bits)
* B = base - surely must have
* +x?? - possible extensions



| priority | rw  | name | detail |
| ---      | --- | ---  | ---    |
| |
| B | r   |  WRITEBACK<br/>IBM: CLEAN | dirty --wb--> clean,<br/>clean-->unaffected
| B | r   |  WB-INVALIDATE<br/>IBM: FLUSH | dirty --wb--> clean,<br/> clean-->unaffected
| +xIO | r   |  INVALIDATE CLEAN | clean --> invalid <br/>  dirty --> unaffected <br/>  secure <br/> suitable for NC I/O 
| B | w   |  INVALIDATE<br/>IBM: DISCARD |   clean --> invalid, <br/>  dirty -- no wb -->  invalid <br/> e.g. n on-coherent I/O, reset
| +xD+ | w   |  safer discards |   see elsewhere 
| |
| +xLRU| r | Set LRU | wish: prefetches/loads/stores that have LRU / not MRU / non-temporal hints
| | 
| B | r |  PREFETCH-R | PREFETCH-X has I$ target | ?? eliminate by making  PREFETCH-R with I$ target <br/> multilevel I$
| B | r |  PREFETCH-W |  prefetch to write, may be clean or dirty
| +xPE| r |  ? PREFETCH-E |  prefetch as if to write, but must be clean <br/>  may need to update outer $/DRAM on way
|  |
| +xL | r | FETCH-W + LOCK |  like creating local  writable copy of shared RAM
| +xL | r | FETCH-R + LOCK |  like creating  local copy of  shared ROM
| +xxLP | r | FETCH-E + LOCK |  like creating  private ROM
| +xxLP | r | FETCH-EW + LOCK |  like creating  private RAM
| |
| .xA | w | NO-FILL ALLOC | like DCBA (security hole)
| .xZ | w | ZALLOC  |  like DCBZ 
| .xZ | w | ZALLOC + LOCK  |  like creating local RAM <br/> TBD:   private / shared 
| |
| .xW | r | way locking |  beyond scope,  way mask separate 

