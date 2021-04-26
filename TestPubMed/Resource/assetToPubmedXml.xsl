<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">

  <xsl:output method="xml" omit-xml-declaration="no"
		indent="yes" doctype-public="-//NLM//DTD PubMed 2.8//EN"
		doctype-system="https://dtd.nlm.nih.gov/ncbi/pubmed/in/PubMed.dtd"
		encoding="UTF-8" />

  <xsl:variable name="inputFolderAndFile">
    <xsl:call-template name="getValuesBeforeAndAfterLastOccurance">
      <xsl:with-param name="inputString" select="string(base-uri(.))" />
      <xsl:with-param name="char" select="'/'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="inputFolderPath" select="substring-before($inputFolderAndFile, '*')" />

  <xsl:include href="utilities.xsl" />
  <xsl:include href="contributors.xsl" />
  <xsl:include href="journal.xsl" />
  <xsl:include href="article.xsl" />
  <xsl:include href="citations.xsl" />
  <xsl:include href="objects.xsl" />
  <xsl:include href="abstract.xsl" />

  <xsl:strip-space elements="*" />

  <!-- Indentity template: process children -->
  <xsl:template match="@* | * | comment() | processing-instruction()">
    <xsl:apply-templates select="@*|node()" />
  </xsl:template>

  <xsl:template match="@* | * | comment() | processing-instruction()" mode="multiple collectiveName">
    <xsl:apply-templates select="@*|node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="text() | tag[ancestor::contributorGroup or ancestor::contributor] | xref[ancestor::contributorGroup or ancestor::contributor] | xref[ancestor::contributorGroup or ancestor::contributor] | emphasis[@style='superscript' and (ancestor::contributorGroup or ancestor::contributor)] | emphasis[@style='subscript' and (ancestor::contributorGroup or ancestor::contributor)]" mode="multiple collectiveName singleAffil"/>

  <!-- Drop template -->
  <xsl:template match="text() | title[not(@ofType='title' or @ofType='sub-title')] | plainText[ancestor::sourceTimestampList and not(ancestor::day or ancestor::month or ancestor::year)] | sourceTimestamp[not(@ofType='received' or @ofType='accepted' or @ofType='revised')] | affiliatedOrganization/addressList | affiliatedOrganization/contactInfoList | emphasis[@style='superscript' and ancestor::affiliatedOrganizationList] | emphasis[@style='subscript' and ancestor::affiliatedOrganizationList] | tag[ancestor::contributorGroup or ancestor::contributor] | xref[ancestor::contributorGroup or ancestor::contributor] | emphasis[@style='superscript' and (ancestor::contributorGroup or ancestor::contributor)] | emphasis[@style='subscript' and (ancestor::contributorGroup or ancestor::contributor)] | metadata[@ofType='issue']/taxonomyIdentifierList/taxonomyIdentifier[@ofType='volume'][lower-case(.) = 'publish ahead of print'] | property[key='Replace']"/>

  <!-- Text to be copied -->
  <xsl:template match="text()[parent::plainText or parent::paragraph or parent::emphasis or parent::externalLink or parent::xref[parent::fullText]] 
		| text()[not(ancestor::contributorGroup) and parent::fullText]
		| text()[ancestor::contributorGroup and parent::fullText][not(position()=last()) and not(position()=1)] 
		| text()[ancestor::contributorGroup and parent::fullText][(position()=last()) and (following-sibling::emphasis or following-sibling::externalLink or following-sibling::xref)] 
		| text()[ancestor::contributorGroup and parent::fullText][(position()=1) and (preceding-sibling::emphasis or preceding-sibling::externalLink or preceding-sibling::xref)]">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()[ancestor::contributorGroup and parent::fullText][position()=1 and not(preceding-sibling::emphasis or preceding-sibling::externalLink or preceding-sibling::xref)]">
    <xsl:value-of select="replace(.,'^ +','')"/>
  </xsl:template>

  <xsl:template match="text()[ancestor::contributorGroup and parent::fullText][position()=last() and not(following-sibling::emphasis or following-sibling::externalLink or following-sibling::xref)]">
    <xsl:value-of select="replace(., '\s+$', '', 'm')"/>
  </xsl:template>

  <!-- Top-level template -->
  <xsl:template match="/">
    <xsl:element name="ArticleSet">

      <xsl:for-each select="collection(concat($inputFolderPath, '?select=*.xml;recurse=yes'))/asset[@ofType='article' and not(metadataList/metadata[@ofType='article']/externalIdentifierList/externalIdentifier[@ofType='other']/valueList/value/plainText[text() = 'PAP-SAME']) and 
			not(metadataList/metadata[@ofType='article']/externalContentTypeList/externalContentType[@ofType='article-type']/valueList/value/plainText[text() = 'Abstract']) and 
			not(metadataList/metadata[@ofType='article']/externalContentTypeList/externalContentType[@ofType='article-type']/valueList/value/plainText[text() = 'Advertisement']) and 
			not(metadataList/metadata[@ofType='article']/externalContentTypeList/externalContentType[@ofType='article-type']/valueList/value/plainText[text() = 'Announcement']) and 
			not(metadataList/metadata[@ofType='article']/externalContentTypeList/externalContentType[@ofType='article-type']/valueList/value/plainText[text() = 'Book-or-Media-Review']) and 
			not(@status='deleted')
			]">

        <xsl:sort select="assetInformation/assetId" />

        <!-- Non-byline property -->
        <xsl:variable name="nonbylinePropertyId" select="//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id" />

        <xsl:variable name="clinicalTrials" select="//text()[contains(., 'NCT')][ancestor::content[@ofType='body-matter'] and ancestor::content[@ofType='section']][following-sibling::externalLink[contains(lower-case(@xlink:href),'clinicaltrials.gov')] or preceding-sibling::externalLink[contains(lower-case(@xlink:href),'clinicaltrials.gov')] or parent::externalLink[contains(lower-case(@xlink:href),'clinicaltrials.gov')]]"/>

        <xsl:element name="Article">
          <xsl:apply-templates select="metadataList/metadata[@ofType='journal']" />
          <xsl:apply-templates select="resourceList/resource[@ofType='properties']/propertySetList/propertySet[@id=//externalIdentifier[@ofType='accession-number']/@propertySetRefId]/propertyList" />
          <xsl:choose>
            <xsl:when test="metadataList/metadata[@ofType='article']/titleList/title[@ofType='sub-title']">
              <xsl:apply-templates select="metadataList/metadata[@ofType='article']/titleList/title[@ofType='sub-title']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="metadataList/metadata[@ofType='article']/titleList/title[@ofType='title']" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/pagination" />
          <xsl:apply-templates select="resourceList/resource[@ofType='languages']/languageList"/>
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/contributorList[descendant::contributor[@ofType='author']]" />
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/contributorGroupList[//contributor[@ofType='author-non-byline']]" />
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/externalIdentifierList"/>
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/sourceTimestampList" />
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/captionList[child::caption[@ofType='abstract'] or child::caption[@ofType='other' and @otherName='main']]"/>
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/copyright/statement"/>
          <xsl:apply-templates select="metadataList/metadata[@ofType='article']/captionList[descendant-or-self::paragraph[contains(lower-case(normalize-space(string(.))),'conflicts of interest') or contains(lower-case(normalize-space(string(.))),'conflict of interest')]]" mode="coi"/>
          <xsl:if test="metadataList/metadata[@ofType='article']/semanticMetadataList[semanticMetadata[@ofType='funding']]
								or metadataList/metadata[@ofType='article']/externalRelatedContentList/externalRelatedContent[descendant::externalLink[@format='doi'] or descendant::externalLink[@format='identifier']]
								or $clinicalTrials">
            <xsl:element name="ObjectList">
              <xsl:apply-templates select="metadataList/metadata[@ofType='article']/semanticMetadataList/semanticMetadata[@ofType='funding']/fundingSetList/fundingSet[descendant::text()]" />
              <xsl:apply-templates select="metadataList/metadata[@ofType='article']/externalRelatedContentList/externalRelatedContent[descendant::externalLink[@format='doi']]"/>
              <xsl:apply-templates select="metadataList/metadata[@ofType='article']/externalRelatedContentList/externalRelatedContent[descendant::externalLink[@format='identifier']]"/>
              <xsl:if test="$clinicalTrials">
                <xsl:for-each select="$clinicalTrials">
                  <xsl:element name="Object">
                    <xsl:attribute name="Type" select="'ClinicalTrials.gov'"/>
                    <xsl:element name="Param">
                      <xsl:attribute name="Name" select="'id'"/>
                      <xsl:value-of select="concat('NCT', substring(substring-after(.,'NCT'),1,8))"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:if>
            </xsl:element>
          </xsl:if>
          <xsl:if test="//content[@ofType='end-matter']/fullText/list[@ofType='references']/listItem" >
            <xsl:apply-templates select="//content[@ofType='end-matter']/fullText/list[@ofType='references']"/>
          </xsl:if>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>


</xsl:stylesheet>
