Asciidoctor [[Ri5-CMOs-proposal]] is used to generate HTML and PDF
from .asciidoc source files which are pages on this wiki.

The generated files can be found in the parent project repo:
  * [HTML-rendered](https://htmlpreview.github.io/?https://github.com/riscv/riscv-CMOs/blob/master/Ri5-CMOs-proposal.html) - as rendered by the htmlpreview proxy
     * [HTML-source](https://github.com/riscv/riscv-CMOs/blob/master/Ri5-CMOs-proposal.html) - GitHub renders as plain text if not proxied
  * [PDF](https://github.com/riscv/riscv-CMOs/blob/master/Ri5-CMOs-proposal.pdf)
      * PDF displays

It would be better to have the generated HTML and PDF on the wiki
because that's where it belongs, since generated from wiki.
Unfortunately HTML and PDF do not display properly in a GitHub wiki.
Raw HTML displayed as text, not rendered; PDF downloads.
In the product repo, since HTML and PDF are displayed there.

Because the wiki and project have separate git repos, they may not match,
i.e. the repo HTML and PDF may be stale.

Even in the wiki the HTML and PDF may be out of date, since scripts must be run to generate.
But more likely to be consistent.