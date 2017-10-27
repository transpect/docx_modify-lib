<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
  xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid"
  xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex" xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
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

  <xsl:import href="http://transpect.io/hub2docx/xsl/omml/mml2omml.xsl"/>

  <xsl:param name="mathtype2omml" select="'no'"/>

  <xsl:template match="* | @*" mode="docx2hub:mml2omml">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="w:r[w:object[mml:math]]" mode="docx2hub:mml2omml">
    <m:oMath>
      <xsl:apply-templates select="w:object/mml:math" mode="mml"/>
    </m:oMath>
  </xsl:template>
</xsl:stylesheet>
