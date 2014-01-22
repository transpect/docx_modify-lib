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
  
  <!--<xsl:function name="docx2hub:is-symbol-rfonts" as="xs:boolean">
    
    <xsl:sequence select=""></xsl:sequence>
  </xsl:function>-->
  
  
  <xsl:template match="w:lvlText[../w:rPr/w:rFonts/@w:ascii=('Symbol', 'Wingdings')]/@w:val" mode="docx2hub:modify">
    <xsl:attribute name="{name()}">
      <xsl:apply-templates select="." mode="wml-to-dbk"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="w:rPr[../w:lvlText]/w:rFonts[@w:ascii=('Symbol', 'Wingdings')]" mode="docx2hub:modify">
    <w:rFonts w:ascii="Arial Unicode MS"
      w:eastAsia="Arial Unicode MS"
      w:hAnsi="Arial Unicode MS"
      w:hint="eastAsia"/>  
  </xsl:template>
  
  
    
  
</xsl:stylesheet>