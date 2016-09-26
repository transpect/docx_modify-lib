<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="docx_modify"
  type="docx2hub:modify"
  >
  
  <p:option name="file" required="true">
    <p:documentation>As required by docx2hub</p:documentation>
  </p:option>
  <p:option name="apply-changemarkup" required="false" select="'no'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Apply all change markup on the compound word document.</p>
    </p:documentation>
  </p:option>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="docx-target-uri" required="false" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>URI where the generated docx will be saved. Possibilities:</p>
      <ul>
        <li>leave it empty to save the docx near docx template file (only file suffix is changed to .mod.docx)</li>
        <li>absolute path to a file</li>
      </ul>
    </p:documentation>
  </p:option>
  <p:option name="docx2hub-add-srcpath-attributes" required="false" select="'no'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Whether docx2hub adds srcpath attributes in mode insert-xpath to content elements or not. Example use: you have to 
        replace already modified content of the docx (external conversion) and match old nodes via @srcpath value.</p>
      <p>Default: no (saves time and memory)</p>
    </p:documentation>
  </p:option>
  <p:option name="media-path" required="false" select="'none'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>If there are external media files that have to be included in the final docx file, media-path determines the path 
        where to find the files. Otherwise it should be 'none'.</p>
    </p:documentation>
  </p:option>

  <p:input port="xslt">
    <p:document href="../xsl/identity.xsl"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>XSLT that transforms the compound OOXML document (all files assembled below a single w:root element,
      as produced by the step named 'insert-xpath') to a target compound document. The stylesheet may of course import
    other stylesheets or use multiple passes in different modes. In order to facilitate this common processing pattern,
    an XProc pipeline may also be supplied for the compound→compound transformation part. This pipeline will be dynamically
    executed by this pipeline. Please note that your stylesheet must use named modes if you are using an tr:xslt-mode 
    pipeline.</p>
      <p>Please also note that if your pipeline/stylesheet don't have a pass in docxhub:modify mode, they need 
    to match @xml:base in any of the other modifying modes and apply-templates to it in mode docxhub:modify.</p>
      <p>Please note that your stylesheet may need to import the identity.xsl or to transform the xml-base attributes itself 
    (old base→new base).</p>
    </p:documentation>
  </p:input>
  <p:input port="xpl">
    <p:document href="single-pass_modify.xpl"/>
    <p:documentation>See the 'xslt' port’s documentation. You may supply another pipeline that will be executed instead of 
      the default single-pass modify pipeline. You pipeline typically consists of chained transformations in different modes, 
      as invoked by tr:xslt-mode. Of course you can supply other pipelines with the same signature (single 
      w:root input/output documents).</p:documentation>
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
  
  <p:output port="result" primary="true">
    <p:documentation>A c:result element with an export-uri attribute of the modified docx file.</p:documentation>
  </p:output>
  <p:output port="modified-single-tree">
    <p:documentation>A /w:root document. This output is mostly for Schematron checks. If you want Schematron
    with srcpaths</p:documentation>
    <p:pipe port="modified-single-tree" step="group"/>
  </p:output>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl" />
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl" />
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/zip/xpl/zip.xpl" />
<!--  <p:import href="http://transpect.io/calabash-extensions/transpect-lib.xpl" />-->
  <p:import href="http://transpect.io/calabash-extensions/unzip-extension/unzip-declaration.xpl"/>
  
  <tr:file-uri name="file-uri">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>

  <p:group name="group">
    <p:output port="result" primary="true"/>
    <p:output port="modified-single-tree">
      <p:pipe port="result" step="export"/>
    </p:output>
    <p:variable name="basename" select="replace(/*/@lastpath, '\.do[ct][mx]$', '')"/>
    <p:variable name="os-path" select="/*/@os-path"/>
    <p:variable name="file-uri" select="/*/@local-href"/>
    
    <p:parameters name="consolidate-params">
      <p:input port="parameters">
        <p:pipe port="params" step="docx_modify"/>
      </p:input>
    </p:parameters>
    
    <tr:unzip name="proto-unzip">
      <p:with-option name="zip" select="$os-path" />
      <p:with-option name="dest-dir" select="concat($os-path, '.tmp')"><p:empty/></p:with-option>
      <p:with-option name="overwrite" select="'yes'" />
    </tr:unzip>
    
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
    
    <tr:store-debug>
      <p:with-option name="pipeline-step" select="concat('docx2hub/', $basename, '00.file-list')"/>
      <p:with-option name="active" select="$debug" />
      <p:with-option name="base-uri" select="$debug-dir-uri" />
    </tr:store-debug>
    
    <p:for-each name="copy">
      <p:iteration-source select="/c:files/c:file"/>
      <p:variable name="base-dir" select="replace(/c:files/@xml:base, '([^/])$', '$1/')">
        <p:pipe port="result" step="unzip"/>
      </p:variable>
      <p:variable name="new-dir" select="replace($base-dir, '(\.do[ct][mx])\.tmp/$', '$1.out/')"/>
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
    
    <p:add-attribute name="params0" attribute-name="value" match="/c:param-set/c:param[@name = 'error-msg-file-path']">
      <p:with-option name="attribute-value" select="replace( static-base-uri(), '/wml2hub.xpl', '' )"/>
      <p:input port="source">
        <p:inline>
          <c:param-set>
            <c:param name="srcpaths"/>
            <c:param name="error-msg-file-path"/>
            <c:param name="hub-version" value="1.1"/>
            <c:param name="unwrap-tooltip-links" value="no"/>
          </c:param-set>
        </p:inline>
      </p:input>
    </p:add-attribute>

    <p:add-attribute name="params" attribute-name="value" match="/c:param-set/c:param[@name = 'srcpaths']">
      <p:with-option name="attribute-value" select="$docx2hub-add-srcpath-attributes"/>
    </p:add-attribute>

    <p:sink/>
    
    <tr:xslt-mode msg="yes" mode="insert-xpath" name="compound-document">
      <p:input port="source"><p:pipe step="document" port="result" /></p:input>
      <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
      <p:input port="stylesheet"><p:document href="http://transpect.io/docx2hub/xsl/main.xsl"/></p:input>
      <p:input port="models"><p:empty/></p:input>
      <p:with-option name="prefix" select="concat('docx2hub/', $basename, '/01')"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-param name="srcpaths" select="$docx2hub-add-srcpath-attributes"/>
    </tr:xslt-mode>
    
    
    <p:choose name="apply-changemarkup-optionally">
      <p:when test="$apply-changemarkup eq 'yes'">
        <p:output port="result" primary="true"><p:pipe step="apply-changemarkup" port="result"/></p:output>
        <tr:xslt-mode msg="yes" mode="docx2hub:apply-changemarkup" name="apply-changemarkup">
          <p:pipeinfo>Mode docx2hub:apply-changemarkup introduced in revision 524 of docx2hub/lib.</p:pipeinfo>
          <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
          <p:input port="stylesheet"><p:document href="http://transpect.io/docx2hub/xsl/main.xsl"/></p:input>
          <p:input port="models"><p:empty/></p:input>
          <p:with-option name="prefix" select="concat('docx2hub/', $basename, '/02')"/>
          <p:with-option name="debug" select="$debug"/>
          <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        </tr:xslt-mode>
      </p:when>
      <p:otherwise>
        <p:output port="result" primary="true"><p:pipe step="id-comp" port="result"/></p:output>
        <p:identity name="id-comp">
          <p:input port="source">
            <p:pipe port="result" step="compound-document"/>
          </p:input>
        </p:identity>
      </p:otherwise>
    </p:choose>
    
    <p:wrap wrapper="cx:document" match="/">
      <p:input port="source">
        <p:pipe step="apply-changemarkup-optionally" port="result"/>
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
      <p:with-param name="file" select="$file-uri"/>
      <p:with-param name="debug" select="$debug"/>
      <p:with-param name="debug-dir-uri" select="replace($debug-dir-uri, '^(.+)\?.*$', '$1')"/>
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
                <cx:option name="debug-dir-uri" value="{replace($debug-dir-uri, '^(.+)\?.*$', '$1')}"/>
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
    
    <tr:xslt-mode msg="yes" mode="docx2hub:export" name="export">
      <p:input port="parameters"><p:pipe step="params" port="result" /></p:input>
      <p:input port="stylesheet"><p:pipe port="xslt" step="docx_modify"/></p:input>
      <p:input port="models"><p:empty/></p:input>
      <p:with-option name="prefix" select="concat('docx_modify/', $basename, '/9')"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-param name="media-path" select="$media-path"/>
      <p:with-param name="srcpaths" select="'no'"/>
    </tr:xslt-mode>
    
    <p:sink/>
    
    <p:xslt name="zip-manifest" cx:depends-on="export">
      <p:with-param name="media-path" select="$media-path"/>
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
            <xsl:param name="media-path"/>
            <xsl:template match="c:files">
              <c:zip-manifest>
                <xsl:apply-templates/>
                <xsl:apply-templates 
                  select="collection()
                            /*:root
                              //*:file[@status eq 'modified-or-new-and-written-to-sys']
                                      [not(@name = collection()/*:files/*:file/@name)]" />
                <xsl:apply-templates 
                  select="collection()
                  /*:root
                  //*:file[not($media-path='none')][@status eq 'external-media-file']
                  [not(@name = collection()/*:files/*:file/@name)]" />
              </c:zip-manifest>
            </xsl:template>
            <xsl:variable name="base-uri" select="replace(/*/@xml:base, '(\.do[ct][mx])\.tmp', '$1.out')" as="xs:string"/>
            <xsl:template match="*:file">
              <xsl:variable name="path-prefix" as="xs:string?" select="concat('file:/', replace($media-path, '^file:/+', ''))"/>
              <c:entry name="{replace(replace(@name, '%5B', '['), '%5D', ']')}" href="{if ((@status eq 'external-media-file')) then concat($path-prefix, replace(@name, '^word/media/', '')) else concat($base-uri, @name)}" compression-method="deflate" compression-level="default"/>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    
    <tr:store-debug>
      <p:with-option name="pipeline-step" select="concat('docx_modify/', $basename, '/zip-manifest')"/>
      <p:with-option name="active" select="$debug" />
      <p:with-option name="base-uri" select="$debug-dir-uri" />
    </tr:store-debug>
    
    <p:sink/>
    
    <p:xslt name="zip-file-uri" template-name="main" cx:depends-on="zip-manifest">
      <p:with-param name="docx-target-uri" select="$docx-target-uri"/>
      <p:with-param name="template-base-uri" select="/c:files/@xml:base" >
        <p:pipe port="result" step="unzip"/>
      </p:with-param>
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet version="2.0">
            <xsl:param name="docx-target-uri" required="yes" as="xs:string" />
            <xsl:param name="template-base-uri" required="yes" as="xs:string" />
            <xsl:template name="main">
              <xsl:variable name="result" as="element(c:result)">
                <c:result>
                  <xsl:choose>
                    <!-- full path given -->
                    <xsl:when test="matches($docx-target-uri, '^.+\.\w+$')">
                      <xsl:value-of select="$docx-target-uri"/>
                    </xsl:when>
                    <!-- no path (empty string) given -->
                    <xsl:otherwise>
                      <xsl:value-of select="replace($template-base-uri, '(\.do[ct][mx])\.tmp/?$', '.mod$1')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </c:result>
              </xsl:variable>
              <xsl:message select="concat('docx_modify: modified docx will be stored in ', $result)"/>
              <xsl:sequence select="$result"/>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    
    <p:sink/>
      
    <tr:zip name="zip" cx:depends-on="zip-file-uri" compression-method="deflated" compression-level="default" command="create">
      <p:with-option name="href" select="/c:result" >
        <p:pipe port="result" step="zip-file-uri"/>
      </p:with-option>
      <p:input port="source">
        <p:pipe step="zip-manifest" port="result"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    </tr:zip>
    
    <p:choose cx:depends-on="zip">
      <p:when test="not($debug = 'yes')">
        <cxf:delete recursive="true" fail-on-error="false">
          <p:with-option name="href" select="/c:files/@xml:base">
            <p:pipe step="proto-unzip" port="result"/>
          </p:with-option>
        </cxf:delete>
        <cxf:delete recursive="true" fail-on-error="false">
          <p:with-option name="href" select="replace(/c:files/@xml:base, '\.tmp/?$', '.out')">
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

    <p:identity name="fwd-zip">
      <p:input port="source">
        <p:pipe port="result" step="zip"/>
      </p:input>
    </p:identity>

  </p:group>

</p:declare-step>
