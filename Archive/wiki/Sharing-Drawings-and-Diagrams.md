Drawings and diagrams are good for technical work, like computer architecture, like RISC-V instruction set design and platform architecture.

Unfortunately, there doesn't seem to be a ubiquitous standard for exchanging drawings. At least not diagrams with smart objects like glue and connectors. SVG may be good enough for simple 2D drawings, but as far as I know the SVGConnector standard has been stalled since 2011.

I asked about what people use on the RISC-V crypto mailing list, and got answers that I will summarize as follows

* Visio
  *proprietary
  * exports/imports to SVG, etc.
  * the .VSD / .VSDX proprietary file formats seem to be the most common exchange format for diagrams
 
* LucidChart
  * proprietary
  * exports/imports to SVG, Visio file formats
  * however, round tripping Vidio -> LucidChart --> Visio --> LucidChart is reported to be unreliable
	
* Markdeep
   * MJO, Marrku on crypto list
   * MarkDeep http://casual-effects.com/markdeep/ internally for CPU documentation. In addition to your easy MarkDown tables and code snippets, it has ASCII type block graphics. Has been sufficient for this particular purpose, but certainly has limits.

* https://www.draw.io/
  * Ben Marshall, University of Bristol	

  * It's free, works online, or as a wrapped up desktop app for offline use.
  * It saves things in a proprietary format unfortunately, but has all the usual export targets: pdf/jpeg/png/svg. Even experimental support for	VSDX, which I think is viseo? 
  * I can also send you a link which entirely encodes the diagram[1] so others can copy/edit it. It's not the live sharing/collaboration thing which google docs does so well, but it's a good alternative.

* LibreOffice Draw
  * Free, glue dots, connectors and SVG export.



* Google Docs Drawing???  
  * Be refers to it
  * IIRC I have tried, but was unhappy. Probably because of off-line behavior, lack of, but I don't remember exactly.