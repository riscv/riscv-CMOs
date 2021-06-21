Minutes for the RISC-V CMOs TG
Cache Management Operations

2020-11-11: Ri5 TG leadership announced policy/standard for storing meeting minutes so that people can find them easily.
* in GitHub repo for TG
    * not wiki :-(
* subfolder agendas-and-minutes
* datestamped filename prefix YYYY-MM-DD

Further rules for this CMOs TG:

* YYYY-MM-DD_CMOs-TG_meeting
    * _meeting, to distinguish from other items that may be stored here
    * _meeting, not _minutes, because more often informal and incomplete notes rather than formal and complete minutes
* YYYY-MM-DD_CMOs-TG_agenda
    * if we announce an agenda in advance - if by email, please also record here
    * it is OK to place both agenda and notes/minutes in the same _meeting file
* YYYY-MM-DD_CMOs-TG_meeting_OTHER_STUFF
    * can add OTHER_STUFF, like main topic, presentation, to datestamped filename - useful in browsing

* if more than one meeting in a day, add timestamp YYYY-MM-DD_hhmm_CMOs-TG_meeting...
    * still sorts with other datestamped but not timestamped filenames
    * not ISO8601 - e.g. colons : not legal in Windows filenames.  T reduces legibility.
    * hhmm - not hh only - followuing at least that part of ISO8601

* Examples:
    *

* Least Common Denominator filenames
    * brief
       * alpha (a-z A-Z), numeric (0-9), punctuation -_ ...
       * avoid whitespace, non-windows characters <>:"/\|?*
       * typically use _ or - instead of whitespace

TBD: moved/link elsewhere more detailed LCD filenames stuff
    * why
       * Users/members have already had problems cloning repo filenames containing charcagers like : that are illegal on Windows
       * Filename length limits: ??? - keep short, but not too short ...
       * Avoid characters
          * Windows: <>:"/\|?*
          * Convenience: no whitespace (including space and newline)
             * use underscore _ where whitespace would be natural
       * avoid the usual special filenames such as . or .., initial ~, ...
       * try to avoid filenames that can be used for exploits, like `"'{}[]() ...
    * regrets
       * common punctuation can really improve readability - but is often problem.  E.g. ?!()[]{}...



Prior minutes for this TG are in email, and certain other places.

2020-11-11: creating placeholders for old minutes - basically empty files
* recording that meeting was held
* TBD: copy/move, and/or provide links to existing minutes/material
