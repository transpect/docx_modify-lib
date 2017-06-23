<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="modify">
  
  <p:documentation>XPL file for a single conversion in mode docx2hub:modify.
    Normally, the source input is the compound-document (result of insert-xpath).
    If you only need to pass additional input documents, you can use this XProc file too (port: external-sources).
    Use collection[2], collection[3] (and so on) to access these documents.</p:documentation>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  
  <p:input port="source" primary="true" sequence="true"/>
  <p:input port="stylesheet" />
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:output port="result" primary="true" />
  
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  
  <tr:xslt-mode msg="yes" mode="docx2hub:modify" prefix="docx_modify/modify">
    <p:input port="source">
      <p:pipe port="source" step="modify"/>
      <p:document href="http://this.transpect.io/xmlcatalog/catalog.xml"/>
    </p:input>
    <p:input port="stylesheet"><p:pipe port="stylesheet" step="modify"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug">
      <p:empty/>
    </p:with-option>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri">
      <p:empty/>
    </p:with-option>
  </tr:xslt-mode>
  
</p:declare-step>
