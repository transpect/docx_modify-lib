<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
  xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex" xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  exclude-result-prefixes="xs rel docx2hub c"
  version="2.0">

  <xsl:param name="debug" select="'no'"/>
  
  <xsl:param name="out-dir-replacement" select="'.docx.out/'"/>
  <xsl:param name="media-path" select="'none'"/>

  <!-- If there is a template single-tree document, we’ll automatically use its styles etc. -->
  <xsl:variable name="template-root" as="document-node(element(w:root))?" select="(collection()[w:root])[2]"/>

  <xsl:template match="* | @*" mode="docx2hub:identity docx2hub:modify docx2hub:export docx2hub:template">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- mode docx2hub:modify / docx2hub:template
       Merge with template styles if template is present -->

  <xsl:template match="w:root[exists($template-root)]" mode="docx2hub:modify">
    <xsl:next-match>
      <xsl:with-param name="max-abstractNumId" as="xs:integer" tunnel="yes"
        select="xs:integer((max(w:numbering/w:abstractNum/@w:abstractNumId), 0)[1])"/>
      <xsl:with-param name="max-numId" as="xs:integer" tunnel="yes"
        select="xs:integer((max(w:numbering/w:num/@w:numId), 0)[1])"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template match="w:styles[exists($template-root)]" mode="docx2hub:modify">
    <xsl:param name="max-abstractNumId" as="xs:integer" tunnel="yes"/>
    <xsl:param name="max-numId" as="xs:integer" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="$template-root/w:root/w:styles/*" mode="docx2hub:template">
        <xsl:with-param name="max-abstractNumId" as="xs:integer" tunnel="yes" select="$max-abstractNumId"/>
        <xsl:with-param name="max-numId" as="xs:integer" tunnel="yes" select="$max-numId"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@w:numId | w:numId/@w:val" mode="docx2hub:template">
    <xsl:param name="max-numId" as="xs:integer" tunnel="yes"/>
    <xsl:attribute name="{name()}" select=". + $max-numId"></xsl:attribute>    
  </xsl:template>

  <xsl:template match="@w:numId[. = '0'] | w:numId/@w:val[. = '0']" mode="docx2hub:template">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="@w:abstractNumId | w:abstractNumId/@w:val" mode="docx2hub:template">
    <xsl:param name="max-abstractNumId" as="xs:integer" tunnel="yes"/>
    <xsl:attribute name="{name()}" select=". + $max-abstractNumId"/>    
  </xsl:template>
  
  <xsl:template match="w:numbering[exists($template-root)]" mode="docx2hub:modify">
    <xsl:param name="max-abstractNumId" as="xs:integer" tunnel="yes"/>
    <xsl:param name="max-numId" as="xs:integer" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:comment> Document abstract numberings: </xsl:comment>
      <xsl:apply-templates select="w:abstractNum" mode="#current"/>
      <xsl:comment> Template abstract numberings: </xsl:comment>
      <xsl:apply-templates select="$template-root/w:root/w:numbering/w:abstractNum" mode="docx2hub:template">
        <xsl:with-param name="max-abstractNumId" as="xs:integer" tunnel="yes" select="$max-abstractNumId"/>
      </xsl:apply-templates>
      <xsl:comment> Document numberings: </xsl:comment>
      <xsl:apply-templates select="w:num" mode="#current"/>
      <xsl:comment> Template numberings: </xsl:comment>
      <xsl:apply-templates select="$template-root/w:root/w:numbering/w:num" mode="docx2hub:template">
        <xsl:with-param name="max-abstractNumId" as="xs:integer" tunnel="yes" select="$max-abstractNumId"/>
        <xsl:with-param name="max-numId" as="xs:integer" tunnel="yes" select="$max-numId"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!-- mode docx2hub:export -->

  <xsl:template match="@xml:base[not(../@mc:Ignorable)][matches(.,'word/\w+\.xml$')]" mode="docx2hub:export">
    <xsl:attribute name="mc:Ignorable" select="'w14 w15 wp14 w16se'"/>
  </xsl:template>
  
  <xsl:template match="@xml:base"  mode="docx2hub:export"/>
  
  <xsl:template match="w:root" mode="docx2hub:export" priority="2">
    <xsl:param name="new-content" as="element(*)*" tunnel="yes"/>
    <xsl:variable name="bookmark-PI-genIds" as="xs:string*"
      select="for $pi in //processing-instruction()[name() = 'docx_modify_docVar_bookmark'] return generate-id($pi)"/>
    <xsl:variable name="new-docVars" as="element(w:docVar)*">
      <xsl:apply-templates select="//processing-instruction()[name() = ('docx_modify_docVar', 'docx_modify_docVar_bookmark')]"
        mode="docx2hub:postprocess">
        <xsl:with-param name="genIds" as="xs:string*" tunnel="yes" select="$bookmark-PI-genIds"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <c:files>
        <xsl:apply-templates select="node()" mode="#current">
          <xsl:with-param name="new-docVars" select="$new-docVars" tunnel="yes"/>
          <xsl:with-param name="max-bookmark-id" as="xs:integer" tunnel="yes" 
            select="xs:integer(max((-1, for $id in (for $b in //w:bookmarkStart/@w:id return tokenize($b,'\s+')) return number($id))))"/>
        </xsl:apply-templates>
        <xsl:sequence select="$new-content"/>
      </c:files>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[rel:Relationships] | w:docTypes" mode="docx2hub:export" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[@xml:base]" mode="docx2hub:export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
    <c:file xmlns="http://www.w3.org/ns/xproc-step" 
      status="modified-or-new-and-written-to-sys"
      name="{if(contains(@xml:base, 'word/_rels/')) 
             then replace(@xml:base, '^.+/(word/_rels/.+)$', '$1') 
             else replace(@xml:base, '^((/word/)|.)+?/((%5BContent_Types|word|_rels|docProps).*)$', '$3')}" />
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="docx2hub:export"/>

  <!-- create docVars from processing instructions named 'docx_modify_docVar'.
    Example <?docx_modify_docVar name value string?> → <w:docVar w:name="name" w:val="value string"/> 
    Please note that w:settings has an @xml:base attribute. The template matching *[xml:base] has higher priority. -->
  <xsl:template match="w:settings" mode="docx2hub:export">
    <xsl:param name="new-docVars" as="element(w:docVar)*" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, * except w:docVars" mode="#current"/>
      <xsl:if test="exists(w:docVars/w:docVar | $new-docVars)">
        <w:docVars>
          <xsl:for-each-group select="w:docVars/w:docVar, $new-docVars" group-by="@w:name">
            <xsl:copy>
              <xsl:for-each select="current-group()[last()]">
                <xsl:copy-of select="@w:name, @w:val"/>
              </xsl:for-each>
            </xsl:copy>
          </xsl:for-each-group>
        </w:docVars>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:r[w:t[processing-instruction()[name() = 'docx_modify_docVar_bookmark']]]" mode="docx2hub:export">
    <xsl:param name="max-bookmark-id" as="xs:integer" tunnel="yes"/>
    <xsl:param name="new-docVars" tunnel="yes" as="element(w:docVar)*"/>
    <xsl:variable name="pi" as="processing-instruction(docx_modify_docVar_bookmark)+" 
      select="w:t/processing-instruction()[name() = 'docx_modify_docVar_bookmark']"/>
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
  
  <xsl:template match="processing-instruction()[name() = ('docx_modify_docVar', 'docx_modify_docVar_bookmark')]" mode="docx2hub:export"/>

  <xsl:template match="processing-instruction()[name() = ('docx_modify_docVar', 'docx_modify_docVar_bookmark')]" mode="docx2hub:postprocess">
    <xsl:param name="genIds" as="xs:string*" tunnel="yes"/>
    <xsl:variable name="pos" select="index-of($genIds, generate-id())" as="xs:integer?"/>
    <xsl:variable name="context" as="processing-instruction()" select="."/>
    <xsl:analyze-string select="." regex="^\s*(\i\c*)\s+(.+)$">
      <xsl:matching-substring>
        <w:docVar w:name="{string-join((regex-group(1), string($pos)[normalize-space()]), '_')}" w:val="{regex-group(2)}">
          <xsl:if test="name($context) = 'docx_modify_docVar_bookmark'">
            <xsl:attribute name="genId" select="generate-id($context)"/>
            <xsl:attribute name="_pos" select="$pos"/>
          </xsl:if>
        </w:docVar>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <w:docVar w:name="invalid_docVarName" w:val="{.}"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="@genId | @_pos" mode="docx2hub:export"/>
  
  <xsl:template match="w:root/*[descendant-or-self::rel:Relationship[@Type[matches(.,'image$')]]][not($media-path='none')]" mode="docx2hub:export" priority="2.5">
    <xsl:for-each select="descendant-or-self::rel:Relationship[@Type[matches(.,'image$')]]/@Target">
      <c:file xmlns="http://www.w3.org/ns/xproc-step" 
        status="external-media-file"
        name="{if (matches(., '^media')) then concat('word/', .) else concat('word/media/', .)}" />  
    </xsl:for-each>
    <xsl:next-match/>
  </xsl:template>
  
</xsl:stylesheet>
