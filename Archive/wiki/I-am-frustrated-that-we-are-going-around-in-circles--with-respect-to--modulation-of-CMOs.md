Current proposal, hoping to break this deadlock: [[Privilege for CMOs]]

# Interception,  Modulation,  and Mapping of CMOs

# Original Proposal: CSRs ansd system calls.

My (Ag's) original proposal looked something like this:

*  CMO instructions that contain CSR operand, along  with  and address  or a (set,way)  cache entry number that indicated what to flush
* A CSR operand for each such CMO instruction, that contained an encoding that indicated which caches aned branch predictors need

however, it is necessary to  accompany this with a system call:
1.  since the user cannot write such a CSR directly
2. since  different software systems may allow  may allow (some) users to perform a CMO,  while the same or other software systems may disallow (some)  users from performing that same CMO
    *  i.e. the privilege required for a CMO depends on the  system software. It is NOT KNOWN to CPU hardware or the ISA
3.  since there needs to be a mapping between abstract user level CMO's and the operations that the hardware actually performs

Mapping

local cluster 
  HW coherent MOESI
SW coherence 
  between clusters

SW P -> C

MOESI
   * flush all dirty data in local cluster to the poc(P,C)
MESI
   * no thread migration
       * flush local CPU only
   * thread  - flush all cluster


Point_of_Unification = pocvg(P.I,P.D)
      * pocvg(P*.I,P*.D)

Point_of_Coherence   = pocvg(P1.D,p2.D;address)

Point_of_Persistence = pocvg(P1,NVRAM) or pocvg(
     * 

Point_of_Serialization = per address
  * FENCE.COMPLETION = persistence / SW coherency / MMIO



