<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w_strict="http://purl.oclc.org/ooxml/wordprocessingml/main"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  exclude-result-prefixes="xs docx2hub w_strict"
  version="2.0">
  
  <xsl:template match="@* | *" mode="#default">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="w_strict:*" mode="#default">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@w_strict:*" mode="#default">
    <xsl:attribute name="{name()}" select="."/>
  </xsl:template>
  
</xsl:stylesheet>