"""
Entry point for command line usage -- see ccinit for usage information.
"""

scr = __name__ == '__main__'
import sys
if scr:
  import scope
else:
  from . import scope


def main_entry():
  """
   Wrapper for use with setuptools.
  """
  if len(sys.argv) == 1:
      # Show command-line info and report that you must provide arguments
      print( scope.dreqUI.__doc__ )
      print( "\nERROR: Please provide command-line arguments." )
      return

  if sys.argv[1] == '-v':
      if scr:
        from packageConfig import __version__, __versionComment__, PACKAGE_DIR
      else:
        from .packageConfig import __version__, __versionComment__, PACKAGE_DIR
      print( 'dreqPy version %s [%s]' % (__version__,__versionComment__) )
      print( 'Installed in %s' % PACKAGE_DIR )
      print( 'Running in python %s' % str( sys.version_info ) )
  elif sys.argv[1] == '--unitTest':
      print( "Starting test suite 1" )
      if scr:
        import simpleCheck
      else:
        from . import simpleCheck
      print( "Starting test suite 2" )
      if scr:
        import examples.ex203 as ex203
      else:
        from .examples import ex203
      ex203.main( scope )
      print( "Tests completed" )
  elif sys.argv[1] == '--makeTables':
      print( "Making web page tables" )
      if scr:
        import makeTables
      else:
        from . import makeTables
      makeTables.run()
  else:
     x = scope.dreqUI(sys.argv[1:])
     x.run()
     if len(scope.dreqQuery.errorLog.keys()) > 0:
       elog = scope.dreqQuery.errorLog
       print( 'ERRORS ENCOUNTERED IN scope.dreqQuery' )
       for k in sorted( elog.keys() ):
         print ( '%s: %s' % (k,len(elog[k]) ) )
         for m in sorted(list(elog[k])):
           print ( '          -- %s' % m )

     if len(scope.volsum.table_utils.vrev.checkVar.errorLog.keys()) > 0:
       elog = scope.volsum.table_utils.vrev.checkVar.errorLog
       print( 'ERRORS ENCOUNTERED IN vrev.checkVar' )
       for k in sorted( elog.keys() ):
         print ( '%s: %s' % (k,len(elog[k]) ) )
         for m in sorted(list(elog[k])):
           print ( '          -- %s' % m )

if __name__ == '__main__':
  main_entry()
