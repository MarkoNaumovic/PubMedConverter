<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">


	<!-- Journal -->
	<xsl:template match="metadata[@ofType='journal']">
		<xsl:element name="Journal">
			<!-- PublisherName -->
			<xsl:choose>
				<xsl:when test="publisherList">
					<xsl:apply-templates select="publisherList" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../metadata[@ofType='article']/copyright/statement" mode="publisherName" />
				</xsl:otherwise>
			</xsl:choose> 
			
			<!-- JournalTitle -->
			<xsl:apply-templates select="titleList"/>
			<!-- Issn -->
			<xsl:choose>
				<xsl:when test="externalIdentifierList/externalIdentifier[@ofType='p-issn']">
					<xsl:apply-templates select="externalIdentifierList/externalIdentifier[@ofType='p-issn']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="externalIdentifierList/externalIdentifier[@ofType='e-issn']"/>
				</xsl:otherwise>
			</xsl:choose>
			<!-- Volume -->
				<xsl:apply-templates select="../metadata[@ofType='issue']/taxonomyIdentifierList/taxonomyIdentifier[@ofType='volume']" />
			<!-- Issue -->
			<xsl:choose>
				<xsl:when test="../metadata[@ofType='issue']/taxonomyIdentifierList/taxonomyIdentifier[@ofType='issue-number']">
					<xsl:apply-templates select="../metadata[@ofType='issue']/taxonomyIdentifierList/taxonomyIdentifier[@ofType='issue-number']" />
				</xsl:when>
				<xsl:when test="../metadata[@ofType='issue']/taxonomyIdentifierList/taxonomyIdentifier[@ofType='supplement-number']">
					<xsl:apply-templates select="../metadata[@ofType='issue']/taxonomyIdentifierList/taxonomyIdentifier[@ofType='supplement-number']" />
				</xsl:when>
			</xsl:choose>
			
			<!-- PubDate[@PubStatus] -->
			<xsl:choose>
				<xsl:when test="../metadata[@ofType='article']/publicationHistoryList/publicationHistory[medium = 'print']">
					<xsl:apply-templates select="../metadata[@ofType='article']/publicationHistoryList/publicationHistory[medium = 'print']" />
				</xsl:when>
				<xsl:when test="../metadata[@ofType='article']/publicationHistoryList/publicationHistory[medium = 'electronic']">
					<xsl:apply-templates select="../metadata[@ofType='article']/publicationHistoryList/publicationHistory[medium = 'electronic']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../metadata[@ofType='article']/publicationHistoryList/publicationHistory" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>


	<!-- JournalTitle -->
	<xsl:template match="titleList[parent::metadata[@ofType='journal']]">
		<xsl:element name="JournalTitle">
			<xsl:value-of select="title/valueList/value[@valueType='normalized']/plainText"/>
			<xsl:if test="not(title/valueList/value[@valueType='normalized'])">
				<xsl:value-of select="title/valueList/value[@valueType='source']/plainText"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- Issn -->
	<xsl:template match="externalIdentifier[@ofType='p-issn'] | externalIdentifier[@ofType='e-issn']">
		<xsl:element name="Issn">
			<xsl:value-of select="translate(., translate(., '0123456789-xX', ''), '')"/>
		</xsl:element>
	</xsl:template>

	<!-- Volume -->
	<xsl:template match="taxonomyIdentifier[@ofType='volume']">
		<xsl:element name="Volume">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<!-- Issue -->
	<xsl:template match="taxonomyIdentifier[@ofType='issue-number']">
		<xsl:element name="Issue">
			<xsl:value-of select="."/>
			<xsl:if test="../taxonomyIdentifier[@ofType='supplement-number']">
				<xsl:value-of select="' '" />
				<xsl:value-of select="normalize-space(concat('Suppl ', translate(../taxonomyIdentifier[@ofType='supplement-number'], translate(../taxonomyIdentifier[@ofType='supplement-number'],'0123456789',''), '')))"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="taxonomyIdentifier[@ofType='supplement-number']">
		<xsl:element name="Issue">
			<xsl:value-of select="normalize-space(concat('Suppl ', translate(., translate(.,'0123456789',''), '')))"/>
		</xsl:element>
	</xsl:template>

	<!-- PubDate[@PubStatus] -->
	<xsl:template match="publicationDate">
		<xsl:element name="PubDate">
			<!-- for print it's ppublish, for electronic it's epublish, for PAP articles it's aheadofprint -->
			<xsl:choose>
				<xsl:when test="/asset/assetInformation/flagList/flag[@ofType='pap' and @value='true']">
					<xsl:attribute name="PubStatus" select="'aheadofprint'"/>
				</xsl:when>
				<xsl:when test="../medium[text() = 'print']">
					<xsl:attribute name="PubStatus" select="'ppublish'"/>
				</xsl:when>
				<xsl:when test="../medium[text() = 'electronic']">
					<xsl:attribute name="PubStatus" select="'epublish'"/>
				</xsl:when>
			</xsl:choose>
			<!-- Year, Month, Day, Season -->
			<xsl:choose>
				<xsl:when test="year">
					<xsl:apply-templates select="year" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="sortedValue" mode="year" />
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="month">
					<xsl:apply-templates select="month" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="sortedValue" mode="month" />
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="day">
					<xsl:apply-templates select="day" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="sortedValue" mode="day" />
				</xsl:otherwise>
			</xsl:choose>
			<!-- Do not use if a Month is available. -->
			<xsl:if test="not(month) and not(sortedValue)">
				<xsl:apply-templates select="period" />
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- Year -->
	<xsl:template match="year[parent::publicationDate] | year[ancestor::sourceTimestamp[@ofType='received']] | year[ancestor::sourceTimestamp[@ofType='accepted']] | year[ancestor::sourceTimestamp[@ofType='revised']]">
		<xsl:element name="Year">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sortedValue" mode="year">
		<xsl:element name="Year">
			<xsl:value-of select="substring(text(), 1, 4)" />
		</xsl:element>
	</xsl:template>

	<!-- Month -->
	<xsl:template match="month[parent::publicationDate] | month[ancestor::sourceTimestamp[@ofType='received']] | month[ancestor::sourceTimestamp[@ofType='accepted']] | month[ancestor::sourceTimestamp[@ofType='revised']]">
		<xsl:element name="Month">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sortedValue" mode="month">
		<xsl:element name="Month">
			<xsl:value-of select="substring(text(), 6, 2)" />
		</xsl:element>
	</xsl:template>	

	<!-- Day -->
	<xsl:template match="day[parent::publicationDate] | day[ancestor::sourceTimestamp[@ofType='received']] | day[ancestor::sourceTimestamp[@ofType='accepted']] | day[ancestor::sourceTimestamp[@ofType='revised']]">
		<xsl:element name="Day">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sortedValue" mode="day">
		<xsl:element name="Day">
			<xsl:value-of select="substring(text(), 9, 2)" />
		</xsl:element>
	</xsl:template>	

	<!-- Season -->
	<xsl:template match="period[parent::publicationDate]">
		<xsl:element name="Season">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
