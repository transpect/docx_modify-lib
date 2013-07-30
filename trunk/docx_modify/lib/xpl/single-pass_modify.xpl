<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect" 
  xmlns:letex="http://www.le-tex.de/namespace"
  version="1.0"
  name="modify"
  >
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  
  <p:input port="source" primary="true" />
  <p:input port="stylesheet" />
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:output port="result" primary="true" />
  
  <p:import href="http://transpect.le-tex.de/xproc-util/xslt-mode/xslt-mode.xpl"/>
  
  <letex:xslt-mode mode="docx2hub:modify" prefix="docx_modify/modify">
    <p:input port="stylesheet"><p:pipe port="stylesheet" step="modify"/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </letex:xslt-mode>
  
</p:declare-step>
