<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="css docx2hub tr xs"
  version="2.0">
  
  <xsl:import href="http://transpect.io/docx2hub/xsl/main.xsl"/>
  <xsl:import href="http://transpect.io/docx_modify/xsl/identity.xsl"/>
  
  <xsl:param name="charmap-policy" select="'msoffice'" as="xs:string"/>

  <xsl:variable name="docx2hub:replace-unicodefont-symbol-by-text" as="xs:boolean"
    select="true()"/>
  
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
    <xsl:variable name="replacement-string-value" as="xs:string?" select="string-join($replacement-text/(self::text() | self::attribute()), '')"/>
    <xsl:variable name="replacement-symbol-map-entry" as="element(symbol)*" select="docx2hub:font-map(@w:ascii)/symbols/symbol[@char = $replacement-string-value][1]"/>
    <xsl:choose>
      <xsl:when test="$replacement-string-value = ../../w:lvlText/@w:val">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test="$replacement-symbol-map-entry/@font">
        <w:rFonts w:ascii="{$replacement-symbol-map-entry/@font}" w:hAnsi="{$replacement-symbol-map-entry/@font}" w:cs="{$replacement-symbol-map-entry/@font}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[self::w:t or self::m:t or self::w:instrText[string-length(.) = 1]]
                        [docx2hub:text-is-rFonts-only-symbol(.)]" mode="docx2hub:modify">
    <xsl:variable name="applied-font" as="xs:string?" select="docx2hub:applied-font-for-w-t(.)"/>
    <xsl:variable name="map" select="docx2hub:font-map($applied-font)" as="document-node(element(symbols))?"/>
    <xsl:variable name="resolved-unicode-char" as="attribute(char)?" select="(key('symbol-by-entity', ., $map)/@char)[1]"/>
    <xsl:choose>
      <xsl:when test="$resolved-unicode-char">
        <xsl:copy>
          <xsl:value-of select="$resolved-unicode-char"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[self::w:t or self::m:t or self::w:instrText[string-length(.) = 1]][
                        not(docx2hub:text-is-rFonts-only-symbol(.))
                        and ../*[self::w:t or self::m:t or self::w:instrText[string-length(.) = 1]][docx2hub:text-is-rFonts-only-symbol(.)]
                      ]" mode="docx2hub:modify">
    <xsl:message select="'Help/Handle me: unmapped text with changed rFonts setting.'"/>
  </xsl:template>

  <xsl:template match="w:rPr[
                        ../*[self::w:t or self::m:t or self::w:instrText[string-length(.) = 1]][docx2hub:text-is-rFonts-only-symbol(.)]
                      ]/w:rFonts[@w:ascii]" mode="docx2hub:modify">
    <xsl:variable name="replacement-symbol-map-entry" as="element(symbol)*"
      select="key('symbol-by-entity', parent::w:rPr/parent::*/*[self::w:t or self::m:t or self::w:instrText[string-length(.) = 1]], docx2hub:font-map(@w:ascii))"/>
    <xsl:variable name="replacement-symbol" as="element(symbol)?"
      select="(
                $replacement-symbol-map-entry[name() = (concat('char-', $charmap-policy))],
                $replacement-symbol-map-entry
              )[1]"/>
    <xsl:choose>
      <xsl:when test="$replacement-symbol-map-entry/@font">
        <w:rFonts w:ascii="{$replacement-symbol-map-entry/@font}" w:hAnsi="{$replacement-symbol-map-entry/@font}" w:cs="{$replacement-symbol-map-entry/@font}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="docx2hub:text-is-rFonts-only-symbol" as="xs:boolean">
    <xsl:param name="w-t_or_m-t" as="element()"/><!-- w:t or m:t only -->
    <xsl:variable name="applied-font" as="xs:string?" select="docx2hub:applied-font-for-w-t($w-t_or_m-t)"/>
    <xsl:variable name="font-map" as="document-node(element(symbols))?" select="docx2hub:font-map($applied-font)"/>
    <xsl:sequence select="if (exists($applied-font) and exists($font-map)) 
                          then boolean(
                                $w-t_or_m-t[
                                  string-length(.) = 1 and 
                                  not(../w:lvlText) and 
                                  $applied-font = $docx2hub:symbol-font-names and
                                  key('symbol-by-entity', ., docx2hub:font-map($applied-font))/@char
                                ]
                               )
                           else false()"/>
  </xsl:function>
  
  <!-- what if there is no w:rFonts element? Then we’d have to match the rPr and insert the w:rFonts at
    the XSD-compliant position. We’d need the sorting routines of hub2docx then. -->
  <xsl:template match="w:rPr[every $e in ../* satisfies (name($e) = ('w:rPr', 'w:sym'))]
                            [../w:sym/@w:font = $docx2hub:symbol-font-names]/w:rFonts" mode="docx2hub:modify">
    <xsl:variable name="replacement" as="item()*"><!-- w:sym or a 'text' element, and PIs -->
      <xsl:apply-templates select="../../w:sym" mode="wml-to-dbk">
        <xsl:with-param name="leave-unmappable-symbols-unchanged" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="replacement-string-value" as="xs:string?" select="string-join($replacement/(self::text() | self::attribute()), '')"/>
    <xsl:variable name="replacement-symbol-map-entry" as="element(symbol)?" 
      select="if(@w:ascii) then docx2hub:font-map(@w:ascii)/symbols
                /symbol[@char = $replacement-string-value]
                       [if(current()/../../w:sym) then current()/../../w:sym/@w:char = @number else true()] 
              else ()"/>
    <xsl:choose>
      <xsl:when test="$replacement/@w:char = ../../w:sym/@w:char">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test="$replacement-symbol-map-entry/@font">
        <w:rFonts w:ascii="{$replacement-symbol-map-entry/@font}" w:hAnsi="{$replacement-symbol-map-entry/@font}" w:cs="{$replacement-symbol-map-entry/@font}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="w:r[every $e in * satisfies (name($e) = ('w:sym'))]
                          [w:sym/@w:font = $docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <xsl:variable name="replacement" as="item()*"><!-- w:sym or a 'text' element, and PIs -->
      <xsl:apply-templates select="w:sym" mode="wml-to-dbk">
        <xsl:with-param name="leave-unmappable-symbols-unchanged" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="replacement-string-value" as="xs:string?" select="string-join($replacement/(self::text() | self::attribute()), '')"/>
    <xsl:variable name="replacement-symbol-map-entry" as="element(symbol)?" 
      select="docx2hub:font-map(w:sym/@w:font)/symbols
                /symbol[@char = $replacement-string-value]
                       [if(current()/w:sym) then current()/w:sym/@w:char = @number else true()]"/>
    <xsl:copy>
      <w:rPr>
        <xsl:choose>
          <xsl:when test="$replacement/@w:char = ../../w:sym/@w:char">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="$replacement-symbol-map-entry/@font">
            <w:rFonts w:ascii="{$replacement-symbol-map-entry/@font}" w:hAnsi="{$replacement-symbol-map-entry/@font}" w:cs="{$replacement-symbol-map-entry/@font}"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>
          </xsl:otherwise>
        </xsl:choose>    
      </w:rPr>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
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

  <xsl:variable name="docx2hub:trusted-unicode-font-names" as="xs:string*"
    select="('Cambria Math', 'Courier New', 'Times New Roman')"/>

  <xsl:template match="w:r[$docx2hub:replace-unicodefont-symbol-by-text]
                          [count(*[not(self::w:rPr)]) = 1]
                          /w:sym[@w:font = $docx2hub:trusted-unicode-font-names]"
    mode="docx2hub:modify" priority="0.5">
    <xsl:if test="not(parent::w:r/w:rPr)">
      <w:rPr>
        <w:rFonts w:ascii="{@w:font}" w:hAnsi="{@w:font}" w:cs="{@w:font}"/>
      </w:rPr>
    </xsl:if>
    <w:t>
      <xsl:value-of select="codepoints-to-string(tr:hex-to-dec(@w:char))"/>
    </w:t>
  </xsl:template>
  <xsl:template match="w:r[$docx2hub:replace-unicodefont-symbol-by-text]
                          [count(*[not(self::w:rPr)]) = 1]
                          [w:sym/@w:font = $docx2hub:trusted-unicode-font-names]
                          /w:rPr"
    mode="docx2hub:modify">
    <w:rPr>
      <xsl:apply-templates select="*" mode="#current"/>
      <w:rFonts w:ascii="{../w:sym/@w:font}" w:hAnsi="{../w:sym/@w:font}" w:cs="{../w:sym/@w:font}"/>
    </w:rPr>
  </xsl:template>

  <xsl:template match="processing-instruction()[name() = 'letex']" mode="docx2hub:modify">
    <xsl:processing-instruction name="docx_modify_docVar" select="concat('letex_', generate-id(), ' ', .)"/>
  </xsl:template>

  <xsl:template match="w:style/w:rPr/w:rFonts[@w:ascii = $docx2hub:symbol-font-names]" mode="docx2hub:modify">
    <xsl:sequence select="$docx2hub:symbol-replacement-rfonts"/>
  </xsl:template>

</xsl:stylesheet>
