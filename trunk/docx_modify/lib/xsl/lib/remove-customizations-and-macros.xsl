<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
  xmlns:ep="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  exclude-result-prefixes="xs docx2hub"
  version="2.0">

  <xsl:template match="@* | *" mode="docx2hub:modify">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>


  <xsl:function name="docx2hub:docrel-ids" as="xs:string*">
    <xsl:param name="doc" as="document-node(element(w:root))"/>
    <!-- Not just paragraphs, but any element below w:body. 
      Typically, you submit $doc/w:root/w:document/w:body/*, but you can restrict it 
      if you only want the docrels only for a specific section of the whole docx file: -->
    <xsl:param name="specific-paragraphs" as="element(*)*"/>
    <xsl:sequence select="$doc/w:root/w:docRels/rel:Relationships/rel:Relationship[
                            not(@Type = ('http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
                                         'http://schemas.microsoft.com/office/2006/relationships/vbaProject',
                                         'http://schemas.microsoft.com/office/2006/relationships/keyMapCustomizations',
                                         'http://schemas.microsoft.com/office/2007/relationships/stylesWithEffects',
                                         'http://schemas.microsoft.com/office/2006/relationships/ui/extensibility'))
                          ]/@Id,
                          distinct-values($specific-paragraphs/descendant::a:blip/@r:embed)" />
  </xsl:function> 

  <xsl:function name="docx2hub:containerrel-ids" as="xs:string*">
    <xsl:param name="doc" as="document-node(element(w:root))"/>
    <xsl:sequence select="$doc/w:root/w:containerRels/rel:Relationships/rel:Relationship[
                            not(@Type = ('http://schemas.microsoft.com/office/2006/relationships/ui/extensibility'))
                          ]/@Id" />
  </xsl:function> 

  <xsl:template match="w:docRels/rel:Relationships/rel:Relationship" 
    mode="docx2hub:modify docx2hub:remove-customizations-and-macros">
    <xsl:param name="docrel-ids" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="@Id = $docrel-ids">
          <xsl:attribute name="Id" select="concat('rId', index-of($docrel-ids, @Id))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="remove-resource" select="'yes'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="@* except @Id"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:containerRels/rel:Relationships/rel:Relationship" 
    mode="docx2hub:modify docx2hub:remove-customizations-and-macros">
    <xsl:param name="containerrel-ids" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="@Id = $containerrel-ids">
          <xsl:attribute name="Id" select="concat('rId', index-of($containerrel-ids, @Id))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="remove-resource" select="'yes'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="@* except @Id"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="a:blip/@r:embed | @r:id" mode="docx2hub:modify docx2hub:remove-customizations-and-macros">
    <xsl:param name="docrel-ids" as="xs:string*" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="concat('rId', index-of($docrel-ids, .))"/>
  </xsl:template>

  <xsl:template match="ct:Types/ct:Default[@ContentType = ('application/vnd.ms-office.vbaProject')]" 
    mode="docx2hub:modify docx2hub:remove-customizations-and-macros"/>
  
  <xsl:template match="ct:Types/ct:Override/@ContentType[. = ('application/vnd.ms-word.stylesWithEffects+xml',
                                                              'application/vnd.ms-word.vbaData+xml',
                                                              'application/vnd.ms-office.vbaProjectSignature',
                                                              'application/vnd.ms-word.keyMapCustomizations+xml',
                                                              'application/vnd.ms-word.attachedToolbars')]" 
                mode="docx2hub:modify">
    <xsl:copy/>
    <xsl:attribute name="remove-resource" select="'yes'"/>
  </xsl:template>
  
  <xsl:template match="ct:Types/ct:Override/@ContentType[. = 'application/vnd.ms-word.document.macroEnabled.main+xml']"
                mode="docx2hub:modify docx2hub:remove-customizations-and-macros">
    <xsl:attribute name="{name()}" select="'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'"/>
  </xsl:template>

  <xsl:template match="w:containerProps/ep:Properties/ep:Template" 
    mode="docx2hub:modify docx2hub:remove-customizations-and-macros">
    <xsl:copy>
      <xsl:value-of select="replace(., '\.dotm$', '.dotx')"/>  
    </xsl:copy>
  </xsl:template>
      
</xsl:stylesheet>