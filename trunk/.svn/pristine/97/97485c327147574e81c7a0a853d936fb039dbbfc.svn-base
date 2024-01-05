<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  xmlns:css="http://www.w3.org/1996/css"
  exclude-result-prefixes="xs docx2hub css"
  version="2.0">
  
  <xsl:import href="http://transpect.io/docx2hub/xsl/main.xsl"/>
  <xsl:import href="http://transpect.io/docx_modify/xsl/identity.xsl"/>
  
  <xsl:variable name="allowed-unicode-regex" select="'[&#x0020;-&#x007e;]|[&#x00a0;-&#x04ff;]|[&#x0590;-&#x05ff;]|[&#x0600;-&#x06ff;]|[&#x0900;-&#x097f;]|[&#x0980;-&#x09ff;]|[&#x0a00;-&#x0A7f;]|[&#x0e00;-&#x0E7f;]|[&#x1100;-&#x11ff;]|[&#x1e00;-&#x202d;]|[&#x202f;-&#x206f;]|[&#x2190;-&#x2b7f;]|[&#x3000;-&#x303f;]|[&#x3040;-&#x30ff;]|[&#x3130;-&#x318f;]|[&#x4e00;-&#x9fff;]|[&#xac00;-&#xd7af;]|[&#x900;-&#xfaff;]|[&#xfb50;-&#xfdff;]|[&#xfe70;-&#xfeff;]|[&#x1d400;-&#x1d7ff;]'"/>
  
  <xsl:template match="w:t" mode="docx2hub:modify">
    <xsl:variable name="context" select="."/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:analyze-string select="." regex="{$allowed-unicode-regex}">
        <xsl:matching-substring>
          <xsl:value-of select="."/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
<!--          <xsl:call-template name="signal-error">
           <xsl:with-param name="hash">
                    <value key="xpath"><xsl:value-of select="$context/(@srcpath, ancestor::*[@srcpath][1]/@srcpath)[1]"/></value>
                    <value key="level">WRN</value>
                    <value key="info-text"><xsl:value-of select="concat('Not allowed unicode character used' , .)"/></value>
                    <value key="pi">Not allowed unicode character used <xsl:value-of select="."/></value>
                    <value key="comment"/>
                  </xsl:with-param>
          </xsl:call-template>-->
          <xsl:processing-instruction name="docx_modify_docVar_bookmark">
            <xsl:value-of select="concat('ltx_unicode  Not allowed unicode character used ' , .)"/>
          </xsl:processing-instruction>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>
