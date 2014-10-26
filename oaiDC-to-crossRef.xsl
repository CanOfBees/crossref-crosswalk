<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:doi_batch="http://www.crossref.org/schema/4.3.3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.crossref.org/schema/4.3.3 http://www.crossref.org/schemas/crossref4.3.3.xsd"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.crossref.org/schema/4.3.3"
  version="2.0">

  <!-- convert NFP OAI_DC to CrossRef -->
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- main template -->
  <xsl:template name="main">
    <!-- spit out one big record -->
    <xsl:result-document href="crossRef-out/all.xml">
      <!-- document root w/namespaces -->
      <doi_batch version="4.3.3" xmlns="http://www.crossref.org/schema/4.3.3"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.crossref.org/schema/4.3.3 http://www.crossref.org/schemas/crossref4.3.3.xsd">
        <head>
          <doi_batch_id>10.5072/FK2</doi_batch_id>
          <timestamp>
            <xsl:value-of select="format-date(current-date(), '[Y][M][D]')"/>
          </timestamp>
          <depositor>
            <name>Bridger Dyson-Smith</name>
            <email_address>bdysonsm@utk.edu</email_address>
          </depositor>
          <registrant>University of Tennessee</registrant>
          <body>
            <xsl:for-each select="collection('nfp-in/')">
              <xsl:if test="/oai_dc:dc/dc:identifier[contains(.,'DOI:')]">
                <book>
                  <booK_metadata>
                    <xsl:if test="./oai_dc:dc/dc:language = 'en'">
                      <xsl:value-of select="'en'"/>
                    </xsl:if>
                    <contributors>
                      <xsl:for-each select="oai_dc:dc/dc:creator">
                        <xsl:variable name="vSurname"
                          select="substring-before(.,',')"/>
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
                          <!-- human bean name -->
                          <!--<xsl:when test="ends-with(.,'.')">
                            <xsl:value-of select="concat(substring-before(substring-after(.,','),'.'[last()]), '2')"/>
                          </xsl:when>
                          <xsl:when test="ends-with(.,',')">
                            <xsl:value-of select="concat(substring-before(substring-after(.,','),','[last()]), '3')"/>
                          </xsl:when>-->
                          <!-- give up -->
                          <xsl:otherwise>
                            <person_name
                              sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
                              contributor_role="author">
                              <given_name>
                                <!--<xsl:value-of select="substring-before(substring-after(.,','),'.'[last()])"/>-->
                                <xsl:value-of select="if (ends-with(.,',')) then 
                                  normalize-space(substring-before(substring-after(.,','[position()=1]),','[last()])) 
                                  else if (ends-with(.,'.')) then 
                                  normalize-space(substring-before(substring-after(.,','[position()=1]),'.'[last()])) 
                                  else ''"/>
                              </given_name>
                              <surname>
                                <xsl:value-of select="normalize-space($vSurname)"/>||<xsl:value-of select="substring-before(.,','[position()=1])"/>
                              </surname>
                            </person_name>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </contributors>
                  </booK_metadata>
                </book>
              </xsl:if>
            </xsl:for-each>
          </body>
        </head>
      </doi_batch>
    </xsl:result-document>

    <!-- spit out individual records -->
    <xsl:for-each select="collection('nfp-in/')">
      <xsl:if test="/oai_dc:dc/dc:identifier[contains(.,'DOI:')]">
        <xsl:variable name="vName" select="tokenize(base-uri(),'/')[last()]"/>
        <xsl:result-document href="crossRef-out/{concat($vName,'.test.xml')}">
          <doi_batch version="4.3.3" xmlns="http://www.crossref.org/schema/4.3.3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.crossref.org/schema/4.3.3 http://www.crossref.org/schemas/crossref4.3.3.xsd">
            <head>
              <doi_batch_id>10.5072/FK2</doi_batch_id>
              <timestamp>
                <xsl:value-of select="format-date(current-date(), '[Y][M][D]')"/>
              </timestamp>
              <depositor>
                <name>Bridger Dyson-Smith</name>
                <email_address>bdysonsm@utk.edu</email_address>
              </depositor>
              <registrant>University of Tennessee</registrant>
              <body>
                <book>
                  <xsl:apply-templates select="oai_dc:dc/dc:title"/>
                  <xsl:apply-templates select="oai_dc:dc/dc:creator"/>
                  <xsl:apply-templates select="oai_dc:dc/dc:date"/>
                  <xsl:apply-templates select="oai_dc:dc/dc:identifier[matches(.,'^DOI:')]"/>
                  <xsl:apply-templates select="oai_dc:dc"/>
                </book>
              </body>
            </head>
          </doi_batch>
        </xsl:result-document>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- end main template -->
  

</xsl:stylesheet>
