

python ptxt.py: to generate schema and sample from vocabDefn.txt
 [Need to edit file to switch modes]
Produces vocabDefn.xml  vocabSample.xml

test vocabDefn.xml

xmllint --schema ../../docs/vocabFrameworkSchema.xsd out/vocabDefn.xml

use xsltproc to generate schema from vocabDefn.xml

xsltproc ../../docs/xlst_xdsSchemaGen.xml out/vocabDefn.xml > out/vocab.xsd

check vocabSample.xml

xmllint --schema out/vocab.xsd out/vocabSample.xml
