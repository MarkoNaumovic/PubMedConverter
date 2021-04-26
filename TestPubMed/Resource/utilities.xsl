<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	exclude-result-prefixes="xs xsl">

	<!-- When we need to change the value of an attribute -->
	<xsl:template name="createLocalNameAttribute">
		<xsl:param name="value" />
		<xsl:attribute name="{local-name()}">
			<xsl:value-of select="$value" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template name="getValuesBeforeAndAfterLastOccurance">
		<xsl:param name="inputString" />
		<xsl:param name="char" />
		<xsl:param name="stringToReturn" select="''" />
		<xsl:choose>
			<xsl:when test="contains($inputString, $char)">
				<xsl:variable name="before"
					select="substring-before($inputString, $char)" />
				<xsl:variable name="after"
					select="substring-after($inputString, $char)" />
				<xsl:variable name="returnValue">
					<xsl:choose>
						<xsl:when test="$stringToReturn eq ''">
							<xsl:value-of select="$stringToReturn" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($stringToReturn, $char)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="getValuesBeforeAndAfterLastOccurance">
					<xsl:with-param name="inputString" select="$after" />
					<xsl:with-param name="char" select="$char" />
					<xsl:with-param name="stringToReturn" select="concat($returnValue,$before)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- returns folderName * fileName -->	
				<xsl:value-of select="concat(concat($stringToReturn, '*'), $inputString)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

</xsl:stylesheet>