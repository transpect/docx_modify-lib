<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm" 
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  xmlns:din="http://din.de/namespace"
  xmlns:letex="http://www.le-tex.de/namespace" 
  version="1.0"
  name="docx_modify"
  type="docx2hub:modify"
  >
  
  <p:option name="file" required="true"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  
  <p:input port="xslt"/>
  <p:output port="result" primary="true" />
  <p:serialization port="result" indent="true" omit-xml-declaration="false"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/xslt-mode/xslt-mode.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl" />
  <p:import href="http://transpect.le-tex.de/calabash-extensions/ltx-lib.xpl" />
  
  <p:variable name="result" select="replace($file, '\.docx$', 'mod.docx')"/>
  <p:variable name="basename" select="replace($file, '^(.+?)([^/\\]+)\.docx$', '$2')"/>
  
  <letex:unzip name="proto-unzip">
    <p:with-option name="zip" select="$file" />
    <p:with-option name="dest-dir" select="concat($file, '.tmp')"><p:empty/></p:with-option>
    <p:with-option name="overwrite" select="'yes'" />
  </letex:unzip>
  
  <p:xslt name="unzip">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:template match="* |@*">
            <xsl:copy>
              <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="@name">
            <xsl:attribute name="name" select="replace(replace(., '\[', '%5B'), '\]', '%5D')"/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
  </p:xslt>
  
  <letex:store-debug>
    <p:with-option name="pipeline-step" select="concat('docx2hub/', $basename, '00.file-list')"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
  
  <p:for-each name="copy">
    <p:iteration-source select="/c:files/c:file"/>
    <p:variable name="base-dir" select="/c:files/@xml:base">
      <p:pipe port="result" step="unzip"/>
    </p:variable>
    <p:variable name="new-dir" select="replace($base-dir, '\.docx\.tmp', '.docx.out')"/>
    <p:variable name="name" select="/*/@name">
      <p:pipe port="current" step="copy"/>
    </p:variable>
    <cxf:mkdir>
      <p:with-option name="href" select="concat($new-dir, string-join(tokenize($name, '/')[position() lt last()], '/'))"/>
    </cxf:mkdir>
    <cxf:copy>
      <p:with-option name="href" select="concat($base-dir, $name)"/>
      <p:with-option name="target" select="concat($new-dir, $name)"/>
    </cxf:copy>
  </p:for-each>
  
  <p:load name="document">
    <p:with-option name="href" select="concat(/c:files/@xml:base, 'word/document.xml')" >
      <p:pipe port="result" step="unzip"/>
    </p:with-option>
  </p:load>
  
  <p:sink/>
  
  <p:add-attribute  name="params" attribute-name="value" match="/c:param-set/c:param[@name = 'error-msg-file-path']">
    <p:with-option name="attribute-value" select="replace( static-base-uri(), '/wml2hub.xpl', '' )"/>
    <p:input port="source">
      <p:inline>
        <c:param-set>
          <c:param name="srcpaths" value="no"/>
          <c:param name="error-msg-file-path"/>
          <c:param name="hub-version" value="1.1"/>
          <c:param name="unwrap-tooltip-links" value="no"/>
        </c:param-set>
      </p:inline>
    </p:input>
  </p:add-attribute>
  
  <p:sink/>
  
  <letex:xslt-mode msg="yes" mode="insert-xpath">
    <p:input port="source"><p:pipe step="document" port="result" /></p:input>
    <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
    <p:input port="stylesheet"><p:document href="http://transpect.le-tex.de/docx2hub/main.xsl"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="prefix" select="concat('docx2hub/', $basename, '/01')"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-param name="srcpaths" select="'no'"/>
  </letex:xslt-mode>
  
  <letex:xslt-mode msg="yes" mode="default">
    <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
    <p:input port="stylesheet"><p:pipe port="xslt" step="docx_modify"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="prefix" select="concat('docx_modify/', $basename, '/1')"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-param name="srcpaths" select="'no'"/>
  </letex:xslt-mode>

  <letex:xslt-mode msg="yes" mode="modify">
    <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
    <p:input port="stylesheet"><p:pipe port="xslt" step="docx_modify"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="prefix" select="concat('docx_modify/', $basename, '/3')"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-param name="srcpaths" select="'no'"/>
  </letex:xslt-mode>
  
  <letex:xslt-mode msg="yes" mode="export" name="export">
    <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
    <p:input port="stylesheet"><p:pipe port="xslt" step="docx_modify"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="prefix" select="concat('docx_modify/', $basename, '/9')"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-param name="srcpaths" select="'no'"/>
  </letex:xslt-mode>
  
  <p:sink/>
  
  <p:xslt name="zip-manifest">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="source">
      <p:pipe port="result" step="unzip"/>
      <p:pipe port="result" step="export">
        <p:documentation>Just in order to get the dependency graph correct. 
          (Zip might start prematurely otherwise.)</p:documentation>
      </p:pipe>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:template match="c:files">
            <c:zip-manifest>
              <xsl:apply-templates/>
            </c:zip-manifest>
          </xsl:template>
          <xsl:variable name="base-uri" select="replace(/*/@xml:base, '\.docx\.tmp', '.docx.out')" as="xs:string"/>
          <xsl:template match="c:file">
            <c:entry name="{replace(replace(@name, '%5B', '['), '%5D', ']')}" href="{concat($base-uri, @name)}" compression-method="deflate" compression-level="default"/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <letex:store-debug>
    <p:with-option name="pipeline-step" select="concat('docx_modify/', $basename, '/zip-manifest')"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
  
  <p:exec command="sleep" args="6" result-is-xml="false"/>
  
  <p:sink/>
  
  <cx:zip compression-method="deflated" compression-level="default" command="create" name="zip">
    <p:with-option name="href" select="replace(/c:files/@xml:base, '\.docx\.tmp/?$', '.mod.docx')" >
      <p:pipe port="result" step="unzip"/>
    </p:with-option>
    <p:input port="source"><p:empty/></p:input>
    <p:input port="manifest">
      <p:pipe step="zip-manifest" port="result"/>
    </p:input>
  </cx:zip>
  
  
  
</p:declare-step>