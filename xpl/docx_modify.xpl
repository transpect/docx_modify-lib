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
  
  <p:option name="file" required="true">
    <p:documentation>As required by docx2hub</p:documentation>
  </p:option>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  
  <p:input port="xslt">
    <p:documentation>XSLT that transforms the compound OOXML document (all files assembled below a single w:root element,
      as produced by the step named 'insert-xpath') to a target compound document. The stylesheet may of course import
    other stylesheets or use multiple passes in different modes. In order to facilitate this common processing pattern,
    an XProc pipeline may also be supplied for the compound→compound transformation part. This pipeline will be dynamically
    executed by this pipeline. Please note that your stylesheet must use named modes if you are using an letex:xslt-mode 
    pipeline.
    Please also note that if your pipeline/stylesheet don't have a pass in docxhub:modify mode, they need to match @xml:base
    in any of the other modifying modes and apply-templates to it in mode docxhub:modify.</p:documentation>
  </p:input>
  <p:input port="xpl">
    <p:document href="single-pass_modify.xpl"/>
    <p:documentation>See the 'xslt' port’s documentation. You may supply another pipeline that will be executed instead of 
      the default single-pass modify pipeline. You pipeline typically consists of chained transformations in different modes, as invoked by 
    letex:xslt-mode. Of course you can supply other pipelines with the same signature (single w:root input/output documents).</p:documentation>
  </p:input>
  <p:input port="params" kind="parameter" primary="true">
    <p:documentation>Arbitrary parameters that will be passed to the dynamically executed pipeline.</p:documentation>
  </p:input>
  <p:input port="external-sources" sequence="true">
    <p:documentation>Arbitrary source XML. Example: Hub XML that is transformed to OOXML and then patched into the
    expanded docx template.</p:documentation>
  </p:input>
  <p:input port="options">
    <p:documentation>Options to the modifying XProc pipeline.</p:documentation>
  </p:input>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/xslt-mode/xslt-mode.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl" />
  <p:import href="http://transpect.le-tex.de/calabash-extensions/ltx-lib.xpl" />
  
  <p:variable name="basename" select="replace($file, '^(.+?)([^/\\]+)\.docx$', '$2')"/>

  <p:parameters name="consolidate-params">
    <p:input port="parameters">
      <p:pipe port="params" step="docx_modify"/>
    </p:input>
  </p:parameters>

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
  
  <p:add-attribute name="params" attribute-name="value" match="/c:param-set/c:param[@name = 'error-msg-file-path']">
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
  
  <letex:xslt-mode msg="yes" mode="insert-xpath" name="compound-document">
    <p:input port="source"><p:pipe step="document" port="result" /></p:input>
    <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
    <p:input port="stylesheet"><p:document href="http://transpect.le-tex.de/docx2hub/main.xsl"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="prefix" select="concat('docx2hub/', $basename, '/01')"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-param name="srcpaths" select="'no'"/>
  </letex:xslt-mode>
  
  <p:wrap wrapper="cx:document" match="/">
    <p:input port="source">
      <p:pipe step="compound-document" port="result"/>
    </p:input>
  </p:wrap>
  <p:add-attribute name="docx-source" attribute-name="port" attribute-value="source" match="/*"/>
  
  <p:sink/>
  
  <p:for-each name="wrap-external-sources">
    <p:iteration-source>
      <p:pipe step="docx_modify" port="external-sources"/>
    </p:iteration-source>
    <p:output port="result" primary="true"/>
    <p:wrap wrapper="cx:document" match="/"/>
    <p:add-attribute attribute-name="port" attribute-value="source" match="/*"/>
  </p:for-each>
  
  <p:sink/>
  
  <p:wrap wrapper="cx:document" match="/">
    <p:input port="source">
      <p:pipe port="xslt" step="docx_modify"/>
    </p:input>
  </p:wrap>
  <p:add-attribute name="stylesheet" attribute-name="port" attribute-value="stylesheet" match="/*"/>
  
  <p:sink/>
  
  <p:wrap wrapper="cx:document" match="/">
    <p:input port="source">
      <p:pipe step="consolidate-params" port="result"/>
    </p:input>
  </p:wrap>
  <p:add-attribute name="parameters" attribute-name="port" attribute-value="parameters" match="/*"/>
  
  <p:sink/>
  
  <p:xslt name="options" template-name="main">
    <p:documentation>Options for the dynamically executed pipeline. You may supply additional
    options using a cx:options document with cx:option name/value entries.</p:documentation>
    <p:with-param name="file" select="$file"/>
    <p:with-param name="debug" select="$debug"/>
    <p:with-param name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="source">
      <p:pipe step="docx_modify" port="options"/> 
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:param name="file" as="xs:string"/>
          <xsl:param name="debug" as="xs:string"/>
          <xsl:param name="debug-dir-uri" as="xs:string"/>
          <xsl:template name="main">
            <cx:options>
              <cx:option name="debug" value="{$debug}"/>
              <cx:option name="debug-dir-uri" value="{$debug-dir-uri}"/>
              <cx:option name="file" value="{$file}"/>
              <xsl:sequence select="collection()/cx:options/cx:option"/>
            </cx:options>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <cx:eval name="modify" detailed="true">
    <p:input port="pipeline">
      <p:pipe port="xpl" step="docx_modify"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="stylesheet"/>
      <p:pipe port="result" step="docx-source"/>
      <p:pipe port="result" step="wrap-external-sources"/>
      <p:pipe port="result" step="parameters"/>
    </p:input>
    <p:input port="options">
      <p:pipe port="result" step="options"/>
    </p:input>
  </cx:eval>

  <p:unwrap match="/cx:document[@port eq 'result']"/>
  
  <letex:xslt-mode msg="yes" mode="docx2hub:export" name="export">
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
  
  <p:choose>
    <p:when test="not($debug = 'yes')">
      <cxf:delete recursive="true" fail-on-error="false">
        <p:with-option name="href" select="/c:files/@xml:base" >
          <p:pipe step="proto-unzip" port="result"/>
        </p:with-option>
      </cxf:delete>
      <cxf:delete recursive="true" fail-on-error="false">
        <p:with-option name="href" select="replace(/c:files/@xml:base, '\.tmp/?$', '.out')" >
          <p:pipe step="proto-unzip" port="result"/>
        </p:with-option>
      </cxf:delete>
    </p:when>
    <p:otherwise>
      <p:sink>
        <p:input port="source">
          <p:pipe port="result" step="zip-manifest"/>
        </p:input>
      </p:sink>
    </p:otherwise>
  </p:choose>

</p:declare-step>
