<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  exclude-result-prefixes="xs rel docx2hub"
  version="2.0">
  
  <xsl:param name="debug" select="'no'"/>
  
  <xsl:param name="out-dir-replacement" select="'.docx.out/'"/>
  <xsl:param name="media-path" select="'none'"/>
  
  <xsl:template match="* | @*" mode="docx2hub:identity docx2hub:modify docx2hub:export">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="docx2hub:modify">
    <xsl:attribute name="{name()}" 
      select="if($out-dir-replacement eq '.docx.out/') 
              then replace(., '\.doc([xm]).tmp/', '.doc$1.out/')
              else replace(., '\.doc[xm].tmp/', $out-dir-replacement)"/>
  </xsl:template>

  <xsl:template match="w:root" mode="docx2hub:export" priority="2">
    <xsl:param name="new-content" as="element(*)*" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <c:files>
        <xsl:apply-templates select="node()" mode="#current"/>
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
    <xsl:copy>
      <xsl:apply-templates select="@*, * except w:docVars" mode="#current"/>
      <xsl:variable name="new-docVars" as="element(w:docVar)*">
        <xsl:apply-templates select="//processing-instruction()[name() = 'docx_modify_docVar']" mode="docx2hub:postprocess"/>
      </xsl:variable>
      <w:docVars>
        <xsl:for-each-group select="w:docVars/w:docVar, $new-docVars" group-by="@w:name">
          <xsl:copy>
            <xsl:for-each select="current-group()[last()]">
              <xsl:copy-of select="@w:name, @w:val"/>
            </xsl:for-each>
          </xsl:copy>
        </xsl:for-each-group>
      </w:docVars>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="processing-instruction()[name() = 'docx_modify_docVar']" mode="docx2hub:postprocess">
    <xsl:analyze-string select="." regex="^\s*(\i\c*)\s+(.+)$">
      <xsl:matching-substring>
        <w:docVar w:name="{regex-group(1)}" w:val="{regex-group(2)}"/>    
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <w:docVar w:name="invalid_docVarName" w:val="{.}"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="w:root/*[descendant-or-self::rel:Relationship[@Type[matches(.,'image$')]]][not($media-path='none')]" mode="docx2hub:export" priority="2.5">
    <xsl:for-each select="descendant-or-self::rel:Relationship[@Type[matches(.,'image$')]]/@Target">
      <c:file xmlns="http://www.w3.org/ns/xproc-step" 
        status="external-media-file"
        name="{if (matches(., '^media')) then concat('word/', .) else concat('word/media/', .)}" />  
    </xsl:for-each>
    <xsl:next-match/>
  </xsl:template>
  
</xsl:stylesheet>
