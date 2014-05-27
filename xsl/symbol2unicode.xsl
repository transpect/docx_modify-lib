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
  
  <xsl:template match="w:lvlText[../w:rPr/w:rFonts/@w:ascii=$docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <xsl:variable name="replacement" as="item()*">
      <xsl:apply-templates select="@w:val" mode="wml-to-dbk"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="w:val" select="$replacement/self::text()" separator=""/>
      <xsl:apply-templates select="$replacement/self::processing-instruction()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:rPr[../w:lvlText]/w:rFonts[@w:ascii=$docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <xsl:variable name="replacement-text" as="item()*">
      <xsl:apply-templates select="../../w:lvlText/@w:val" mode="wml-to-dbk">
        <xsl:with-param name="leave-unmappable-symbols-unchanged" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-join($replacement-text/(self::text() | self::attribute()), '') = ../../w:lvlText/@w:val">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- what if there is no w:rFonts element? Then we’d have to match the rPr and insert the w:rFonts at
    the XSD-compliant position. We’d need the sorting routines of hub2docx then. -->
  <xsl:template match="w:rPr[every $e in ../* satisfies (name($e) = ('w:rPr', 'w:sym'))]
                            [../w:sym/@w:font = $docx2hub:symbol-font-names]/w:rFonts" mode="docx2hub:modify">
    <xsl:variable name="replacement" as="item()*"><!-- w:sym or a 'text' element, and PIs -->
      <xsl:apply-templates select="../../w:sym" mode="wml-to-dbk">
        <xsl:with-param name="leave-unmappable-symbols-unchanged" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$replacement/@w:char = ../../w:sym/@w:char">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="w:sym[@w:font = $docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <xsl:variable name="replacement" as="item()*"><!-- w:sym or a 'text' element -->
      <xsl:apply-templates select="." mode="wml-to-dbk">
        <xsl:with-param name="leave-unmappable-symbols-unchanged" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$replacement/@w:char = @w:char"><!-- mapping failed -->
        <xsl:sequence select="."/>
        <xsl:apply-templates select="$replacement/self::processing-instruction()" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <w:t>
          <xsl:sequence select="$replacement"/>
        </w:t>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="processing-instruction()[name() = 'letex']" mode="docx2hub:modify">
    <xsl:processing-instruction name="docx_modify_docVar" select="concat('letex_', generate-id(), ' ', .)"/>
  </xsl:template>

</xsl:stylesheet>