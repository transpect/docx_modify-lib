<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:docx2hub = "http://transpect.io/docx2hub"
  xmlns:tr="http://transpect.io"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  version="1.0"
  name="docx_modify"
  type="docx2hub:modify"
  >
  
  <p:option name="file" required="false" select="''">
    <p:documentation>As required by docx2hub</p:documentation>
    <p:documentation>If there is already a single tree that you want to modify you can use the single-tree and 
      single-tree-manifest input ports.</p:documentation>
  </p:option>
  <p:option name="template-file" select="''">
    <p:documentation>Another optional OOXML file that will serve as a template, i.e., static files will be taken
    from this file rather than from the original. Its single-tree representation will be supplied to the modifying
    pipeline as an additional input so that it can be merged with existing or newly generated content, its styles
    can be used in lieu of the original styles, etc. Its static files will be copied to the resulting file if they
    are referenced in the resulting relationship files. 
    Please note that you cannot generate docm or dotm files with this step because the resulting zip needs to be
    digitally signed, which is a task that we cannot do yet with XProc.</p:documentation>
  </p:option>
  <p:option name="copy-from-template-file-regex" 
    select="'(^vba|\.bin$|/word/(theme|embeddings|glossary|media)|/customUI|/customXml|(_rels/)?customizations.xml(\.rels)?)'">
    <p:documentation>If template-file is non-empty, this regex will be used to match file names (c:file/@name attributes in
      tr:unzip output) in the unzipped template file against. Files that match </p:documentation>
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
  <p:option name="extract-dir" select="''">
    <p:documentation>Where $file will be unzipped (OS path, usually ending in .tmp)</p:documentation>
  </p:option>
  <p:option name="indent" required="false" select="'true'"/>
  <p:option name="docx2hub-add-srcpath-attributes" required="false" select="'no'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Whether docx2hub adds srcpath attributes in mode insert-xpath to content elements or not. Example use: you have to 
        replace already modified content of the docx (external conversion) and match old nodes via @srcpath value.</p>
      <p>Default: no (saves time and memory)</p>
    </p:documentation>
  </p:option>
  <p:option name="no-srcpaths-for-text-runs-threshold" select="'40000'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Limitation of nodes for adding srcpath attributes.</p>
      <p>See also docx2hub (single-tree) documentation.</p>
    </p:documentation>
  </p:option>
  <p:option name="media-path" required="false" select="'none'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>If there are external media files that have to be included in the final docx file, media-path determines the path 
        where to find the files. Otherwise it should be 'none'.</p>
    </p:documentation>
  </p:option>
  <p:option name="mathtype2omml" required="false" select="'no'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Activates use of mathtype2mml extension (see docx2hub for selectable option values)</p>
      <p>Default: no</p>
      <p>If not set to 'no', the external resource hub2docx/xsl/omml/mml2omml.xsl is accessible via xmlcatalog.</p>
    </p:documentation>
  </p:option>
  <p:option name="mathtype2omml-cleanup" required="false" select="'yes'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Deletion of converted files of the MathType and WMF formulas in the new word container + Relationshop elements.</p>
      <p>Default: yes</p>
    </p:documentation>
  </p:option>
  <p:option name="mathtype-source-pi" required="false" select="'no'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Insertion of processing-instructions into mml:math element, containing information about the mml source (ole, wmf).</p>
      <p>Default: no</p>
    </p:documentation>
  </p:option>
  <p:option name="mml-space-handling" required="false" select="'char'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>How to handle Mathtype-spacing in Mathml. Possible: 'char', 'mspace'.</p>
      <p>Default for docx_modify: char (reproduce input as is, do not change thinspace to percentual mspace)</p>
    </p:documentation>
  </p:option>
  <p:option name="docx2hub-insert-document-defaults" required="false" select="'no'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Wether document default settings (i.e. language and font names) are inserted by docx2hub into single-tree or not.</p>
      <p>Normally, we want to modify the entire word contents as is. The default value for docx2hub conversion is 'yes'.</p>
      <p>Default: no</p>
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
      the default single-pass modify pipeline. Your pipeline typically consists of chained transformations in different modes, 
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
  <p:input port="single-tree" sequence="true">
    <p:documentation>Single xml input of the docx that used be modified INSTEAD OF input via file OPTION.</p:documentation>
    <p:empty/>
  </p:input>
  <p:input port="single-tree-manifest" sequence="true">
    <p:documentation>Zip manifest of the single xml input of the docx that used be modified INSTEAD OF input via file OPTION.</p:documentation>
    <p:empty/>
  </p:input>
  <p:input port="options">
    <p:documentation>Options to the modifying XProc pipeline, as /cx:options/cx:option[@name]/@value
      documents.</p:documentation>
  </p:input>
  <p:input port="docx2hub-xslt">
    <p:document href="http://transpect.io/docx2hub/xsl/main.xsl"/>
    <p:documentation>Main XSL file of docx2hub. To manipulate the single-tree, optionally.</p:documentation>
  </p:input>
  <p:input port="update-zip-manifest-xslt">
    <p:document href="../xsl/update-zip-manifest.xsl"/>
    <p:documentation>An XSL that updates the original zip manifest, based on the updated single tree and possibly also
    on the template’s zip manifest.</p:documentation>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:documentation>A c:result element with an export-uri attribute of the modified docx file.</p:documentation>
    <p:pipe port="result" step="zip-file-uri"/>
  </p:output>
  <p:output port="modified-single-tree">
    <p:documentation>A /w:root document. This output is mostly for Schematron checks. If you want Schematron
    with srcpaths, invoke it with docx2hub-add-srcpath-attributes=yes</p:documentation>
    <p:pipe port="result" step="mml2omml"/>
  </p:output>
  <p:output port="report" sequence="true">
    <p:documentation>A possible sequence of /c:errors and/or SVRL documents.</p:documentation>
    <p:pipe port="report" step="template-single-tree"/>
  </p:output>
  <p:output port="wrapped-ci-docs" primary="false">
    <p:documentation>A document containing the w:root and zip manifest of the file for CI reasons</p:documentation>
    <p:pipe port="result" step="wrapped-result-for-ci"/>
  </p:output>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl" />
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl" />
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/zip/xpl/zip.xpl" />
  <p:import href="http://transpect.io/docx2hub/xpl/single-tree-enhanced.xpl" />
  <p:import href="http://transpect.io/calabash-extensions/unzip-extension/unzip-declaration.xpl"/>
  
  <p:parameters name="consolidate-params">
    <p:input port="parameters">
      <p:pipe port="params" step="docx_modify"/>
    </p:input>
  </p:parameters>
  
  <p:choose name="file-uri">
    <p:when test="matches($file, '\.do[ct][mx]$')">
      <p:output port="result" primary="true"/>
      <tr:file-uri>
        <p:with-option name="filename" select="$file"/>
        <p:input port="resolver">
          <p:document href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
        </p:input>
        <p:input port="catalog">
          <p:document href="http://this.transpect.io/xmlcatalog/catalog.xml"/>
        </p:input>
      </tr:file-uri>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <p:identity>
        <p:input port="source">
          <p:pipe port="single-tree" step="docx_modify"/>
        </p:input>
      </p:identity>
      <tr:file-uri>
        <p:with-option name="filename" select="/*/@local-href"/>
      </tr:file-uri>
    </p:otherwise>
  </p:choose>
  
  <p:choose name="single-tree">
    <p:when test="matches($file, '\.do[ct][mx]$')">
      <p:output port="result" primary="true">
        <p:pipe port="result" step="single-tree-enhanced"/>
      </p:output>
      <p:output port="zip-manifest">
        <p:pipe port="zip-manifest" step="single-tree-enhanced"/>
      </p:output>
      <p:output port="params">
        <p:pipe port="params" step="single-tree-enhanced"/>
      </p:output>
    
      <docx2hub:single-tree-enhanced name="single-tree-enhanced">
        <p:input port="xslt">
          <p:pipe port="docx2hub-xslt" step="docx_modify"/>
        </p:input>
        <p:with-option name="apply-changemarkup" select="$apply-changemarkup"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="extract-dir" select="$extract-dir"/>
        <p:with-option name="srcpaths" select="$docx2hub-add-srcpath-attributes"/>
        <p:with-option name="no-srcpaths-for-text-runs-threshold" select="$no-srcpaths-for-text-runs-threshold"/>
        <p:with-option name="mathtype2mml" select="$mathtype2omml"/>
        <p:with-option name="mathtype2mml-cleanup" select="$mathtype2omml-cleanup"/>
        <p:with-option name="mathtype-source-pi" select="$mathtype-source-pi"/>
        <p:with-option name="mml-space-handling" select="$mml-space-handling"/>
        <p:with-option name="insert-document-defaults" select="$docx2hub-insert-document-defaults"/>
        <p:with-option name="docx" select="/*/@os-path"/>
      </docx2hub:single-tree-enhanced>
      <p:sink/>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true">
        <p:pipe port="result" step="single-tree-ident"/>
      </p:output>
      <p:output port="zip-manifest">
        <p:pipe port="single-tree-manifest" step="docx_modify"/>
      </p:output>
      <p:output port="params">
        <p:pipe port="params" step="docx_modify"/>
      </p:output>

      <p:identity name="single-tree-ident">
        <p:input port="source">
          <p:pipe port="single-tree" step="docx_modify"/>
        </p:input>
      </p:identity>
      <p:sink/>
    </p:otherwise>
  </p:choose>
  
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="single-tree"/>
    </p:input>
  </p:identity>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('docx_modify/', replace(/*/@lastpath, '\.do[ct][mx]$', ''), '/single-tree_source')">
      <p:pipe port="result" step="file-uri"/>
    </p:with-option>
    <p:with-option name="indent" select="'false'"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>

  <p:sink/>

  <p:choose name="template-single-tree">
    <p:when test="normalize-space($template-file)">
      <p:output port="result" primary="true" sequence="true"/>
      <p:output port="report" sequence="true"/>
      <p:output port="zip-manifest" sequence="true">
        <p:pipe port="zip-manifest" step="template-single-tree-1"/>
      </p:output>
      <p:variable name="file-uri" select="/*/@local-href">
        <p:pipe port="result" step="file-uri"/>
      </p:variable>
      <tr:file-uri name="template-file-uri">
        <p:with-option name="filename" select="$template-file"/>
        <p:input port="resolver">
          <p:document href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
        </p:input>
        <p:input port="catalog">
          <p:document href="http://this.transpect.io/xmlcatalog/catalog.xml"/>
        </p:input>
      </tr:file-uri>
      
      <docx2hub:single-tree-enhanced name="template-single-tree-1">
        <p:input port="xslt">
          <p:pipe port="docx2hub-xslt" step="docx_modify"/>
        </p:input>
        <p:with-option name="apply-changemarkup" select="$apply-changemarkup"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="srcpaths" select="$docx2hub-add-srcpath-attributes"/>
        <p:with-option name="mathtype2mml" select="$mathtype2omml"/>
        <p:with-option name="mathtype2mml-cleanup" select="$mathtype2omml-cleanup"/>
        <p:with-option name="mathtype-source-pi" select="$mathtype-source-pi"/>
        <p:with-option name="mml-space-handling" select="$mml-space-handling"/>
        <p:with-option name="insert-document-defaults" select="$docx2hub-insert-document-defaults"/>
        <p:with-option name="docx" select="/*/@os-path"/>
        <p:with-option name="extract-dir" select="concat($file-uri, '.template.tmp')">
          <p:documentation>We assume that the input file directory is writeable while the template file directory maybe not.</p:documentation>
        </p:with-option>
      </docx2hub:single-tree-enhanced>

    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <p:output port="report"/>
      <p:output port="zip-manifest" sequence="true">
        <p:empty/>
      </p:output>
      <p:identity>
        <p:input port="source">
          <p:empty/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  
  <p:sink/>

  <p:for-each name="wrap-sources">
    <p:iteration-source>
      <p:pipe port="result" step="single-tree"/>
      <p:pipe port="result" step="template-single-tree"/>
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
    <p:with-param name="file" select="/*/@local-href">
      <p:pipe port="result" step="file-uri"/>
    </p:with-param>
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
      <p:pipe port="result" step="wrap-sources"/>
      <p:pipe port="result" step="parameters"/>
    </p:input>
    <p:input port="options">
      <p:pipe port="result" step="options"/>
    </p:input>
  </cx:eval>
  
  <p:unwrap match="/cx:document[@port eq 'result']" name="unwrap-result"/>
  
  <p:choose name="mml2omml">
    <p:when test="not($mathtype2omml = 'no')">
      <p:output port="result" primary="true"/>
      
      <tr:xslt-mode msg="yes" mode="docx2hub:mml2omml" name="mml2omml-xslt">
        <p:input port="parameters"><p:pipe step="single-tree" port="params" /></p:input>
        <p:input port="stylesheet"><p:document href="http://transpect.io/docx_modify/xsl/mml2omml.xsl"/></p:input>
        <p:input port="models"><p:empty/></p:input>
        <p:with-option name="prefix" select="concat('docx_modify/', replace(/*/@lastpath, '\.do[ct][mx]$', ''), '/8')">
          <p:pipe port="result" step="file-uri"/>
        </p:with-option>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-param name="mathtype2omml" select="$mathtype2omml"/>
      </tr:xslt-mode>

    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:delete match="@srcpath"/>

  <tr:xslt-mode msg="yes" mode="docx2hub:export" name="export">
    <p:input port="parameters"><p:pipe step="single-tree" port="params"/></p:input>
    <p:input port="stylesheet"><p:pipe port="xslt" step="docx_modify"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="prefix" select="concat('docx_modify/', replace(/*/@lastpath, '\.do[ct][mx]$', ''), '/9')">
      <p:pipe port="result" step="file-uri"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-param name="mathtype2omml" select="$mathtype2omml"/>
    <p:with-param name="media-path" select="$media-path"/>
    <p:with-option name="indent" select="$indent"/>
    <p:with-param name="srcpaths" select="'no'"/>
  </tr:xslt-mode>
  
  <p:sink/>
  
  <p:xslt name="zip-manifest" cx:depends-on="export" initial-mode="update-zip-manifest">
    <p:with-param name="media-path" select="$media-path"/>
    <p:input port="source">
      <p:pipe port="zip-manifest" step="single-tree"/>
      <p:pipe port="result" step="export"/>
      <p:pipe port="zip-manifest" step="template-single-tree"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="update-zip-manifest-xslt" step="docx_modify"/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('docx_modify/', replace(/*/@lastpath, '\.do[ct][mx]$', ''), '/zip-manifesto')">
      <p:pipe port="result" step="file-uri"/>
    </p:with-option>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>
  
  <p:sink/>
  
  <p:xslt name="zip-file-uri" template-name="main" cx:depends-on="zip-manifest">
    <p:with-param name="docx-target-uri" select="$docx-target-uri"/>
    <p:with-param name="template-base-uri" select="/*/@xml:base" >
      <p:pipe port="zip-manifest" step="single-tree"/>
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
   
  <p:wrap-sequence name="wrapped-result-for-ci" wrapper="c:wrap">
    <p:input port="source">
      <p:pipe port="result" step="zip-manifest"/>
      <p:pipe port="result" step="mml2omml"/>
    </p:input>
  </p:wrap-sequence>
  
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

</p:declare-step>
