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

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <!-- creates head element for a doi_batch node -->
  <xsl:template name="doiBatchHead">
    <head>
      <doi_batch_id>
        <xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]-[H]-[m]-[s][f]')"/>
      </doi_batch_id>
      <timestamp>
        <xsl:value-of select="format-date(current-date(),'[Y][M][D]')"/>
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
      <xsl:apply-templates select="oai_dc:dc/dc:creator[not(ends-with(.,'.'))]" mode="personMode"/>
      <xsl:apply-templates select="oai_dc:dc/dc:creator[ends-with(.,'.') and contains(.,',')]"
                           mode="personMode"/>
    </contributors>
  </xsl:template>

  <!-- get titles, like the name says -->
  <xsl:template name="getTitles" xpath-default-namespace="http://www.crossref.org/schema/4.3.6">
    <titles>
      <title>
        <xsl:value-of select="normalize-space(substring-before(oai_dc:dc/dc:title,'/'[last()]))"/>
      </title>
    </titles>
  </xsl:template>

  <!-- surprisingly, this template gets the publication date -->
  <xsl:template name="getPublicationDate" xpath-default-namespace="http://www.crossref.org/schema/4.3.6">
    <publication_date media_type="online">
      <year>
        <xsl:value-of
            select="if (oai_dc:dc/dc:date) then
                    (if (starts-with(oai_dc:dc/dc:date,'c')) then
                      substring-before(substring-after(oai_dc:dc/dc:date,'c'),'.')
                      else substring-before(oai_dc:dc/dc:date,'.'))
                      else '2015'"/>
      </year>
    </publication_date>
  </xsl:template>

  <!-- (start) grab(bing) the ISBN number -->
  <xsl:template name="getISBN">
    <xsl:apply-templates select="oai_dc:dc/dc:identifier[starts-with(.,'URN:ISBN')]"/>
  </xsl:template>

  <!-- finish processing the ISBN number -->
  <xsl:template match="oai_dc:dc/dc:identifier[starts-with(.,'URN:ISBN')]" xpath-default-namespace="http://www.crossref.org/schema/4.3.6">
    <isbn media_type="electronic">
      <xsl:analyze-string select="." regex="[0-9]+">
        <xsl:matching-substring>
          <xsl:value-of select="."/>
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

  <!-- modalities -->
  <xsl:template match="oai_dc:dc/dc:creator" mode="orgMode">
    <organization
        sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
        contributor_role="author">
      <xsl:value-of select="substring-before(.,'.'[last()])"/>
    </organization>
  </xsl:template>

  <xsl:template match="oai_dc:dc/dc:creator" mode="personMode">
    <person_name
      sequence="{if (position() &gt; 1) then 'additional' else 'first'}"
      contributor_role="author">
      <given_name>
        <xsl:value-of
            select="if (ends-with(.,',')) then
                  normalize-space(substring-before(substring-after(.,','[position()=1]),','[last()]))
                  else if (ends-with(.,'.')) then
                  normalize-space(substring-before(substring-after(.,','[position()=1]),'.'[last()]))
                  else ''"/>
      </given_name>
      <surname>
        <xsl:value-of select="substring-before(.,','[position()=1])"/>
      </surname>

    </person_name>
  </xsl:template>





</xsl:stylesheet>