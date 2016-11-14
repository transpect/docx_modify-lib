<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:tr="http://transpect.io"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  exclude-result-prefixes="tr xs w" 
  version="2.0">

  <xsl:import href="http://transpect.io/xslt-util/hex/xsl/hex.xsl"/>

  <xsl:param name="media-path" as="xs:string?"/>

  <xsl:template match="/c:zip-manifest" mode="update-zip-manifest">
    <xsl:copy>
      <xsl:apply-templates 
        select="@*,
                collection()
                  /w:root
                    //c:file[@status eq 'modified-or-new-and-written-to-sys'
                             or
                             (
                               not($media-path='none')
                               and
                               @status eq 'external-media-file'
                             )],
                collection()[1]
                  /c:zip-manifest
                    /c:entry[not(@name = (for $n in collection()/w:root//c:file/@name
                                          return tr:unescape-uri($n)))]" 
        mode="#current" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="base-uri" select="base-uri(/*)" as="xs:string"/>
  
  <xsl:template match="c:entry | @*" mode="update-zip-manifest">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="c:file" mode="update-zip-manifest">
    <xsl:variable name="path-prefix" as="xs:string?" select="concat('file:/', replace($media-path, '^file:/+', ''))"/>
    <c:entry name="{tr:unescape-uri(@name)}" 
      href="{if ((@status eq 'external-media-file')) 
             then concat($path-prefix, replace(@name, '^word/media/', '')) 
             else concat($base-uri, @name)}" 
      compression-method="deflate" compression-level="default"/>
  </xsl:template>

</xsl:stylesheet>
