<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">

	
	<!-- History -->
	<xsl:template match="sourceTimestampList">
		<xsl:element name="History">
			<xsl:apply-templates select="sourceTimestamp" />
		</xsl:element>
	</xsl:template>

	<!-- History/PubDate[@PubStatus] -->
	<xsl:template match="sourceTimestamp[@ofType='received'] | sourceTimestamp[@ofType='accepted'] | sourceTimestamp[@ofType='revised']">
		<xsl:element name="PubDate">
			<xsl:attribute name="PubStatus">
				<xsl:value-of select="@ofType" />
			</xsl:attribute>

			<xsl:choose>
				<xsl:when test="date/year">
					<xsl:apply-templates select="date/year" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="date/sortedValue" mode="year" />
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="date/month">
					<xsl:apply-templates select="date/month" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="date/sortedValue" mode="month" />
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="date/day">
					<xsl:apply-templates select="date/day" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="date/sortedValue" mode="day" />
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:element>		
	</xsl:template>

	<!-- Object[@Type='grant'] -->
	<xsl:template match="fundingSet[ancestor::semanticMetadata[@ofType='funding']][descendant::text()]">
		<xsl:choose>
			<xsl:when test="count(fundingList/funding/externalIdentifierList/externalIdentifier[@ofType='award-id']) > 1">
				<xsl:for-each select="fundingList/funding/externalIdentifierList/externalIdentifier[@ofType='award-id']">
					<xsl:element name="Object">
						<xsl:attribute name="Type" select="'grant'" />
						<xsl:apply-templates select="." />
						<xsl:apply-templates select="../../sponsor[@ofType='organization']/organization/nameList/name/valueList/value" />
					</xsl:element>	
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="Object">
					<xsl:attribute name="Type" select="'grant'" />
					<xsl:apply-templates select="fundingList/funding/externalIdentifierList/externalIdentifier[@ofType='award-id']" />
					<xsl:apply-templates select="fundingList/funding/sponsor[@ofType='organization']/organization/nameList/name/valueList/value" />
				</xsl:element>			
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Param[@Name='id'] -->
	<xsl:template match="externalIdentifier[@ofType='award-id']">
		<xsl:element name="Param">
			<xsl:attribute name="Name" select="'id'" />
			<xsl:value-of select="valueList/value" />
		</xsl:element>
	</xsl:template>

	<!-- Param[@Name='grantor'] -->
	<xsl:template match="value[ancestor::semanticMetadata[@ofType='funding']]">
		<xsl:element name="Param">
			<xsl:attribute name="Name" select="'grantor'" />
			<xsl:choose>
				<xsl:when test="not(descendant-or-self::node()/child::tag)">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="tag[@propertySetRefId = //propertySet[propertyList/property/valueList/value/plainText = 'funder-name']/@id]/nameList/name/valueList/value/fullText"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- Object[@Type='companion] -->
	<xsl:template match="externalRelatedContent[descendant::externalLink[@format='doi']]">
		<xsl:element name="Object">
			<xsl:attribute name="Type" select="'companion'"/>
			<xsl:apply-templates select="externalLink[@ofType='related-article' and @format='doi']" mode="ParamTypeDoi"/>
			<xsl:apply-templates select="externalLink[@ofType='related-article' and @format='doi' and @xlink:href]" mode="ParamIdDoi"/>
		</xsl:element>
	</xsl:template>

	<!-- Param[@Name='type'] -->
	<xsl:template match="externalLink[@ofType='related-article' and @format='doi']" mode="ParamTypeDoi">
		<xsl:element name="Param">
			<xsl:attribute name="Name" select="'Type'"/>
			<xsl:value-of select="@format"/>
		</xsl:element>
	</xsl:template>


	<!-- Param[@Name='id'] -->
	<xsl:template match="externalLink[@ofType='related-article' and @format='doi' and @xlink:href]" mode="ParamIdDoi">
		<xsl:element name="Param">
			<xsl:attribute name="Name" select="'id'"/>
			<xsl:value-of select="@xlink:href"/>
		</xsl:element>
	</xsl:template>

	<!-- Object[@Type='correction'] -->
	<xsl:template match="externalRelatedContent[descendant::externalLink[@format='identifier']]">
		<xsl:element name="Object">
			<xsl:attribute name="Type" select="'correction'"/>
			<xsl:apply-templates select="externalLink[@ofType='related-article' and @format='identifier']" mode="ParamTypeIdentifier"/>
			<xsl:apply-templates select="externalLink[@ofType='related-article' and @format='identifier' and @xlink:href]" mode="ParamIdIdentifier"/>
		</xsl:element>
	</xsl:template>

	<!-- Param[@Name='type'] identifier-->
	<xsl:template match="externalLink[@ofType='related-article' and @format='identifier']" mode="ParamTypeIdentifier">
		<xsl:element name="Param">
			<xsl:attribute name="Name" select="'Type'"/>
			<xsl:value-of select="@format"/>
		</xsl:element>
	</xsl:template>


	<!-- Param[@Name='id'] identifier -->
	<xsl:template match="externalLink[@ofType='related-article' and @format='identifier' and @xlink:href]" mode="ParamIdIdentifier">
		<xsl:element name="Param">
			<xsl:attribute name="Name" select="'id'"/>
			<xsl:value-of select="@xlink:href"/>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
