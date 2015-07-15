### README ###

This script aims to turn OAI_DC into CrossRef-friendly ingest metadata.

It's currently set to only do the items that have DOIs. The remainder of the documents can be pulled in fairly easily.

#### HOW ####

* Use oXygen to configure a tranformation scenario and apply the xsl stylesheet against the files in nfp-in/; the results should be available in crossRef-out/. NOTE: you'll need to supply the initial template name ("main") in order for the transform to work.

* alternately, if you have saxon (saxon-B or saxon-he) installed, you can run the following from the cli:

   saxon -it:main -xsl:oaiDC-to-crossref.xsl
 
