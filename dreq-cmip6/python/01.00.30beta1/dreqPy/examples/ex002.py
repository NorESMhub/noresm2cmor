
import sys, os

if len(sys.argv) > 1:
  if os.path.isdir( sys.argv[1] ):
    if os.path.isfile( '%s/dreq.py' % sys.argv[1] ):
      sys.path.insert(0, sys.argv[1] )
      import dreq
    else:
      print ( 'No dreq.py in specified directory' )
      sys.exit(0)
  else:
    print  ('Specified directoty does not exist' )
    sys.exit(0)
else:
  from dreqPy import dreq



dq = dreq.loadDreq()

dcppLinks = [x for x in dq.coll['requestLink'].items if x.mip == 'DCPP']
print ('Request links found for DCPP: %s' % len( dcppLinks ) )

dcppRequestedGroups = set( [dq.inx.uid[x.refid] for x in dcppLinks] )
print ('Request groups found for DCPP: %s' % len( dcppRequestedGroups ) )

dcppRequestedCmorVars = set()
for vg in dcppRequestedGroups:
   for x in dq.inx.iref_by_sect[vg.uid].a['requestVar']:
       dcppRequestedCmorVars.add( dq.inx.uid[x].vid )
print ('Requested CMOR Variables found for DCPP: %s' % len( dcppRequestedCmorVars ) )

