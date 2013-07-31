<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  exclude-result-prefixes="xs letex docx2hub"
  version="2.0">
  
  <xsl:import href="identity.xsl"/>
 
  <xsl:template match="* | @*" mode="bookmarkstart bookmarkpagefinal listchange">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:body" mode="docx2hub:modify">
    <xsl:variable name="bookmarkstart">
      <xsl:apply-templates select="." mode="bookmarkstart"/>
    </xsl:variable>
    
    <xsl:variable name="bookmarkpagefinal">
      <xsl:apply-templates select="$bookmarkstart" mode="bookmarkpagefinal"/>
    </xsl:variable>
    
    <xsl:variable name="listchange">
      <xsl:apply-templates select="$bookmarkpagefinal" mode="listchange"/>
    </xsl:variable>
    
    <xsl:sequence select="$listchange"/>
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="bookmarkstart">
    <xsl:apply-templates select="." mode="docx2hub:modify"/>
  </xsl:template>
  
  <xsl:template match="w:body" mode="bookmarkstart">
    <w:body>
      <xsl:for-each-group select="*" group-adjacent="w:pPr/w:pBdr/w:left/@w:color = '000000'">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <w:schwarz>
              <xsl:sequence select="current-group()"/>
            </w:schwarz>
          </xsl:when>
          <xsl:otherwise>
            <w:bunt>
              <xsl:sequence select="current-group()"/>
            </w:bunt>     
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </w:body>
  </xsl:template>
  
  <xsl:template match="w:bunt/w:p[1]" mode="bookmarkpagefinal">
    <xsl:variable name="intgesamt" select="count(../../../w:body//w:bookmarkStart)" as="xs:integer"/>
    <xsl:variable name="intbook" select="count(../preceding-sibling::w:schwarz[1]//w:bookmarkStart[contains(@w:name,'page_')])" as="xs:integer"/>
    <xsl:variable name="starts" select="../preceding-sibling::w:schwarz[1]//w:bookmarkStart[contains(@w:name,'page_')]" as="element(w:bookmarkStart)*"/>
    <xsl:variable name="strname" select="../preceding-sibling::w:schwarz[1]//w:bookmarkStart[contains(@w:name,'page_')]/@w:name" as="xs:string*"/>
    <xsl:copy>
      <xsl:copy-of select="@*, w:pPr"/>
      <xsl:if test="$strname[$intbook] != ''">
        <w:bookmarkStart w:id="{$intgesamt + $starts[$intbook]/@w:id}" w:name="page_tag_Start_{substring($strname[$intbook],6)}"/>
      </xsl:if>      
      <xsl:copy-of select="* except w:pPr"/>
      <xsl:if test="$strname[$intbook] != ''">
        <w:bookmarkEnd w:id="{$intgesamt + $starts[$intbook]/@w:id}"/>
      </xsl:if> 
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:bunt | w:schwarz" mode="bookmarkpagefinal">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
</xsl:stylesheet>