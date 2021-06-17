See [[Privilege for CMOs]].   This privilege mechanism provides a basic way of trapping CMOs, e.g. to prevent users or guest OSes from performing operations that might be security holes, and also software mapping, e.g. to M-mode which might use idiosyncratic MMIO locations to manage external caches that are not fully integrated with the CPU instruction set or bus transactions.

I have been unable to persuade people that there is need for a more general mapping mechanism (even though there is).

Therefore, if you want to do things like 
* map user operation "flush all made by this thread to NVRAM persistent storage"
NOT to the  "CMO shootdown" operation
* "flush all dirty data from all CPU caches in the coherence domain ..."
to the more efficient
* "flush only writes made on the local hart..."
Because system software knows that there is no hardware cache to cache migration of dirty cache lines,
and no software thread migration between harts/processors

This ISA provides no such ability to do such mapping cheaply.

If you want to do this, then you've got to trap and emulate.
