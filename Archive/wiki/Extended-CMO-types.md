There are more types of CMOs
* than are represented in computer architecture textbooks
* than can be fit into small number of instruction encodings.

Therefore, I propose <extended_cmo_type>

a) that can be placed in a <cmo_type> encoding that maps to one of 2 CSRs that contains the <extended_cmo_type>

or

b) that can be placed in a register operand passed to the CMO instruction.


The first approach, using CSRs to hold the <extended_cmo_type>, is IMHO preferred, because it exposes less of the microarchitecture while supporting greater architectural flexibility, and requires less complexity to make secure (non-forgeable).  The latter approach, placing the <extended_cmo_type> in a register operand is correspondingly deprecated, and is not part of the active proposal.


= <extended_cmo_type> in a CSR

The last <cmo_type> is used to say "use the <extended_cmo_type> specified in CSR_TBD".

The ISA does not define the format of the <extended_cmo_type>, although this proposal provides a basic recommendation.

I propose that OS or platform specific software abstract things as follows:
* User code makes a system call that tells the OS, e.g.  "I am only trying to synchronize with threads/processes running on other harts/CPUs with which I share an L3$, so flush/invalidate the L1$, L2$, and everything all the way to the L3$, but don't flush the L3$ or L4$.: - when the standard <cmo_type> flush operations wouyld also flush the L4.
* OS determines if the user is allowed to do the operation, error if not
* OS determines the implementation dependent encodings to be placed in the CSR
* OS returns to user
* user can now use the CMO.* instructions with <cmo_type>=use CSR that contains <extended_cmo_type>
* OS knows that the user is allowed to use the CMO, because it tested it at the time it was set up.

= <extended_cmo_type> in a register input

Intead of
* CMO.VAR.<cmo_inst_type>.<virtual/physical> rd, rs1
  * rd=nbytes, rs1=hi_addr
* CMO.FSZ.<fixed_size>.<cmo_type>.<virtual/physical> rs1
  * rs1=addr

Use an additional register
* CMO.VAR.<cmo_inst_type>.<virtual/physical> rd, rs1, rs2
  * rd=nbytes, rs1=hi_addr, rs2=<extended_cmo_type>
* CMO.FSZ.<fixed_size>.<cmo_type>.<virtual/physical> rs1
  * rs1=addr, rs2=<extended_cmo_type>

I would prefer that the ISA did NOT define the <extended_cmo_type> format.
I propose that OS or platform specific software abstract things as follows:
* User code makes a system call that tells the OS, e.g.  "I am only trying to synchronize with threads/processes running on other harts/CPUs with which I share an L3$, so flush/invalidate the L1$, L2$, and everything all the way to the L3$, but don't flush the L3$ or L4$.: - when the standard <cmo_type> flush operations wouyld also flush the L4.
* OS determines if the user is allowed to do the operation, error if not
* OS returns to the user an encoding that it can pass as the rs2 cmo_type value above.
* user can now use the CMO.* instructions with rs2=value returned by OS
* However, OS must prevent user from forging access to CMOs that they should not be allowed.
  * e.g. it may be a handfle number, mapped to a full CMO encoding in a table, with table index checks
  * or OS may have loaded a list of permitted encodings, that HW must check user provided value against.

= <extended_cmo_type> encoding - reference implementation

I would prefer that the ISA did NOT define the <extended_cmo_type> format.

But nevertheless I want to provide a reference example.

Bits in an XLEN register value

* 1-bit:
  * writeback dirty data
  * invalidate dirty data without writing back - security sensitive!!!
* 1-bit:
  * invalidate all lines scanned
  * leave clean lines
* 1-bit: I: applies to all caches that can hold instrtuctions
* 1-bit D: applies to all caches that can hold data
  * note: bitmask, so can CMO I-only, D-only, or both
* 3-bits: cache depth
  * systems with L0..L4 caches are available nowadays - this allows up to 8 levels of hierarchy
  * cache numbering is system specific, e.g. the L1/L2 may be exclusive
* 3-bits: virtual/physical guest/host ...
  * 000 = (guest) virtual
  * 001 = (guest) physical
  * 010 = host virtual
  * 011 = host physical
  * ... reserved
* 1-bit: use cache uarch parameters
  * 3-bits: cache number
  * 1-bit: flush all
  * 16-bits: way mask <-- e.g. if user is given only certain ways for isolation
  * ??
* 8-bits: value to be placed on a bus transaction to flush external caches outside the CPU.


* pou = I & D
* poc
* pop = point of persistence (battery backed uop DRAM)
* pop = point of persistence (NVRAM)




It can be seen that this can quickly exceed 32-bits. And I am not trying very hard.

Nevertheless, this format is NOT part of the architecture.  Just a suggestion.
