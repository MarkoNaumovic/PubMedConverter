<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">
	
	<xsl:variable name="doiRegex" as="xs:string">10\.\d{4,9}/[-._;()/:A-Za-z0-9]+</xsl:variable>
	
	<!-- ReferenceList -->
	<xsl:template match="list[@ofType='references']">
		<xsl:element name="ReferenceList">
			<!-- according to spec, skip it if title is equal to 'References' -->
			<xsl:if test="lower-case(header/text()) != 'references'">
				<xsl:apply-templates select="header" />
			</xsl:if>
			<xsl:apply-templates select="listItem[descendant::tag[@ofType='display-citation']]" />
		</xsl:element>
	</xsl:template>

	<!-- ReferenceList/Title -->
	<xsl:template match="header[ancestor::list[@ofType='references']]">
		<xsl:element name="Title">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<!-- Reference -->
	<xsl:template match="listItem[parent::list[@ofType='references']]">
		<xsl:element name="Reference">
			<xsl:apply-templates select="xref/tag[@ofType='display-citation']" />
			
			<xsl:variable name="baseXpath" select="/asset/resourceList/resource[@ofType='citations']/citationSetList/citationSet/citationList/citation[@id = current()/xref/@refId]/metadataList/metadata[@ofType='article']"/>
			<xsl:choose>
				<xsl:when test="$baseXpath/externalIdentifierList/externalIdentifier[@ofType='doi']">
					<xsl:apply-templates select="$baseXpath/externalIdentifierList/externalIdentifier[@ofType='doi']" />
				</xsl:when>
				<xsl:when test="$baseXpath/captionList/caption[@ofType='comment'][matches(., $doiRegex) or contains(lower-case(.), 'pii')]">
					<xsl:apply-templates select="$baseXpath/captionList/caption[@ofType='comment'][matches(., $doiRegex) or contains(lower-case(.), 'pii')]" />
				</xsl:when>
				<xsl:when test="$baseXpath/externalRepresentationList/externalRepresentation/externalLink[@format='uri' or @format='doi' or @format='url']/@xlink:href[contains(., 'doi')]">
					<xsl:apply-templates select="$baseXpath/externalRepresentationList/externalRepresentation/externalLink[@format='uri' or @format='doi' or @format='url'][@xlink:href[contains(., 'doi')]]" />
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- Citation -->
	<xsl:template match="tag[@ofType='display-citation']">
		<xsl:element name="Citation">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	<!-- ArticleId from ExternalIdentifierList -->
	<xsl:template match="externalIdentifier[@ofType='doi'][ancestor::citation] | externalIdentifier[@ofType='other' and @otherName='object-id'][ancestor::citation]">
		<xsl:element name="ArticleIdList">
			<xsl:element name="ArticleId">
				<xsl:attribute name='IdType' select="'doi'"/>
				<xsl:value-of select="valueList/value" />			
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- ArticleId from caption comment -->
	<xsl:template match="caption[@ofType='comment'][child::valueList[matches(value, $doiRegex) or contains(lower-case(value), 'pii')]][ancestor::citation]">
		<xsl:element name="ArticleIdList">

			<!-- doi -->
			<xsl:if test="valueList[matches(value, $doiRegex)]">
				<xsl:analyze-string select="." regex="{$doiRegex}">
					<xsl:matching-substring>
						<xsl:element name="ArticleId">
							<xsl:attribute name='IdType' select="'doi'"/>
							<xsl:value-of select="." />
						</xsl:element>						
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:if>

			<!-- pii -->
			<xsl:choose>
				<xsl:when test="valueList[contains(lower-case(value), 'pii: ')]">
					<xsl:element name="ArticleId">
						<xsl:attribute name='IdType' select="'pii'"/>
							<xsl:choose>
								<xsl:when test="substring-before(substring-after(lower-case(valueList/value), 'pii: '), ' ')">
									<xsl:value-of select="substring-before(substring-after(lower-case(valueList/value), 'pii: '), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-after(lower-case(valueList/value), 'pii: ')" />
								</xsl:otherwise>
							</xsl:choose>
					</xsl:element>
				</xsl:when>
				<xsl:when test="valueList[contains(lower-case(value), 'pii:')]">
					<xsl:element name="ArticleId">
						<xsl:attribute name='IdType' select="'pii'"/>
							<xsl:choose>
								<xsl:when test="substring-before(substring-after(lower-case(valueList/value), 'pii:'), ' ')">
									<xsl:value-of select="substring-before(substring-after(lower-case(valueList/value), 'pii:'), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-after(lower-case(valueList/value), 'pii:')" />
								</xsl:otherwise>
							</xsl:choose>	
					</xsl:element>
				</xsl:when>					
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- ArticleId from externalLink -->
	<xsl:template match="externalLink[@format='uri'][ancestor::citation] | externalLink[@format='url'][ancestor::citation] | externalLink[@format='doi'][ancestor::citation]">
		<xsl:element name="ArticleIdList">
			<xsl:element name="ArticleId">
				<xsl:attribute name='IdType' select="'doi'"/>
				<xsl:choose>
					<xsl:when test="substring-after(@xlink:href, 'doi.org/')">
						<xsl:value-of select="substring-after(@xlink:href, 'doi.org/')" />
					</xsl:when>
					<xsl:when test="substring-after(., 'doi.org/')">
						<xsl:value-of select="substring-after(@xlink:href, 'doi.org/')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="." />
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:element>
		</xsl:element>
	</xsl:template>


</xsl:stylesheet>
