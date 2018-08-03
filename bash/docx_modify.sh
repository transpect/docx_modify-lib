#!/bin/bash
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac

# It is assumed that the grandparent directory of this script is called docx_modify
# and that this docx_modify directory has a sibling directory calabash
DIR="$( cd -P "$(dirname $( readlink -f "${BASH_SOURCE[0]}"))"/../.. && pwd )"
XSL="$( readlink -f "$1" )"
DOCX="$( readlink -f "$2" )"
MODIFY_XPL="$( readlink -f "$3" )"
XPL="$DIR"/docx_modify/xpl/docx_modify.xpl

if [ -z $XSL ]; then
    echo "Usage: [DEBUG=yes|no] [HEAP=xxxxm] [MATHTYPE2OMML=yes|no] docx_modify XSL DOCX [XPL] [DOCX2HUB_XSL]";
    echo "(The prefixed DEBUG=yes or HEAP=2048m work only if your shell is bash-compatible.)";
    echo "";
    echo "Sample invocation (identity with debug): ";
    echo "DEBUG=yes ./docx_modify.sh lib/xsl/identity.xsl /path/to/myfile.docx";
    echo "";
    echo "The resulting file will end in .mod.docx, with the same base name.";
    echo "The .docx file's directory will be used to temporarily extract the files.";
    echo "So you need write permissions there (also for the resulting file)."
    echo "There's no option yet to create the .mod.docx in another place."
    echo "";
    echo "The third argument [XPL] is the path (may be relative) to an optional XProc pipeline ";
    echo "that implements the modification. If none is specified, lib/xpl/single-pass_modify.xpl";
    echo "will be used. See this XProc file as an example to build your own pipeline. Typically, ";
    echo "pipelines are built by chaining multiple letex:xslt-mode steps with the same stylesheet.";
    echo "";
    echo "See lib/xsl for transformation examples (e.g., identity for reproducing the .docx identically,";
    echo "or rename_pstyles.xsl for renaming paragraphs. More complex, but also very specific ";
    echo "examples are in epub_formatsicherung.xsl (including generation of new character styles";
    echo "from actual formatting) or page-bookmarks.xsl (this uses an XSLT micropipeline for";
    echo "a multi-pass transformation -- if the XPL option had been in place by the time we ";
    echo "wrote this transformation, we would have used it. Now there are two alternative";
    echo "invocations:";
    echo "./docx_modify.sh lib/xsl/page-bookmarks.xsl /path/to/myfile.docx";
    echo "./docx_modify.sh lib/xsl/page-bookmarks.xsl /path/to/myfile.docx lib/xpl/page-bookmarks.xpl";
    echo "";
    echo "If you don't use the mode docx2hub:modify in your custom XSLT, it is important that ";
    echo "you invoke docx2hub:modify's handling of @xml:base attributes. So if one of your modes";
    echo "is mymode, you should include the following template:";
    echo "  <xsl:template match=\"@xml:base\" mode=\"mymode\">";
    echo "    <xsl:apply-templates select=\".\" mode=\"docx2hub:modify\"/>";
    echo "  </xsl:template>";
    echo "";
    echo "Of course you may invoke Calabash directly, either by using calabash/calabash.sh";
    echo "(see how the command line is assembled in docx_modify.sh) or, bare metal, using";
    echo "the java command.";
    echo "Please note that this tool requires a Calabash extension (calabash/lib/ltx/ltx-unzip/)";
    echo "that is included here but not in a vanilla XML Calabash distribution.";
    echo "";
    echo "Apart from DEBUG, you may prepend LOCALDEFS=/path/to/localdefs.sh for overriding calabash ";
    echo "settings. You may also supply the minimum heap space (java option -Xmx) in a prepended ";
    echo "HEAP declaration, e.g., HEAP=2048m";
    echo "";
    echo "The parameter MATHTYPE2OMML (default: no) is for converting MathType formulas into OMML."
    echo "If you just want your MathType formulas type converted, you may use the following invocation:";
    echo "MATHTYPE2OMML=yes ./docx_modify.sh lib/xsl/identity.xsl /path/to/myfile.docx";
    echo "";
    echo "To modify the docx2hub single-tree use the parameter DOCX2HUB_XSL to point to your XSLT."
    echo "(default: "$DIR"/docx2hub/xsl/main.xsl)"
    exit 1;
fi

if [ -z $DOCX ]; then
    echo "Please supply a .docx file as second argument"
    exit 1
fi

if [ -z $DEBUG ]; then
    DEBUG=no
fi

if [ -z $DEBUGDIR ]; then
    DEBUGDIR=$DOCX.tmp/debug
fi

if [ -z $HEAP ]; then
    HEAP=2048m
fi

if [ -z $ADAPTIONS_DIR ]; then
    ADAPTIONS_DIR=$DIR/adaptions
fi

if [ -z $LOCALDEFS ]; then
    LOCALDEFS=$ADAPTIONS_DIR/common/calabash/localdefs.sh
fi

DEVNULL=/dev/null

if $cygwin; then
  XSL=file:/$(cygpath -ma $XSL)
  DOCX2HUB_XSL=file:/$(cygpath -ma $DOCX2HUB_XSL)
  DOCX=$(cygpath -ma $DOCX)
  DEBUGDIR=file:/$(cygpath -ma $DEBUGDIR)
  DEVNULL=$(cygpath -ma /dev/null)
  XPL=file:/$(cygpath -ma $XPL)
  if [ ! -z $MODIFY_XPL ]; then
    MODIFY_XPL=file:/$(cygpath -ma $MODIFY_XPL)
  fi
  if [ ! -z $DOCX2HUB_XSL ]; then
    DOCX2HUB_XSL=file:/$(cygpath -ma $DOCX2HUB_XSL)
  fi
fi

if [ ! -z $MODIFY_XPL ]; then
  MODIFY_XPL="-i xpl=$MODIFY_XPL"
fi

if [ -z $MATHTYPE2OMML ]; then
  MATHTYPE2OMML=no
fi

if [ -z $DOCX2HUB_XSL ]; then
  DOCX2HUB_XSL="$DIR"/docx2hub/xsl/main.xsl
fi

if [ "$DEBUG" == "yes" ]; then
  echo LOCALDEFS=$LOCALDEFS HEAP=$HEAP $DIR/calabash/calabash.sh -D -i xslt="$XSL" -i docx2hub-xslt=$DOCX2HUB_XSL -o result="$DEVNULL" -o modified-single-tree="$DEVNULL" $MODIFY_XPL "$XPL" file="$DOCX" mathtype2omml=$MATHTYPE2OMML debug=$DEBUG debug-dir-uri=$DEBUGDIR
fi

LOCALDEFS=$LOCALDEFS HEAP=$HEAP $DIR/calabash/calabash.sh -D -i xslt="$XSL" -i docx2hub-xslt=$DOCX2HUB_XSL -o result="$DEVNULL" -o modified-single-tree="$DEVNULL" $MODIFY_XPL "$XPL" file="$DOCX" mathtype2omml=$MATHTYPE2OMML debug=$DEBUG debug-dir-uri=$DEBUGDIR
if [ "$DEBUG" == "no" ]; then
  rm -rf $DOCX.tmp/
fi
