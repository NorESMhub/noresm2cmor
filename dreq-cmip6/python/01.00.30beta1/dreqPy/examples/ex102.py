
import sys, os
import xml
import xml.dom.minidom

if len( sys.argv ) > 1:
  fn = sys.argv[1]
  if os.path.isfile( fn ):
    xmlf = fn
  else:
    print ( 'File %s not found' % fn )
    sys.exit(0)
else:
  xmlf = 'out/annotated_20150731.xml'

doc = xml.dom.minidom.parse( xmlf )

dcppLinks = []
requestedGroups = set()

# find request links 
sect = doc.getElementsByTagName( 'requestLink' )[0]
s = set()
for item in sect.getElementsByTagName( 'item' ):
  if item.getAttribute( 'mip' ) == 'DCPP':
    dcppLinks.append( item )
    requestedGroups.add( item.getAttribute( 'refid' ) )

print ( 'Request links found for DCPP: %s' % len( dcppLinks ) )

print ( 'Request groups found for DCPP: %s' % len( requestedGroups ) )

sect = doc.getElementsByTagName( 'requestVar' )[0]
cmorVars = set()
for item in sect.getElementsByTagName( 'item' ):
  if item.getAttribute( 'vgid' ) in requestedGroups:
    cmorVars.add(  item.getAttribute( 'vid' ) )

print ( 'CMOR variables requested by DCPP: %s' % len(cmorVars) )
