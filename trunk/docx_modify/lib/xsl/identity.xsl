<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  exclude-result-prefixes="xs rel"
  version="2.0">
  
  <xsl:param name="out-dir-replacement" select="'.docx.out'"/>
  
  <xsl:template match="* | @*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="modify">
    <xsl:attribute name="{name()}" select="replace(., '\.docx.tmp', $out-dir-replacement)"/>
  </xsl:template>


  <xsl:template match="w:root | *[rel:Relationships]" mode="export" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[@xml:base]" mode="export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="export"/>

  <xsl:template match="@mc:Ignorable" mode="export"/>
    
</xsl:stylesheet>