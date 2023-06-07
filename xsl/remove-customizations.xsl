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
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:hub="http://transpect.io/hub"
  exclude-result-prefixes="xs rel docx2hub c hub"
  version="2.0">

  <!-- This stylesheet removes relationships to any customizations in your docx.
       Modifying your docx so shows the MS Word ribbon bar and turns of macros.
       The custom files will stay in your docx, for a later use. -->
  
  <xsl:import href="identity.xsl"/>

  <xsl:template match="w:docTypes/ct:Types/ct:Override[@PartName[ends-with(., 'customizations.xml')]]" mode="docx2hub:modify"/>
  
  <xsl:template match="w:containerRels/rel:Relationships/rel:Relationship[@Type = 'http://schemas.microsoft.com/office/2006/relationships/ui/extensibility']" mode="docx2hub:modify"/>
  
  <xsl:template match="w:docRels/rel:Relationships/rel:Relationship[@Type = 'http://schemas.microsoft.com/office/2006/relationships/keyMapCustomizations']" mode="docx2hub:modify"/>
</xsl:stylesheet>
