# WIP: repo/wiki splitting into top and -discuss

[[issues wrt repo and wiki split]]

# riscv-CMOs/wiki/Home.md

Welcome to riscv-CMOs/wiki ... This may not be the wiki you are looking for. Not if you wat to discuss and post wiki-style.  This repo and wiki are 

The CMOs TG has more than one GitHub repo, each with their associated wiki.

* riscv-CMOs
    * [repo](https://github.com/riscv/riscv-CMOs), [wiki](https://github.com/riscv/riscv-CMOs/wiki)
    * for administrivia, meeting minutes, draft proposals, etc.
        * should only be changed by limited group - TG chair co-chair, helpers...
        * world readable, as is most RISC-V stuff, GitHub and elsewhere
    * https://github.com/riscv/riscv-CMOs ...

* riscv-CMOs-discuss
    * [repo](https://github.com/riscv/riscv-CMOs-discuss), [wiki](https://github.com/riscv/riscv-CMOs-discuss/wiki)
    * for discussion, e,g, in wiki
         * should be changeable by all CMOs TG members (who have a GitHub account, contact chairs for permissions...)
         * world readable, as is most RISC-V stuff, GitHub and elsewhere
    * possibly other stuff ... 
         * e.g. post slides/docs you want to discuss present here, wherther in wiki or repo - nicer than email fly-by
         *  ... although if we want to reddice chances of accidetally disapearing, may move to [riscv-CMOs](https://github.com/riscv/riscv-CMOs)
    * https://github.com/riscv/riscv-CMOs-discuss ...

Why separate repos?  Permissions - GitHub seems to only have per-repo access control, not separate wiki/repo, and not per file or folder in repo.
* It will be embarrassing if this is incorrect, if GitHub has fine grain access control. Please tell me if it does!!!

Originally, we only had a single repo [riscv-CMOs](https://github.com/riscv/riscv-CMOs), mixing both.
We knew from the start that we wanted different permissions. 
RISC-V overall wasted much time wasted thrashing - should we move to Google Drive/Docs? Confluence? GitLab? Stay with Groups.io?

Circa 2020-11-09 RISC-V settled on GitHub for TG meeting minutes.

11/12/2020-11-12: 
* CMOs TG got separate GitHub repos for access control
* 12th and 13th: original [riscv-CMOs](https://github.com/riscv/riscv-CMOs) duplicated, with history, to [riscv-CMOs-discuss](https://github.com/riscv/riscv-CMOs-discuss) => both start out almost exactly the same at tis time.

WIP 11/12/2020-11-13: 
* disentangling, separating the repos. Mainly, deleting stuff.
* submodule structure

# Home.md - this file's status, old and new -discuss wikis

"Merging"
* new riscv-CMOs-discuss/wiki/Home.md
* and old new riscv-CMOs/wiki/Home.md

by concatenating.

Subsequently will separate.
# original Home.md for new riscv-CMOs-discuss/wiki
 
The new GitHub repo riscv-CMOs-discuss and its wiki

were created so that we can split the old GitHub repo riscv-CMOs and wiki

into two pieces

riscv-CMOs + wiki
* readable by the world
* writable - restricted to TG chairs and maintainers

riscv-CMOs-discuss + wiki
* readable by the world
* writable - by all CMOs TG members
    * at first, mainly for wiki access

At the time of writing (2020-11-12) I am propagating the old wiki to this new wiki.  Have already done so for the main repo.


# old riscv-CMOs/wiki/Home.md

...the below...

# riscv-CMOs wiki

This is the wiki for the RISC-V CMOs (Cache Management Operations) Technical Group.

[[RISC-V standard disclaimer]]

## CMO TG meeting minutes

RISC-V thrashed a lot wrt where stuff like TG minutes should be placed.  Email... Groups.io files... Groups.io wiki... Github wiki... Github repo...Google drive... Confluence wiki...

As of 2020-11-08, there is a policy -  put the minutes in the GitHub code repo, not in the GitHub wiki, and not anywhere else.

As a result of the thrashing, this TG minutes are  in several different places

* older minutes on email - will be moved here

* wiki: [[Meeting 11-09-2020]]

*  and now the official 
     * https://github.com/riscv/riscv-CMOs/tree/master/agendas-and-minutes

TBD/WIP: Gather/collect  and link/copy old minutes here, so that they can be found.   This may be a low priority task, as long as future minutes are placed here



## [[How to search this wiki, repo, issues, etc.]]

## Upcoming

See [RISC-C Tech Groups Calendar](https://sites.google.com/a/riscv.org/risc-v-staff/home/tech-groups-cal), for info including Zoom links

### [[Agenda for CMOs TG]]



## [[RISC-V CMO proposal]]

See [separate page](RISC-V CMO proposal) for links to the generated PDF and HTML for "releases",
as well as info on how to access.

Note that as of Sept 2020, the proposal is actually generated from pages in this wiki.

## Arguments, Counter-Proposals, etc.

Most of our discussion proceeds in email, but from time to time large screeds, PowerPoint slides, etc. are prepared.
These may be upgraded to the actual repo or whatever other file storage is present and linked to from here

* [[Arguments against address range CMO.AR]]

## [[Administrivia]]

### CMO TG

Chair: Andy Glew (SiFive)

Vice-chair: David Kruckemyer (Ventana)

GitHub riscv/riscv-CMOs [repo](https://github.com/riscv/riscv-CMOs) and [wiki](https://github.com/riscv/riscv-CMOs/wiki)
* note: repo has wiki as a git submodule. C;one'ing using SSH works; cloning via HTTPS has problems, e.g. GitHub desktop client
* As of Sept 2020, the GitHub repo - especially the wiki - is the true "home" of most of the CMO TG

Traditional RISC-V TG "homepage": https://lists.riscv.org/g/tech-cmo
* NOTE: inconsistent spelling: "CMOs" on GitHub, but "cmo" on lists.riscv.org
* Although the wiki has most "home" info, including proposals andf agendae, lists.riscv.org is the hub for stuff like
    * Mailing list: tech-cmo@lists.riscv.org
       * subscription info
       * email messages archive: https://lists.riscv.org/g/tech-cmo/topics
       * yet another wiki
* files: https://lists.riscv.org/g/tech-smo/files
   * not used as of Sept 2020
   * but may be used in future if we need access restricted to members

Calendar:
* CMO TG meetings are posted on https://sites.google.com/a/riscv.org/risc-v-staff/home/tech-groups-cal
  * as are all RISC-V TG meetings - all on the same calendar
* ical:  https://calendar.google.com/calendar/ical/c_sumcgd4h4k09ktuppmqjb27o1s%40group.calendar.google.com/public/basic.ics
* Zoom links will be posted in the calendar item
  * or possibly in a file in https://lists.riscv.org/g/tech-smo/files, linked to friom the calendar item
  * but will NOT be sebt in email.


Issue Tracking: on the GitHub wiki https://github.com/riscv/riscv-CMOs/issues

Network locations - GitHub repo, wiki, mailing lists, etc.

See [[TOC - Table of Contents]]
  * almost certainly out of date
  * TBD: [[automate generation and update of wiki TOC]] as wiki evolves

## Where else is CMOs TG stuff?

### Wikis: there are too many wikis... 

Original GitHub wiki https://github.com/riscv/riscv-CMOs/wiki
   * the "main" wiki as of Sept 2020
       * 2020-11-13: WIP: splitting off discussion into the new [-discuss wiki](ttps://github.com/riscv/riscv-CMOs-discuss/wiki
   * contains a draft CMO proposal
   * clone as a submodule of the GitHub (code) repo https://github.com/riscv/riscv-CMOs

New [-discuss wiki ](https://github.com/riscv/riscv-CMOs-discuss/wiki) 
   * 2020-11-13: WIP: splitting off from the older [top repo wiki](ttps://github.com/riscv/riscv-CMOs/wiki) as of November 2020
   * CMO TG members can Post discussions to this wiki...
   * 2020-11-13:  beware: contains stale information like stale draft CMO proposal

Groups.io wiki: https://lists.riscv.org/g/tech-cmo/wiki
   * not used as of Sept 22, 2020
   * big advantage over the GitHub wiki: allows copy-paste of bitmap images, e.g. diagrams - easier than up0loading image files

Confluence -  yet another RISC-V wiki - https://wiki.riscv.org.
   * for a while it looks like we were going to have to move things like CMO TG  minutes and other pages to this wiki
   * as of 2020-11-13  will not see much use, perhaps just pointers to the GitHub wiki
   * pro/con:  like the Groups.io wiki, can copy.paste bitmaps,  and all the other good stuff that the GitHub wiki cannot do 
   * See [CMO TG page on wiki.riscv.org](https://wiki.riscv.org/display/TECH/CMO+%28Cache+Management+Operations%29+TG)

Other wiki-like stuff:

* Google Drive
   * RISC-V has an official Google Drive. TBD: link
   * [[Google Drive is not a wiki]]  although some people mistake it for one
   * TBD:  link/collect old CMO stuff  from the Google Drive


## Filesystems:  again, there are/were to many...

GitHub -  main file storage for CMOs TG
* https://github.com/riscv/riscv-CMOs
* https://github.com/riscv/riscv-CMOs-discuss

Note:  files may also have been uploaded to the corresponding GitHub wikis...

Groups.io file storage : https://lists.riscv.org/g/tech-cmo/files
   * not used by the CMOs TG 
   * although historically used by other TGs, like security

Google Drive
   * RISC-V has an official Google Drive. TBD: link
   * 2020-11-13:  not being used for most CMO.TG discussion and work
   *  however, RISC-V CTO and program management require TG status to be updated in various places on this drive
       * TBD: link   

Again, note that files may have been or may yet be uploaded to any of the several too many wikis 
   * Approved
      *  [top wiki riscv-CMOs/wiki](https://github.com/riscv/riscv-CMOs.wiki)
      *  [discussion  wiki riscv-CMOs-discuss/wiki](https://github.com/riscv/riscv-CMOs-discuss.wiki)
   * Please avoid
      * Ri5 Confluence: [CMO TG page on wiki.riscv.org](https://wiki.riscv.org/display/TECH/CMO+%28Cache+Management+Operations%29+TG)
      * [old Groups.io wiki](https://lists.riscv.org/g/tech-cmo/wiki)
    * Mentioned only  increase you really do need to go hunting for something maybe put in the wrong place


## Wiki Administrivia
* [[hack-relative-URLs-in-github-project-wiki-repo]]
* [[Sharing Drawings and Diagrams]]


# [[Non-CMO stuff to be deleted]]

# WIP: repo/wiki splitting into top and -discuss

[[issues wrt repo and wiki split]]
