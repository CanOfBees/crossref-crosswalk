<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:doi_batch="http://www.crossref.org/schema/4.3.6"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.crossref.org/schema/4.3.6"
  xmlns="http://www.crossref.org/schema/4.3.6"
  version="2.0">

  <!-- convert NFP OAI_DC to CrossRef -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <!-- includes -->
  <xsl:include href="includes/templates.xsl"/>

  <!-- main template -->
  <xsl:template name="main">
    <xsl:result-document href="crossRef-out/all.xml">
      <doi_batch version="4.3.6" xmlns="http://www.crossref.org/schema/4.3.6"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd">
        <xsl:call-template name="doiBatchHead" xpath-default-namespace="http://www.crossref.org/schema/4.3.6"/>
        <body>
          <xsl:for-each select="collection('nfp-in/')[oai_dc:dc/dc:identifier[contains(.,'DOI:')]]">
            <book book_type="edited_book">
                <book_metadata
                  language="{if (oai_dc:dc/dc:language eq 'eng') then 'en' else oai_dc:dc/dc:language}">
                  <xsl:call-template name="getContributors"/>
                  <xsl:call-template name="getTitles"/>
                  <xsl:call-template name="getPublicationDate"/>
                  <xsl:call-template name="getISBN"/>
                  <xsl:call-template name="getPublisher"/>
                 <doi_data>
                    <doi>10.5072/FK2</doi>
                    <resource>http://www.example.org/</resource>
                  </doi_data>
                </book_metadata>
              </book>
          </xsl:for-each>
        </body>
      </doi_batch>
    </xsl:result-document>

    <!-- spit out individual records -->
    <xsl:for-each select="collection('nfp-in/')[oai_dc:dc/dc:identifier[contains(.,'DOI:')]]">
        <!-- var for making the individual file names -->
        <xsl:variable name="vName" select="tokenize(base-uri(),'/')[last()]"/>
        <xsl:result-document href="crossRef-out/{concat(substring-before($vName,'.xml'),'.test.xml')}">
          <doi_batch version="4.3.6" xmlns="http://www.crossref.org/schema/4.3.6"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd">
            <xsl:call-template name="doiBatchHead"/>
            <body>
              <book book_type="edited_book">
                <book_metadata
                  language="{if (oai_dc:dc/dc:language eq 'eng') then 'en' else oai_dc:dc/dc:language}">
                  <xsl:call-template name="getContributors"/>
                  <xsl:call-template name="getTitles"/>
                  <xsl:call-template name="getPublicationDate"/>
                  <xsl:call-template name="getISBN"/>
                  <xsl:call-template name="getPublisher"/>
                  <doi_data>
                    <doi>10.5072/FK2</doi>
                    <resource>http://www.example.org/</resource>
                  </doi_data>
                </book_metadata>
              </book>
            </body>
          </doi_batch>
        </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
