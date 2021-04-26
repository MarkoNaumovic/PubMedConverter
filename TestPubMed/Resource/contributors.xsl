<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:asset="http://www.wolterskluwer.com/ssr/asset"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xpath-default-namespace="http://www.wolterskluwer.com/ssr/asset"
	exclude-result-prefixes="xlink xs xsl asset">

	
	<!-- AuthorList -->
	<xsl:template match="contributorList[descendant::contributor[@ofType='author']]">	
		<xsl:element name="AuthorList">
			<xsl:choose>
				<xsl:when test="count(../affiliatedOrganizationList/affiliatedOrganization) = 1">
					<xsl:apply-templates select="contributor[@ofType='author']" mode="singleAffil"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="contributor[@ofType='author']"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<!-- Check for groups which are not non-byline (linked directly or via contributor/xref) -->
				<xsl:when test="../contributorGroupList/contributorGroup[textFormatList[descendant::text()]][not(@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId) 
				and @id=//contributor[not(@ofType='author-non-byline')][not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]">
					<xsl:apply-templates select="../contributorGroupList/contributorGroup[textFormatList[descendant::text()]][not(@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId) 
				and @id=//contributor[not(@ofType='author-non-byline')][not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]" mode="collectiveName" />
				</xsl:when>
				<!-- byline group linked to contributorGroup/xref -->
				<xsl:when test="../contributorGroupList/contributorGroup[textFormatList[descendant::text()]][@id=//contributorGroup[not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]">
					<xsl:apply-templates select="../contributorGroupList/contributorGroup[textFormatList[descendant::text()]][@id=//contributorGroup[not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]" mode="collectiveName" />
				</xsl:when>
				<!-- otherwise use onBehalfOf value -->
				<xsl:otherwise>
					<xsl:apply-templates select="contributor/onBehalfOf"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:element>
	</xsl:template>

	<!-- Author -->
	<xsl:template match="contributor[@ofType='author' and nameList]">
		<xsl:variable name="contributorgroupXref" select="xref[@ofType='contributor-group' or @ofType='person-group']/@refId"/>
		<xsl:variable name="affiliationXref" select="xref[@ofType='affiliation']/@refId"/>

		<xsl:element name="Author">
			<xsl:variable name="authorId" select="xref/@refId"/>
			
			<xsl:apply-templates select="descendant-or-self::node()/child::firstName 
										| descendant-or-self::node()/child::lastName 
										| descendant-or-self::node()/child::middleName 
										| descendant-or-self::node()/child::suffix"/>

			<xsl:variable name="outsideContrList" select="/asset[@ofType='article']/metadataList/metadata[@ofType='article']/affiliatedOrganizationList
					/affiliatedOrganization[@id = $affiliationXref]/textFormatList/textFormat" />
			<xsl:variable name="insideContr" select="/asset[@ofType='article']/metadataList/metadata[@ofType='article']/contributorList
						/contributor[@ofType='author']/affiliationList/affiliation/textFormatList/textFormat" />
			<xsl:variable name="insideContrGroup" select="affiliatedOrganizationList/affiliatedOrganization[xref[@ofType='person-group' or @ofType='contributor-group']/@refId = $contributorgroupXref]/textFormatList/textFormat" />
			<xsl:variable name="outsidePersonGroup" select="/asset[@ofType='article']/metadataList/metadata[@ofType='article']/affiliatedOrganizationList
					/affiliatedOrganization[@id = //contributorGroup[@id = $contributorgroupXref]/xref[@ofType='affiliation']/@refId]/textFormatList/textFormat/fullText/paragraph" />
			<xsl:variable name="outsidePersonGroup2" select="/asset[@ofType='article']/metadataList/metadata[@ofType='article']/affiliatedOrganizationList
					/affiliatedOrganization[xref/@refId = $contributorgroupXref]/textFormatList/textFormat" />

			<xsl:choose>
				<xsl:when test="$outsideContrList">
					<xsl:if test="count(xref[@ofType='affiliation']) = 1">
						<xsl:apply-templates select="../../affiliatedOrganizationList/affiliatedOrganization[@id = current()/xref/@refId]"/>					
					</xsl:if>
					<xsl:if test="count(xref[@ofType='affiliation']) > 1">
						<xsl:apply-templates select="../../affiliatedOrganizationList/affiliatedOrganization[@id = current()/xref/@refId]" mode="multiple"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$insideContr">
					<xsl:if test="count(affiliationList/affiliation) = 1">
						<xsl:apply-templates select="affiliationList/affiliation"/>					
					</xsl:if>
					<xsl:if test="count(affiliationList/affiliation) > 1">
						<xsl:apply-templates select="affiliationList/affiliation" mode="multiple"/>		
					</xsl:if>
				</xsl:when>
				<xsl:when test="$outsidePersonGroup">
					<xsl:if test="count(../../affiliatedOrganizationList
						/affiliatedOrganization[@id = //contributorGroup[@id = //contributor/xref[@ofType='person-group' or @ofType='contributor-group']/@refId]/xref[@ofType='affiliation']/@refId]) = 1">
						<xsl:apply-templates select="../../affiliatedOrganizationList
						/affiliatedOrganization[@id = //contributorGroup[@id = //contributor/xref[@ofType='person-group' or @ofType='contributor-group']/@refId]/xref[@ofType='affiliation']/@refId]"/>
					</xsl:if>
					<xsl:if test="count(../../affiliatedOrganizationList
						/affiliatedOrganization[@id = //contributorGroup[@id = //contributor/xref[@ofType='person-group' or @ofType='contributor-group']/@refId]/xref[@ofType='affiliation']/@refId]) > 1">
						<xsl:apply-templates select="../../affiliatedOrganizationList
						/affiliatedOrganization[@id = //contributorGroup[@id = //contributor/xref[@ofType='person-group' or @ofType='contributor-group']/@refId]/xref[@ofType='affiliation']/@refId]" mode="multiple"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$outsidePersonGroup2">
					<xsl:if test="count(../../affiliatedOrganizationList/affiliatedOrganization[xref/@refId = $contributorgroupXref]) = 1">
						<xsl:apply-templates select="../../affiliatedOrganizationList/affiliatedOrganization[xref/@refId = $contributorgroupXref]"/>				
					</xsl:if>
					<xsl:if test="count(../../affiliatedOrganizationList/affiliatedOrganization[xref/@refId = $contributorgroupXref]) > 1">
						<xsl:apply-templates select="../../affiliatedOrganizationList/affiliatedOrganization[xref/@refId = $contributorgroupXref]" mode="multiple"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$insideContrGroup">
					<xsl:if test="count(xref[@ofType='contributor-group']) = 1">
						<xsl:apply-templates select="affiliatedOrganizationList/affiliatedOrganization[xref[@ofType='person-group' or @ofType='contributor-group']/@refId = //contributor/xref[@ofType='person-group' or @ofType='contributor-group']/@refId]"/>					
					</xsl:if>
					<xsl:if test="count(xref[@ofType='contributor-group']) > 1">
						<xsl:apply-templates select="affiliatedOrganizationList/affiliatedOrganization[xref[@ofType='person-group' or @ofType='contributor-group']/@refId = //contributor/xref[@ofType='person-group' or @ofType='contributor-group']/@refId]" mode="multiple"/>	
					</xsl:if>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>

			<xsl:apply-templates select="externalIdentifierList/externalIdentifier[@ofType='orcid']" />
		</xsl:element>
	</xsl:template>

	<!-- First Author when only 1 Affiliation exists -->
	<xsl:template match="contributor[@ofType='author' and nameList and not(preceding-sibling::contributor[@ofType='author' and nameList])]" mode="singleAffil">
		<xsl:element name="Author">	
			<xsl:apply-templates select="descendant-or-self::node()/child::firstName 
										| descendant-or-self::node()/child::lastName 
										| descendant-or-self::node()/child::middleName 
										| descendant-or-self::node()/child::suffix"/>
			<xsl:apply-templates select="../../affiliatedOrganizationList/affiliatedOrganization" />
			<xsl:apply-templates select="externalIdentifierList/externalIdentifier[@ofType='orcid']" />
		</xsl:element>
	</xsl:template>
	
	<!-- Remaining Authors when only 1 Affiliation exists -->
	<xsl:template match="contributor[@ofType='author' and nameList and preceding-sibling::contributor[@ofType='author' and nameList]]" mode="singleAffil">
		<xsl:element name="Author">
			<xsl:apply-templates select="descendant-or-self::node()/child::firstName 
										| descendant-or-self::node()/child::lastName 
										| descendant-or-self::node()/child::middleName 
										| descendant-or-self::node()/child::suffix"/>
			<xsl:apply-templates select="externalIdentifierList/externalIdentifier[@ofType='orcid']" />
		</xsl:element>
	</xsl:template>
	
	<!-- FirstName -->
	<xsl:template match="firstName">
		<xsl:element name="FirstName">
			<xsl:value-of select="descendant-or-self::node()/child::text()"/>
		</xsl:element>
	</xsl:template>

	<!-- LastName -->
	<xsl:template match="lastName">
		<xsl:element name="LastName">
			<xsl:value-of select="descendant-or-self::node()/child::text()"/>
		</xsl:element>
	</xsl:template>

	<!-- MiddleName -->
	<xsl:template match="middleName">
		<xsl:element name="MiddleName">
			<xsl:value-of select="descendant-or-self::node()/child::text()"/>
		</xsl:element>
	</xsl:template>

	<!-- Suffix -->
	<xsl:template match="suffix">
		<xsl:element name="Suffix">
			<xsl:value-of select="descendant-or-self::node()/child::text()"/>
		</xsl:element>
	</xsl:template>


	<!-- Affiliation -->
	<xsl:template match="affiliatedOrganization | affiliation">
		<xsl:element name="Affiliation">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>	

	<xsl:template match="affiliatedOrganization | affiliation" mode="multiple">
		<xsl:element name="AffiliationInfo">
			<xsl:element name="Affiliation">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="paragraph[ancestor::affiliatedOrganization and following-sibling::paragraph] | paragraph[ancestor::affiliation and following-sibling::paragraph]">
			<xsl:apply-templates/>
			<xsl:value-of select="' '"/>	
	</xsl:template>

	<xsl:template match="tag[ancestor::affiliatedOrganization//fullText] | externalLink[ancestor::affiliatedOrganization//fullText]">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="fullText/text()[contains(., 'E-mail') and contains(.,':')]" priority="2">
		<xsl:value-of select="concat(substring-before(., ' E-mail'), substring-after(., ':'))"/>
	</xsl:template>

	<!-- Author/Identifier -->
	<xsl:template match="externalIdentifier[@ofType='orcid']">
		<xsl:element name="Identifier">
			<xsl:attribute name="Source">ORCID</xsl:attribute>
			<xsl:value-of select="translate(., translate(., '0123456789-', ''), '')" />
		</xsl:element>
	</xsl:template>

	<!-- GroupList -->
	<xsl:template match="contributorGroupList">
		<xsl:element name="GroupList">
			<xsl:element name="Group">
				<xsl:choose>
					<!-- Check for non-byline group linked via contributor xref -->
					<xsl:when test="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId]">
						<xsl:element name="GroupName">
							<xsl:apply-templates select="contributorGroup[@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId]" />
						</xsl:element>
					</xsl:when>
					<!-- Check for non-byline groups linked directly to non-byline contributor -->
					<xsl:when test="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author')][@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/xref[@ofType='collaboration']/@refId]">
						<xsl:element name="GroupName">
							<xsl:apply-templates select="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author')][@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/xref[@ofType='collaboration']/@refId]" />
						</xsl:element>
					</xsl:when>			
					<!-- Check for byline groups linked via contributor xref -->
					<xsl:when test="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/@id]/xref[@ofType='collaboration']/@refId]">
						<xsl:element name="GroupName">
							<xsl:apply-templates select="contributorGroup[@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/@id]/xref[@ofType='collaboration']/@refId]" />
						</xsl:element>
					</xsl:when>
					<!-- Check for byline groups linked directly to byline contributor -->
					<xsl:when test="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author-non-byline')][not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]">
						<xsl:element name="GroupName">
							<xsl:apply-templates select="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author-non-byline')][not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]" />
						</xsl:element>
					</xsl:when>					
					<!-- Check for non-byline group linked via contributor xref without GroupName -->
					<xsl:when test="contributorGroup[@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId]">
						<xsl:apply-templates select="contributorGroup[@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId]" />
					</xsl:when>	
					<!-- use GroupName from onBehalfOf -->
					<xsl:otherwise>
						<xsl:apply-templates select="../contributorList/contributor/onBehalfOf" mode="groupName" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="../contributorList/contributor[@ofType='author-non-byline' and nameList]" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Byline GroupName value -->
	<xsl:template match="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/@id]/xref[@ofType='collaboration']/@refId] | contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author-non-byline')][not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]">
		<xsl:apply-templates/>
		<xsl:if test="following-sibling::contributorGroup[textFormatList[descendant::text()]][descendant::text()][@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/@id]/xref[@ofType='collaboration']/@refId] or following-sibling::contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author-non-byline')][not(@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id)]/xref[@ofType='collaboration']/@refId]">
			<xsl:value-of select="' and '"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Non-Byline GroupName value -->
	<xsl:template match="contributorGroup[textFormatList[descendant::text()]][@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId] | contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author')][@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/xref[@ofType='collaboration']/@refId]">
		<xsl:apply-templates/>
		<xsl:if test="following-sibling::contributorGroup[textFormatList[descendant::text()]][@id=//contributor[xref[@ofType='contributor-group']/@refId=//contributorGroup[@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/@id]/xref/@refId] or ../following-sibling::contributorGroup[textFormatList[descendant::text()]][@id=//contributor[not(@ofType='author')][@propertySetRefId=//propertySet[descendant::property[key='content-type' and descendant::value[plainText='collaborators' or plainText='nonbyline-author' or plainText='author non-byline']]]/@id]/xref[@ofType='collaboration']/@refId]">
			<xsl:value-of select="' and '"/>
		</xsl:if>
	</xsl:template>
		
	<!-- CollectiveName -->
	<xsl:template match="contributorGroup[textFormatList[descendant::text()]]" mode="collectiveName">
		<xsl:element name="Author">
			<xsl:element name="CollectiveName">
				<xsl:apply-templates />
			</xsl:element>	
		</xsl:element>
	</xsl:template>
	
	<!-- CollectiveName from onBehalfOf -->
	<xsl:template match="onBehalfOf">
		<xsl:element name="Author">
			<xsl:element name="CollectiveName">
				<xsl:apply-templates />
			</xsl:element>
		</xsl:element>
	</xsl:template>	
	
	<!-- GrupName from onBehalfOf -->
	<xsl:template match="onBehalfOf" mode="groupName">
		<xsl:element name="GroupName">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>	
	
	<!-- remove extra on behalf of text -->
	<xsl:template match="text()[ancestor::onBehalfOf or ancestor::contributorGroup][starts-with(., 'on behalf of the')]" priority="2">
		<xsl:value-of select="substring-after(., 'on behalf of the ')"/>
	</xsl:template>

	<!-- IndividualName -->
	<xsl:template match="contributor[@ofType='author-non-byline' and nameList]">
		<xsl:element name="IndividualName">
			<xsl:apply-templates select="descendant-or-self::node()/child::firstName 
										| descendant-or-self::node()/child::lastName 
										| descendant-or-self::node()/child::middleName 
										| descendant-or-self::node()/child::suffix"/>
			<xsl:apply-templates select="affiliationList"/>	
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
