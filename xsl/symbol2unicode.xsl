<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  xmlns:css="http://www.w3.org/1996/css"
  exclude-result-prefixes="xs docx2hub"
  version="2.0">
  
  <xsl:import href="http://transpect.le-tex.de/docx2hub/main.xsl"/>
  <xsl:import href="http://transpect.le-tex.de/docx_modify/xsl/identity.xsl"/>
  
  <xsl:template match="w:lvlText[../w:rPr/w:rFonts/@w:ascii=$docx2hub:symbol-font-names]/@w:val" mode="docx2hub:modify">
    <xsl:attribute name="{name()}">
      <xsl:apply-templates select="." mode="wml-to-dbk"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:variable name="arial-unicode-rfonts" as="element(w:rFonts)">
    <w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math" w:cs="Cambria Math"/>
    <!--<w:rFonts w:ascii="Arial Unicode MS"
      w:eastAsia="Arial Unicode MS"
      w:hAnsi="Arial Unicode MS"
      w:hint="eastAsia"/>-->
  </xsl:variable>
  
  <xsl:template match="  w:rPr[../w:lvlText]/w:rFonts[@w:ascii=$docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <xsl:sequence select="$arial-unicode-rfonts"/>
  </xsl:template>
  
  <!-- what if there is no w:rFonts element? Then we’d have to match the rPr and insert the w:rFonts at
    the XSD-compliant position. We’d need the sorting routines of hub2docx then. -->
  <xsl:template match="w:rPr[every $e in ../* satisfies (name($e) = ('w:rPr', 'w:sym'))]
                            [../w:sym/@w:font = $docx2hub:symbol-font-names]/w:rFonts" mode="docx2hub:modify">
    <xsl:sequence select="$arial-unicode-rfonts"/>
  </xsl:template>
  
  <xsl:template match="w:sym[@w:font = $docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <w:t>
      <xsl:apply-templates select="." mode="wml-to-dbk"/>
    </w:t>
  </xsl:template>
    
  
</xsl:stylesheet>