import collections, os, sys
nt__charmeEnable = collections.namedtuple( 'charme', ['id','site'] )

try:
  import dreq
  import vrev
  import misc_utils
  import rvgExtraTable
  import volsum
  import table_utils
except:
  import dreqPy.volsum as volsum
  import dreqPy.dreq as dreq
  import dreqPy.vrev as vrev
  import dreqPy.misc_utils as misc_utils
  import dreqPy.table_utils as table_utils
  import dreqPy.rvgExtraTable as rvgExtraTable

python2 = True
if sys.version_info[0] == 3:
  python2 = False
  def cmp(x,y):
    if x == y:
      return 0
    elif x > y:
      return 1
    else:
      return -1

setMlab = misc_utils.setMlab

#priority	long name	units 	comment 	questions & notes	output variable name 	standard name	unconfirmed or proposed standard name	unformatted units	cell_methods	valid min	valid max	mean absolute min	mean absolute max	positive	type	CMOR dimensions	CMOR variable name	realm	frequency	cell_measures	flag_values	flag_meanings

strkeys = [u'procNote', u'uid', u'odims', u'flag_meanings', u'prov', u'title', u'tmid', u'label', u'cell_methods', u'coords', u'cell_measures', u'spid', u'flag_values', u'description']

ntstr = collections.namedtuple( 'ntstr', strkeys )

class cmpd(object):
  def __init__(self,k):
    self.k = k
  def cmp(self,x,y):
    return cmp( x.__dict__[self.k], y.__dict__[self.k] )

class cmpd2(object):
  def __init__(self,k1,k2):
    self.k1 = k1
    self.k2 = k2
  def cmp(self,x,y):
    if x.__dict__[self.k1] == y.__dict__[self.k1]:
      return cmp( x.__dict__[self.k2], y.__dict__[self.k2] )
    else:
      return cmp( x.__dict__[self.k1], y.__dict__[self.k1] )

class cmpdn(object):
  def __init__(self,kl):
    self.kl = kl
  def cmp(self,x,y):
    for k in self.kl:
      if x.__dict__[k] != y.__dict__[k]:
        return cmp( x.__dict__[k], y.__dict__[k] )
    
    return cmp( 0,0 )

import re

class makePurl(object):
  def __init__(self,dq):
    c1 = re.compile( '^[a-zA-Z][a-zA-Z0-9]*$' )
    mv = dq.coll['var'].items
    oo = open( 'htmlRewrite.txt', 'w' )
    for v in mv:
      if c1.match( v.label ):
         oo.write( 'RewriteRule ^%s$ http://clipc-services.ceda.ac.uk/dreq/u/%s.html\n' % (v.label,v.uid) )
      else:
         print ('Match failed: %s' % v.label )
    oo.close()
      

hdr = """
function f000(value) { return (value + "").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;") };

function formatter00(row, cell, value, columnDef, dataContext) {
        var vv = value.split(" ");
        return '<b><a href="u/' + vv[1] + '.html">' + (vv[0] + " ").replace(/&/g,"&amp;") + '</a></b>, ';
    };
function formatter01(row, cell, value, columnDef, dataContext) { return '<i>' + f000(value) + '</i> ' };
function formatter02(row, cell, value, columnDef, dataContext) { return '[' + f000(value) + '] ' };
function formatter03(row, cell, value, columnDef, dataContext) { if (value != "'unset'"  ) { return '(' + f000(value) + ') ' } else {return ''} };
function formatter04(row, cell, value, columnDef, dataContext) { return '{' + f000(value) + '} ' };
function formatter05(row, cell, value, columnDef, dataContext) { return '&lt;' + f000(value) + '&gt; ' };

var getData  = {
cols: function() {
  var columns = [ {id:0, name:'Variable', field:0, width: 100, formatter:formatter00 },
              {id:1, name:'Standard name', field:1, width: 210, formatter:formatter01 },
              {id:2, name:'Long name', field:2, width: 180, formatter:formatter02},
              {id:3, name:'Units', field:3, width: 180, formatter:formatter03},
              {id:4, name:'Description', field:4, width: 180, formatter:formatter04},
              {id:5, name:'uid', field:5, width: 180, formatter:formatter05}];
 return columns;
},

data: function() {
var data = [];
"""
ftr = """return data;
}
};
"""
##rtmpl = 'data[%(n)s] = { "id":%(n)s, 0:"%(var)s",  1:"%(sn)s", 2:"%(ln)s", 3:"%(u)s", 4:"%(uid)s" };'
rtmpl = 'data[%(n)s] = { "id":%(n)s, 0:"%(var)s",  1:"%(sn)s", 2:"%(ln)s", 3:"%(u)s", 4:"%(d)s", 5:"%(uid)s" };'

class htmlTrees(object):
  def __init__(self,dq,odir='html/t/'):
    self.dq = dq
    self.odir = odir
    self.c = vrev.checkVar( dq )
    self.anno = {}
    for v in dq.coll['var'].items:
      self.makeTree( v )
    
  def makeTree( self, v ):
    ee = self.c.chk2( v.label )
    if len(ee.keys()) > 0:
      title = 'Usage tree for %s' % v.label
      bdy = ['<h1>%s</h1>' % title, ]
      bdy.append( '<html><head></head><body>\n' )
      bdy.append( '<ul>\n' )
      for k in sorted( ee.keys() ):
        l1, xx = ee[k]
        lx = list( xx )
        if len( lx ) == 0:
          bdy.append( '<li>%s: Empty</li>\n' % l1 )
        else:
          bdy.append( '<li>%s:\n<ul>' % l1 )
          for x in lx:
            bdy.append( '<li>%s</li>\n' % x )
          bdy.append( '</ul></li>\n' )
      bdy.append( '</ul></body></html>\n' )
      oo = open( '%s/%s.html' % (self.odir,v.label), 'w' )
      oo.write( self.dq.pageTmpl % ( title, '', '../', '../index.html', '\n'.join( bdy ) ) )
      oo.close()
      self.anno[v.label] = '<a href="../t/%s.html">Usage</a>' % v.label
    else:
      self.anno[v.label] = 'Unused'
        

class makeJs(object):
  def __init__(self,dq):
    n = 0
    rl = []
    for v in dq.coll['var'].items:
      if 'CMORvar' in dq.inx.iref_by_sect[v.uid].a and len(dq.inx.iref_by_sect[v.uid].a['CMORvar'] ) > 0:
        var = '%s %s' % (v.label,v.uid)
        sn = v.sn
        ln = v.title
        u = v.units
        d = v.description
        uid = v.uid
        d = locals()
        for k in ['sn','ln','u','var','d']:
    
          if  d[k].find( '"' ) != -1:
            print ( "WARNING ... quote in %s .. %s [%s]" % (k,var,d[k]) )
            d[k] =  d[k].replace( '"', "'" )
            print ( d[k] )
        
        rr = rtmpl % d
        rl.append( rr )
        n += 1
    oo = open( 'data3.js', 'w' )
    oo.write( hdr )
    for r in rl:
      oo.write( r + '\n' )
    oo.write( ftr )
    oo.close()

class styles(object):
  def __init__(self):
    pass

  def rqvLink01(self,targ,frm='',ann=''):
    if targ._h.label == 'remarks':
      return '<li>%s: %s</li>' % ( targ.__href__(odir='../u/', label=targ.title), "Link to request variable broken"  )
    elif frm != "CMORvar":
      cmv = targ._inx.uid[ targ.vid ]
      if targ._h.label == 'remarks':
        return '<li>%s [%s]: %s</li>' % ( cmv.label, targ.__href__(odir='../u/',label=targ.priority) , 'Variable not defined or not found'  )
      else:
        ng = len( targ._inx.iref_by_sect[cmv.uid].a['requestVar'] )
        try:
          nv = len( targ._inx.iref_by_sect[cmv.vid].a['CMORvar'] )
        except:
          print ( 'FAILED: %s' % cmv.uid )
          raise
        return '<li>%s.%s [%s]: %s {groups: %s, vars: %s}</li>' % ( cmv.label,cmv.mipTable, targ.__href__(odir='../u/',label=targ.priority) , cmv.__href__(odir='../u/',label=cmv.title), ng, nv  )
    else:
      rg = targ._inx.uid[ targ.vgid ]
      if targ._h.label == 'remarks':
        return '<li>%s [%s]: %s</li>' % ( targ.label, targ.__href__(label=targ.priority) , 'Link not defined or not found'  )
      elif rg._h.label == 'remarks':
        return '<li>%s [%s]: %s</li>' % ( rg.label, targ.__href__(label=targ.priority) , 'Group not defined or not found'  )
      else:
        return '<li>%s [%s]: %s</li>' % ( rg.label, targ.__href__(label=targ.priority) , rg.__href__(label=rg.mip)  )

  def snLink01(self,a,targ,frm='',ann=''):
    if targ._h.label == 'remarks':
      return '<li>%s: Standard name under review [%s]</li>' % ( a, targ.__href__() )
    else:
      return '<li>%s [%s]: %s</li>' % ( targ._h.title, a, targ.__href__(label=targ.label)  )

  def stidLink01(self,a,targ,frm='',ann=''):
    if targ._h.label == 'remarks':
      return '<li>%s: Broken link to structure  [%s]</li>' % ( a, targ.__href__() )
    else:
      return '<li>%s [%s]: %s [%s]</li>' % ( targ._h.title, a, targ.__href__(label=targ.title), targ.label  )

  def baseLink01(self,targ,frm='',ann=''):
    if targ._h.label == 'remarks':
      return '<li>Broken link [%s]</li>' % ( targ.__href__() )
    else:
      return '<li>%s: %s</li>' % ( targ.label, targ.__href__(odir='../u/',label=targ.title)  )

  def rqlLink02(self,targ,frm='',ann=''):
    t2 = targ._inx.uid[targ.refid]
    if t2._h.label == 'remarks':
      return '<li>%s: %s</li>' % ( targ.__href__(odir='../u/', label=targ.title), "Link to variable group broken"  )
    elif frm == "requestVarGroup":
      return '<li>%s: %s [%s]</li>' % ( targ.__href__(odir='../u/', label=targ.mip), targ.title, targ.objective  )
    else:
      gpsz = len(t2._inx.iref_by_sect[t2.uid].a['requestVar'])
      return '<li>%s: Link to group: %s [%s]</li>' % ( targ.__href__(odir='../u/', label='%s:%s' % (targ.mip,targ.title)), t2.__href__(odir='../u/', label=t2.title), gpsz  )

  def rqiLink02(self,targ,frm='',ann=''):
    t2 = targ._inx.uid[targ.rlid]
    if t2._h.label == 'remarks':
      return '<li>%s: %s</li>' % ( targ.__href__(odir='../u/', label=targ.title), "Link to request link broken"  )
    else:
      try:
        t3 = t2._inx.uid[t2.refid]
      except:
        print ( [t2.uid, t2.__dict__] )
        raise
      if t3._h.label == 'remarks':
        return '<li>%s [%s]: %s</li>' % ( targ.__href__(odir='../u/', label=targ.title), t2.__href__(odir='../u/', label=t2.title),"Link to request group broken"  )
      else:
        nv = len( t3._inx.iref_by_sect[t3.uid].a['requestVar'] )
        return '<li>%s [%s]: %s (%s variables)</li>' % ( targ.__href__(odir='../u/', label=targ.title), t2.__href__(odir='../u/', label=t2.title), t3.__href__(odir='../u/', label=t3.title), nv )

  def snLink(self,targ,frm='',ann=''):
    return '<li>%s [%s]: %s</li>' % ( targ.title, targ.units, targ.__href__(odir='../u/') )

  def varLink(self,targ,frm='',ann=''):
    return '<li>%s: %s [%s]%s</li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.title, targ.units, ann )

  def mipLink(self,targ,frm='',ann=''):
    if targ.url != '':
      return '<li>%s: %s <a href="%s">[project site]</a></li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.title, targ.url )
    else:
      return '<li>%s: %s</li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.title )

  def cmvLink(self,targ,frm='',ann=''):
    t2 = targ._inx.uid[targ.stid]
    if 'requestVar' in targ._inx.iref_by_sect[targ.uid].a:
      nrq = len( targ._inx.iref_by_sect[targ.uid].a['requestVar'] )
    else:
      nrq = 'unused'
    return '<li>%s {%s}: %s [%s: %s] (%s)</li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.mipTable, targ.title, targ.frequency, t2.title, nrq )

  def objLink(self,targ,frm='',ann=''):
    return '<li>%s [%s]: %s</li>' % (  targ.label, targ.mip, targ.__href__(odir='../u/', label=targ.title,title=targ.description) )

  def unitLink(self,targ,frm='',ann=''):
    return '<li>%s [%s]: %s</li>' % (  targ.text, targ.label, targ.__href__(odir='../u/', label=targ.title) )

  def strLink(self,targ,frm='',ann=''):
    sz0 = len(targ._inx.iref_by_sect[targ.uid].a['CMORvar'])
    sz1 = 0
    if sz0 > 0:
      for u in targ._inx.iref_by_sect[targ.uid].a['CMORvar']:
        sz1 += len( targ._inx.iref_by_sect[u].a['requestVar'] )
    return '<li>%s: %s [%s/%s]</li>' % (  targ.label, targ.__href__(odir='../u/', label=targ.title), sz0, sz1 )

  def remarkLink(self,targ,frm='',ann=''):
    if 'tid' in targ.__dict__ and targ.tid in targ._inx.uid:
      ii = targ._inx.uid[ targ.tid ]
      return '<li>%s.%s [%s]: %s</li>' % (  ii._h.label, targ.tattr, ii.label, targ.__href__(odir='../u/', label=targ.uid) )
    else:
      return '<li>%s [%s]: %s</li>' % (  targ.label, targ.tattr, targ.__href__(odir='../u/', label=targ.uid) )

  def cmLink(self,targ,frm='',ann=''):
    sz0 = len(targ._inx.iref_by_sect[targ.uid].a['structure'])
    sz1 = 0
    if sz0 > 0:
      for id in targ._inx.iref_by_sect[targ.uid].a['structure']:
        sz1 += len(targ._inx.iref_by_sect[id].a['CMORvar'])
    return '<li>%s [%s]: %s {%s/%s}</li>' % (  targ.cell_methods,targ.label, targ.__href__(odir='../u/', label=targ.title),sz0,sz1 )

  def objLnkLink(self,targ,frm='',ann=''):
    lab1 = targ.title
    if lab1 == '':
        lab1 = targ.label

    if frm == 'objective':
      t2 = targ._inx.uid[targ.rid]
      t3 = targ._inx.uid[t2.refid]
      thislab = '%s (%s)' % (t2.mip,t3.label)
      ##return '<li>%s: %s</li>' % (  t2.title, t2.__href__(odir='../u/',label=thislab) )
      return '<li>%s: %s</li>' % (  targ.__href__(odir='../u/',label=lab1), t2.__href__(odir='../u/',label=thislab, title=t2.title) )
    else:
      t2 = targ._inx.uid[targ.oid]
      return '<li>%s: %s</li>' % (  targ.__href__(odir='../u/',label=lab1), t2.__href__(odir='../u/',label=t2.label, title=t2.title) )

  def labTtl(self,targ,frm='',ann=''):
    return '<li>%s: %s</li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.title )

  def vgrpLink(self,targ,frm='',ann=''):
    gpsz = len(targ._inx.iref_by_sect[targ.uid].a['requestVar'])
    nlnk = len(targ._inx.iref_by_sect[targ.uid].a['requestLink'])
    return '<li>%s {%s}: %s variables, %s request links</li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.mip, gpsz, nlnk )

  def miptableLink(self,targ,frm='',ann=''):
    sz = len(targ._inx.iref_by_sect[targ.uid].a['CMORvar'])
    return '<li>%s:%s [%s] (%s variables)</li>' % (  targ.__href__(odir='../u/', label=targ.label), targ.title, targ.frequency, sz )

def obsolete_getTable(sc,m,m2,pmax,odsz,npy,odir='d1',txt=False,xls=False,txtOpts=None):
     """replaces tables.getTable( self, m,m2,pmax,odsz,npy)"""
##
## this creates a new instance, and calls doTable ....
## very messy ...
##
     vs = volsum.vsum( sc, odsz, npy, table_utils.makeTab, tables )
     mlab = setMlab( m )
     vs.run( m, 'requestVol_%s_%s_%s' % (mlab,sc.tierMax,pmax), pmax=pmax )


## collected=summed volumes by table for first page.
     table_utils.makeTab( sc.dq, subset=vs.thiscmvset, dest='%s/%s-%s_%s_%s' % (odir,mlab,mlab2,sc.tierMax,pmax), collected=collector[kkc].a,
              mcfgNote=sc.mcfgNote,
              txt=doTxt, xls=doXls, txtOpts=txtOpts )

styls = styles()

htmlStyle = {}
htmlStyle['CMORvar'] = {'getIrefs':['__all__']}
htmlStyle['requestVarGroup'] = {'getIrefs':['requestVar','requestLink']}
htmlStyle['var'] = {'getIrefs':['CMORvar']}
htmlStyle['objective'] = {'getIrefs':['objectiveLink']}
htmlStyle['requestLink'] = {'getIrefs':['objectiveLink','requestItem']}
htmlStyle['exptgroup'] = {'getIrefs':['__all__']}
htmlStyle['requestItem'] = {'getIrefs':['__all__']}
htmlStyle['experiment'] = {'getIrefs':['__all__']}
htmlStyle['mip'] = {'getIrefs':['__all__']}
htmlStyle['miptable'] = {'getIrefs':['__all__']}
htmlStyle['remarks'] = {'getIrefs':['__all__']}
htmlStyle['grids'] = {'getIrefs':['__all__']}
htmlStyle['varChoice'] = {'getIrefs':['__all__']}
htmlStyle['spatialShape'] = {'getIrefs':['__all__']}
htmlStyle['temporalShape'] = {'getIrefs':['__all__']}
htmlStyle['structure']    = {'getIrefs':['__all__']}
htmlStyle['cellMethods']  = {'getIrefs':['__all__']}
htmlStyle['standardname'] = {'getIrefs':['__all__']}
htmlStyle['varRelations'] = {'getIrefs':['__all__']}
htmlStyle['varRelLnk']    = {'getIrefs':['__all__']}
htmlStyle['units']        = {'getIrefs':['__all__']}
htmlStyle['timeSlice']    = {'getIrefs':['__all__']}

def run():
  try:
    import makeTables
    import scope
  except:
    import dreqPy.scope as scope
    import dreqPy.makeTables as makeTables

  assert os.path.isdir( 'html' ), 'Before running this script you need to create "html", "html/index" and "html/u" sub-directories, or edit the call to dq.makeHtml'
  assert os.path.isdir( 'html/u' ), 'Before running this script you need to create "html", "html/index" and "html/u" sub-directories, or edit the call to dq.makeHtml, and refernces to "u" in style lines below'
  assert os.path.isdir( 'html/index' ), 'Before running this script you need to create "html", "html/index" and "html/u" sub-directories, or edit the call to dq.makeHtml, and refernces to "u" in style lines below'
  assert os.path.isdir( 'tables' ), 'Before running this script you need to create a "tables" sub-directory, or edit the table_utils.makeTab class'

  dq = dreq.loadDreq( htmlStyles=htmlStyle, manifest='out/dreqManifest.txt' )
##
## add special styles to dq object "itemStyle" dictionary.
##
  dq.itemStyles['standardname'] = styls.snLink
  dq.itemStyles['var'] = styls.varLink
  dq.itemStyles['mip'] = styls.mipLink
  dq.itemStyles['CMORvar'] = styls.cmvLink
  dq.itemStyles['objective'] = styls.objLink
  dq.itemStyles['units'] = styls.unitLink
  dq.itemStyles['structure'] = styls.strLink
  dq.itemStyles['cellMethods'] = styls.cmLink
  dq.itemStyles['remarks'] = styls.remarkLink
  dq.itemStyles['exptgroup'] = styls.baseLink01
  dq.itemStyles['objectiveLink'] = styls.objLnkLink
  dq.itemStyles['requestVarGroup'] = styls.vgrpLink
  dq.itemStyles['miptable'] = styls.miptableLink
  dq.itemStyles['requestLink'] = styls.rqlLink02
  dq.itemStyles['requestItem'] = styls.rqiLink02
  dq.itemStyles['spatialShape'] = styls.labTtl
  dq.indexSortBy['miptable'] = 'label'
  dq.coll['var'].items[0].__class__._linkAttrStyle['sn'] = styls.snLink01
  dq.coll['CMORvar'].items[0].__class__._linkAttrStyle['stid'] = styls.stidLink01
##dq.coll['requestVarGroup'].items[0].__class__._linkAttrStyle['requestVar'] = styls.rqvLink01
  dq.itemStyles['requestVar'] = styls.rqvLink01

  dreq.dreqItemBase._extraHtml['requestVarGroup'] = rvgExtraTable.vgx1(dq).mxoGet
  dreq.dreqItemBase.__charmeEnable__['var'] = nt__charmeEnable( 'test','http://clipc-services.ceda.ac.uk/dreq' )

  ht = htmlTrees(dq)
  dq.makeHtml( annotations={'var':ht.anno}, ttl0='Data Request [%s]' % dreq.version )
  sc = scope.dreqQuery(dq=dq)
  try:
    mt = table_utils.makeTab( sc)
  except:
    print ('Could not make tables ...')
    raise
  mp = makePurl( dq )
  mj = makeJs( dq )

if __name__ == "__main__":
  run()
