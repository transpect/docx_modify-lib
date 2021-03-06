<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:tr="http://transpect.io"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  exclude-result-prefixes="xs tr docx2hub"
  version="2.0">
  
  <xsl:import href="identity.xsl"/>
  <xsl:import href="props.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/colors/xsl/colors.xsl"/>

  <xsl:template match="w:root" mode="docx2hub:modify">
    <xsl:variable name="font-replacements" as="element(font-replacements)">
      <font-replacements>
        <xsl:apply-templates select="w:settings/w:docVars/w:docVar[matches(@w:name, '^ltx_ebup_fonts_replace_\d+')]"
          mode="parse-doc-vars"/>
      </font-replacements>
    </xsl:variable>
    <xsl:if test="$debug = 'yes'">
      <xsl:message select="$font-replacements"/>  
    </xsl:if>
    <xsl:next-match>
      <xsl:with-param name="font-replacements" tunnel="yes" select="$font-replacements"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="w:docVar" mode="parse-doc-vars">
    <xsl:variable name="tokenized" select="tokenize(@w:val, '§\$\$§')" as="xs:string+"/>
    <xsl:if test="$tokenized[5]">
      <xsl:variable name="prelim" as="attribute(*)*">
        <xsl:attribute name="font" select="replace($tokenized[4], '\s+', '')"/>
        <xsl:attribute name="color" select="replace(
                                              tr:int-rgb-colors-to-hex(
                                                for $i in tokenize($tokenized[5], ':')
                                                return number($i)
                                              ),
                                              '^#',
                                              ''
                                            )"/>
        <xsl:if test="$tokenized[6] != '0'">
          <xsl:attribute name="font-weight" select="'bold'"/>
        </xsl:if>
        <xsl:if test="$tokenized[7] != '0'">
          <xsl:attribute name="font-style" select="'italic'"/>
        </xsl:if>
        <xsl:if test="$tokenized[8] != '0'">
          <xsl:attribute name="font-variant" select="'small-caps'"/>
        </xsl:if>
        <xsl:if test="$tokenized[9] != '2'">
          <xsl:attribute name="position" select="'superscript'"/>
        </xsl:if>
        <xsl:if test="$tokenized[10] != '2'">
          <xsl:attribute name="position" select="'subscript'"/>
        </xsl:if>
      </xsl:variable>
      <font-replacement name="ZF_{string-join($prelim[not(name() = 'color')], '_')}">
        <xsl:sequence select="$prelim"/>
      </font-replacement>
      <xsl:if test="not($prelim[name() = 'position'])">
        <font-replacement name="ZF_{string-join($prelim[not(name() = 'color')], '_')}_superscript">
          <xsl:sequence select="$prelim"/>
          <xsl:attribute name="position" select="'superscript'"/>
        </font-replacement>
        <font-replacement name="ZF_{string-join($prelim[not(name() = 'color')], '_')}_subscript">
          <xsl:sequence select="$prelim"/>
          <xsl:attribute name="position" select="'subscript'"/>
        </font-replacement>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:styles" mode="docx2hub:modify">
    <xsl:param name="font-replacements" as="element(font-replacements)" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, *" mode="#current"/>
      <xsl:variable name="docroot" select="root()" as="document-node(element(w:root))"/>
      <xsl:variable name="context" select="." as="element(w:styles)"/>
      <xsl:for-each-group select="$font-replacements/font-replacement"
        group-by="@name">
        <xsl:if test="not($context/w:style[@w:styleId = current-grouping-key()])">
          <w:style w:styleId="{current-grouping-key()}" w:type="character">
            <w:name w:val="{current-grouping-key()}"/>
            <w:rPr>
              <xsl:apply-templates select="@*" mode="replacement-to-rPr"/>
            </w:rPr>
            <!--<xsl:sequence select="(key('run-by-props', ., $docroot))[1]"/>-->
          </w:style>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>  
  
  <xsl:template match="@*" mode="replacement-to-rPr"/>
  
  <xsl:template match="@position" mode="replacement-to-rPr">
    <w:vertAlign w:val="{.}"/>
  </xsl:template>
    
  <xsl:template match="@font-weight[. = 'bold']" mode="replacement-to-rPr">
    <w:b/>
  </xsl:template>
  
  <xsl:template match="@font-style[. = 'italic']" mode="replacement-to-rPr">
    <w:i/>
  </xsl:template>
  
  <xsl:template match="@font-variant[. = 'small-caps']" mode="replacement-to-rPr">
    <w:smallCaps w:val="true"/>
  </xsl:template>
  
  <xsl:template match="@font" mode="replacement-to-rPr">
    <w:rFonts w:ascii="{.}" w:hAnsi="{.}" />
  </xsl:template>
  
  <xsl:template match="w:spacing" mode="docx2hub:modify"/>
 
  <xsl:function name="w:matching-font-replacement" as="element(font-replacement)?">
    <xsl:param name="rPr" as="element(w:rPr)"/>
    <xsl:param name="repls" as="element(font-replacement)*"/>
    <xsl:sequence select="$repls[@color = $rPr/w:color/@w:val]
                                [if ($rPr/w:vertAlign/@w:val = ('superscript', 'subscript'))
                                 then @position = $rPr/w:vertAlign/@w:val
                                 else not(@position)
                                ]"/>
  </xsl:function>
 
  <xsl:template match="w:r[w:t]/w:rPr[*]" mode="docx2hub:modify">
    <xsl:param name="font-replacements" as="element(font-replacements)" tunnel="yes"/>
    <xsl:copy>
      <xsl:variable name="matching-replacement" select="w:matching-font-replacement(., $font-replacements/*)" as="element(font-replacement)*"/>
      <xsl:choose>
        <xsl:when test="exists($matching-replacement)"> 
          <w:rStyle w:val="{$matching-replacement/@name}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-match/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  
</xsl:stylesheet>