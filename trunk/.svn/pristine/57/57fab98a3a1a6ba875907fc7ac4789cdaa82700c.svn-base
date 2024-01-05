<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  exclude-result-prefixes="xs docx2hub"
  version="2.0">
  

  <xsl:function name="w:prop-signature" as="xs:string">
    <xsl:param name="prop-obj" as="element(*)"/><!-- w:rPr, w:pPr, ... -->
    <xsl:variable name="props" select="$prop-obj/(
                                         w:color[not(@w:val eq 'auto')]
                                         | w:b
                                         | w:i
                                         | w:lang[@w:val]
                                         | w:u
                                         | w:sz
                                         | w:rFonts[@w:ascii]
                                         | w:shd[@w:fill][not(@w:fill eq 'auto')]
                                       )" as="element(*)*"/>
    <xsl:variable name="string-props" as="xs:string*">
      <xsl:apply-templates select="$props" mode="docx2hub:signature"/>  
    </xsl:variable>
    <xsl:sequence select="string-join($string-props, '__')"/>
  </xsl:function>
  
  <xsl:template match="w:b[not(@*)] | w:i[not(@*)]" mode="docx2hub:signature">
    <xsl:sequence select="local-name()"/>
  </xsl:template>
  
  <xsl:template match="w:rFonts[@w:ascii]" mode="docx2hub:signature" as="xs:string?">
    <xsl:sequence select="@w:ascii"/>
  </xsl:template>
  
  <xsl:template match="w:u" mode="docx2hub:signature" as="xs:string?">
    <xsl:sequence select="string-join((local-name(), @w:val), '_')"/>
  </xsl:template>
  
  <xsl:template match="w:shd" mode="docx2hub:signature" as="xs:string?">
    <xsl:sequence select="string-join((local-name(), @w:fill), '_')"/>
  </xsl:template>
  
  <xsl:template match="w:sz | w:color | w:lang" mode="docx2hub:signature" as="xs:string?">
    <xsl:sequence select="@w:val"/>
  </xsl:template>
  
  <xsl:key name="run-by-props" match="w:rPr" use="w:prop-signature(.)"/> 
      
</xsl:stylesheet>