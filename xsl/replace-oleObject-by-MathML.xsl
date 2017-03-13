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
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  exclude-result-prefixes="xs rel docx2hub c"
  version="2.0">

  <xsl:include href="identity.xsl"/>
  <xsl:include href="path/to/hub2docx/xsl/omml/mml2omml.xsl"/>

  <xsl:template match="w:object[o:OLEObject]" mode="docx2hub:modify">
    <xsl:variable name="mathml-filepath" as="xs:string"
      select="concat('/data/sandbox/pglatza/docx-splitter-frontend/test/mathml/', replace(//*:docRels//*:Relationship[@Id = current()/o:OLEObject/@r:id]/@Target, '^embeddings/(oleObject\d+).bin$', '$1.mml'))"/>
    
    <xsl:message select="$mathml-filepath, 'available?', doc-available( $mathml-filepath )"/>
    <xsl:variable name="mathml">
      <xsl:apply-templates select="doc($mathml-filepath)" mode="add-mml-namespace"/>
    </xsl:variable>
    <xsl:if test="not(ends-with(preceding::w:t[1], '&#x20;'))">
      <w:r>
        <w:t xml:space="preserve"><xsl:text>&#x20;</xsl:text></w:t>
      </w:r>
    </xsl:if>
    <m:oMath>
      <xsl:apply-templates select="$mathml" mode="mml"/>
    </m:oMath>
    <xsl:if test="not(starts-with(following::w:t[1], '&#x20;'))">
      <w:r>
        <w:t xml:space="preserve"><xsl:text>&#x20;</xsl:text></w:t>
      </w:r>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:r[every $n in node() satisfies $n[self::w:rPr or self::w:object[o:OLEObject]]]" mode="docx2hub:modify">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  <xsl:template match="w:r[every $n in node() satisfies $n[self::w:rPr or self::w:object[o:OLEObject]]]/w:rPr" mode="docx2hub:modify"/>
  
  <xsl:template match="*" mode="add-mml-namespace">
    <xsl:element name="{local-name()}" xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*" mode="add-mml-namespace">
    <xsl:copy/>
  </xsl:template>
  
</xsl:stylesheet>
