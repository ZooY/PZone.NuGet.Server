<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:def="http://www.w3.org/2005/Atom" 
                xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" 
                xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">
  <xsl:template match="/">
    <ul>
      <xsl:for-each select="def:feed/def:entry">
        <li>
          <xsl:value-of select="def:title"/> v<xsl:value-of select="m:properties/d:Version"/> 
          <span class="description"><xsl:value-of select="m:properties/d:Description"/></span>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
</xsl:stylesheet>