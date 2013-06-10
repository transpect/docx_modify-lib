<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="identity.xsl"/>
  <xsl:import href="props.xsl"/>
  
  <xsl:template match="w:root" mode="modify">
    <xsl:variable name="font-replacements" as="element(font-replacements)">
      <font-replacements>
        <xsl:apply-templates select="w:settings/w:docVars/w:docVar[matches(@w:name, '^ltx_ebup_fonts_replace_\d+')]"
          mode="parse-doc-vars"/>
      </font-replacements>
    </xsl:variable> 
    <xsl:message select="$font-replacements"/>
    <xsl:next-match>
      <xsl:with-param name="font-replacements" tunnel="yes" select="$font-replacements"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="w:docVar" mode="parse-doc-vars">
    <xsl:variable name="tokenized" select="tokenize(@w:val, '§\$\$§')" as="xs:string+"/>
    <xsl:if test="$tokenized[5]">
      <font-replacement>
        <xsl:attribute name="font" select="replace($tokenized[4], '\s+', '')"/>
        <xsl:attribute name="color" select="$tokenized[5]"/>
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
      </font-replacement>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:styles" mode="modify">
    <xsl:param name="font-replacements" as="element(font-replacements)" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, *" mode="#current"/>
      <xsl:variable name="docroot" select="root()" as="document-node(element(w:root))"/>
      <xsl:variable name="context" select="." as="element(w:styles)"/>
      <xsl:for-each-group select="$font-replacements/font-replacement"
        group-by="string-join((@font, @font-weight, @font-style, @font-variant, @position), '_')">
        <xsl:if test="not($context/w:style[@w:styleId = current-grouping-key()])">
          <w:style w:styleId="ZF_{current-grouping-key()}" w:type="character">
            <w:name w:val="ZF_{current-grouping-key()}"/>
            <!--<xsl:sequence select="(key('run-by-props', ., $docroot))[1]"/>-->
          </w:style>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>  
  
  <xsl:template match="w:spacing" mode="modify"/>
 
  

  
</xsl:stylesheet>