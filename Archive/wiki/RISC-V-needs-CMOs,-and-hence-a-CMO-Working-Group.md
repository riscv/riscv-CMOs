All successful computer instruction sets have Cache Management Operations (CMOs).

Several RISC-V systems have already defined implementation specific CMO instructions.
It is desirable to have standard CMO instructions to facilitate portable software.

CMOs do things like flushing dirty data and invalidating clean data for use cases that include 
non-coherent DMA I/O,
security (e.g. Spectre), 
power management (flush to battery backed-up DRAM), 
persistence (flush to NVRAM),
and more.

CMOs cut across several problem domains. It is desirable to have a consistent approach, rather than different idiosyncratic instructions for different problem domains.
RISC-V therefore needs a CMO working group that will coordinate with any working groups in those overlapping domains.

### Administrivia

2020/8/5: Email proposing this will soon be sent to the RISC-V Technical Steering Committee 
and other mailing lists, seeking approval of the formation of such a CMO working group.

Here linked is a wiki version of the WG proposal [[RISC V needs CMOs, and hence a CMO Working Group]].
Also a [[CMOs WG Draft Proposed Charter]] - although probably too long.

**Assuming the CMO WG is approved:**

Please indicate if you are interested by replying to this email (to me, Andy Glew).
To faciliate scheduling of meetings, please indicate timezone.

A risc.org mailing list should be set up soon.

We have already set up https://github.com/riscv/riscv-CMOs,
and will arrange permissions for working group members as soon as possible.

Here linked is a [[CMOs WG Draft Proposed Charter]].

Proposals:
* At least one CMO proposal has been developed in some detail. It is linked to from https://github.com/riscv/riscv-CMOs, and may soon be moved to this official place.
* We welcome: Other proposals, and/or examples of implementation specific CMO extensions already implemented

