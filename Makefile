# Makefile for Ri5-CMOs-proposal

# As of Wednesday, May 6, 2020-05-06
# The main purpose is to run  a command to expand the AsciiDoc include  directives
# so that you can get a better idea what will actually look like

HTML_VIEWER=/cygdrive/c/Windows/explorer.exe
PDF_VIEWER=/cygdrive/c/Windows/explorer.exe
WEB_VIEWER=start URL...

C:=$(shell basename `pwd`)
W=Ri5-stuff.wiki

default: open-docs-in-browser


###############
# git stuff
# mainly to remind me about git submodule commands
# that I do not know by heart
# (and think are kluges anyway)

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

# echo DEBUG: - I'm not really debugging
# I just want these messages colorized (in emacs)
# and I already have colorization cvode for DEBUG:.*
# whereas my attempt at colorizing INFO:.* failed
# <2020-05-14>
git-status:
	@echo DEBUG: $C;git status
	@(echo DEBUG: $C/$W ;cd $W; git status)




git-ci: git-ci-generated-docs
	@echo 'Only doing git-ci-generated-docs'
	@echo 'checkin non-generated stuff by hand'

M='committing generated HTML and PDF files'
git-ci-generated-docs:
	-git ci -m $M Ri5-CMOs-proposal.html
	-git ci -m $M Ri5-CMOs-proposal.pdf
	-(cd $W;git ci -m $M Ri5-CMOs-proposal.html)
	-(cd $W;git ci -m $M Ri5-CMOs-proposal.pdf)



# Make and display proposal draft

open-docs-in-browser: open-local-docs-in-browser
open-local-docs-in-browser: open-html-in-browser open-pdf-in-browser

open-github-docs-in-browser:


open-html-in-browser: $W/Ri5-CMOs-proposal.html
	@# KLUGE: Windows HTML viewer does not understand / paths
	@# either need to convert / --> /, cd, or cygpath
	-(cd $W;$(HTML_VIEWER) Ri5-CMOs-proposal.html)
open-pdf-in-browser: $W/Ri5-CMOs-proposal.pdf
	@# KLUGE: Windows PDF viewer does not understand / paths
	@# either need to convert / --> /, cd, or cygpath
	-(cd $W;$(PDF_VIEWER) Ri5-CMOs-proposal.pdf)

ASCIIDOCTOR=/home/glew/bin/asciidoctor
ASCIIDOCTOR_PDF=/home/glew/bin/asciidoctor-pdf
#TBD: Move asciidoctor to standard location

generated-docs: ./Ri5-CMOs-proposal.html ./Ri5-CMOs-proposal.pdf

./Ri5-CMOs-proposal.html $W/Ri5-CMOs-proposal.html: always $W/Ri5-CMOs-proposal.asciidoc $W/*.asciidoc
	$(ASCIIDOCTOR) -b html $W/Ri5-CMOs-proposal.asciidoc -o $W/Ri5-CMOs-proposal.html
	cp $W/Ri5-CMOs-proposal.html .
./Ri5-CMOs-proposal.pdf $W/Ri5-CMOs-proposal.pdf: always $W/Ri5-CMOs-proposal.asciidoc $W/*.asciidoc
	$(ASCIIDOCTOR_PDF) -b pdf $W/Ri5-CMOs-proposal.asciidoc -o $W/Ri5-CMOs-proposal.pdf
	cp $W/Ri5-CMOs-proposal.pdf .

# TBD: should I eliminate one of the generated .html files - likely will cause problems since redundant
# But... I really want to have the generated HTML in the wiki, not the parent.

always:


# While it would be nice to have real tags for he documents, and wiki pages, e.g. for sections
# at the moment although I am really reusing the tags for is to do global tags-query-replacve in emacs
# so I only need the planning, not any patterns.
tags-ad TAGS: always
	cp /dev/null TAGS
	etags --append --langdef=asciidoc --langmap=asciidoc:.asciidoc --regex-asciidoc='/^=+\\(.*\\)/\\1/' $W/*.asciidoc

tags tags-all: tags-ad
	etags --append --langdef=markdown --langmap=markdown:.md --regex-markdown='/^=+\\(.*\\)/\\1/' $W/*.md
