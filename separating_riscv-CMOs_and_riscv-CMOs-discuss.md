Whining:

Should this WIP entry be inthe isse tracker, wiki, or repo admin/WIP?  yes/bo to all. 

Damn, I hate GitHub's limitations! 

The wiki doesn't have subdirectories, so gets messy.   
The repo supports Markdown, but not wiki style [link targets that do not exist yet]. 
The issue tracker gets messy, like so many issue trackers.
Oh, for twiki or foswiki... Or for MEMEX, as we may think

---

Originally:  single repo+wiki riscv-CMOs, containing both proposal and wiki.

Want: 
* TG members able to post to wiki
* but draft proposals, minutes, etc., writeable by opnly a few people. 

Since GitHub access control seems to ve per-repo, we are splitting the original repo into two:

riscv-CMOs
* to contain protected stuff like drafys and minutes

riscv-CMOs-discuss 
* writeable by TG members
* e.g. wiki
   * TBD: publish how TG members can gain wiki post access
   
# DONE

2020-11-09 ... 10: Ag requested new repo, waffled on names

2020-11-11: Stephano Cetola set up new repo, named the riscv-CMOs-members

2020-11-12: 
* Ag renamed it riscv-CMOs-dscuss
* duplicated old->new, both repo and wiki (full git history)\
* fixed submodules so that old repo->old wiki, new rep->new wiki

# To Do

* Split conteht - deleting and/or disentangling -discuss and non-discuss contet

* most repo files will stay in riscv-CMOs, non-discuss
* leave README, etc., in riscv-CMOs-discuss repo and wiki pointing to the old repo (and vice versa)

* wiki files 
    * some will stay in the old risc-CMOs wiki, some in the new
    * some will need to be edited, fxed up, disentangled
    
* issue tracker
   * fortunately did not propagate when repo+wiki hostory transferred.
        * good fr this task, but someties wanted in other stuations.
        
 * draft proposal
     * currently in wiki - dupred old and new
     * verify can still build in old place
     
     * decide if sgoud be removed from new, and from wiki overall
     * ==> will break wiki links all ovrr
         * GitHub wiki nopt good for trackig wiki page rtenaing and deletions :-(
 
 * once the badsic admin stuff is removed from riscv-CMOs-dscuss, open it up to TG mermbes to use
    * publish how to get access to wiki
    
 * update crosslinks in other CMO TG places
    * old and new repo + wiki on GitHub
    * RISC-V Confluence wiki
    * RISC-V Googke drive pages
    * groups.io mailing list pages, files, wiki etc. (yet anoter wiki :-( )
    
 
    




