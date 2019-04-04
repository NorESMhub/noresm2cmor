import sys, os

if len(sys.argv) > 1:
  if os.path.isdir( sys.argv[1] ):
    if os.path.isfile( '%s/scope.py' % sys.argv[1] ):
      sys.path.insert(0, sys.argv[1] )
      import scope
    else:
      print ( 'No scope.py in specified directory' )
      sys.exit(0)
  else:
    print  ('Specified directory does not exist' )
    sys.exit(0)
else:
  from dreqPy import scope


sc = scope.dreqQuery()
p=1
sc.volByMip2('DCPP',p, makeTabs=True)
