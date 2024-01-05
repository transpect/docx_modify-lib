<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:tr="http://transpect.io"
  version="1.0" 
  name="unstrict"
  type="docx2hub:unstrict">

  <p:output port="result" primary="true">
    <p:documentation>The zip manifest</p:documentation>
  </p:output>

  <p:option name="docx" required="true">
    <p:documentation>OS name (preferably with full path, may not resolve if only a relative path is given), file:, http:, or
      https: URL. The file will be fetched first if it is an HTTP URL.</p:documentation>
  </p:option>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'file:/tmp/debug'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>

  <tr:file-uri name="file-uri">
    <p:with-option name="filename" select="$docx"/>
  </tr:file-uri>

  <pxp:unzip name="zip-dir">
    <p:with-option name="href" select="/*/@local-href"/>
  </pxp:unzip>

  <p:viewport match="c:file[@name = 'word/document.xml']" name="viewport">
    <p:variable name="zip-href" select="/*/@href">
      <p:pipe port="result" step="zip-dir"/>
    </p:variable>
    <pxp:unzip name="extract-xml-file">
      <p:with-option name="href" select="$zip-href"/>
      <p:with-option name="file" select="/*/@name"/>
    </pxp:unzip>
    <p:xslt name="patch-namespaces">
      <p:with-option name="output-base-uri" select="resolve-uri(/*/@name, $zip-href)">
        <p:pipe step="viewport" port="current"/>
      </p:with-option>
      <p:input port="stylesheet">
        <p:document href="../xsl/unstrict.xsl"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>
    <cx:message>
      <p:with-option name="message" select="'HHHHHHHHHHHHHH ', base-uri()">
<!--        <p:pipe port="result" step="patch-namespaces"/>-->
      </p:with-option>
    </cx:message>
    <p:sink/>
    <p:add-attribute match="c:entry" attribute-name="name" name="proto-manifest">
      <p:input port="source">
        <p:inline>
          <zip-manifest xmlns="http://www.w3.org/ns/xproc-step">
            <entry/>
          </zip-manifest>
        </p:inline>
      </p:input>
      <p:with-option name="attribute-value" select="/*/@name">
        <p:pipe port="current" step="viewport"/>
      </p:with-option>
    </p:add-attribute>
    <p:add-attribute match="c:entry" attribute-name="href" name="manifest">
      <p:with-option name="attribute-value" select="base-uri()">
        <p:pipe port="result" step="patch-namespaces"/>
      </p:with-option>
    </p:add-attribute>
    <pxp:zip name="update-zip" command="update" compression-method="deflated" compression-level="default" cx:depends-on="delete-in-zip">
      <p:with-option name="href" select="$zip-href"/>
      <p:input port="source">
        <p:pipe port="result" step="patch-namespaces"/>
      </p:input>
      <p:input port="manifest">
        <p:pipe port="result" step="manifest"/>
      </p:input>
    </pxp:zip>
  </p:viewport>

</p:declare-step>
