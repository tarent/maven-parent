<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nl "&#x0A;">
]>
<!-- https://stackoverflow.com/a/4747858/2171120 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="text" encoding="UTF-8" indent="no"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="vApos">'</xsl:variable>
	<xsl:template match="*[@* or not(*)] ">
		<xsl:if test="not(*)">
			<xsl:apply-templates select="ancestor-or-self::*" mode="path"/>
			<xsl:value-of select="concat('=',$vApos,.,$vApos)"/>
			<xsl:text>&nl;</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="@*|*"/>
	</xsl:template>
	<xsl:template match="*" mode="path">
		<xsl:value-of select="concat('/',name())"/>
		<xsl:variable name="vnumPrecSiblings" select="count(preceding-sibling::*[name()=name(current())])"/>
		<xsl:if test="$vnumPrecSiblings">
			<xsl:value-of select="concat('[', $vnumPrecSiblings +1, ']')"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:apply-templates select="../ancestor-or-self::*" mode="path"/>
		<xsl:value-of select="concat('[@',name(), '=',$vApos,.,$vApos,']')"/>
		<xsl:text>&nl;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
