# Makefile for riscv/riscv-CMOs

# As of <2020-08-12 Wednesday, August 12, WW33>
# mainly encapsulates knowledge of how to update submodule for wiki corresponding to repo
# (since document may be produced from wiki files)

###############
# git stuff
# mainly to remind me about git submodule commands
# that I do not know by heart
# (and think are kluges anyway)

# submodule
# git  submodule add git@github.com:riscv/riscv-CMOs.wiki.git
# TBD: this is imperfect: clone of a clone does not clone clone's submodule(s)

# run `make git-post-clone' right after git clone of Ri5-stuff
# to update submodules (currently only Ri5-stuff.wiki)
git-post-clone:
	git submodule init
	git submodule update

# checking in generated docs
# a) to make visible on web/GitHub
# b) because toolchain fragile
# TBD: checking in redundant copies, in wiki and parent,
# mostly because belongs and should be versioned with wiki,
# but displays only in parent.

git-diff:
	git diff --submodule
