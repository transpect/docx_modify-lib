<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
  xmlns:ep="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  exclude-result-prefixes="xs docx2hub"
  version="2.0">

  <xsl:template match="w:root" mode="docx2hub:modify">
    <xsl:param name="new-comments" as="element(w:comment)*" tunnel="yes"/>
    <xsl:param name="new-content" as="element(*)*" tunnel="yes"/>
    <xsl:variable name="comments" as="element(w:comments)?">
      <w:comments>
        <xsl:attribute name="xml:base" select="''"/>
        <xsl:apply-templates select="$new-comments, w:comments/w:comment" mode="#current"/>
      </w:comments>
    </xsl:variable>
    <xsl:next-match>
      <xsl:with-param name="new-content" select="$new-content, $comments"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template match="w:comments" mode="docx2hub:modify"/>

</xsl:stylesheet>