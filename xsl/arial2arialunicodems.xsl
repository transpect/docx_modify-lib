<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="xs docx2hub css rel tr"
  version="2.0">
  
  <!-- Some characters are not in the standard font 'Arial'
       MS Word tries to replace them with another unicode font (which? how?)

       This stylesheet directly changes the font name 
       for these characters to 'Arial Unicode MS'.
       It can be applied for example on hub2docx mode 'hub:merge' output.

       Info: Arial Unicode MS is not part of MS Word anymore, since v2016 -->

  <xsl:import href="http://transpect.io/docx2hub/xsl/main.xsl"/>
  
  <xsl:variable name="xml-chars" as="element(font)?" 
    select="doc('http://transpect.le-tex.de/font-chars-to-xml/fontmap.xml')/fonts/font[@name_word = 'Arial']"/>

  <xsl:template match="w:r[
                         ancestor::*/name() = ('w:footnotes', 'w:endnotes', 'w:comments', 'w:body', 'w:footer', 'w:header')
                       ][
                         w:t[not(empty($xml-chars))]
                            [docx2hub:is-non-unicode-arial-font-textnode(.)]
                            [not(every $char in string-to-codepoints(.)
                             satisfies $char = $xml-chars/char/dec)]
                       ]" mode="docx2hub:arial2arialunicodems">
    <xsl:variable name="context" select="." as="element(w:r)"/>
    <xsl:for-each-group select="string-to-codepoints(w:t)" 
      group-adjacent="not(. = $xml-chars/char/dec)">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <w:r>
            <xsl:apply-templates select="$context/@*" mode="#current"/>
            <w:rPr>
              <w:rFonts w:ascii="Arial Unicode MS" w:eastAsia="Arial Unicode MS" w:hAnsi="Arial Unicode MS" w:cs="Arial Unicode MS"/>
              <xsl:apply-templates select="$context/w:rPr/* except $context/w:rPr/w:rFonts" mode="#current"/>
            </w:rPr>
            <w:t>
              <xsl:attribute name="xml:space" select="'preserve'"/>
              <xsl:value-of select="codepoints-to-string(current-group())"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <xsl:apply-templates select="$context/@*, 
                                         $context/node() except $context/w:t" mode="#current"/>
            <w:t>
              <xsl:attribute name="xml:space" select="'preserve'"/>
              <xsl:value-of select="codepoints-to-string(current-group())"/>
            </w:t>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:function name="docx2hub:is-non-unicode-arial-font-textnode" as="xs:boolean">
    <xsl:param name="w-t" as="element(w:t)"/>
    <xsl:variable name="applied-font" as="xs:string?" 
      select="docx2hub:applied-font-for-w-t($w-t)"/>
    <xsl:choose>
      <xsl:when test="docx2hub:applied-font-for-w-t($w-t) = 'Arial'">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="* | @*" mode="docx2hub:arial2arialunicodems">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
