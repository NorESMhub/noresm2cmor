import  sys, os, xml
import xml.dom.minidom

xmlf = sys.argv[1]
doc = xml.dom.minidom.parse( xmlf )

ver = doc.getElementsByTagName('pav:version')[0]
print ( ver.firstChild.data )
