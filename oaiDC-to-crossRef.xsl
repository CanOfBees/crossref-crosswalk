<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:doi_batch="http://www.crossref.org/schema/4.3.6"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.crossref.org/schema/4.3.6"
  version="2.0">

  <!-- convert NFP OAI_DC to CrossRef -->
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- main template -->
  <xsl:template name="main">
    <!-- spit out one big record -->
    <xsl:result-document href="crossRef-out/all.xml">
      <!-- document root w/namespaces -->
      <doi_batch version="4.3.6" xmlns="http://www.crossref.org/schema/4.3.6"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd">
        <head>
          <doi_batch_id>
            <xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]-[H]-[m]-[s][f]')"/>
          </doi_batch_id>
          <timestamp>
            <xsl:value-of select="format-date(current-date(),'[Y][M][D]')"/>
          </timestamp>
          <depositor>
            <name>Bridger Dyson-Smith</name>
            <email_address>bdysonsm@utk.edu</email_address>
          </depositor>
          <registrant>University of Tennessee</registrant>
        </head>
        <body>
          <xsl:for-each select="collection('nfp-in/')">
            <xsl:if test="oai_dc:dc/dc:identifier[contains(.,'DOI:')]">
              <book book_type="edited_book">
                <book_metadata
                  language="{if (oai_dc:dc/dc:language eq 'eng') then 'en' else oai_dc:dc/dc:language}">
                  <contributors>
                    <xsl:for-each select="oai_dc:dc/dc:creator">
                      <!-- test -->
                      <!--<xsl:variable name="vC"
                          select="if (ends-with(.,'.')
                                  and not(contains(.,',')))
                                  then substring-before(.,'.'[last()]) else ''"/>-->
                      <!-- end test -->
                      <xsl:choose>
                        <!-- corp name attempt -->
                        <xsl:when test="ends-with(.,'.') and not(contains(.,','))">
                          <organization
                            sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
                            contributor_role="author">
                            <xsl:value-of select="substring-before(.,'.'[last()])"/>
                          </organization>
                        </xsl:when>
                        <!-- try for people names -->
                        <xsl:otherwise>
                          <person_name
                            sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
                            contributor_role="author">
                            <given_name>
                              <xsl:value-of
                                select="if (ends-with(.,',')) then
                                  normalize-space(substring-before(substring-after(.,','[position()=1]),','[last()]))
                                  else if (ends-with(.,'.')) then
                                  normalize-space(substring-before(substring-after(.,','[position()=1]),'.'[last()]))
                                  else ''"
                              />
                            </given_name>
                            <surname>
                              <xsl:value-of select="substring-before(.,','[position()=1])"/>
                            </surname>
                          </person_name>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </contributors>
                  <titles>
                    <title>
                      <xsl:value-of select="normalize-space(substring-before(oai_dc:dc/dc:title,'/'[last()]))"/>
                    </title>
                  </titles>
                  <publication_date media_type="online">
                    <year>
                      <xsl:value-of
                        select="if (oai_dc:dc/dc:date) then
                                  (if (starts-with(oai_dc:dc/dc:date,'c')) then
                                    substring-before(substring-after(oai_dc:dc/dc:date,'c'),'.')
                                    else substring-before(oai_dc:dc/dc:date,'.'))
                                else '2014'"
                      />
                    </year>
                  </publication_date>
                  <xsl:for-each select="oai_dc:dc/dc:identifier">
                    <xsl:choose>
                      <xsl:when test="starts-with(.,'URN:ISBN')">
                        <isbn media_type="electronic">
                          <xsl:analyze-string select="." regex="[0-9]+">
                            <xsl:matching-substring>
                              <xsl:value-of select="."/>
                            </xsl:matching-substring>
                          </xsl:analyze-string>
                        </isbn>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:choose>
                    <xsl:when test="oai_dc:dc/dc:publisher">
                      <publisher>
                        <publisher_name>
                          <xsl:value-of
                            select="normalize-space(substring-after(oai_dc:dc/dc:publisher,':'))"/>
                        </publisher_name>
                        <publisher_place>
                          <xsl:value-of
                            select="normalize-space(substring-before(oai_dc:dc/dc:publisher,':'))"/>
                        </publisher_place>
                      </publisher>
                    </xsl:when>
                    <xsl:otherwise>
                      <publisher>
                        <publisher_name>
                          <xsl:value-of select="'Newfound Press, University of Tennessee Libraries'"/>
                        </publisher_name>
                        <publisher_place>
                          <xsl:value-of select="'Knoxville, Tenn.'"/>
                        </publisher_place>
                      </publisher>
                    </xsl:otherwise>
                  </xsl:choose>
                  <doi_data>
                    <doi>10.5072/FK2</doi>
                    <resource>http://www.example.org/</resource>
                  </doi_data>
                </book_metadata>
              </book>
            </xsl:if>
          </xsl:for-each>
        </body>
      </doi_batch>
    </xsl:result-document>

    <!-- spit out individual records -->
    <xsl:for-each select="collection('nfp-in/')">
      <xsl:if test="/oai_dc:dc/dc:identifier[contains(.,'DOI:')]">
        <xsl:variable name="vName" select="tokenize(base-uri(),'/')[last()]"/>
        <xsl:result-document href="crossRef-out/{concat($vName,'.test.xml')}">
          <doi_batch version="4.3.6" xmlns="http://www.crossref.org/schema/4.3.6"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd">
            <head>
              <doi_batch_id>
                <xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]-[H]-[m]-[s][f]')"/>
              </doi_batch_id>
              <timestamp>
                <xsl:value-of select="format-date(current-date(), '[Y][M][D]')"/>
              </timestamp>
              <depositor>
                <name>Bridger Dyson-Smith</name>
                <email_address>bdysonsm@utk.edu</email_address>
              </depositor>
              <registrant>University of Tennessee</registrant>
            </head>
            <body>
              <book book_type="edited_book">
                <book_metadata
                  language="{if (oai_dc:dc/dc:language eq 'eng') then 'en' else oai_dc:dc/dc:language}">
                  <contributors>
                    <xsl:for-each select="oai_dc:dc/dc:creator">
                      <!-- test -->
                      <!--<xsl:variable name="vC"
                          select="if (ends-with(.,'.') 
                                  and not(contains(.,','))) 
                                  then substring-before(.,'.'[last()]) else ''"/>-->
                      <!-- end test -->
                      <xsl:choose>
                        <!-- corp name attempt -->
                        <xsl:when test="ends-with(.,'.') and not(contains(.,','))">
                          <organization
                            sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
                            contributor_role="author">
                            <xsl:value-of select="substring-before(.,'.'[last()])"/>
                          </organization>
                        </xsl:when>
                        <!-- try for people names -->
                        <xsl:otherwise>
                          <person_name
                            sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
                            contributor_role="author">
                            <given_name>
                              <xsl:value-of
                                select="if (ends-with(.,',')) then 
                                normalize-space(substring-before(substring-after(.,','[position()=1]),','[last()])) 
                                else if (ends-with(.,'.')) then 
                                normalize-space(substring-before(substring-after(.,','[position()=1]),'.'[last()])) 
                                else ''"
                              />
                            </given_name>
                            <surname>
                              <xsl:value-of select="substring-before(.,','[position()=1])"/>
                            </surname>
                          </person_name>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </contributors>
                  <titles>
                    <title>
                      <xsl:value-of select="normalize-space(substring-before(oai_dc:dc/dc:title,'/'[last()]))"/>
                    </title>
                  </titles>
                  <publication_date media_type="online">
                    <year>
                      <xsl:value-of
                        select="if (oai_dc:dc/dc:date) then
                        (if (starts-with(oai_dc:dc/dc:date,'c')) then
                        substring-before(substring-after(oai_dc:dc/dc:date,'c'),'.') 
                        else substring-before(oai_dc:dc/dc:date,'.')) 
                        else '2014'"
                      />
                    </year>
                  </publication_date>
                  <xsl:for-each select="oai_dc:dc/dc:identifier">
                    <xsl:choose>
                      <xsl:when test="starts-with(.,'URN:ISBN')">
                        <isbn media_type="electronic">
                          <xsl:analyze-string select="." regex="[0-9]+">
                            <xsl:matching-substring>
                              <xsl:value-of select="."/>
                            </xsl:matching-substring>
                          </xsl:analyze-string>
                        </isbn>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:choose>
                    <xsl:when test="oai_dc:dc/dc:publisher">
                      <publisher>
                        <publisher_name>
                          <xsl:value-of
                            select="normalize-space(substring-after(oai_dc:dc/dc:publisher,':'))"/>
                        </publisher_name>
                        <publisher_place>
                          <xsl:value-of
                            select="normalize-space(substring-before(oai_dc:dc/dc:publisher,':'))"/>
                        </publisher_place>
                      </publisher>
                    </xsl:when>
                    <xsl:otherwise>
                      <publisher>
                        <publisher_name>
                          <xsl:value-of select="'Newfound Press, University of Tennessee Libraries'"/>
                        </publisher_name>
                        <publisher_place><xsl:value-of select="'Knoxville, Tenn.'"/></publisher_place>
                      </publisher>
                    </xsl:otherwise>
                  </xsl:choose>
                  <doi_data>
                    <doi>10.5072/FK2</doi>
                    <resource>http://www.example.org/</resource>
                  </doi_data>
                </book_metadata>
              </book>
            </body>
          </doi_batch>
        </xsl:result-document>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- end main template -->


</xsl:stylesheet>
