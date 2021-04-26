<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">


	<!-- ArticleTitle -->

	<xsl:template match="title[@ofType='title' and ancestor::metadata[@ofType='article'] and (contains(@languageRefId, 'ENGLISH') or not(@languageRefId))]">
		<!-- make sure there is articleTitle value -->
		<xsl:element name="ArticleTitle">
			<!-- choose 'source' ArticleTitle value if many are available -->
			<xsl:choose>
				<xsl:when test="descendant::value[@valueType='source']">
					<xsl:apply-templates select="descendant-or-self::node()/child::value[@valueType='source']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="descendant-or-self::node()/child::value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="title[@ofType='title' and ancestor::metadata[@ofType='article'] and (contains(@languageRefId, 'ENGLISH') or not(@languageRefId))]" mode="sub-title">
			<xsl:choose>
				<xsl:when test="descendant::value[@valueType='source']">
					<xsl:apply-templates select="descendant-or-self::node()/child::value[@valueType='source']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="descendant-or-self::node()/child::value"/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<!-- VernacularTitle -->
	<!-- non english title -->
	<xsl:template match="title[@ofType='title' and @languageRefId and ancestor::metadata[@ofType='article'] and not(contains(@languageRefId, 'ENGLISH'))]">
		<xsl:element name="VernacularTitle">
			<xsl:choose>
				<xsl:when test="descendant::value[@valueType='source']">
					<xsl:apply-templates select="descendant-or-self::node()/child::value[@valueType='source']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="descendant-or-self::node()/child::value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="title[@ofType='sub-title']">
		<xsl:element name="ArticleTitle">
			<xsl:choose>
				<xsl:when test="descendant::value[@valueType='source']">
					<xsl:apply-templates select="../title[@ofType='title']" mode="sub-title"/>
					<xsl:value-of select="': '"/>					
					<xsl:apply-templates select="descendant-or-self::node()/child::value[@valueType='source']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../title[@ofType='title']" mode="sub-title"/>
					<xsl:value-of select="': '"/>					
					<xsl:apply-templates select="descendant-or-self::node()/child::value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="value[ancestor::title[@ofType='sub-title']][@valueType='source'][preceding-sibling::value[@valueType='source']]">
		<xsl:value-of select="': '" />
		<xsl:apply-templates />
	</xsl:template>

	<!-- Pagination -->
	<xsl:template match="pagination">
		<xsl:apply-templates select="pageRangeList/pageRange/firstPage" />
		<xsl:apply-templates select="pageRangeList/pageRange/lastPage" />
		<xsl:apply-templates select="pageRangeList/pageRange/firstPage[not(../lastPage)]" mode="lastPage"/>
		<xsl:apply-templates select="elocation-id"/>
	</xsl:template>

	<!-- PublisherName -->
	<xsl:template match="publisherList">
		<xsl:element name="PublisherName">
			<xsl:value-of select="publisher/nameList/name"/>
		</xsl:element>
	</xsl:template>
	
	<!-- PublisherName from statement -->
	<xsl:template match="statement[(descendant::value[@valueType='normalized'] or descendant::value[@valueType='source']) and parent::copyright]" mode="publisherName">

		<xsl:variable name="normalized" select="valueList/value[@valueType='normalized']/plainText"/>
		<xsl:variable name="trialNormalized" select="replace(string(valueList/value[@valueType='normalized']/plainText/current()), '.*\d{4}\s?','')"/> 
		<xsl:variable name="trialSource" select="replace(string(valueList/value[@valueType='source']/plainText/current()), '.*\d{4}\s?','')"/> 

		<xsl:element name="PublisherName">
			<xsl:choose>
				<xsl:when test="$normalized">	
					<xsl:value-of select="$trialNormalized"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$trialSource"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- FirstPage -->
<xsl:template match="firstPage">
	<xsl:element name="FirstPage">
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- LastPage -->
<xsl:template match="lastPage">
	<xsl:element name="LastPage">
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- LastPage alternative if only one page -->
<xsl:template match="firstPage" mode="lastPage">
	<xsl:element name="LastPage">
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- ElocationID -->
<!-- “xx.xxxx/yyy” value format for attribute name 'doi' else it is equal to 'pii' -->
<xsl:template match="elocation-id">
	<xsl:element name="ELocationID">
		<xsl:attribute name="EIdType">
			<xsl:choose>
				<xsl:when test="matches(.,'\d{2}\.\d{4}.*')">doi</xsl:when>
				<xsl:otherwise>pii</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="not(descendant::plainText)">
			<xsl:value-of select="."/>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Language -->
<xsl:template match="language">
	<xsl:element name="Language">
		<xsl:choose>
			<xsl:when test="definition/code">
				<xsl:value-of select="upper-case(definition/code)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="upper-case(definition/@normalizedCode)"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:element>
</xsl:template>

<!-- ArticleIdList -->
<xsl:template match="externalIdentifierList">
	<xsl:if test="child::externalIdentifier[@ofType='doi'], child::externalIdentifier[@ofType='accession-number']">
		<xsl:element name="ArticleIdList">
			<xsl:apply-templates select="externalIdentifier"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ArticleId -->
<!-- Default attribute name 'pii' and value, put both if exist -->
<xsl:template match="externalIdentifier">
	<xsl:variable name="IdType" select="@ofType"/>
	<xsl:if test="$IdType='accession-number'">
		<xsl:element name="ArticleId">
			<xsl:attribute name="IdType">pii</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:if>
	<xsl:if test="$IdType='doi'">
		<xsl:element name="ArticleId">
			<xsl:attribute name="IdType" select="$IdType"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- CopyrightInformation -->
<!-- choose normalized value if available -->
<xsl:template match="statement[(descendant::value[@valueType='normalized'] or descendant::value[@valueType='source']) and parent::copyright]">
	<xsl:element name="CopyrightInformation">
		<xsl:choose>
			<xsl:when test="valueList/value[@valueType='normalized']">
				<xsl:value-of select="normalize-space(valueList/value[@valueType='normalized']/plainText)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(valueList/value[@valueType='source']/plainText)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>		
</xsl:template>

<!-- CoiStatement -->
<xsl:template match="captionList[descendant-or-self::paragraph[contains(lower-case(normalize-space(string(.))),'conflicts of interest') or contains(lower-case(normalize-space(string(.))),'conflict of interest')]]" mode="coi">
	<xsl:element name="CoiStatement">
		<xsl:value-of separator=" " select="descendant-or-self::paragraph[contains(lower-case(normalize-space(string(.))),'conflicts of interest') or contains(lower-case(normalize-space(string(.))),'conflict of interest')]/normalize-space()"/>
	</xsl:element>
</xsl:template>

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


<!-- Replaces -->
<xsl:template match="propertyList[property[key='Replace']][ancestor::resource[@ofType='properties']]">
	<xsl:element name="Replaces">
		<xsl:choose>
			<xsl:when test="/asset[@ofType='article']/metadataList/metadata[@ofType='article']/externalIdentifierList/externalIdentifier[@ofType='doi']">
				<xsl:attribute name="IdType" select="'doi'" />
				<xsl:value-of select="/asset[@ofType='article']/metadataList/metadata[@ofType='article']/externalIdentifierList/externalIdentifier[@ofType='doi']/valueList/value/plainText"/>				
			</xsl:when>	
			<xsl:otherwise>
				<xsl:attribute name="IdType" select="'pubmed'" />
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>		
</xsl:template>

</xsl:stylesheet>
