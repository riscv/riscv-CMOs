Relative links can cross-link between GitHub wikis and repo on GitHub itself.

However, when cloned, the wiki and the repo are different git archives. If care is taken the relative cross-links will work. I have made the wiki a submodule of the repo, so that if the repo is cloned recursively the links should still worl=k.

The wiki links will nearly always work, whether on GitHub itself or in a clone, but the links from wiki to repo (and back again) may not always work if cloned without taking the nesting into account.