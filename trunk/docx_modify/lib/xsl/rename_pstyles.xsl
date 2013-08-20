<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  exclude-result-prefixes="xs letex docx2hub"
  version="2.0">
  
  <xsl:import href="identity.xsl"/>
  <xsl:import href="props.xsl"/>

  <!-- assumption: no new styles need to be created -->

  <xsl:template match="w:p/w:pPr/w:pStyle/@w:val[. = 'IEVUeberschrift']" mode="docx2hub:modify">
    <xsl:attribute name="w:val" select="'Heading3'"/>
  </xsl:template>
  
</xsl:stylesheet>