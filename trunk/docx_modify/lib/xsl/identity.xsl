<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  exclude-result-prefixes="xs rel docx2hub"
  version="2.0">
  
  <xsl:import href="http://transpect.le-tex.de/xslt-util/colors/colors.xsl"/>
  
  <xsl:param name="debug" select="'no'"/>
  
  <xsl:param name="out-dir-replacement" select="'.docx.out'"/>
  
  <xsl:template match="* | @*" mode="docx2hub:identity docx2hub:modify docx2hub:export">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="docx2hub:modify">
    <xsl:attribute name="{name()}" select="replace(., '\.docx.tmp', $out-dir-replacement)"/>
  </xsl:template>

  <xsl:template match="w:root" mode="docx2hub:export" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[rel:Relationships] | w:docTypes" mode="docx2hub:export" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[@xml:base]" mode="docx2hub:export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
    <file xmlns="http://www.w3.org/ns/xproc-step" 
      status="modified-or-new-and-written-to-sys"
      name="{replace(@xml:base, '^((/word/)|.)+/((%5BContent_Types|word/).*)$', '$3')}" />
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="docx2hub:export"/>

</xsl:stylesheet>
