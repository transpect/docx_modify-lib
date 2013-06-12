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
    <xsl:variable name="runs" as="element(w:r)*" 
      select="w:document//w:r[w:t]"/>
    <xsl:variable name="prop-signatures" select="for $r in $runs/w:rPr return w:prop-signature($r)" as="xs:string*"/>
    <xsl:next-match>
      <xsl:with-param name="run-signatures" tunnel="yes" select="distinct-values($prop-signatures[not(. eq '')])"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="w:r[w:t]/w:rPr[*]" mode="modify">
    <xsl:param name="run-signatures" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:variable name="prop-signature" select="w:prop-signature(.)" as="xs:string"/>
      <xsl:choose>
        <xsl:when test="$prop-signature = $run-signatures"> 
          <w:rStyle w:val="ltx_{$prop-signature}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-match/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:styles" mode="modify">
    <xsl:param name="run-signatures" as="xs:string*" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:variable name="docroot" select="root()" as="document-node(element(w:root))"/>
      <xsl:for-each select="$run-signatures">
        <w:style w:styleId="ZF_{.}" w:type="character">
          <w:name w:val="ZF_{.}"/>
          <xsl:sequence select="(key('run-by-props', ., $docroot))[1]"/>
        </w:style>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  
</xsl:stylesheet>