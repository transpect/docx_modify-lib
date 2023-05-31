<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  exclude-result-prefixes="xs docx2hub"
  version="2.0">
  
  <xsl:import href="http://transpect.io/docx2hub/xsl/main.xsl"/>
  <xsl:import href="identity.xsl"/>
  <xsl:import href="props.xsl"/>

  <xsl:template match="/w:root" mode="docx2hub:modify">
    <xsl:apply-templates select="." mode="docx2hub:apply-changemarkup"/>
  </xsl:template>
  
</xsl:stylesheet>