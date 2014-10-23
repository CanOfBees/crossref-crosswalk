<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:doi_batch="http://www.crossref.org/schema/4.3.4"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.crossref.org/schema/4.3.3 http://www.crossref.org/schemas/crossref4.3.3.xsd"
  exclude-result-prefixes="#all" version="2.0">

  <!-- convert NFP OAI_DC to CrossRef -->
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:template name="main">
    <!-- spit out one big record -->
    <xsl:result-document href="crossRef-out/all.xml">
      <doi_batch version="4.3.3" xmlns="http://www.crossref.org/schema/4.3.3"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.crossref.org/schema/4.3.3 http://www.crossref.org/schemas/crossref4.3.3.xsd">
        <xsl:for-each select="collection('nfp-in/')">
          <book><xsl:text>Hi!</xsl:text></book>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
      </doi_batch>
    </xsl:result-document>
    
    <!-- spit out individual records -->
    <xsl:for-each select="collection('nfp-in/')/oai_dc:dc/dc:identifier[contains(.,'DOI:')]">
      <xsl:variable name="vName" select="substring-before(base-uri(),'.xml')"/>
        <xsl:result-document href="crossRef-out/{concat($vName,'.test.xml')}">
        <doi_batch version="4.3.3"
          xmlns="http://www.crossref.org/schema/4.3.3" 
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xsi:schemaLocation="http://www.crossref.org/schema/4.3.3 http://www.crossref.org/schemas/crossref4.3.3.xsd">
          <head>
            <doi_batch_id>10.5072/FK2</doi_batch_id>
            <timestamp>
              <xsl:value-of select="format-date(current-date(),'[Y][M][D]')"/>
            </timestamp>
            <depositor>
              <name><xsl:value-of select="$vName"/></name>
              <email_address>bdysonsm@utk.edu</email_address>
            </depositor>
            <registrant>The University of Tennessee Libraries</registrant>
          </head>
          <body>
            <book>
              <xsl:text>HI!</xsl:text>
            </book>
          </body>
        </doi_batch> 
        </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
