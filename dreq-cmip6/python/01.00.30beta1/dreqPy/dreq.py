"""This module provides a basic python API to the Data Request.
After ingesting the XML documents (configuration and request) the module generates two python objects:
1. A collection of records
2. Index
"""
import xml, collections
import xml.dom
import xml.dom.minidom
import re, shelve, os, sys
try:
  from __init__ import DOC_DIR, version, PACKAGE_DIR, VERSION_DIR
  import utilities
except:
  from dreqPy.__init__ import DOC_DIR, version, PACKAGE_DIR, VERSION_DIR
  from dreqPy import utilities

python2 = True
if sys.version_info[0] == 3:
  python2 = False
  pythonPre27 = False
elif sys.version_info[0] == 2:
  pythonPre27 = sys.version_info[1] < 7

charmeTempl = """<span title="Using the CHARMe annotation system">Comment on this page:<a href="%s/%s/%s.html" class="charme-metadata-document"></a></span>

<span>
<div id="charme-placeholder"></div>
</span>
<br/>
<!-- the charme-placeholder-all-targets appears to be required, but can be hidden ... -->
<span style="display: None;">
<div id="charme-placeholder-all-targets"></div>
</span>
"""

dreqMonitoring = '''<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-126903002-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-126903002-1');
</script>
'''


jsh='''<link type="text/css" href="/css/jquery-ui-1.8.16.custom.css" rel="Stylesheet" />
 <script src="/js/2013/jquery.min.js" type="text/javascript"></script>
 <script src="/js/2013/jquery-ui.min.js" type="text/javascript"></script>
 <script src="/js/2013/jquery.cookie.js" type="text/javascript"></script>
%s

<link type="text/css" href="/css/dreq.css" rel="Stylesheet" />
''' % dreqMonitoring

def dref(i,x):
  return i._inx.uid[i.__dict__[x]]

blockSchemaFile = '%s/%s' % (DOC_DIR, 'BlockSchema.csv' )

class lutilsC(object):

  def __init__(self):
    pass

  def addAttributes( self, thisClass, attrDict ):
    """Add a set of attributes, from a dictionary, to a class"""
    for k in attrDict:
      setattr( thisClass, '%s' % k , attrDict[k] )

  def itemClassFact(self, sectionInfo,ns=None):
     class dreqItem(dreqItemBase):
       """Inherits all methods from dreqItemBase.

USAGE
-----
The instanstiated object contains a single data record. The "_h" attribute links to information about the record and the section it belongs to. 

object._a: a python dictionary defining the attributes in each record. The keys in the dictionary correspond to the attribute names and the values are python "named tuples" (from the "collections" module). E.g. object._a['priority'].type contains the type of the 'priority' attribute. Type is expressed using XSD schema language, so "xs:integer" implies integer.  The "useClass" attribute carries information about usage. If object._a['xxx'].useClass = u'internalLink' then the record attribute provides a link to another element and object.xxx is the unique identifier of that element.

object._h: a python named tuple describing the section. E.g. object._h.title is the section title (E.g. "CMOR Variables")
"""
       _base=dreqItemBase
       
     dreqItem.__name__ = 'dreqItem_%s' % str( sectionInfo.header.label )
     dreqItem._h = sectionInfo.header
     dreqItem._a = sectionInfo.attributes
     dreqItem._d = sectionInfo.defaults
     if sectionInfo.attributes != None:
        self.addAttributes(dreqItem, sectionInfo.attributes )
     ##dreqItem.itemLabelMode = itemLabelMode
     ##dreqItem.attributes = attributes
     dreqItem._rc = rechecks()
     dreqItem.ns = ns
     return dreqItem

##
## from http://stackoverflow.com/questions/4474754/how-to-keep-comments-while-parsing-xml-using-python-elementtree
##
## does not work for python3 ... may not be needed.
##
## needed in python2.6 to preserve comments in output XML
##
def getParser():
  import xml.etree.ElementTree as ET
  class PCParser(ET.XMLTreeBuilder):

     def __init__(self):
       ET.XMLTreeBuilder.__init__(self)
       # assumes ElementTree 1.2.X
       self._parser.CommentHandler = self.handle_comment

     def handle_comment(self, data):
       self._target.start(ET.Comment, {})
       self._target.data(data)
       self._target.end(ET.Comment)

  return PCParser

def loadBS(bsfile):
  """Read in the 'BlockSchema' definitions of the attributes defining attributes"""
  ii = open( bsfile, 'r' ).readlines()
  ll = []
  for l in ii:
    ll.append( [x for x in l.strip().split('\t') ] )
  cc = collections.defaultdict( dict )
  
  for l in ll[3:]:
    l[-1] = l[-1] == '1'
    if len(l) < len(ll[2]):
      l.append( '' )
    try:
      for i in range( len(ll[2]) ):
        cc[l[0]][ll[2][i]] = l[i]
    except:
      print (l)
      raise
  return cc

class rechecks(object):
  """Checks to be applied to strings"""
  def __init__(self):
    self.__isInt = re.compile( '^-{0,1}[0-9]+$' )

  def isIntStr( self, tv ):
    """Check whether a string is a valid representation of an integer."""
    if type( tv ) not in [type(''),type(u'')]:
      self.reason = 'NOT STRING'
      return False
    ok = self.__isInt.match( tv ) != None
    if not ok:
      self.reason = 'Failed to match regular expression for integers'
    else:
      self.reason = ''
    return ok

class dreqItemBase(object):
       __doc__ = """A base class used in the definition of records. Designed to be used via a class factory which sets "itemLabelMode" and "attributes" before the class is instantiated: attempting to instantiate the class before setting these will trigger an exception."""
       _indexInitialised = False
       _inx = None
       _urlBase = ''
       _htmlStyle = {}
       _linkAttrStyle = {}
       __charmeEnable__ = {}
       _extraHtml = {}
       _strictRequired = False

       def __init__(self,idict=None,xmlMiniDom=None,id='defaultId',etree=False):
         self._strictRead = True
         dictMode = idict != None
         mdMode = xmlMiniDom != None
         self._htmlTtl = None
         assert not( dictMode and mdMode), 'Mode must be either dictionary of minidom: both assigned'
         assert dictMode or mdMode, 'Mode must be either dictionary of minidom: neither assigned'
         ##self._defaults = { }
         ##self._globalDefault = '__unset__'
         self._contentInitialised = False
         self._greenIcon = '<img height="12pt" src="/images/154g.png" alt="[i]"/>'
         if dictMode:
           self.dictInit( idict )
         elif mdMode:
           try:
             self.mdInit( xmlMiniDom, etree=etree )
           except:
             print ('Exception raise initialising data request item')
             raise

       def hasattr(self,tag):
         """Return True id the argument passed is the name of an attribute of this instance."""
         return tag in self.__dict__

       def __repr__(self):
         """Provide a one line summary of identifying the object."""
         if self._contentInitialised:
           return 'Item <%s>: [%s] %s' % (self._h.title,self.label,self.title)
         else:
           return 'Item <%s>: uninitialised' % self._h.title

       def __info__(self,full=False):
         """Print a summary of the data held in the object as a list of key/value pairs"""
         if self._contentInitialised:
           print ( 'Item <%s>: [%s] %s' % (self._h.title,self.label,self.title) )
           for a in self.__dict__.keys():
             if a[0] != '_' or full:
               if hasattr( self._a[a], 'useClass') and self._a[a].useClass == 'internalLink' and self._base._indexInitialised:
                 if self.__dict__[a] in self._base._inx.uid:
                   targ = self._base._inx.uid[ self.__dict__[a] ]
                   print ( '   %s: [%s]%s [%s]' % ( a, targ._h.label, targ.label, self.__dict__[a] ) )
                 else:
                   print ( '   %s: [ERROR: key not found] [%s]' % ( a, self.__dict__[a] ) )
               else:
                 print ( 'INFO:    %s: %s' % ( a, self.__dict__[a] ) )
         else:
           print ( 'Item <%s>: uninitialised' % self.sectionLabel )

       def __href__(self,odir="",label=None,title=None):
         """Generate html text for a link to this item."""
         igns =  ['','__unset__']
         if title == None:
           if self._htmlTtl == None:
             if 'description' in self.__dict__ and self.description != None and self.description.strip( ) not in igns:
               ttl = self.description
             elif 'title' in self.__dict__ and self.title != None and self.title.strip( ) not in igns:
               ttl = self.title
             else:
               ttl = self.label
             ttl = ttl.replace( '"', '&quot;' )
             ttl = ttl.replace( '<', '&lt;' )
             self._htmlTtl = ttl.replace( '>', '&gt;' )
           title=self._htmlTtl
         if label == None:
             label = self.uid
         if odir == '':
           odir = './'
             
         return '<span title="%s"><a href="%s%s.html">%s</a></span>' % (title,odir,self.uid,label)

       def htmlLinkAttrListStyle(self,a,targ,frm=None):
           xx = '; '.join( ['%s [%s]' % (x.label, x.__href__()) for x in targ])
           return '<li>%s: [%s] %s</li>' % ( a, targ[0]._h.label, xx )

       def getHtmlLinkAttrStyle(self,a):
           """Return a string containing a html fragment for a link to an attribute."""
           if a in self.__class__._linkAttrStyle:
             return self.__class__._linkAttrStyle[a]
           else:
             return lambda a,targ, frm='': '<li>%s: [%s] %s [%s]</li>' % ( a, targ._h.label, targ.label, targ.__href__() )

       def __htmlLink__(self,a, sect,app):
          """Create html line for a link or list of links"""
          if self._a[a].useClass == 'internalLink':
                   lst = self.getHtmlLinkAttrStyle(a)
                   try:
                     targ = self._base._inx.uid[ self.__dict__[a] ]
                     m = lst( app, targ, frm=sect )
                   except:
                     print ( 'INFO.cex.00001:',a, self.__dict__[a], sect, self.label )
                     m = '<li>%s: %s .... broken link</li>' % ( app, self.__dict__[a] )
                     print ( '%s: %s .... broken link' % ( app, self.__dict__[a]  ) )
                     raise
          else:
            assert self._a[a].useClass == 'internalLinkList', 'Unrecognised useClass in __htmlLink__: %s' % self._a[a].useClass
            m = self.htmlLinkAttrListStyle( app, [self._base._inx.uid[u] for u in self.__dict__[a] ], frm=sect )
            return m
          return m
                   ##m = '<li>%s, %s: [%s] %s [%s]</li>' % ( a, self.__class__.__dict__[a].__href__(label=self._greenIcon), targ._h.label, targ.label, targ.__href__() )
       def __html__(self,ghis=None):
         """Create html view"""
         msg = []
         if self._contentInitialised:
           sect = self._h.label
           msg.append( '<h1>%s: [%s] %s</h1>' % (self._h.title,self.label,self.title) )
           if sect in self.__charmeEnable__:
             msg.append( charmeTempl % (self.__charmeEnable__[sect].site, 'u', self.uid) )
           msg.append( '<a href="../index.html">Home</a> &rarr; <a href="../index/%s.html">%s section index</a><br/>\n' % (sect, self._h.title) )
           msg.append( '<ul>' )
           for a in self.__dict__.keys():
             if a[0] != '_':
               app = '%s%s' % (a, self.__class__.__dict__[a].__href__(label=self._greenIcon) )
               if hasattr( self._a[a], 'useClass') and self._a[a].useClass in ['internalLink','internalLinkList'] and self._base._indexInitialised:
                 if self.__dict__[a] == '__unset__':
                   m = '<li>%s: %s [missing link]</li>' % ( app, self.__dict__[a] )
                 else:
                   m = self.__htmlLink__(a, sect,app)
               elif hasattr( self._a[a], 'useClass') and self._a[a].useClass == 'externalUrl':
                 m = '<li>%s: <a href="%s" title="%s">%s</a></li>' % ( app, self.__dict__[a], self._a[a].description, self._a[a].title )
               else:
                 m = '<li>%s: %s</li>' % ( app, self.__dict__[a] )
               msg.append( m )
           msg.append( '</ul>' )
           sect = self._h.label
           if sect in self._extraHtml:
             rc, href, hlab = self._extraHtml[sect](self)
             if rc:
                msg.append( '<p><a href="%s">%s</a></p>' % (href,hlab) )
##
## add list of inward references
##
           if self._base._indexInitialised:
             msg += self.__irefHtml__(sect,ghis)

           if sect in self.__charmeEnable__:
             msg.append( '<script src="/js/dreq/charme/charme.js"></script>' )
         else:
           msg.append( '<b>Item %s: uninitialised</b>' % self.sectionLabel )
         return msg


       def __irefHtml__(self, sect,ghis):
         """Returns html (as a list of text strings) for inward references"""
         if self._htmlStyle.get( sect, {} ).get( 'getIrefs', None ) == None:
           return []
         
         tl = self._htmlStyle[sect]['getIrefs']
         doall = '__all__' in tl
         if doall:
           tl = self._inx.iref_by_sect[self.uid].a.keys()
         tl1 = []
         for t in tl:
           if t in self._inx.iref_by_sect[self.uid].a and len( self._inx.iref_by_sect[self.uid].a[t] ) > 0:
             tl1.append( t )
         am = []
         if len(tl1) > 0:
               am.append( '''<div class="demo">\n<div id="tabs">\n<ul>''' )
               for t in tl1:
                   u0 = self._inx.iref_by_sect[self.uid].a[t][0]
                   this1 = '<li><a href="#tabs-%s">%s</a></li>' % (t,self._inx.uid[u0]._h.title )
                   am.append( this1 )
               am.append( '</ul>' )
               for t in tl1:
                   u0 = self._inx.iref_by_sect[self.uid].a[t][0]
                   am.append( '<div id="tabs-%s">' % t )
                   am.append( '<h3>%s</h3>' % self._inx.uid[u0]._h.title )
                   am.append( '<ul>' )
                   items = [self._inx.uid[u] for  u in self._inx.iref_by_sect[self.uid].a[t] ]
                   ##items.sort( ds('label').cmp )
                   items = sorted( items, key=ds('label').key )
                   for targ in items:
                     if ghis == None:
                       m = '<li>%s:%s [%s]</li>' % ( targ._h.label, targ.label, targ.__href__() )
                     else:
                       lst = ghis( targ._h.label )
                       m = lst( targ, frm=sect )
                     am.append( m )
                   am.append( '</ul>' )
                   am.append( '</div>' )
               if len(am) > 0:
                 am.append( '</div>' )
                 am0 = [ '<h2>Links from other sections</h2>' ,]
                 am0.append( ''' <script>
        $(function() {
                $( "#tabs" ).tabs({cookie: { expires: 1 } });
        });
 </script>
<!-- how to make tab selection stick: http://stackoverflow.com/questions/5066581/jquery-ui-tabs-wont-save-selected-tab-index-upon-page-reload  expiry time in days-->''' )
                 return am0 + am
         else:
           return []
               
       def dictInit( self, idict ):
         __doc__ = """Initialise from a dictionary."""
         for a in self._a.keys():
           vv = False
           if a in idict:
             val = idict[a]
             vv = True
           else:
             if type( self.__class__.__dict__[a] ) not in (type( ''), type( u'' )) and (not self.__class__.__dict__[a].required):
               if hasattr( self, a):
                 setattr( self, a, None )
                 ##self.a = None
                 delattr( self, a )
                 ##if a in self.__dict__:
                   ##self.__dict__.pop(a)
               else:
                 print ( 'ERROR: attempt to remove non-existent attribute: %s' % a )
             else:
               val = self._d.defaults.get( a, self._d.glob )
               vv = True
           if vv:
             setattr( self, a, val )
         self._contentInitialised = True

       def mdInit( self, el, etree=False ):
         __doc__ = """Initialisation from a mindom XML element. The list of attributes must be set by the class factory before the class is initialised"""
         deferredHandling=False
         nw1 = 0
         tvtl = []
         if etree:
           ks = set( el.keys() )
           for a in self._a.keys():
             if a in ks:
               aa = '%s%s' % (self.ns,a)
               tvtl.append( (a,True, str( el.get( a ) ) ) )
             elif self._a[a].__dict__.get( 'required', True ) in [False,'false',u'false']:
               tvtl.append( (a,True,None) )
             else:
               tvtl.append( (a,False,None) )
               if self._strictRequired:
                 assert False, 'Required attribute absent: %s:: %s' % (a,str(el.__dict__))
         else:
           for a in self._a.keys():
             if el.hasAttribute( a ):
               tvtl.append( (a,True, str( el.getAttribute( a ) ) ) )
##
## attributes are treated as required unless they have a required attribute set to false
##
             elif self._a[a].__dict__.get( 'required', True ) not in [False,'false',u'false']:
               tvtl.append( (a,False,None) )
       
         for a,tv,v in tvtl:
           if a == 'uid':
             uid = v

         for a,tv,v in tvtl:
           if tv:
             erase = False
             if v == None:
               pass
               erase = True
             elif self._a[a].type == u'xs:float':
               if v == '':
                 v = None
               else:
                 try:
                   v = float(v)
                 except:
                   print ( 'Failed to convert real number: %s,%s,%s' % (a,tv,v) )
                   raise
             elif self._a[a].type in [u'aa:st__floatList', u'aa:st__floatListMonInc']:
                 v = [float(x) for x in v.split()]
             elif self._a[a].type in [u'aa:st__integerList', u'aa:st__integerListMonInc']:
               try:
                 v = [int(x) for x in v.split()]
               except:
                 v = [int(float(x)) for x in v.split()]
                 print ('WARN: non-compliant integer list [%s:%s]: %s' % (thissect,a,v))
               if self._a[a].type in [u'aa:st__integerListMonInc'] and self._strictRead:
                   for i in range(len(v)-1):
                     assert v[i] <= v[i+1], 'Attribute %s of type %s with non-monotonic value: %s' % (a,self._a[a].type,str(v))
             elif self._a[a].type == u'xs:integer':
               if self._rc.isIntStr( v ):
                 v = int(v)
               else:
                 v = v.strip()
                 thissect = '%s [%s]' % (self._h.title,self._h.label)
                 if v in [ '',u'',' ', u' ', [], '[]']:
                   if nw1 < 20:
                     print ( 'WARN.050.0001: input integer non-compliant: %s: %s: "%s" -- set to zero' % (thissect,a,v) )
                     nw1 += 1
                   v = 0
                 else:
                   try:
                     v0 = v
                     v = int(float(v))
                     print ( 'WARN: input integer non-compliant: %s: %s: %s [%s] %s' % (thissect,a,v0,v,uid) )
                   except:
                     msg = 'ERROR: failed to convert integer: %s: %s: %s, %s' % (thissect,a,v,type(v))
                     deferredHandling=True
             elif self._a[a].type == u'xs:boolean':
               v = v in ['true','1']
             elif self._a[a].type == u'aa:st__stringList':
               if v.find(' ') != -1:
                 v = tuple( v.split() )
               else:
                 v = (v,)
             elif self._a[a].type not in [u'xs:string', u'aa:st__uid', 'aa:st__fortranType', 'aa:st__configurationType','aa:st__sliceType']:
               print ('ERROR: Type %s not recognised [%s:%s]' % (self._a[a].type,self._h.label,a) )

             if erase:
               ### need to overwrite attribute (which is inherited from parent class) before deleting it.
               ### this may not be needed in python3
               self.__dict__[a] = '__tmp__'
               delattr( self, a )
             else:
               self.__dict__[a] = v
           else:
             if a in ['uid',]:
               thissect = '%s' % (self._h.title)
               print ( 'ERROR.020.0001: missing uid: %s: a,tv,v: %s, %s, %s\n %s' % (thissect,a,tv,v,str( self.__dict__ )) )
               if etree:
                 ##p = self.parent_map( el )
                 print ( ks )
                 raise
                 import sys
                 sys.exit(0)
             self.__dict__[a] = self._d.defaults.get( a, self._d.glob )

           if deferredHandling:
             print ( msg )

         self._contentInitialised = True

    
class config(object):
  """Read in a vocabulary collection configuration document and a vocabulary document"""

  def __init__(self, configdoc='out/dreqDefn.xml', thisdoc='../workbook/trial_20150724.xml', manifest=None, useShelve=False, strings=False,configOnly=False,lxml=False):
    self.rc = rechecks()
    self.lu = lutilsC()
    self.silent = True
    self.configOnly = configOnly
    self.coll = {}
    self.recordAttributeDefn = {}

    self.nts = collections.namedtuple( 'sectdef', ['tag','label','title','id','itemLabelMode','level','maxOccurs','labUnique','uid','description'] )
    self.nti = collections.namedtuple( 'itemdef', ['tag','label','title','type','useClass','techNote','required'] )
    self.ntt = collections.namedtuple( 'sectinit', ['header','attributes','defaults'] )
    self.nt__default = collections.namedtuple( 'deflt', ['defaults','glob'] )
    self.ntf = collections.namedtuple( 'sect', ['header','attDefn','items'] )
    self.bscc = loadBS(blockSchemaFile)
    self.strings = strings
    self.docl = []

    self._desc = {}
    self.tt0 = {}
    self.tt1 = {}
    self.ttl2 = []
    self.docs = {}
    self.version = None
    self.useLxml = lxml

    if manifest != None:
      assert os.path.isfile( manifest ), 'Manifest file not found: %s' % manifest
      ii = open(manifest).readlines() 
      docl = []
      for l in ii[1:]:
        bits = l.strip().split()
        assert len( bits ) > 1, 'Failed to parse line in manifest %s: \n%s' % (manifest,l)
        bb = []
        for b in bits[:2]:
          if not os.path.isfile( b ):
             b = '%s/%s' % (PACKAGE_DIR,b)
          assert os.path.isfile( b ), 'File %s not found (listed in %s)' % (b,manifest )
          bb.append( b )
        docl.append( tuple( bb ) )
      for d,c in docl:
        self.__read__(d, c)
    else:
      self.__read__(thisdoc, configdoc)

  def getByUid(self,uid):
    mmm = []
    for fn,rr in self.docs.items():
       root, doc = rr
       mm = root.findall( ".//*[@uid='%s']" % uid )
       mmm += mm
       print ('%s: %s' % (fn, str(mm)) )
    return mmm

  def __read__(self, thisdoc, configdoc):
    self.vdef = configdoc
    self.vsamp = thisdoc
    self.docl.append( (thisdoc,configdoc) )
    fn = thisdoc.split( '/' )[-1]

    if self.strings:
      doc = xml.dom.minidom.parseString( self.vdef  )
    else:
      doc = xml.dom.minidom.parse( self.vdef  )
##
## elementTree parsing implemented for main document
##
    self.etree = False
    self.etree = True
    self.ns = None
    if not self.configOnly:
      if self.etree:
        if self.useLxml:
          import lxml
          import lxml.etree as et
        else:
          import xml.etree.cElementTree as cel
      
        if not pythonPre27:
          ## this for of namespace registration not available in 2.6
          ## absence of registration means module cannot write data exactly as read.
          ##
          if self.useLxml:
            ##et.register_namespace('', "urn:w3id.org:cmip6.dreq.dreq:a")
            et.register_namespace('pav', "http://purl.org/pav/2.3")
          else:
            cel.register_namespace('', "urn:w3id.org:cmip6.dreq.dreq:a")
            cel.register_namespace('pav', "http://purl.org/pav/2.3")

        if not self.strings:
          if self.useLxml:
            ##parser = etree.XMLParser( remove_blank_text=True )
            ##self.contentDoc = et.parse( self.vsamp, parser  )
            self.contentDoc = et.parse( self.vsamp  )
          elif python2:
            parser = getParser()()
            self.contentDoc = cel.parse( self.vsamp, parser=parser )
          else:
            self.contentDoc = cel.parse( self.vsamp )

          root = self.contentDoc.getroot()
        else:
          root = cel.fromstring(self.vsamp)

        self.docs[fn] = (root, self.contentDoc)
        bs = root.tag.split( '}' )
        if len( bs ) > 1:
          self.ns = bs[0] + '}'
        else:
          self.ns = None
        vl = root.findall( './/{http://purl.org/pav/2.3}version' )
        if self.version != None:
          if vl[0].text != self.version:
            print ('WARNING: version difference between %s [%s] and %s [%s]' % (self.docl[0][0],self.version,thisdoc,vl[0].text) )
        else:
          self.version = vl[0].text
        self.parent_map = dict((c, p) for p in root.getiterator() for c in p)
      else:
        if self.strings:
          self.contentDoc = xml.dom.minidom.parseString( self.vsamp  )
        else:
          self.contentDoc = xml.dom.minidom.parse( self.vsamp )

          vl = self.contentDoc.getElementsByTagName( 'prologue' )
          v = vl[0].getElementsByTagName( 'pav:version' )
          self.version = v[0].firstChild.data
        self.ns = None

    vl = doc.getElementsByTagName( 'table' ) + doc.getElementsByTagName( 'annextable' )
    self.tables = {}
    tables = {}
    self.tableClasses = {}
    self.tableItems = collections.defaultdict( list )
##
## this loads in some metadata, but not yet in a useful way.
##
    self._t0 = self.parsevcfg(None)
    self._t2 = self.parsevcfg('__main__')
    self._tableClass0 = self.lu.itemClassFact( self._t0, ns=self.ns )
##
## define a class for the section heading records.
##
    self._t1 = self.parsevcfg('__sect__')
##
## when used with manifest .. need to preserve entries in "__main__" from each document.
##
    self._sectClass0 = self.lu.itemClassFact( self._t1, ns=self.ns )

    for k in self.bscc:
      self.tt0[k] = self._tableClass0(idict=self.bscc[k])
      if k in self._t0.attributes:
        setattr( self._tableClass0, '%s' % k, self.tt0[k] )
      if k in self._t1.attributes:
        setattr( self._sectClass0, '%s' % k, self.tt0[k] )

##
## save header information, as for recordAttributeDefn below
##
    self._recAtDef = {'__core__':self._t0, '__sect__':self._t1}
##
## addition of __core__ to coll dictionary ..
##
    self.coll['__core__'] = self.ntf( self._t0.header, self._t0.attributes, [self.tt0[k] for k in self.tt0] )

    ec = {}
    for i in self.coll['__core__'].items:
      ec[i.label] = i


    for v in vl:
      t = self.parsevcfg(v)
      tables[t[0].label] = t
      self.tableClasses[t[0].label] = self.lu.itemClassFact( t, ns=self.ns )
      thisc = self.tableClasses[t[0].label]
      self.tt1[t[0].label] = self._sectClass0( idict=t.header._asdict() )
      self.tt1[t[0].label].maxOccurs = t.header.maxOccurs
      self.tt1[t[0].label].labUnique = t.header.labUnique
      self.tt1[t[0].label].level = t.header.level
      self.tt1[t[0].label].uid = t.header.uid
      self.tt1[t[0].label].itemLabelMode = t.header.itemLabelMode
      self._desc[t[0].label] = t.header.description
      self.ttl2 += [thisc.__dict__[a] for a in t.attributes]
    mil = [t[1] for t in self._t2.attributes.items()]
    self.coll['__main__'] = self.ntf( self._t2.header, self._t2.attributes, self.ttl2 )

    self.coll['__sect__'] = self.ntf( self._t1.header, self._t1.attributes, [self.tt1[k] for k in self.tt1] )

    for sct in ['__core__','__main__','__sect__']:
      for k in self.coll[sct].attDefn.keys():
        assert k in ec, 'Key %s [%s] not found' % (k,sct)
        self.coll[sct].attDefn[k] = ec[k]

    for k in tables:
      self.recordAttributeDefn[k] = tables[k]

    if self.configOnly:
      return
    for k in tables.keys():
      if self.etree:
        vl = root.findall( './/%s%s' % (self.ns,k) )
        if len(vl) == 1:
          v = vl[0]
          t = v.get( 'title' )
          i = v.get( 'id' )
          uid = v.get( 'uid' )
          useclass = v.get( 'useClass' )

          self.tt1[k].label = k
          self.tt1[k].title = t
          self.tt1[k].id = i
          self.tt1[k].uid = uid
          self.tt1[k].useClass = useclass
          self.tableClasses[k]._h = self.tt1[k]
          il = v.findall( '%sitem' % self.ns )
          self.info( '%s, %s, %s, %s' % ( k, t, i, len(il) ) )
 
          self.tables[k] = (i,t,len(il))
        
          for i in il:
            try:
              ii = self.tableClasses[k](xmlMiniDom=i, etree=True)
            except:
              print ('Exception raises instantiating item in section %s' % k)
              print ('At item uid=%s' % str(i) )
              raise
            self.tableItems[k].append( ii )
        elif len(vl) > 1:
          assert False, 'not able to handle repeat sections with etree yet'
      else:
        vl = self.contentDoc.getElementsByTagName( k )
        if len(vl) == 1:
          v = vl[0]
          t = v.getAttribute( 'title' )
          i = v.getAttribute( 'id' )
          il = v.getElementsByTagName( 'item' )
          self.info( '%s, %s, %s, %s' % ( k, t, i, len(il) ) )
 
          self.tables[k] = (i,t,len(il))
        
          for i in il:
            ii = self.tableClasses[k](xmlMiniDom=i)
            self.tableItems[k].append( ii )
        elif len(vl) > 1:
          l1 = []
          l2 = []
          for v in vl:
            t = v.getAttribute( 'title' )
            i = v.getAttribute( 'id' )
            il = v.getElementsByTagName( 'item' )
            self.info( '%s, %s, %s, %s' % ( k, t, i, len(il) ) )
            l1.append( (i,t,len(il)) )
          
            l2i = []
            for i in il:
              ii = self.tableClasses[k](xmlMiniDom=i)
              l2i.append( ii )
            l2.append( l2i )
          self.tables[k] = l1
          self.tableItems[k] = l2
      self.coll[k] = self.ntf( self.recordAttributeDefn[k].header, self.recordAttributeDefn[k].attributes, self.tableItems[k] )
 
  def info(self,ss):
    """Switchable print function ... switch off by setting self.silent=True"""
    if not self.silent:
      print ( ss )

  def parsevcfg(self,v):
      """Parse a section definition element, including all the record attributes. The results are returned as a named tuple of attributes for the section and a dictionary of record attribute specifications."""
      if v in [ None,'__main__']:
        idict = {'description':'An extended description of the object', 'title':'Record Description', \
           'techNote':'', 'useClass':'__core__', 'superclass':'rdf:property',\
           'type':'xs:string', 'uid':'__core__:description', 'label':'label', 'required':'required' }
        if v == None:
          vtt = self.nts( '__core__', 'CoreAttributes', 'X.1 Core Attributes', '00000000', 'def', '0', '0', 'false', '__core__', 'The core attributes, used in defining sections and attributes' )
        else:
          vtt = self.nts( '__main__', 'DataRequestAttributes', 'X.2 Data Request Attributes', '00000001', 'def', '0', '0', 'false', '__main__' , 'The attributes used to define data request records')
      elif v == '__sect__':
        idict = {'title':'Record Description', \
         'uid':'__core__:description', 'label':'label', 'useClass':'text', 'id':'id', 'maxOccurs':'', 'itemLabelMode':'', 'level':'', 'labUnique':'' }
        vtt = self.nts( '__sect__', 'sectionAttributes', 'X.3 Section Attributes', '00000000', 'def', '0', '0', 'false', '__sect__', 'The attributes used to define data request sections' )
##<var label="var" uid="SECTION:var" useClass="vocab" title="MIP Variable" id="cmip.drv.001">
      else:
        l = v.getAttribute( 'label' )
        t = v.getAttribute( 'title' )
        i = v.getAttribute( 'id' )
        u = v.getAttribute( 'uid' )
        ilm = v.getAttribute( 'itemLabelMode' )
        lev = v.getAttribute( 'level' )
        maxo = v.getAttribute( 'maxOccurs' )
        labu = v.getAttribute( 'labUnique' )
        des = v.getAttribute( 'description' )
        il = v.getElementsByTagName( 'rowAttribute' )
        ##vtt = self.nts( v.nodeName, l,t,i,ilm,lev, maxo, labu, 's__%s' % v.nodeName )
        vtt = self.nts( v.nodeName, l,t,i,ilm,lev, maxo, labu, u, des )
        idict = {}
        for i in il:
          tt = self.parseicfg(i)
          idict[tt.label] = tt
      deflt = self.nt__default( {}, '__unset__' )

      ## return a named tuple: (header, attributes, defaults)
      return self.ntt( vtt, idict, deflt )

  def parseicfg(self,i):
      """Parse a record attribute specification"""
      defs = {'type':"xs:string"}
      ll = []
      ee = {}
      for k in ['label','title','type','useClass','techNote','description','uid','required']:
        if i.hasAttribute( k ):
          ll.append( i.getAttribute( k ) )
        else:
          ll.append( defs.get( k, None ) )
        ee[k] = ll[-1]
      l, t, ty, cls, tn, desc, uid, rq = ll
      self.lastTitle = t
      if rq in ['0', 'false']:
        rq = False
      else:
        rq = True
      ee['required'] = rq

      returnClass = True
      if returnClass:
        return self._tableClass0( idict=ee )
      else:
        return self.nti( i.nodeName, l,t,ty,cls,tn,rq )

class container(object):
  """Simple container class, to hold a set of dictionaries of lists."""
  def __init__(self, atl ):
    self.uid = {}
    for a in atl:
      self.__dict__[a] =  collections.defaultdict( list )

class c1(object):
  def __init__(self):
    self.a = collections.defaultdict( list )

class index(object):
  """Create an index of the document. Cross-references are generated from attributes with class 'internalLink'. 
This version assumes that each record is identified by an "uid" attribute and that there is a "var" section. 
Invalid internal links are recorded in tme "missingIds" dictionary. 
For any record, with identifier u, iref_by_uid[u] gives a list of the section and identifier of records linking to that record.
"""

  def __init__(self, dreq,lock=True):
    self.silent = True
    self.uid = {}
    self.uid2 = collections.defaultdict( list )
    nativeAtts = ['uid','iref_by_uid','iref_by_sect','missingIds']
    naok = map( lambda x: not x in dreq, nativeAtts )
    assert all(naok), 'This version cannot index collections containing sections with names: %s' % str( nativeAtts )
    self.var_uid = {}
    self.var_by_name = collections.defaultdict( list )
    self.var_by_sn = collections.defaultdict( list )
    self.iref_by_uid = collections.defaultdict( list )
    irefdict = collections.defaultdict( list )
    for k in dreq.keys():
      if 'sn' in dreq[k].attDefn:
         self.__dict__[k] =  container( ['label','sn'] )
      else:
         self.__dict__[k] =  container( ['label'] )
    ##
    ## collected names of attributes which carry internal links
    ##
      for ka in dreq[k].attDefn.keys():
        if hasattr( dreq[k].attDefn[ka], 'useClass') and dreq[k].attDefn[ka].useClass in  ['internalLink','internalLinkList']:
           irefdict[k].append( ka )

    for k in dreq.keys():
        for i in dreq[k].items:
          assert 'uid' in i.__dict__, 'uid not found::\n%s\n%s' % (str(i._h),str(i.__dict__) )
          if 'uid' in self.uid:
            print ( 'ERROR.100.0001: Duplicate uid: %s [%s]' % (i.uid,i._h.title) )
            self.uid2[i.uid].append( (k,i) )
          else:
### create index bx uid.
            self.uid[i.uid] = i

    self.missingIds = collections.defaultdict( list )
    self.iref_by_sect = collections.defaultdict( c1 )
    for k in dreq.keys():
        for k2 in irefdict.get( k, [] ):
          n1 = 0
          n2 = 0
          for i in dreq[k].items:
            if k2 in i.__dict__:
              id2 = i.__dict__.get( k2 )
              if id2 != '__unset__':
                sect = i._h.label
  ## append attribute name and target  -- item i.uid, attribute k2 reference item id2
                if type(id2) not in [type( [] ),type(())]:
                  id2 = [id2,]
                for u in id2:
                  self.iref_by_uid[ u ].append( (k2,i.uid) )
                  self.iref_by_sect[ u ].a[sect].append( i.uid )
                  if u in self.uid:
                    n1 += 1
                  else:
                    n2 += 1
                    self.missingIds[u].append( (k,k2,i.uid) )
          self.info(  'INFO:: %s, %s:  %s (%s)' % (k,k2,n1,n2) )

    for k in dreq.keys():
      for i in dreq[k].items:
        self.__dict__[k].uid[i.uid] = i
        self.__dict__[k].label[i.label].append( i.uid )
        if 'sn' in dreq[k].attDefn:
          self.__dict__[k].sn[i.sn].append( i.uid )

    if lock:
      for k in self.iref_by_uid:  
         self.iref_by_uid[k] = tuple( self.iref_by_uid[k] )
      for k in self.iref_by_sect:
        for s in self.iref_by_sect[ k ].a:
          self.iref_by_sect[ k ].a[s] = tuple( self.iref_by_sect[ k ].a[s] )

  def info(self,ss):
    if not self.silent:
      print ( ss )

class ds(object):
  """Comparison object to assist sorting of lists of dictionaries"""
  def __init__(self,k):
    self.k = k
  def cmp(self,x,y):
    return cmp( x.__dict__[self.k], y.__dict__[self.k] )
  def key(self,x):
    return x.__dict__[self.k]

class kscl(object):
  """Comparison object to assist sorting of dictionaries of class instances"""
  def __init__(self,idict,k):
    self.k = k
    self.idict = idict
  def cmp(self,x,y):
    return cmp( self.idict[x].__dict__[self.k], self.idict[y].__dict__[self.k] )
  def key(self,x):
    return self.idict[x].__dict__[self.k]

src1 = '../workbook/trial_20150831.xml'

#DEFAULT LOCATION -- changed automatically when building distribution
defaultDreq = 'dreq.xml'
#DEFAULT CONFIG
defaultConfig = 'dreq2Defn.xml'

defaultDreqPath = '%s/%s' % (DOC_DIR, defaultDreq )
defaultConfigPath = '%s/%s' % (DOC_DIR, defaultConfig )
defaultManifestPath = '%s/dreqManifest.txt' % DOC_DIR

class loadDreq(object):
  """Load in a vocabulary document.
  dreqXML: full path to the XML document
  configdoc: full path to associated configuration document
  useShelve: flag to specify whether to retrieve data from cache (not implemented)
  htmlStyles: dictionary of styling directives which influence structure of html page generates by the "makeHtml" method
  lxml [False]: if true, use python lxml package for elementree module instead of the default xml package.
"""

  def __init__(self, xmlVersion=None, dreqXML=None, configdoc=None, useShelve=False, htmlStyles=None, strings=False, manifest=defaultManifestPath , configOnly=False,lxml=False):
    self._extensions_ = {}
    if xmlVersion != None:
      assert os.path.isdir( VERSION_DIR ),'Version diretory %s not found;\nCreate or change environment variable DRQ_VERSION_DIR' % VERSION_DIR 
      assert os.path.isdir( '%s/%s' % (VERSION_DIR,xmlVersion) ), 'Version %s not in %s .. download from ..' % (xmlVersion,VERSION_DIR)
      dreqXML='%s/%s/dreq.xml' % (VERSION_DIR,xmlVersion)
      configdoc='%s/%s/dreq2Defn.xml' % (VERSION_DIR,xmlVersion)
      manifest = None
    elif manifest == None:
      if dreqXML == None:
       dreqXML=defaultDreqPath
      if configdoc==None:
       configdoc=defaultConfigPath
    self._VERSION_DIR_ = VERSION_DIR
    self.c = config( thisdoc=dreqXML, configdoc=configdoc, useShelve=useShelve,strings=strings,manifest=manifest,configOnly=configOnly,lxml=lxml)
    self.coll = self.c.coll
    self.version = self.c.version
    self.softwareVersion = version
    self.indexSortBy = {}
    if not configOnly:
      self.inx = index(self.coll)
      self.itemStyles = {}
      self.defaultItemLineStyle = lambda i, frm='', ann='': '<li>%s: %s</li>' % ( i.label, i.__href__(odir='../u/') )
##
## add index to Item base class .. so that it can be accessed by item instances
##
      dreqItemBase._inx = self.inx
      dreqItemBase._indexInitialised = True
##
## load in additional styling directives
##
      if htmlStyles != None:
        for k in htmlStyles:
          dreqItemBase._htmlStyle[k] = htmlStyles[k]

##    dreqItemBase._htmlStyle['__general__'] = {'addRemarks':True}

      self.pageTmpl = """<html><head><title>%%s</title>
%%s
<link rel="stylesheet" type="text/css" href="%%scss/dreq.css">
%s
</head><body>

<div id="top">
   <div id="corner"></div>
   CMIP6 Data Request
</div>
<div id="nav"><div><a href="%%s" title="Home">Home</a></div></div>

<div id="section">
%%s
</div>
</body></html>"""  % dreqMonitoring

  def getHtmlItemStyle(self, sect):
    """Get the styling method associated with a given section."""
    if sect in self.itemStyles:
      return self.itemStyles[sect]
    return self.defaultItemLineStyle

  def updateByUid( self, uid, dd, delete=[] ):
    typePar={'xs:string':'x', 'xs:integer':0, 'xs:float':1., 'xs:boolean':True, 'xs:duration':'x', 'aa:st__sliceType':'simpleRange','aa:st__fortrantype':'real'}
    listTypePar={ "aa:st__integerList":1,"aa:st__integerListMonInc":1, "aa:st__stringList":'x', "aa:st__floatList":1. }

    mmm = self.c.getByUid( uid )
    assert len(mmm) == 1, 'Expected single uid match, found: %s' % len(mmm)
    thisdoc = mmm[0]
    item = self.inx.uid[uid]
    d1 = [d for d in delete if d not in item._a]
    e1 = len(d1) > 0
    if e1:
      print ('ERROR.update.0001: request to delete non-existent keys: %s' % d1 )
    d1 = [d for d in delete if d in item._a and item._a[d].required ]
    e1b = len(d1) > 0
    if e1b:
      print ('ERROR.update.0002: request to delete required attributes: %s' % d1 )
    d2 = [d for d in dd if d not in item._a]
    e2 = len(d2) > 0
    if e2:
      print ('ERROR.update.0003: request to modify non-existent keys: %s' % d2 )
    e3 = []
    for k in [d for d in dd if d in item._a]:
      if item._a[k].type in typePar:
        e3.append( type( dd[k] ) != type( typePar[item._a[k].type] ) )
        if e3[-1]:
          print ('ERROR.update.0004: value has wrong type [%s] %s --- %s' % (item._a[k].type, dd[k], type( dd[k] ) ) )
      elif item._a[k].type in listTypePar:
        a = type( dd[k] ) not in [type( [] ), type( () )]
        if a:
          print ('ERROR.update.0005: value has wrong type [%s] %s --- should be list or tuple' % (item._a[k].type, dd[k] ) )
        else:
          a = not all( [type(x) == type(listTypePar[item._a[k].type]) for x in dd[k]] )
          if a:
            print ('ERROR.update.0005: value has wrong type [%s] %s --- %s' % (item._a[k].type, dd[k], [type(x)for x in dd[k]] ) )

        if not a and item._a[k].type == 'aa:st__integerListMonInc':
          a = not all( [dd[k][i+1] > dd[k][i] for i in range( len(dd[k]) -1 )] )
          if a:
            print ('ERROR.update.0006: value should be a monotonic increasing integer list: %s' % str( dd[k] ) )
        e3.append(a)
      else:
        print ( 'Type not recognised: %s' % item._a[k].type )
        e3.append( False )
    eee = any([e1,e1b,e2,any(e3)])
    assert not eee, 'STOPPING: validation errors'
    self.thisdoc = thisdoc
    for k in dd:
      thisdoc.set( k, self.__string4xml__( dd[k], item._a[k].type ) )
      item.__dict__[k] = dd[k]

  def saveXml( self, docfn=None, targ=None ):
    if docfn == None:
      docfn, tt = self.c.docs.items()[0]
    else:
      tt = self.c.docs[docfn]

    if targ == None:
      targ = docfn
    tt[1].write( targ )
    print ('XML document saved to %s' % targ)
 
  def __string4xml__(self,v,typ):
    if typ in ['xs:string','xs:duration','aa:st__sliceType']:
       return v
    elif typ in ['xs:integer', 'xs:float', 'xs:boolean']:
       return str(v)
    elif typ == "aa:st__stringList":
       return ' '.join(v)
    elif typ in ["aa:st__integerList","aa:st__integerListMonInc", "aa:st__floatList"]:
       return ' '.join( [str(x) for x in v] )
    else:
       assert False, 'Data type not recognised'
      
  def _sectionSortHelper(self,title):

    ab = title.split(  )[0].split('.')
    if len( ab ) == 2:
      a,b = ab

      if self.c.rc.isIntStr(a):
        a = '%3.3i' % int(a)
      if self.c.rc.isIntStr(b):
        b = '%3.3i' % int(b)
      rv = (a,b)
    elif len(ab) == 1:
      rv = (ab[0],0)
    else:
      rv = ab 
    return rv

  def makeHtml(self,odir='./html', ttl0 = 'Data Request Index', annotations=None):
    """Generate a html view of the vocabularies, using the "__html__" method of the vocabulary item class to generate a
page for each item and also generating index pages.
    odir: directory for html files;
    ttl0: Title for main index (in odir/index.html)"""
    markup = utilities.markupHtml( '' )

    ks = self.inx.uid.keys()
    ##ks.sort( kscl( self.inx.uid, 'title' ).cmp )
    ks = sorted( ks, key=kscl( self.inx.uid, 'title' ).key )
    for k in ks:
      i = self.inx.uid[k]
      ttl = 'Data Request Record: [%s]%s' % (i._h.label,i.label)
      bdy = '\n'.join( i.__html__( ghis=self.getHtmlItemStyle ) )
      oo = open( '%s/u/%s.html' % (odir,i.uid), 'w' )
      oo.write( self.pageTmpl % (ttl, jsh, '../', '../index.html', bdy ) )
      oo.close()

    subttl1 = 'Overview tables and search'
    subttl2 = 'Sections of the data request'
    msg0 = ['<h1>%s</h1>' % ttl0, '<h2>%s</h2>' % subttl1, '<ul>',]
    msg0.append( '<li><a href="tab01_3_3.html">Overview: all variables and experiments</a></li>' )
    msg0.append( '<li><a href="tab01_1_1.html">Overview: priority 1 variables, tier 1 experiments</a></li>' )
    msg0.append( '<li><a href="tab01_1_1_dn.html">Overview: priority 1 variables, tier 1 experiments (grid default to native)</a></li>' )
    msg0.append( '<li><a href="mipVars.html">Search for variables</a></li>' )
    msg0.append( '<li><a href="experiments.html">Search for experiments</a></li>' )
    msg0 += ['</ul>', '<h2>%s</h2>' % subttl2, '<ul>',]
    ks = sorted( self.coll.keys() )
    ee = {}
    for k in ks:
      ee[self.coll[k].header.title] = k
    kks = sorted( ee.keys(),  key = self._sectionSortHelper )
    for kt in kks:
      k = ee[kt]
##
## sort on item label
##
      if annotations != None and k in annotations:
        ann = annotations[k]
      else:
        ann = {}

      sortkey = self.indexSortBy.get( k,'title')
      ##self.coll[k].items.sort( ds(self.indexSortBy.get( k,'title') ).cmp )
      items = sorted( self.coll[k].items, key=ds(sortkey).key )
      ttl = 'Data Request Section: %s' % k
      msg0.append( '<li><a href="index/%s.html">%s [%s]</a></li>\n' % (k,self.coll[k].header.title,k) )
      msg = ['<h1>%s</h1>\n' % ttl, '<ul>',]
      msg.append( '<a href="../index.html">Home</a><br/>\n' )
      msg.append( '<p>%s</p>\n' % markup.parse( self.coll[k].header.description ) )
      lst = self.getHtmlItemStyle(k)
      
      msg1 = []
      for i in items:
        ##m = '<li>%s: %s</li>' % ( i.label, i.__href__(odir='../u/') )
       
        m = lst( i, ann=ann.get( i.label ) )
        msg1.append( m )
      if k in self.indexSortBy:
        msg += msg1
      else:
        msg += sorted( msg1 )
      msg.append( '</ul>' )
      bdy = '\n'.join( msg )
      oo = open( '%s/index/%s.html' % (odir,k), 'w' )
      oo.write( self.pageTmpl % (ttl, '', '../', '../index.html', bdy ) )
      oo.close()
    msg0.append( '</ul>' )
    bdy = '\n'.join( msg0 )
    oo = open( '%s/index.html' % odir, 'w' )
    oo.write( self.pageTmpl % (ttl0, '', '', 'index.html', bdy ) )
    oo.close()
    
if __name__ == '__main__':
  dreq = loadDreq(manifest='out/dreqManifest.txt' )

