scr = __name__ == '__main__'
try:
  from __init__ import DOC_DIR
except:
  from dreqPy.__init__ import DOC_DIR
##if scr:
  ##from __init__ import DOC_DIR
##else:
  ##from . import __init__
  ##DOC_DIR = __init__.DOC_DIR

import os, sys, collections

usingPython3 = sys.version_info >= (3,0)

try:
  import pkgutil
  l = pkgutil.iter_modules()
  ll = map( lambda x: x[1], l )
  pkgutilFailed=False
except:
  pkgutilFailed=True
  print ( 'Failed to load pkgutil .. more limited tests on available modules will be done' )
  ll = []

requiredModules = ['xml']
confirmed = []
installFailed = []
missingLib = []
for x in requiredModules:
  if x in ll or pkgutilFailed:
      try:
        __import__(x)
        confirmed.append( x )
      except:
        installFailed.append( x )
        print ( 'Failed to install %s' % x )
  else:
      missingLib.append( x )

if len( missingLib ) > 0 or len(installFailed) > 0:
  print ( 'Could not load all required python libraries' )
  if len(missingLib) > 0:
    print ( 'MISSING LIBRARIES: %s' % str(missingLib) )
  if len(installFailed) > 0:
    print ( 'LIBRARIES PRESENT BUT FAILED TO INSTALL:%s' % str(missingLib) )
  all = False
  exit(0)
else:
  print ( 'Required libraries present' )
  all = True

import inspect
class checkbase(object):
  def __init__(self,lab):
    self.lab = lab
    self.ok = True
    self.entryPoint = sys.argv[0].split( '/' )[-1]
    ##if os.path.isdir( 'out' ):
      ##self.docdir = 'out'
    ##elif os.path.isdir( 'docs' ):
      ##self.docdir = 'docs'
    ##else:
      ##assert False, 'Document directory not found'

#document directory
    self.docdir = DOC_DIR
#schema location
    self.schema = '%s/dreq2Schema.xsd' % self.docdir
#sample xml location
    self.sampleXml = '%s/dreq2Sample.xml' % self.docdir
#definition document xml location
    self.defnXml = '%s/dreq2Defn.xml' % self.docdir

    ml = inspect.getmembers( self, predicate=inspect.ismethod ) 
    ok = True
    for tag,m in ml:
      if tag[:3] == '_ch':
        try:
          self.ok = False
          m()
          ok &= self.ok
        except:
          print ( 'Failed to complete check %s' % tag )
          raise
    if ok:
      print ( '%s: All checks passed' % lab )
    else: 
      print ( '%s: Errors detected' % lab )
       
class check1(checkbase):
  def _ch01_importDreq(self):
    try:
      import dreq
    except:
      from . import dreq
    print ( 'Dreq software import checked' )
    self.ok = True

  def _ch02_importSample(self):
    try:
      import dreq
    except:
      from . import dreq
    self.dq = dreq.loadDreq( manifest='%s/dreqManifest.txt' % self.docdir  )
    print ( 'Dreq sample load checked' )
    self.ok = True

  def _ch03_linkCheck(self):
    try:
      import dreq
    except:
      from . import dreq

    nn = 0
    self.dq = dreq.loadDreq( manifest='%s/dreqManifest.txt' % self.docdir  )
    for section in self.dq.coll :
      ks=[k for k in self.dq.coll[section].attDefn.keys() if self.dq.coll[section].attDefn[k].useClass == 'internalLink']
      nerr = 0
      cc = collections.defaultdict( int )
      for i in self.dq.coll[section].items:
        for k in ks :
          if k in i.__dict__:
            if i.__dict__[k] not in self.dq.inx.uid:
              nerr += 1
              cc[k] += 1
              print ('Bad link found: section: %s: %s   %s [%s]' % (section, k, i.__dict__[k], i.uid) )
      if nerr > 0:
           msg = ''
           for k in cc:
             msg += '%s: %s; ' % (k,cc[k])
           print ( 'Section %s: bad links: %s %s' % (section,nerr,msg) )
           nn += nerr
      ##print section, ks, nerr
    if nn == 0:
      print ( 'Dreq links checked' )
    self.ok = nn == 0

class check2(checkbase):

  def _clear_ch03(self):
    os.unlink( '.simpleCheck_check2_err.txt' )
    os.unlink( '.simpleCheck_check2.txt' )

  def _clear_ch04(self):
    os.unlink( '.simpleCheck_check2_err.txt' )
    os.unlink( '.simpleCheck_check2.txt' )

  def _getCmd(self):
    if self.entryPoint == 'drq':
       self.cmd = 'drq'
    else:
       if usingPython3:
         self.cmd = 'python3 dreqCmdl.py'
       else:
         self.cmd = 'python dreqCmdl.py'

  def _ch05_checkMcfg(self):
    self._getCmd()
    thisCmd = '%s -m CMIP -e historical --mcfg 259200,60,64800,40,20,5,100' % self.cmd
    os.popen( '%s 2> .simpleCheck_check5_err.txt 1>.simpleCheck_check5.txt' % thisCmd ).readlines()

    ii = open( '.simpleCheck_check5_err.txt' ).readlines()
    if len(ii) > 0:
      print ( 'WARNING[005]: failed to get volume est. with command line call' )
      self.ok = False
      ##self._clear_ch04()
      return

    ii = open( '.simpleCheck_check5.txt' ).readlines()
    if len(ii) < 1:
      print ( 'WARNING[006]: failed to get get volume est. with command line call' )
      self.ok = False
      ##self._clear_ch04()
      return

    self.ok = True
    return

  def _ch04_checkCmd(self):
    import os
    self._getCmd()

    os.popen( '%s -v  2> .simpleCheck_check2_err.txt 1>.simpleCheck_check2.txt' % self.cmd ).readlines()

    ii = open( '.simpleCheck_check2_err.txt' ).readlines()
    if len(ii) > 0:
      print ( 'WARNING[003]: failed to get version with command line call' )
      self.ok = False
      self._clear_ch04()
      return

    ii = open( '.simpleCheck_check2.txt' ).readlines()
    if len(ii) < 1:
      print ( 'WARNING[004]: failed to get version with command line call' )
      self.ok = False
      self._clear_ch04()
      return

    self.ok = True
    return

  def _ch03_checkXML(self):
    import os
    os.popen( 'which xmllint 2> .simpleCheck_check2_err.txt 1>.simpleCheck_check2.txt' ).readlines()
    ii = open( '.simpleCheck_check2_err.txt' ).readlines()
    if len(ii) > 0:
      print ( 'WARNING[001]: failed to detect xmllint command line program' )
      print ( 'optional checks omitted' )
      self.ok = False
      self._clear_ch03()
      return
    ii = open( '.simpleCheck_check2.txt' ).readlines()
    if len(ii) < 1:
      print ( 'WARNING[002]: failed to detect xmllint command line program' )
      print ( 'Optional checks omitted' )
      self.ok = False
      self._clear_ch03()
      return

    cmd = 'xmllint --noout --schema %s %s  2> .simpleCheck_check2_err.txt 1>.simpleCheck_check2.txt' % (self.schema,self.sampleXml) 
    os.popen( cmd ).readlines()
    ii = open( '.simpleCheck_check2_err.txt' ).readlines()
    if len(ii) == 0:
      print ( 'WARNING[003]: Failed to capture xmllint response' )
      print ( cmd )
      self.ok = False
      self._clear_ch03()
      return
    if ii[0].find('validates') != -1:
      print ( 'Sample XML validated' )
      self.ok = True
      self._clear_ch03()
    else:
      print ( 'Sample XML failed to validate' )
      print ( cmd )
      self.ok = False
    return
    
all &= check1('Suite 1 (dreq module)').ok
all &= check2('Suite 2 (xmllint & command line)').ok

if all:
  print ( 'ALL CHECK PASSED' )
