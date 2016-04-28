<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w_strict="http://purl.oclc.org/ooxml/wordprocessingml/main"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  exclude-result-prefixes="xs docx2hub w_strict"
  version="2.0">
  
  <xsl:import href="identity.xsl"/>
  
  <xsl:template match="w_strict:*" mode="docx2hub:modify">
    <xsl:element name="{name()}" xmlns="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>