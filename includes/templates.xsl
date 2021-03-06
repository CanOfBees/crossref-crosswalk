<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:doi_batch="http://www.crossref.org/schema/4.3.6"
                xmlns:cob="http://cob.net/cob"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schemas/crossref4.3.6.xsd"
                exclude-result-prefixes="#all" xpath-default-namespace="http://www.crossref.org/schema/4.3.6"
                xmlns="http://www.crossref.org/schema/4.3.6"
                version="2.0">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <!-- variables -->
  <xsl:variable name="timeStamp" select="format-date(current-date(),'[Y][M][D]')"/>

  <!-- creates head element for a doi_batch node -->
  <xsl:template name="doiBatchHead">
    <head>
      <doi_batch_id>
        <xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]-[H]-[m]-[s][f]')"/>
      </doi_batch_id>
      <timestamp>
        <xsl:value-of select="$timeStamp"/>
      </timestamp>
      <depositor>
        <depositor_name>Bridger Dyson-Smith</depositor_name>
        <email_address>bdysonsm@utk.edu</email_address>
      </depositor>
      <registrant>University of Tennessee</registrant>
    </head>
  </xsl:template>

  <!-- processes dc:creator to extract a contributor. maybe. -->
  <xsl:template name="getContributors">
    <contributors>
      <xsl:apply-templates select="oai_dc:dc/dc:creator[ends-with(.,'.') and not(contains(.,','))]" mode="orgMode"/>
      <xsl:apply-templates select="oai_dc:dc/dc:creator[contains(.,',')]" mode="personMode"/>
      <xsl:apply-templates select="oai_dc:dc/dc:contributor" mode="personMode"/>
   </contributors>
  </xsl:template>

  <!-- get titles, like the name says -->
  <xsl:template name="getTitles">
    <titles>
      <title>
        <xsl:value-of
            select="if (oai_dc:dc/dc:title[contains(.,'/')]) then
                    normalize-space(substring-before(oai_dc:dc/dc:title,'/'[last()]))
                    else oai_dc:dc/dc:title"/>
      </title>
    </titles>
  </xsl:template>

  <!-- surprisingly, this template gets the publication date -->
  <xsl:template name="getPublicationDate">
    <publication_date media_type="online">
      <year>
        <xsl:value-of
            select="if (oai_dc:dc/dc:date) then
                    (if (starts-with(oai_dc:dc/dc:date,'c') and ends-with(oai_dc:dc/dc:date,'.')) then
                      substring-before(substring-after(oai_dc:dc/dc:date,'c'),'.')
                      else oai_dc:dc/dc:date)
                    else '2015'"/>
      </year>
    </publication_date>
  </xsl:template>

  <!-- (start) grab(bing) the ISBN number -->
  <xsl:template name="getISBN">
    <xsl:apply-templates select="oai_dc:dc/dc:identifier[contains(.,'ISBN')]"/>
  </xsl:template>

  <!-- the following two templates handle the invalid ISBNs in Wonderous Bird's Nest II -->
  <xsl:template match="oai_dc:dc/dc:identifier[contains(.,'ISBN') and following-sibling::dc:identifier[matches(.,'DOI:10.7290/V7KW5CX1')]][1]">
    <noisbn reason="simple_series"/>
  </xsl:template>
  <xsl:template match="oai_dc:dc/dc:identifier[contains(.,'ISBN') and following-sibling::dc:identifier[matches(.,'DOI:10.7290/V7KW5CX1')]][2]"/>

  <!-- handles all of the other ISBNs. hopefully. -->
  <xsl:template match="oai_dc:dc/dc:identifier[contains(.,'ISBN') and not(following-sibling::dc:identifier[matches(.,'DOI:10.7290/V7KW5CX1')])]">
    <isbn media_type="electronic">
      <xsl:analyze-string select="." regex="(^.*:)\s{{0,1}}([0-9X]+)(.*$)">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(2)"/>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </isbn>
  </xsl:template>

  <!-- get or create publisher info -->
  <!-- i'd like to refactor this, make it a bit less choose/when/otherwise -->
  <xsl:template name="getPublisher" xpath-default-namespace="http://www.crossref.org/schema/4.3.6">
    <xsl:choose>
      <xsl:when test="oai_dc:dc/dc:publisher">
        <publisher>
          <publisher_name>
            <xsl:value-of select="normalize-space(substring-after(oai_dc:dc/dc:publisher,':'))"/>
          </publisher_name>
          <publisher_place>
            <xsl:value-of select="normalize-space(substring-before(oai_dc:dc/dc:publisher,':'))"/>
          </publisher_place>
        </publisher>
      </xsl:when>
      <xsl:otherwise>
        <publisher>
          <publisher_name>
            <xsl:text>Newfound Press, University of Tennessee Libraries</xsl:text>
          </publisher_name>
          <publisher_place>
            <xsl:text>Knoxville, Tenn.</xsl:text>
          </publisher_place>
        </publisher>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- builds the doi_data node -->
  <xsl:template name="getDOIData">
    <doi_data>
      <doi>
        <xsl:value-of select="substring-after(oai_dc:dc/dc:identifier[starts-with(.,'DOI:')],':')"/>
      </doi>
      <timestamp><xsl:value-of select="$timeStamp"/></timestamp>
      <resource>
        <xsl:value-of
            select="if (oai_dc:dc/dc:identifier[contains(.,'/pubs/') and not(ends-with(.,'.html'))]) then
                    oai_dc:dc/dc:identifier[contains(.,'/pubs/') and not(ends-with(.,'.html'))]
                    else oai_dc:dc/dc:identifier[contains(.,'/pubs/')]"/>
      </resource>
    </doi_data>
  </xsl:template>

  <!-- modalities -->
  <!-- process dc:creator for a potential organization name -->
  <xsl:template match="oai_dc:dc/dc:creator" mode="orgMode">
    <organization
        sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
        contributor_role="author">
      <xsl:value-of select="if (ends-with(.,'.')) then
                            normalize-space(substring-before(.,'.'[last()])) else
                            normalize-space(.)"/>
    </organization>
  </xsl:template>

  <!-- process dc:creator for a person's name -->
  <xsl:template match="oai_dc:dc/dc:creator" mode="personMode">
    <xsl:choose>
      <xsl:when test="contains(.,';')">
        <xsl:for-each select="tokenize(.,';')">
          <xsl:call-template name="getPerson"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="getPerson"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--  process dc:contributor and make a lot of potentially bad decisions with it -->
  <xsl:template match="oai_dc:dc/dc:contributor" mode="personMode">
    <person_name sequence="additional" contributor_role="{if (contains(.,'Edit')) then 'editor' else 'author'}">
      <given_name><xsl:sequence select="normalize-space(cob:nameProc(.))"/></given_name>
      <surname>
        <xsl:sequence select="if (contains(.,':')) then
                              normalize-space(substring-after(substring-before(.,','[position()=1]),':'))
                              else normalize-space(substring-before(.,','[position()=1]))"/>
      </surname>
    </person_name>
  </xsl:template>

  <!-- process names -->
  <!-- generates the main part of the <contributor> element for CrossRef -->
  <xsl:template name="getPerson">
    <person_name sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
            contributor_role="author">
      <given_name><xsl:sequence select="normalize-space(cob:nameProc(.))"/></given_name>
      <surname><xsl:sequence select="normalize-space(substring-before(.,','[position()=1]))"/></surname>
    </person_name>
  </xsl:template>

  <!-- functions -->
  <!-- processes the pieces of dc:(creator|contributor) and hopefully returns good info -->
  <xsl:function name="cob:nameProc">
    <xsl:param name="pInput"/>
    <xsl:sequence select="if (ends-with($pInput,',')) then
            normalize-space(substring-before(substring-after($pInput,','[position() = 1]),','[last()]))
            else if (ends-with($pInput,'.')) then
            normalize-space(substring-before(substring-after($pInput,','[position() = 1]),'.'[last()]))
            else if (ends-with($pInput,'1676 ')) then
            normalize-space(substring-before(substring-after($pInput,','[position()=1]),','[last()]))
            else if (ends-with($pInput,'-')) then
            normalize-space(substring-before(substring-after($pInput,','[position() = 1]),','[last()]))
            else if (not(ends-with($pInput,',')) and not(ends-with($pInput,'.'))) then
            normalize-space(substring-after($pInput,','[position()=1]))
            else normalize-space($pInput)"/>
  </xsl:function>
</xsl:stylesheet>