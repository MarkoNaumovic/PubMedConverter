<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">

	<xsl:template match="caption[@ofType='abstract']" mode="abstract">
		<xsl:element name="Abstract">
			<xsl:apply-templates select="valueList/value/fullText"/>
		</xsl:element>
	</xsl:template>

	<!-- Abstract with AbstractText --> 
	<xsl:template match="caption[@ofType='abstract']" mode="abstractText">
		<xsl:if test="descendant::header[not(text())] or descendant::header[text()]">
			<xsl:element name="Abstract">
				<xsl:apply-templates select="valueList/value/fullText/content"/>
				<xsl:if test="not(descendant::content)">
				<xsl:apply-templates select="valueList/value/fullText" mode="withoutContent"/>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="captionList[descendant::listItem[ancestor::caption[@ofType='abstract'] and descendant::paragraph[text()]]]">
		<xsl:element name="Abstract">
			<xsl:apply-templates select="caption[@ofType='abstract']/valueList/value/fullText/paragraph/list/listItem"/>
		</xsl:element>
	</xsl:template> 

	<!-- Caption -->
	<xsl:template match="fullText[ancestor::caption[@ofType='abstract']]">
		<xsl:value-of select="content/fullText/paragraph"/>
		<xsl:value-of select="paragraph"/>
	</xsl:template> 

	<!-- AbstractText -->
	<!-- Abstract text from section -->
	<xsl:template match="content[@ofType='section'][ancestor::caption[@ofType='abstract']]">
	 <xsl:variable name="AllowedSymbols" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/, '"/>
		<xsl:element name="AbstractText">
			<xsl:attribute name="Label" select="translate(fullText/upper-case(header), translate(fullText/upper-case(header), $AllowedSymbols, ''),'')"/>
			<xsl:apply-templates select="fullText/paragraph"/>
		</xsl:element>
	</xsl:template> 
	
	<!-- AbstractText without content and with header -->
	<xsl:template match="fullText" mode="withoutContent">
	<xsl:variable name="AllowedSymbols" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/, '"/>
		<xsl:element name="AbstractText">
			<xsl:attribute name="Label" select="translate(upper-case(header), translate(upper-case(header), $AllowedSymbols, ''),'')"/>
			<xsl:apply-templates select="paragraph"/>
		</xsl:element>
	</xsl:template>
	
	<!-- AbstractText -->
	<!-- Abstract text from list -->
	<xsl:template match="listItem[ancestor::caption[@ofType='abstract']]">
		<xsl:element name="AbstractText">
			<xsl:attribute name="Label" select="upper-case(header)"/>
			<xsl:apply-templates select="paragraph"/>
		</xsl:element>
	</xsl:template>

	<!-- OtherAbstract non-English with AbstractText -->
	<xsl:template match="caption[@ofType='abstract']" mode="otherAbstractText">
		<xsl:element name="OtherAbstract">
			<xsl:variable name="language" select="@languageRefId"/>
			<xsl:attribute name="Language" select="../../../../resourceList/resource[@ofType='languages']/languageList/language[@id=$language]/definition/code"/>
			<xsl:apply-templates select="valueList/value/fullText/content"/>
		</xsl:element>
	</xsl:template> 

	<!-- OtherAbstract plain Language -->
	<xsl:template match="caption[@ofType='abstract']" mode="plainLanguage">
		<xsl:element name="OtherAbstract">
			<xsl:attribute name="Language" select="'eng'"/>
			<xsl:attribute name="Type" select="'plain-language-summary'"/>
			<xsl:apply-templates select="valueList/value/fullText"/>
		</xsl:element>
	</xsl:template>

	<!-- OtherAbstract non-English -->
	<xsl:template match="caption[@ofType='abstract']" mode="otherAbstract">
		<xsl:variable name="language" select="@languageRefId"/>
		<xsl:element name="OtherAbstract">
			<xsl:attribute name="Language" select="../../../../resourceList/resource[@ofType='languages']/languageList/language[@id=$language]/definition/code"/>
			<xsl:apply-templates select="valueList/value/fullText"/>
		</xsl:element>
	</xsl:template>

	<!-- Paragraph with text() -->
	<xsl:template match="paragraph[text() and not(ancestor::affiliatedOrganization)]">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<!-- OtherAbstract or Abstract without AbstractText -->
	<xsl:template match="captionList[child::caption[@ofType='abstract' and (descendant::header[not(text())] or not(descendant::header)) and descendant::value[not(@type)]]]">
		<xsl:choose>
			<xsl:when test="caption[@languageRefId and not(contains(@languageRefId,'ENGLISH'))]">	
				<xsl:apply-templates select="caption[@ofType='abstract']" mode="otherAbstract"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="caption[@ofType='abstract']" mode="abstract"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- OtherAbstract or Abstract with AbstractText -->
	<xsl:template match="captionList[child::caption[@ofType='abstract' and not(descendant::listItem) and  (descendant::header[text()] and descendant::header)]]">
		<xsl:if test="caption[@ofType='abstract'][1] and caption[not(@languageRefId) or contains(@languageRefId,'ENGLISH')]">
			<xsl:apply-templates select="caption[@ofType='abstract'][1]" mode="abstractText"/>
		</xsl:if>
		<xsl:if test="caption[@ofType='abstract'][2]">
			<xsl:apply-templates select="caption[@ofType='abstract'][2]" mode="plainLanguage"/>
		</xsl:if>
		<xsl:if test="caption[@languageRefId and not(contains(@languageRefId,'ENGLISH'))]">
			<xsl:apply-templates select="caption[@ofType='abstract']" mode="otherAbstractText"/>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>
