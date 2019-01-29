<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="xs docx2hub"
  version="2.0">
  
  <xsl:import href="identity.xsl"/>
  
  <xsl:import href="http://transpect.io/htmlreports/xsl/svrl2xsl.xsl"/>

  <xsl:variable name="report" select="collection()[/c:reports]"/>
  <!--  in this case the input is a hub (or docx2hub singletree) document -->
  <xsl:variable name="html-with-srcpaths" select="collection()[/*:hub]" />
 
  <xsl:variable name="collected-messages" as="element(tr:message)*">
    <xsl:apply-templates select="$report//c:error[@*]" mode="collect-messages"/>
    <xsl:apply-templates select="$report//svrl:text[parent::svrl:successful-report | parent::svrl:failed-assert]"
      mode="collect-messages"/>
  </xsl:variable>
  
  <xsl:key name="message-by-srcpath" match="tr:message" use="@srcpath" />

 <xsl:template match="/" mode="docx2hub:modify">
   <xsl:copy>
     <xsl:apply-templates mode="#current"/>
   </xsl:copy>
 </xsl:template>
  
  <xsl:template match="*[@srcpath]" mode="docx2hub:modify">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="key('message-by-srcpath',@srcpath, $messages-grouped-by-type)">
        <xsl:processing-instruction name="docx_modify_docVar_bookmark">
          <xsl:value-of select="concat('ltx_schematron ', replace(key('message-by-srcpath',@srcpath, $messages-grouped-by-type)/@type,' ','_'))"/>
        </xsl:processing-instruction>
        <xsl:processing-instruction name="docx_modify_docVar">
          <xsl:value-of select="concat('ltx_schematron ', replace(key('message-by-srcpath',@srcpath, $messages-grouped-by-type)/@type,' ','_'))"/>
        </xsl:processing-instruction>
      </xsl:if>
      <xsl:next-match/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[processing-instruction()[name() = 'docx_modify_docVar_bookmark']]" mode="docx2hub:export">
    <xsl:param name="max-bookmark-id" as="xs:integer" tunnel="yes"/>
    <xsl:param name="new-docVars" tunnel="yes" as="element(w:docVar)*"/>
    <xsl:variable name="pi" as="processing-instruction(docx_modify_docVar_bookmark)+" 
      select="processing-instruction()[name() = 'docx_modify_docVar_bookmark']"/>
    <xsl:for-each select="$pi">
      <xsl:variable name="matching-docVar" select="$new-docVars[@genId = generate-id(current())]" as="element(w:docVar)"/>
      <xsl:variable name="num" as="xs:integer" select="$max-bookmark-id + xs:integer($matching-docVar/@_pos)"/>
      <w:bookmarkStart w:id="{$num}" w:name="{$matching-docVar/@w:name}"/> 
    </xsl:for-each>
    <xsl:next-match/>
    <xsl:for-each select="reverse($pi)">
      <xsl:variable name="matching-docVar" select="$new-docVars[@genId = generate-id(current())]" as="element(w:docVar)"/>
      <xsl:variable name="num" as="xs:integer" select="$max-bookmark-id + xs:integer($matching-docVar/@_pos)"/>
      <w:bookmarkEnd w:id="{$num}"/> 
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>