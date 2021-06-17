
# CLEAN
also known as: write back

writes dirty data out of the cache, leaving clean data behind.

I.e. the cache contents after this operation should be all have been written back.

[[Issue: Q: should  CMOs like clean and flush update LRU]]

[[CMO Scope]]: local,

[[CMO target]]:

Examples:
* flush to point of persistence (NVRAM)
* flush two point of persistence


* flush two point of persistence (battery backed up DRAM)
* flush two point of coherence (SW managed cache consistency
* flush to shared cache level

issue: vocabulary/terminology: I am very much used to saying "flush to DRAM" indicating that all dirty accesses should be sent to DRAM. I am not at all used to saying "clean to DRAM".



#Flush
a.k.a. write back and invalidate

Writes dirty data out of the cache.

I.e. the cache contents after this operation all have been invalidated.

# DISCARD

a.k.a. Invalidate, Forget

Actually throws away dirty data in the cache, to the extent that is permissible by the cache protocol.

Motivation: once temporary memory buffers are no longer needed, it is "wasteful" to write the temporary values back to memory. Of interest mostly for really large caches, or to avoid writing back unneeded dirty data to NV RAM in a persistent memory system.

Analogy: SSD TRIM commands.

Unsafe:
* this can expose old data in memory that was overwritten by values that are now being forgotten.
  * note that system code may
