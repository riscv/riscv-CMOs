This github project has at least two git repos, the main repo and the wiki repo.
* main: https://github.com/riscv/riscv-CMOs.git
* wiki https://github.com/riscv/riscv-CMOs.wiki.git

I want to use relative links between the workspaces that ordinarily correspond to these repos,
* both on the github website and when I have cloned elsewhere
* e.g. so that I can clone both together and be consistent
  * TBD: exact (automated) procedure to clone both repos and stay relatively consistent

Markdown syntax relative links fail:
* [[..]] - \[[..]]
* [[../../wiki]] - \[[../../wiki]]

Trying HTML relative links:
* FAIL: <a href="wiki">href="wiki" relative</a> - \<a href="wiki">href="wiki" relative]\</a>
  * fails because it resolves to https://github.com/riscv/riscv-CMOs/blob/master/wiki,
  * i.e. the relative position is not https://github.com/riscv/riscv-CMOs but is blob/master/wiki
* which tells us what we need to know
  * <a href=".">href="." relative</a> underneath that.
  * <a href="..">href=".."</a>
  * <a href="../..">href="../.." relative</a>
  * <a href="../blob/master/hack-relative-URLs-in-github-project-main-repo.md">href="../blob/master/hack-relative-URLs-in-github-project-main-repo.md"</a>
  * https:../blob/master/hack-relative-URLs-in-github-project-main-repo.md


I am so used to websites not allowing ascending relative components in URLs that I wonder if there is a security hole here... Should not be as long as cannot actually escape an areas mapped to the logged in user or guest.

Recording this in two places:
* main: https://github.com/riscv/riscv-CMOs/blob/master/hack-relative-URLs-in-github-project-main-repo.md
* wiki: https://github.com/riscv/riscv-CMOs/wiki/hack-relative-URLs-in-github-project-wiki-repo
TBD: can I CSE this stuff, transclude, to reduce duplication?

Bottom line: relative links
* from wiki
  * to project "root" from wiki: <a href="..">href=".."</a>
  * to main from wiki: <a href="../blob/master/README.md">href="../blob/master/README.md"</a>
  * to user "root" from wiki: <a href="../..">href="../.."</a>
* from main
  * to project "root" from main: <a href="../..">href="../.."</a>
  * to user "root" from main: <a href="../../..">href="../../.."</a>
  * to wiki from main: <a href="../../wiki">href="../../wiki"</a>