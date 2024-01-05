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
  <xsl:import href="http://transpect.io/xslt-util/num/xsl/num.xsl"/>
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
        <xsl:for-each select="key('message-by-srcpath',@srcpath, $messages-grouped-by-type)">
          <xsl:message select="current()"></xsl:message>
          <xsl:processing-instruction name="docx_modify_docVar_bookmark">
            <xsl:value-of select="concat('ltx_schematron ', replace(current()/@type,' ','_'))"/>
          </xsl:processing-instruction>
          <xsl:processing-instruction name="docx_modify_docVar">
            <xsl:value-of select="concat('ltx_schematron ', replace(current()/@type,' ','_'), ' §$$§ ', string-join(current()/svrl:text/text()/normalize-space(),' ') ,' §$$§ ToDO:', string-join(current()/svrl:text/span[@class='todo'],''))"/>
          </xsl:processing-instruction>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
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
  
  <xsl:function name="tr:pad" as="xs:string">
    <xsl:param name="string"     as="xs:string"/>
    <xsl:param name="width"     as="xs:integer"/>
    <xsl:sequence select="string-join((for $i in (string-length($string) to $width - 1) return '0', $string), '')"/>
  </xsl:function>
  
  <xsl:template match="processing-instruction()[name() = ('docx_modify_docVar', 'docx_modify_docVar_bookmark')]" mode="docx2hub:postprocess">
    <xsl:param name="genIds" as="xs:string*" tunnel="yes"/>
    <xsl:variable name="pos" select="index-of($genIds, generate-id())" as="xs:integer?"/>
    <xsl:variable name="context" as="processing-instruction()" select="."/>
    <xsl:analyze-string select="." regex="^\s*(\i\c*)\s+(.+)$">
      <xsl:matching-substring>
        <w:docVar w:name="{string-join((regex-group(1), string(tr:pad(xs:string(($pos,'0')[1]),5))[normalize-space()]), '_')}" w:val="{regex-group(2)}">
          <xsl:if test="name($context) = 'docx_modify_docVar_bookmark'">
            <xsl:attribute name="genId" select="generate-id($context)"/>
            <xsl:attribute name="_pos" select="tr:pad(xs:string(($pos,'0')[1]),5)"/>
          </xsl:if>
        </w:docVar>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <w:docVar w:name="invalid_docVarName" w:val="{.}"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
</xsl:stylesheet>