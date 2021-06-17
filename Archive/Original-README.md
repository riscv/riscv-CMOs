# riscv-CMOs

Cache Management Operations (CMOs) for RISC-V

* Created by: 	Stephano Cetola
* Requested by: 	Andy Glew


* TBD: working group
* TBD: riscv mailing list

## Charter

The Cache Management Operation, or CMO, task group intends to define data cache
management operations for the RISC-V architecture, providing support for use-cases
such as software-managed cache coherence, power management, persistent storage,
security, and RAS. In the process, a data cache model will be developed, and the
interactions of CMOs with the memory ordering model will be specified. In addition,
the CMO specification will attempt to minimize the requirements on system design
and will not prescribe a specific cache state model or cache coherence protocol.
The CMO TG will coordinate with other RISC-V committees and task groups and with
external parties to ensure consistency and interoperability with respect to any
cache-related features and extensions.

## related GitHub repos and wikis for CMOs TG

* top: https://github.com/riscv/riscv-CMOs
   * for admin stuff like minutes, drafts
   * top-wiki: https://github.com/riscv/riscv-CMOs/wiki
* discuss: https://github.com/riscv/riscv-CMOs-discuss
   * members can add/change
   * mainly in wiki: top-wiki: https://github.com/riscv/riscv-CMOs-discuss/wiki

* git clone --recurse git@github.com:riscv/riscv-CMOs.git
=> 
```
$> tree -d riscv-CMOs/
riscv-CMOs/
|-- admin
|-- agendas-and-minutes
|-- discussion-files
|-- riscv-CMOs-discuss
|   |-- discussion-files
|   `-- riscv-CMOs-discuss.wiki
`-- riscv-CMOs.wiki
    |-- files
    `-- skins
```

Note that riscv-CMOs/wiki and riscv-CNOs-discuss/wiki are duplicated (artifact of original creation 2020-11-13, should be ceaned up soon),
as are some reated files referred to by wiki.

## Wiki-centric

The active work on the proposal is in the wiki.
Eventually it may be moved to the main repository,
although there are tools to assemble the actual proposed spec for
publication from the wiki directly.
Such tools,
also things like highlight unfinished parts of the proposal on the wiki,
will be placed in the main repository, i.e. here.

Q: is there a way to treat this project on github, both "main git repo" and "wiki git repo", as the same object? Otherwise will just check out the reps separately, and coordinate.
    * 5/7/2020: set up wiki as a submodule of repo

## Key wiki pages [@](https://github.com/riscv/riscv-CMOs/wiki)
* [RISC-V needs CMOs, and hence a CMO Working Group](https://github.com/riscv/riscv-CMOs/wiki/RISC-V-needs-CMOs%2C-and-hence-a-CMO-Working-Group)
  * email seeking WG approval and call for participation
* [CMOs WG Draft Proposed Charter](https://github.com/riscv/riscv-CMOs/wiki/CMOs-WG-Draft-Proposed-Charter)
* [Draft CMO proposals](https://github.com/riscv/riscv-CMOs/wiki/Draft-CMO-proposals)
(for that matter, also the other parts of the project, like issues)
   * [[generated-HTML-and-PDF-for-CMOs-proposal]] (local)
   * on web: https://github.com/riscv/riscv-CMOs/wiki/generated-HTML-and-PDF-for-CMOs-proposal





## Links

Project on GitHib:
* https://github.com/riscv/riscv-CMOs
* https://github.com/riscv/riscv-CMOs/wiki
* TBD: links that work when checked out locally as well as on GitHub

Relative, when checked out
* relative <a href="../../wiki">href="../../wiki"</a>,
   * if you have cloned both project git repos, code and wiki
   * this may link to your local clone, rather than back to github


## Originally from

* https://github.com/AndyGlew/Ri5-stuff
* https://github.com/AndyGlew/Ri5-stuff.wiki
