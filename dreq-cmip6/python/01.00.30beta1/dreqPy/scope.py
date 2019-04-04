"""Date Request Scoping module
------------------------------
The scope.py module contains the dreqQuery class and a set of ancilliary functions. The dreqQuery class contains methods for analysing the data request.
"""

class exYr(object):
  def __init__(self):
    pass

try:
  import dreq
  imm=1
except:
  import dreqPy.dreq  as dreq
  imm=2

if imm == 1:
  from utilities import cmvFilter, gridOptionSort
  import misc_utils
  import scope_utils
  import fgrid
  import volsum
else:
  import dreqPy.scope_utils as scope_utils
  import dreqPy.volsum as volsum
  import dreqPy.fgrid as fgrid
  from dreqPy.utilities import cmvFilter, gridOptionSort 
  import dreqPy.misc_utils as misc_utils

import collections, operator
import sys, os

def intdict():
    return collections.defaultdict( int )

if sys.version_info >= (2,7):
  oldpython = False
else:
  oldpython = True

gridSorter = gridOptionSort( oldpython )

class timeSlice( object ):
  def __init__(self,tsl):
    self.tsl = tsl

  def sort(self):
    tsl = self.tsl
    s = set()
    ee = dict()
    for ts in tsl:
      if ts[0] == None:
        return (1,ts,'Taking unsliced option')
      s.add( ts[0][1] )
      ee[ts[0][0]] = ts
    tst = s.pop()
    p = min( [ee[k][1] for k in ee.keys()] )
    if len(s) > 0 or tst == 'dayList':
      if sorted(ee.keys()) in [['piControl030a','piControl200'],['piControl030', 'piControl030a', 'piControl200']]:
        return (1,(ee['piControl200'][0],p), 'Taking larger slice (possible alignment issues)')
      elif sorted(ee.keys()) in [['piControl030', 'piControl030a']]:
        return (1,(ee['piControl030'][0],p), 'Taking preferred slice (possible alignment issues)')
      elif sorted(ee.keys()) == ['RFMIP','RFMIP2']:
        return (1,(('RFMIP-union', 'dayList', None, None),p), 'Taking ad-hoc union')
      elif sorted(ee.keys()) == ['RFMIP', 'RFMIP2', 'hist55']:
        return (1,(('hist55plus', 'rangeplus', 1960, 2014),p), 'Taking ad-hoc union with extra ...')
      elif sorted(ee.keys()) == ['RFMIP', 'hist55']:
        return (1,(('hist55plus', 'rangeplus', 1960, 2014),p), 'Taking ad-hoc union with extra ...')
      elif sorted(ee.keys()) == ['RFMIP2', 'hist55']:
        return (1,(ee['hist55'][0],p), 'Taking larger containing slice')
      elif sorted(ee.keys()) == ['DAMIP20','DAMIP40']:
        return (1,(ee['DAMIP40'][0],p), 'Taking larger containing slice')
      return (-1,None,'Multiple slice types: %s' % sorted(ee.keys()))

    if not ( tst in ['simpleRange','relativeRange'] or (len(tst) > 13 and tst[:13] == 'branchedYears') ):
      return (-2,None,'slice type aggregation not supported')
    if len(tsl) == 2:
      tsll = list( tsl )
      sa,ea = tsll[0][0][2:]
      sb,eb = tsll[1][0][2:]
      if sa <= sb and ea >= eb:
        return (1,tsll[0], 'Taking largest slice')
      if sb <= sa and eb >= ea:
        return (1,tsll[1], 'Taking largest slice')
      if ea < sb or eb < sa:
        return (2,tsll, 'Slices are disjoint')
      return (-3,None, 'Overlapping slices')
    else:
##
## sort by end year and length .. if longest of last ending is also the first starting, we can sort ...
##
      tsll = sorted( list(tsl), key=lambda x: (x[0][3],x[0][3]-x[0][2]) )
      if min( [x[0][2] for x in tsll] ) == tsll[-1][0][2]:
        return (1,tsll[-1], 'Taking largest slice')
      return (-4,None, 'Cannot sort slices')

def sortTimeSlice( tsl ):
  
  s = set()
  for ts in tsl:
    if ts[0] == None:
      return (1,ts,'Taking unsliced option')
    s.add( ts[0][1] )
  if len(s) > 1:
    return (-1,None,'Multiple slice types')
  tst = s.pop()
  if not ( tst in ['simpleRange','relativeRange'] or (len(tst) > 13 and tst[:13] == 'branchedYears') ):
    return (-2,None,'slice type aggregation not supported')
  if len(tsl) == 2:
    tsll = list( tsl )
    sa,ea = tsll[0][0][2:]
    sb,eb = tsll[1][0][2:]
    if sa <= sb and ea >= eb:
      return (1,tsll[0], 'Taking largest slice')
    if sb <= sa and eb >= ea:
      return (1,tsll[1], 'Taking largest slice')
    if ea < sb or eb < sa:
      return (2,tsll, 'Slices are disjoint')
    return (-3,None, 'Overlapping slices')
  else:
##
## sort by end year and length .. if longest of last ending is also the first starting, we can sort ...
##
    tsll = sorted( list(tsl), key=lambda x: (x[0][3],x[0][3]-x[0][2]) )
    if min( [x[0][2] for x in tsll] ) == tsll[-1][0][2]:
        return (1,tsll[-1], 'Taking largest slice')
    return (-4,None, 'Cannot sort slices')

odsz = {'landUse':(5,'free'), 'tau':7, 'scatratio':15, 'effectRadLi|tau':(28,'query pending'), 'vegtype':(8,'free'), 'sza5':5, 'site':(119,'73 for aquaplanet .. '), 'iceband':(5,'free'), 'dbze':15, 'spectband':(10,'free'), 'misrBands':(7,'query pending'), 'effectRadIc|tau':(28,'query pending')}

python2 = True
if sys.version_info[0] == 3:
  python2 = False
  from functools import reduce
  try: 
    from utilP3 import mlog3
  except:
    from dreqPy.utilP3 import mlog3
  mlg = mlog3()
else:
  from utilP2 import util
  mlg = util.mlog()

class c1(object):
  def __init__(self):
    self.a = collections.defaultdict( int )
class c1s(object):
  def __init__(self):
    self.a = collections.defaultdict( set )

NT_txtopts = collections.namedtuple( 'txtopts', ['mode'] )

def vfmt(ss):
  stb = ss*1.e-12
  if stb < .099:
    return '%7.2fGb' % (stb*100)
  else:
    return '%7.2fTb' % stb

class baseException(Exception):
  """Basic exception for general use in code."""

  def __init__(self,msg):
    self.msg = 'scope:: %s' % msg

  def __str__(self):
    return repr( self.msg )

  def __repr__(self):
    return self.msg

nt_mcfg = collections.namedtuple( 'mcfg', ['nho','nlo','nha','nla','nlas','nls','nh1'] )
class cmpd(object):
  def __init__(self,dct):
    self.d = dct
  def cmp(self,x,y,):
    return cmp( self.d[x], self.d[y] )


def filter1( a, b ):
  if b < 0:
    return a
  else:
    return min( [a,b] )

def filter2( a, b, tt, tm ):
## largest tier less than or equal to tm
  ll = [t for t in tt if t <= tm]
  if len( ll ) > 0:
    t1 = [t for t in tt if t <= tm][-1]
    it1 = tt.index(t1)
    aa = a[it1]
    if b < 0:
      return aa
    else:
      return min( [aa,b] )
  else:
    return 0

npy = {'1hrClimMon':24*12, 'daily':365, u'Annual':1, u'fx':0.01, u'1hr':24*365, u'3hr':8*365,
       u'monClim':12, u'Timestep':100, u'6hr':4*365, u'day':365, u'1day':365, u'mon':12, u'yr':1,
       u'1mon':12, 'month':12, 'year':1, 'monthly':12, 'hr':24*365, 'other':24*365,
        'subhr':24*365, 'Day':365, '6h':4*365, '3 hourly':8*365, '':1, 'dec':0.1,
        '1hrCM':24*12, '1hrPt':24*365, '3hrPt':8*365, '6hrPt':4*365, 'monPt':12, 'monC':12, 'subhrPt':24*365, 'yrPt':1 }

def vol01( sz, v, npy, freq, inx ):
  n1 = npy[freq]
  s = sz[inx.uid[v].stid]
  assert type(s) == type(1), 'Non-integer size found for %s' % v
  assert type(n1) in (type(1),type(0.)), 'Non-number "npy" found for %s, [%s]' % (v,freq)
  return s*n1

class col_list(object):
  def __init__(self):
    self.a = collections.defaultdict(list)

class col_count(object):
  def __init__(self):
    self.a = collections.defaultdict(int)

class dreqQuery(object):
  __doc__ = """Methods to analyse the data request, including data volume estimates"""
  errorLog = collections.defaultdict( set )
  def __init__(self,dq=None,tierMax=1):
    if dq == None:
      self.dq = dreq.loadDreq()
    else:
      self.dq = dq
    self.rlu = {}
    for i in self.dq.coll['objective'].items:
      k = '%s.%s' % (i.mip,i.label)
      ##assert not k in self.rlu, 'Duplicate label in objectives: %s' % k
      if k in self.rlu:
        print ( 'SEVERE: Duplicate label in objectives: %s' % k )
      self.rlu[k] = i.uid

    self.odsz = odsz
    self.npy = npy
    self.strSz = dict()
    self.cmvFilter = cmvFilter( self )
    self.tierMax = tierMax
    self.gridPolicyDefaultNative = False
    self.gridOceanStructured = True
    self.gridPolicyForce = None
    self.retainRedundantRank = False
    self.intersection = False
    self.gridPolicyTopOnly = True
    self.exptFilter = None
    self.exptFilterBlack = None
    self.uniqueRequest = False

    ##self.mips = set( [x.label for x in self.dq.coll['mip'].items ] )
    ##self.mips = ['CMIP','AerChemMIP', 'C4MIP', 'CFMIP', 'DAMIP', 'DCPP', 'FAFMIP', 'GeoMIP', 'GMMIP', 'HighResMIP', 'ISMIP6', 'LS3MIP', 'LUMIP', 'OMIP', 'PAMIP', 'PMIP', 'RFMIP', 'ScenarioMIP', 'VolMIP', 'CORDEX', 'DynVar', 'DynVarMIP', 'SIMIP', 'VIACSAB']
    self.mips = ['CMIP'] + scope_utils.mips
    self.mipsp = self.mips[:-4]
    self.cmvGridId, i4 = fgrid.fgrid( self.dq )
    assert len(i4) == 0

    self.experiments = set( [x.uid for x in self.dq.coll['experiment'].items ] )
    self.exptByLabel = {}
    self.rqLinkByExpt = self._setRqLinkByExpt()
    for x in self.dq.coll['experiment'].items:
      if x.label in self.exptByLabel:
        print ( 'ERROR: experiment label duplicated: %s' % x.label )
      self.exptByLabel[x.label] = x.uid
    self.mipls = sorted( list( self.mips ) )

    self.default_mcfg = nt_mcfg._make( [259200,60,64800,40,20,5,100] )
    self.mcfg = self.default_mcfg._asdict()
    self.mcfgNote = None
    self.szcfg()
    self.requestItemExpAll(  )

  def _setRqLinkByExpt(self):
    dq = self.dq
    ee = {}
#
# loop over experiment records
##
    for e in dq.coll['experiment'].items:
      eu = e.uid
      ss = set()

## loop over request link records
      for l in dq.coll['requestLink'].items:
        lu = l.uid

## check to see if any request items associated with the record link to current experiment.
        for u in dq.inx.iref_by_sect[lu].a['requestItem']:
            esid = dq.inx.uid[u].esid
            if esid == eu or 'experiment' in dq.inx.iref_by_sect[esid].a and eu in dq.inx.iref_by_sect[esid].a['experiment']:
              ss.add( lu )
      ee[eu] = ss
    return ee

  def showOpts(self):
    print ( ( self.tierMax, self.gridPolicyDefaultNative, self.gridOceanStructured, self.gridPolicyForce,
    self.retainRedundantRank, self.gridPolicyTopOnly, self.exptFilter, self.exptFilterBlack,
    self.uniqueRequest ))

  def setMcfg(self, ll, msg=None ):
    assert len(ll) == 7, 'Model config must be of length 7: %s' % str(ll)
    assert all( [type(x) == type(1) for x in ll] )
    self.mcfg = nt_mcfg._make( ll )._asdict()
    if msg == None:
      self.mcfgNote = 'User supplied model configuration: %s' % str(ll)
    else:
      self.mcfgNote = msg
    self.szcfg()

  def szcfg(self):
    szr = {'100km':64800, '1deg':64800, '2deg':16200 }
    self.szss = {}
    self.sz = {}
    self.szg = collections.defaultdict( dict )
    self.szgss = collections.defaultdict( dict )
    self.isLatLon = {}
    self.szSrf = collections.defaultdict( dict )
    self.szssSrf = collections.defaultdict( dict )
    for i in self.dq.coll['spatialShape'].items:
      gtype = 'a'
      if i.levelFlag == False:
        ds =  i.dimensions.split( '|' )
        if ds[-1] in ['site', 'basin']:
          vd = ds[-2]
        else:
          vd = ds[-1]
 
        if vd[:4] == 'olev' or vd == 'rho':
          gtype = 'o'
          nz = self.mcfg['nlo']
        elif vd[:4] == 'alev':
          nz = self.mcfg['nla']
        elif vd in ['slevel']:
          nz = self.mcfg['nls']
        elif vd in ['snowdepth','sdepth']:
          nz = 5
        elif vd == 'aslevel':
          nz = self.mcfg['nlas']
        else:
          mlg.prnt( 'Failed to parse dimensions %s: %s' % (i.label,i.dimensions) )
          raise
      else:
        nz = i.levels

      dims = set( i.dimensions.split( '|' ) )
      if 'latitude' in dims and 'longitude' in dims:
        if gtype == 'o':
          nh = self.mcfg['nho']
          self.isLatLon[i.uid] = 'o'
        else:
          nh = self.mcfg['nha']
          self.isLatLon[i.uid] = 'a'
      else:
        nh = 10
        self.isLatLon[i.uid] = False

      self.szss[i.uid] = nh*nz
      if self.isLatLon[i.uid] != False and len(dims) == 2:
        self.szssSrf[i.uid] = { 'a':self.mcfg['nha']*nz, 'o':self.mcfg['nho']*nz }

      for k in szr:
        if self.isLatLon[i.uid] != False:
          self.szgss[k][i.uid] = szr[k]*nz
        else:
          self.szgss[k][i.uid] = nh*nz

    for i in self.dq.coll['structure'].items:
      s = 1
      knownAtmos = False
      if i.__dict__.get('odims','')  != '':
        if i.odims in odsz:
           sf = odsz[i.odims]
        else:
           ## print 'SEVERE.odims.00001: no information on dimension size: %s' % i.odims
           sf = 5
        if type( sf ) == type( () ):
          sf = sf[0]
        s = s*sf
        if i.odims not in ['iceband']:
          knownAtmos = True
      if i.spid in self.szss:
        self.sz[i.uid] = self.szss[i.spid]*s

        if i.uid in self.szssSrf:
          if knownAtmos:
            self.sz[i.uid] = self.szssSrf[i.spid]['a']*s
          else:
            for k in ['a','o']:
               self.szSrf[i.uid][k] = self.szssSrf[i.spid][k]*s

        for k in szr:
          self.szg[k][i.uid] = self.szgss[k][i.spid]*s
      else:
        print ('WARNING: spid has no size info: %s [%s]' % (i.spid,i.uid) )
        self.sz[i.uid] = 0.
        for k in szr:
          self.szg[k][i.uid] = 0.

  def getRequestLinkByMip( self, mipSel ):
    """Return the set of request links which are associated with specified MIP"""

    if type(mipSel) == type( {} ):
      return self.getRequestLinkByMipObjective(self,mipSel)

    if type(mipSel) == type(''):
      t1 = lambda x: x == mipSel
    elif type(mipSel) == type(set()):
      t1 = lambda x: x in mipSel

    s = set()
    for i in self.dq.coll['requestLink'].items:
      if t1(i.mip):
        if 'requestItem' in self.dq.inx.iref_by_sect[i.uid].a:
          if any( [ self.rqiExp[x][3] > 0 for  x in self.dq.inx.iref_by_sect[i.uid].a['requestItem'] if x in self.rqiExp ] ):
            s.add( i )

    self.rqs = list( s )
    return self.rqs

  def getRequestLinkByMipObjective( self, mipSel ):
    """Return the set of request links which are associated with specified MIP and its objectives"""

    assert type(mipSel) == type( {} ),'Argument must be a dictionary, listing objectives for each MIP'

    s = set()
    for i in self.dq.coll['requestLink'].items:
      if i.mip in mipSel:
        if len(mipSel[i.mip]) == 0:
          s.add( i )
        elif 'objectiveLink' in self.dq.inx.iref_by_sect[i.uid].a:
          ss = set( [self.dq.inx.uid[k].label for k in self.dq.inx.iref_by_sect[i.uid].a['objectiveLink'] ] )
          if any( [x in mipSel[i.mip] for x in ss] ):
            s.add( i )
##
## filter requestLinks by tierMax: check to see whether they link to experiments with tier below or equal to tiermax.
##
    s1 = set()
    for i in s:
      if 'requestItem' in self.dq.inx.iref_by_sect[i.uid].a:
        if any( [ self.rqiExp[x][-1] > 0 for  x in self.dq.inx.iref_by_sect[i.uid].a['requestItem'] if x in self.rqiExp ] ):
            s1.add( i )

    self.rqs = list( s1 )
    return self.rqs

  def varGroupXexpt(self, rqList ):
    """For a list of request links, return a list of variable group IDs for each experiment"""
    self.cc = collections.defaultdict( list )
    ## dummy = {self.cc[i.expt].append(i.rlid) for i in self.dq.coll['requestItem'].items if i.rlid in {j.uid for j in rqList} }
    return self.cc

  def yearsInRequest(self, rql ):
    self.ntot = sum( [i.ny for i in self.dq.coll['requestItem'].items if i.rlid == rql.uid] )
    return self.ntot

  def rqlByExpt( self, l1, ex, pmax=2, expFullEx=False ):
    """rqlByExpt: return a set of request links for an experiment"""
##
    inx = self.dq.inx

    if ex != None:
    
      exi = self.dq.inx.uid[ex]
      if exi._h.label == 'experiment':
        exset = set( [ex,exi.egid,exi.mip] )
      else:
        exset = set( self.esid_to_exptList(ex,deref=False,full=expFullEx) )
##
## rql is the set of all request links which are associated with a request item for this experiment set
##
   
      l1p = set()
      for i in l1:
        if i.preset < 0 or i.preset <= pmax:
          if i.esid in exset:
            l1p.add(i)
    else:
      exset = None
      l1p = l1

    rql0 = set()
    for i in l1p:
       rql0.add(i.rlid)

    rqlInv = set()
    for u in rql0:
      if inx.uid[u]._h.label == 'remarks':
        rqlInv.add( u )
    if len(rqlInv) != 0:
      mlg.prnt ( 'WARNING.001.00002: %s invalid request links from request items ...' % len(rqlInv) )
    rql = set()
    for u in rql0:
       if inx.uid[u]._h.label != 'remarks':
         rql.add( u ) 

    return rql, l1p, exset

  def varsByRql( self, rql, pmax=2, intersection=False, asDict=False): 
      """The complete set of variables associated with a set of request links."""
      inx = self.dq.inx
      cc1 = collections.defaultdict( set )
      for i in rql:
        o = inx.uid[i]
        if o.opt == 'priority':
          p = int( float( o.opar ) )
          assert p in [1,2,3], 'Priority incorrectly set .. %s, %s, %s' % (o.label,o.title, o.uid)
          cc1[inx.uid[i].mip].add( (inx.uid[i].refid,p) )
        else:
          cc1[inx.uid[i].mip].add( inx.uid[i].refid )

      if intersection:
        ccv = {}
#
# set of request variables for each MIP
#
        for k in cc1:
          thisc = reduce( operator.or_, [set( inx.iref_by_sect[vg].a['requestVar'] ) for vg in cc1[k] ] )
          rqvgs = collections.defaultdict( set )
          for x in cc1[k]:
            if type(x) == type( () ):
              rqvgs[x[0]].add( x[1] )
            else:
              rqvgs[x].add( 3 )
          
          s = set()
          for vg in rqvgs:
            for l in inx.iref_by_sect[vg].a['requestVar']:
              if inx.uid[l].priority <= min(pmax,max(rqvgs[vg])):
                s.add( inx.uid[l].vid )
          ccv[k] = s

        if len( ccv.keys() ) < len( list(imips) ):
          vars = set()
        else:
          vars =  reduce( operator.and_, [ccv[k] for k in ccv] )
      else:
        rqvgs = collections.defaultdict( set )
        for k in cc1:
          for x in cc1[k]:
            if type(x) == type( () ):
              rqvgs[x[0]].add( x[1] )
            else:
              rqvgs[x].add( 3 )
          
###To obtain a set of variables associated with this collection of variable groups:

        if asDict:
          vars = collections.defaultdict( list )
        else:
          vars = set()
        for vg in rqvgs:
          for l in inx.iref_by_sect[vg].a['requestVar']:
            if inx.uid[l].priority <= min(pmax,max(rqvgs[vg])):
               if asDict:
                 vars[inx.uid[l].vid].append( vg )
               else:
                 vars.add(inx.uid[l].vid)

        ##col1 = reduce( operator.or_, [set( inx.iref_by_sect[vg].a['requestVar'] ) for vg in rqvg ] )
### filter out cases where the request does not point to a CMOR variable.
    ##vars = {vid for vid in vars if inx.uid[vid][0] == u'CMORvar'}

      if asDict:
        thisvars = {}
        for vid in vars:
           if inx.uid[vid]._h.label == u'CMORvar':
             thisvars[vid] = vars[vid]
      else:
        thisvars = set()
        for vid in vars:
           if inx.uid[vid]._h.label == u'CMORvar':
             thisvars.add(vid)

      return thisvars

  def exptYears( self, rqll, ex=None, exBlack=None):
    """Parse a set of request links, and get years requested for each (varGroup, expt, grid) tuple """
      
    self.tsliceDict = collections.defaultdict( dict )
    ccts = collections.defaultdict( dict )
    ccts2 = collections.defaultdict( set )
    cc = collections.defaultdict( set )
    for rl in rqll:
      if 'requestItem' not in self.dq.inx.iref_by_sect[rl.uid].a:
        self.errorLog['WARN.001.00001'].add( 'no request items for: %s, %s' % (rl.uid, rl.title) )
        ##print ( 'WARN.001.00001: no request items for: %s, %s' % (rl.uid, rl.title) )
      else:

        ##print rl.uid, rl.title, rl.grid, rl.gridreq
        if self.gridPolicyForce != None:
          grd = self.gridPolicyForce
        elif rl.grid in ['1deg','2deg','100km']:
          if rl.grid == '100km':
            grd = '1deg'
          else:
            grd = rl.grid
        else:
          ## note that naming of "gridreq" is unfortunate ... "No" means that native grid is required
          if rl.gridreq in ['No', 'no']:
             #or self.gridPolicyDefaultNative:
            grd = 'native'
          elif rl.gridreq in ['no*1']:
             #or self.gridPolicyDefaultNative:
            grd = 'native:01'
          else:
            ##print ( 'INFO.grd.00001: defaulting to grid ..%s, %s, %s' % (rl.label,rl.title, rl.uid) )
            grd = 'DEF'

        for iu in self.dq.inx.iref_by_sect[rl.uid].a['requestItem']:
          i = self.dq.inx.uid[iu]

##
## apply "treset" filter to request items linked to this group.
##
          if self.tierMax < 0 or 'treset' not in i.__dict__ or i.treset <= self.tierMax:
            if iu in self.rqiExp:
              for e in self.rqiExp[iu][1]:
                if (ex == None or e in ex) and (exBlack == None or e not in exBlack):
                  this = self.rqiExp[iu][1][e]
                  if this != None:
                    thisns = this[-3]
                    thisny = this[-2]
                    thisne = this[-1]
                    ##cc[ (rl.refid,e,grd) ].add( filter1( thisns*thisny*thisne, i.nymax) )
                    cc[ (rl.refid,e,grd) ].add( thisns*thisny*thisne )
                    if self.rqiExp[iu][4] != None:
                      ccts[(rl.refid,e)][thisns*thisny*thisne] = self.rqiExp[iu][4]
                      ccts2[(rl.refid,e)].add( self.rqiExp[iu][4] )

    ee = collections.defaultdict( dict )

    revertToLast = True
    ey = exYr()
    if revertToLast:
      for g,e,grd in cc:
        ee[g][(e,grd)] = max( cc[( g,e,grd) ] )
        ##if (g,e) in ccts and ee[g][(e,grd)] in ccts[(g,e)]:
#
# possible corner cut here ... as max length may not include all years where there is a non-overlap ...
#
           ##self.tsliceDict[g][e] = ccts[(g,e)][ ee[g][(e,grd)] ]
## change to a set of slices
        self.tsliceDict[g][e] = ccts2[(g,e)]
      ey.exptYears = ee
      return ey
    ff = collections.defaultdict( dict )
##
## this needs to be done separately for ocean and atmosphere, because of the default logic workflow ...
    for g,e,grd in cc:
      ee[(g,e)][grd] = max( cc[( g,e,grd) ] )

    xx = collections.defaultdict( dict )
    for g,e in ee:
      ddef = ee[(g,e)].get( 'DEF', 0 )
      for grd in ee[(g,e)]:
        if grd != 'DEF':
          xx[(g,'a')][(e, grd)] = ee[(g,e)][grd]
          xx[(g,'o')][(e, grd)] = ee[(g,e)][grd]
          xx[(g,'')][(e, grd)] = ee[(g,e)][grd]
        if grd == 'native' and ddef != 0:
          xx[(g,'a')][(e, 'native')] = max( [xx[(g,'a')][(e, 'native')],ddef] )
          xx[(g,'')][(e, 'native')] = max( [xx[(g,'')][(e, 'native')],ddef] )
        if grd == '1deg' and ddef != 0:
          xx[(g,'o')][(e, '1deg')] = max( [xx[(g,'o')][(e, '1deg')],ddef] )

    for grp,flg in xx:
      ff[grp][flg] = xx[(grp,flg)]
          
    ## return dict[<variable group>]{dict[<experiment><grid>]{<years>}}
    ## return dict[<variable group>][grid flag]{dict[<experiment>,<grid>]{<years>}}
    return ff

  def volByExpt( self, l1, ex, pmax=1, cc=None, intersection=False,expFullEx=False, adsCount=False ):
    """volByExpt: calculates the total data volume associated with an experiment/experiment group and a list of request items.
          The calculation has some approximations concerning the number of years in each experiment group.
          cc: an optional collector, to accumulate indexed volumes. """
##
    inx = self.dq.inx
    imips = set()
    for i in l1:
      imips.add(i.mip)
    
    rql, l1p, exset = self.rqlByExpt( l1, ex, pmax=pmax, expFullEx=expFullEx )
    verbose = False
    if verbose:
      for i in rql:
        r = inx.uid[i]
        print ( '%s, %s, %s' % (r.label, r.title, r.uid) )

    if ex != None:
      
      exi = self.dq.inx.uid[ex]
      if exi._h.label == 'experiment':
        exset = set( [ex,exi.egid,exi.mip] )
#####
    if len( rql ) == 0:
      self.vars = set()
      return (0,{},{} )

## The complete set of variables associated with these requests:
    vars = self.varsByRql( rql, pmax=pmax, intersection=intersection, asDict=True) 
##
## filter by configuration option and rank
##
    if not self.retainRedundantRank:
      len1 = len(vars.keys())
      cmv = self.cmvFilter.filterByChoiceRank(cmv=set(vars.keys()))
      vars = cmv
    
    self.vars = vars

    e = {}
    for u in rql:
### for request variables which reference the variable group attached to the link, add the associate CMOR variables, subject to priority
      i = inx.uid[u]
      e[i.uid] = set()
      si = collections.defaultdict( list )
      for x in inx.iref_by_sect[i.refid].a['requestVar']:
           if inx.uid[x].priority <= pmax:
              e[i.uid].add( inx.uid[x].vid )

              if verbose:
                cmv = inx.uid[inx.uid[x].vid]
                if cmv._h.label == 'CMORvar':
                  si[ cmv.mipTable ].append( inx.uid[x].label )
#
# for each variable, calculate the maximum number of years across all the request links which reference that variable.
##
## for each request item we have nymax, nenmax, nexmax.
##
    nymg = collections.defaultdict( dict )
##
## if dataset count rather than volume is wanted, use item 3 from rqiExp tuple.
    if adsCount:
      irqi = 3
    else:
      irqi = 2

    sgg = set()
    for v in vars:
      s = set()
      sg = collections.defaultdict( set )
      cc2 = collections.defaultdict( set )
      cc2s = collections.defaultdict( c1s )
      for i in l1p:
##################
        if (exset == None or i.esid in exset) and v in e[i.rlid]:
          ix = inx.uid[i.esid]
          rl = inx.uid[i.rlid]
          sgg.add( rl.grid )
          if rl.grid in ['100km','1deg','2deg']:
            grd = rl.grid
          else:
            grd = 'native'

          this = None
          if exset == None:
            thisz = 100
## 
## for a single experiment, look up n years, and n ensemble.
## should have nstart????
##
          elif exi._h.label == 'experiment' or ix._h.label == 'experiment':
            this = None
            if ex in self.rqiExp[i.uid][1]:
              this = self.rqiExp[i.uid][1][ex]
            elif ix.uid in self.rqiExp[i.uid][1]:
              this = self.rqiExp[i.uid][1][ix.uid]
            if this != None:
              thisns = this[-3]
              thisny = this[-2]
              thisne = this[-1]
              cc2s[grd].a[u].add( filter1( thisns*thisny*thisne, i.nymax) )
          else:
            thisz = None
            if 'experiment' in inx.iref_by_sect[i.esid].a:
              for u in inx.iref_by_sect[i.esid].a['experiment']:
                if u in self.rqiExp[i.uid][1]:
                  this = self.rqiExp[i.uid][1][u]
                  thisns = this[-3]
                  thisny = this[-2]
                  thisne = this[-1]
##
###   aggregate year count for each experiment and output grid
## clarify definition and usage of nymax -- should be redundant ... could be replaced by inward references from "timeSlice"
                  cc2s[grd].a[u].add( filter1( thisns*thisny*thisne, i.nymax) )

          if exset != None:
            sg[grd].add( self.rqiExp[i.uid][irqi] )
      
###
### sum over experiments of maximum within each experiment
###
      for g in sg:
        nymg[v][g] = sum( [max( cc2s[g].a[k] ) for k in cc2s[g].a] )

    szv = {}
    ov = []
    for v in vars:
      if 'requestVar' not in inx.iref_by_sect[v].a:
         print ( 'Variable with no request ....: %s, %s' % (inx.uid[v].label, inx.uid[v].mipTable) )
      try:
        szv[v] = self.sz[inx.uid[v].stid]*npy[inx.uid[v].frequency]
      except:
        if inx.uid[v].stid not in self.sz:
          print ('ERROR: size not found for stid %s (v=%s, %s)' % (inx.uid[v].stid,v,inx.uid[v].label) )
        if inx.uid[v].frequency not in npy:
          print ('ERROR: npy not found for frequency %s (v=%s, %s)' % (inx.uid[v].frequency,v,inx.uid[v].label) )
        szv[v] = 0
      ov.append( self.dq.inx.uid[v] )

    ff = {}
    for v in vars:
      if adsCount:
        ff[v] = 1
      else:
        if 'native' in nymg[v]:
          ff[v] = szv[v]
          ny = nymg[v]['native']
        else:
          ks0 = nymg[v].keys()
          if len(ks0) == 0:
            ff[v] = 0.
            ny = 0.
          else:
            ks = gridSorter.sort( nymg[v].keys() )[0]
            ##ks = list( nymg[v].keys() )[0]
            ny = nymg[v][ks]
            if inx.uid[v].stid in self.szg[ks]:
              ff[v] = self.szg[ks][ inx.uid[v].stid ] * npy[inx.uid[v].frequency]
            else:
              ff[v] = 0.

        if inx.uid[v].frequency not in ['monClim','monC']:
          ff[v] = ff[v]*ny

    ee = self.listIndexDual( ov, 'mipTable', 'label', acount=None, alist=None, cdict=ff, cc=cc )
    self.ngptot = sum( [  ff[v]  for v in vars] )
    return (self.ngptot, ee, ff )

  def esid_to_exptList(self,esid,deref=False,full=False):
    if not esid in self.dq.inx.uid:
      mlg.prnt ( 'Attempt to dereferece invalid uid: %s' % esid )
      raise

    if self.dq.inx.uid[esid]._h.label == 'experiment':
      expts = [esid,]
    elif self.dq.inx.uid[esid]._h.label != 'remarks':
      if esid in self.dq.inx.iref_by_sect and 'experiment' in self.dq.inx.iref_by_sect[esid].a:
        expts = list( self.dq.inx.iref_by_sect[esid].a['experiment'][:] )
      else:
        expts = []

## add in groups and mips for completeness
##
      if full:
        if self.dq.inx.uid[esid]._h.label == 'mip':
          s = set()
          for e in expts:
            if self.dq.inx.uid[e]._h.label != 'experiment':
              mlg.prnt ( 'ERROR: %s, %s, %s ' % (esid,e, self.dq.inx.uid[e].title ) )
            s.add( self.dq.inx.uid[e].egid )
          for i in s:
            expts.append( i )
        expts.append( esid )
    else:
      return None

    if self.tierMax > 0:
      expts1 = []
      for i in expts:
        if self.dq.inx.uid[i]._h.label == 'experiment':
          if self.dq.inx.uid[i].tier[0] <= self.tierMax:
            expts1.append( i )
        elif self.dq.inx.uid[i]._h.label == 'exptgroup':
          if self.dq.inx.uid[i].tierMin <= self.tierMax:
            expts1.append( i )
        else:
            expts1.append( i )
    else:
      expts1 = expts

    if deref:
      return [self.dq.inx.uid[e] for e in expts1]
    else:
      return expts1
##
## need to call this on load
## then use instead of i.ny etc below
##
  def requestItemExpAll( self ):
    self.rqiExp = {}
    for rqi in self.dq.coll['requestItem'].items:
      a,b,c,d,e = self.requestItemExp( rqi )
      if a != None:
        self.rqiExp[rqi.uid] = (a,b,c,d,e)

  def requestItemExp( self, rqi ):
    assert rqi._h.label == "requestItem", 'Argument to requestItemExp must be a requestItem'
    tsl = None
    if 'tslice' in rqi.__dict__:
      ts = self.dq.inx.uid[ rqi.tslice ]
      if ts._h.label == 'timeSlice':
        if ts.type in ['simpleRange','relativeRange']:
          tsl = (ts.label, ts.type, ts.start,ts.end)
        elif ts.type == 'branchedYears':
          tsl = (ts.label,'%s:%s' % (ts.type,ts.child), ts.start,ts.end)
        else:
          tsl = (ts.label, ts.type, None, None )

      
    u = rqi.esid
    if self.dq.inx.uid[u]._h.label == 'experiment':
      expts = [u,]
    elif self.dq.inx.uid[u]._h.label != 'remarks':
      if u in self.dq.inx.iref_by_sect and 'experiment' in self.dq.inx.iref_by_sect[u].a:
        expts = self.dq.inx.iref_by_sect[u].a['experiment']
      else:
        expts = []
    else:
      return (None, None, None, None,None)

    if self.tierMax > 0:
      expts = [i for i in expts if self.dq.inx.uid[i].tier[0] <= self.tierMax]

    self.multiTierOnly = False
    if self.multiTierOnly:
      expts = [i for i in expts if len(self.dq.inx.uid[i].tier) > 1]
      print ('Len expts: %s' % len(expts) )

    if len(expts) > 0:
      e = [self.dq.inx.uid[i] for i in expts]
      for i in e:
        if i._h.label != 'experiment':
          mlg.prnt ( 'ERROR: %s, %s, %s ' % ( u,i._h.label, i.label, i.title ) )
      dat2 = {}
      for i in e:
        ## verified that this change (i.ntot --> None) has zero impact on tab01_3_3.texfrag ... i.e. data volumes are not affected.
        ## just as well, since values in data request are not correct.
        ##dat2[i.uid] = (i.ntot, i.yps, i.ensz, i.tier, i.nstart, filter1(i.yps,rqi.nymax), filter2(i.ensz,rqi.nenmax,i.tier,self.tierMax) )
        dat2[i.uid] = (None, i.yps, i.ensz, i.tier, i.nstart, filter1(i.yps,rqi.nymax), filter2(i.ensz,rqi.nenmax,i.tier,self.tierMax) )

      nytot = sum( [dat2[x][-2]*dat2[x][-3] for x in dat2 ] )
      netot = sum( [dat2[x][-1] for x in dat2 ] )
    else:
      dat2 = {}
      nytot = 0
      netot = 0
    
##
## to get list of years per expt for each requestLink ... expts is union of all dat2 keys, 
## and want max of dat2[x][0] for each experiment x.
##
    return (expts, dat2, nytot, netot, tsl )

  def setTierMax( self, tierMax ):
    """Set the maxium tier and recompute request sizes"""
    if tierMax != self.tierMax:
      self.tierMax = tierMax
      self.requestItemExpAll(  )

  def summaryByMip( self, pmax=1 ):
    bytesPerFloat = 2.
    for m in self.mipls:
      v = self.volByMip( m, pmax=pmax )
      mlg.prnt ( '%12.12s: %6.2fTb' % (m,v*bytesPerFloat*1.e-12) )

  def rqlByMip( self, mip):
    if mip == 'TOTAL':
        mip = self.mips

    if type(mip) in [type( '' ),type( u'') ]:
      if mip not in self.mips:
        mlg.prnt ( self.mips )
        raise baseException( 'rqiByMip: Name of mip not recognised: %s' % mip )
      l1 = [i for i in  self.dq.coll['requestLink'].items if i.mip == mip]
    elif type(mip) in [ type( set()), type( [] ) ]:
      nf = [ m for m in mip if m not in self.mips]
      if len(nf) > 0:
          raise baseException( 'rqlByMip: Name of mip(s) not recognised: %s' % str(nf) )
      l1 = [i for i in  self.dq.coll['requestLink'].items if i.mip in mip]
    elif type(mip) == type( dict()):
      nf = [ m for m in mip if m not in self.mips]
      if len(nf) > 0:
        raise baseException( 'rqlByMip: Name of mip(s) not recognised: %s' % str(nf) )
      l1 = []
      for i in  self.dq.coll['requestLink'].items:
        if i.mip in mip:
          ok = False
          if len( mip[i.mip] ) == 0:
            ok = True
          else:
            for ol in self.dq.inx.iref_by_sect[i.uid].a['objectiveLink']:
              o = self.dq.inx.uid[ol]
              if self.dq.inx.uid[o.oid].label in mip[i.mip]:
                ok = True
          if ok:
              l1.append( i )
    else:
      raise baseException( 'rqiByMip: "mip" (1st explicit argument) should be type string or set: %s -- %s' % (mip, type(mip))   )

    return l1

  def rqiByMip( self, mip):
    l1 = self.rqlByMip( mip )
    if len(l1) == 0:
       return []
    l2 = [] 
    for i in l1:
       if 'requestItem' in self.dq.inx.iref_by_sect[i.uid].a:
          for u in self.dq.inx.iref_by_sect[i.uid].a['requestItem']:
               l2.append( self.dq.inx.uid[u] )

    l20 = self.rqiByMip0( mip )
    ##for i in l20:
      ##assert i in l2
    return l2
    
    
  def rqiByMip0( self, mip):

    if mip == 'TOTAL':
        mip = self.mips
    if type(mip) in [type( '' ),type( u'') ]:
      if mip not in self.mips:
        mlg.prnt ( self.mips )
        raise baseException( 'rqiByMip: Name of mip not recognised: %s' % mip )
      l1 = [i for i in  self.dq.coll['requestItem'].items if i.mip == mip]
    elif type(mip) in [ type( set()), type( [] ) ]:
      nf = [ m for m in mip if m not in self.mips]
      if len(nf) > 0:
          raise baseException( 'rqiByMip: Name of mip(s) not recognised: %s' % str(nf) )
      l1 = [i for i in  self.dq.coll['requestItem'].items if i.mip in mip]
    elif type(mip) == type( dict()):
      nf = [ m for m in mip if m not in self.mips]
      if len(nf) > 0:
        raise baseException( 'rqiByMip: Name of mip(s) not recognised: %s' % str(nf) )
      l1 = []
      for i in  self.dq.coll['requestLink'].items:
        if i.mip in mip:
          ok = False
          if len( mip[i.mip] ) == 0:
            ok = True
          else:
            for ol in self.dq.inx.iref_by_sect[i.uid].a['objectiveLink']:
              o = self.dq.inx.uid[ol]
              if self.dq.inx.uid[o.oid].label in mip[i.mip]:
                ok = True
          if ok:
              if 'requestItem' in self.dq.inx.iref_by_sect[i.uid].a:
                for u in self.dq.inx.iref_by_sect[i.uid].a['requestItem']:
                  l1.append( self.dq.inx.uid[u] )
    else:
      raise baseException( 'rqiByMip: "mip" (1st explicit argument) should be type string or set: %s -- %s' % (mip, type(mip))   )

    return l1

  def checkDir(self,odir,msg):
      if not os.path.isdir( odir ):
         try:
            os.mkdir( odir )
         except:
            print ('\n\nFailed to make directory "%s" for: %s: make necessary subdirectories or run where you have write access' % (odir,msg) )
            print ( '\n\n' )
            raise
         print ('Created directory %s for: %s' % (odir,msg) )

  def xlsByMipExpt(self,m,ex,pmax,odir='xls',xls=True,txt=False,txtOpts=None):
    mxls = scope_utils.xlsTabs(self,tiermax=self.tierMax,pmax=pmax,xls=xls, txt=txt, txtOpts=txtOpts,odir=odir)
    mlab = misc_utils.setMlab( m )
    mxls.run( m, mlab=mlab )

  def cmvByInvMip( self, mip,pmax=1,includeYears=False, exptFilter=None,exptFilterBlack=None ):
    mips = set( self.mips[:] )
    if type(mip) == type( '' ):
        mips.discard( mip )
    else:
      for m in mip:
        mips.discard( m )

    return self.cmvByMip( mips,pmax=pmax,includeYears=includeYears, exptFilter=exptFilter, exptFilterBlack=exptFilterBlack )

  def cmvByMip( self, mip,pmax=1,includeYears=False, exptFilter=None, exptFilterBlack=None ):
    if exptFilter != None:
      assert type(exptFilter) == type( set() ), 'Argument exptFilter must be None or a set: %s' % str(exptFilter)
    if exptFilterBlack != None:
      assert type(exptFilterBlack) == type( set() ), 'Argument exptFilterBlack must be None or a set: %s' % str(exptFilterBlack)
      if exptFilter != None:
        assert len( exptFilter.difference( exptFilterBlack ) ) > 0, 'If exptFilter and exptFilterBlack are both set, exptFilter must have non-black listed elements' 

    l1,ee = self.rvgByMip( mip, includePreset=True, returnLinks=True )
    if includeYears:
      expys = self.exptYears( l1, ex=exptFilter, exBlack=exptFilterBlack )
      cc = collections.defaultdict( set )
      ccts = collections.defaultdict( set )

    mipsByVar = collections.defaultdict( set )
    ss = set()
    for pr in ee:
### loop over request  var groups.
      for i in ee[pr]:
        if 'requestVar' in self.dq.inx.iref_by_sect[i.uid].a:
#
# loop over request vars in group
#
          for x in self.dq.inx.iref_by_sect[i.uid].a['requestVar']:
            i1 = self.dq.inx.uid[x]

            thisp = i1.priority
            if pr != -1:
              thisp = pr
              
            if thisp <= pmax:
              if includeYears and i1.vid in self.cmvGridId:
                ##assert i.uid in expys, 'No experiment info found for requestVarGroup: %s' % i.uid
                ## may have no entry as a consequence of tierMin being set in the requestLink(s).
                assert i1.vid in self.cmvGridId, 'No grid identification lookup found for %s: %s' % (i1.label,i1.vid)
                assert self.cmvGridId[i1.vid] in ['a','o','si','li'], 'Unexpected grid id: %s: %s:: %s' % (i1.label,i1.vid, self.cmvGridId[i1.vid])
                gflg = {'si':'','li':''}.get( self.cmvGridId[i1.vid], self.cmvGridId[i1.vid] )
                rtl = True

                if i.uid in expys.exptYears:
                  mipsByVar[i1.vid].add( i.mip )
                  if rtl:
                    for e,grd in expys.exptYears[i.uid]:
                        if exptFilter == None or e in exptFilter:
                          if grd == 'DEF':
                            if gflg == 'o' and not self.gridPolicyDefaultNative:
                            ##if gflg == 'o':
                              grd1 = '1deg'
                            else:
                              grd1 = 'native'
                          else:
                            grd1 = grd
                          cc[(i1.vid,e,grd1)].add( expys.exptYears[i.uid][e,grd] )
                          if i.uid in self.tsliceDict and e in self.tsliceDict[i.uid]:
                            for thisSlice in self.tsliceDict[i.uid][e]:
                              ccts[(i1.vid,e)].add( (thisSlice,thisp) )
                          else:
                            ccts[(i1.vid,e)].add( (None,thisp) )

                  else:

                   for gf in expys.exptYears[i.uid]:
                    for e,grd in expys.exptYears[i.uid][gf]:
                      if grd in ["1deg",'2deg'] or gf == gflg:
                        if exptFilter == None or e in exptFilter:
                          cc[(i1.vid,e,grd)].add( expys.exptYears[i.uid][gf][e,grd] )
              else:
                print ( 'SKIPPING %s: %s' % (i1.label,i1.vid) )
                ss.add( i1.vid )

    if self.intersection and type(mip) == type( set() ) and len(mip) > 1:
      sint = set( [k for k in mipsByVar if len( mipsByVar[k] ) == len(mip)] )
      print ( 'INTERSECTION: %s out of %s variables [%s]' % (len(sint),len(mipsByVar.keys()),str(mip)) )
      xxx = [t for t in cc if t[0] not in sint]
      for t in xxx:
          del cc[t]
    if includeYears:
      l2 = collections.defaultdict( dict )
      l2x = collections.defaultdict( dict )
##
## this removes lower ranked grids .... but for some groups want different grids for different variable categories
##
      if self.gridPolicyTopOnly:
        for v,e,g in cc:
          l2x[(v,e)][g] = max( list( cc[(v,e,g)] ) )
        for v,e in l2x:
          if len( l2x[(v,e)].keys() ) == 1:
             g,val = list( l2x[(v,e)].items() )[0]
          else:
            kk = gridSorter.sort( l2x[(v,e)].keys() )
            gflg = {'si':'','li':''}.get( self.cmvGridId[v], self.cmvGridId[v] )
            g = kk[0]
            if g not in l2x[(v,e)]:
              print ( '%s not found in %s (%s):' % (g,str(l2x[(v,e)].keys()),str(kk)) )
            val = l2x[(v,e)][g]
                
          l2[v][(e,g)] = val
      else:
        for v,e,g in cc:
          l2[v][(e,g)] = max( list( cc[(v,e,g)] ) )

      l2ts = collections.defaultdict( dict )
      for v in l2:
        for e,g in l2[v]:
          if (v,e) in ccts:
            ccx = collections.defaultdict( set )
            for x in ccts[(v,e)]:
              ccx[x[0]].add( x[1] )
            if len( ccx.keys() ) > 1:
              tslp = [ (k,min(ccx[k])) for k in ccx ]
              thisTimeSlice = timeSlice( tslp )
              rc, ts, msg = thisTimeSlice.sort()
              ##rc, ts, msg = sortTimeSlice( tslp )
              if rc == 1:
                l2ts[v][e] = tuple( list(ts) + [g,] )
              elif rc == 2:
                try:
##(('abrupt5', 'simpleRange', 0, 5), 1), (('abrupt30', 'simpleRange', 121, 150), 1)]
                  yl = list( range( ts[0][0][2], ts[0][0][3] + 1) ) + list( range( ts[1][0][2], ts[1][0][3] + 1) )
                except:
                  print ( 'FAILED TO GENERATE YEARLIST' )
                  print ( str((v,e) ) )
                  print ( 'range( ts[0][0][2], ts[0][0][3] + 1) + range( ts[1][0][2], ts[1][0][3] + 1)' )
                  print ( str(ts) )
                  raise
### tslab,tsmode,a,b,priority,grid
                l2ts[v][e] = ('_union', 'YEARLIST', len(yl), str(yl), ts[1], g )
              else:
                print ('TIME SLICE MULTIPLE OPTIONS FOR : %s, %s, %s, %s' % (v,e,str(ccts[(v,e)]), msg ) )
            else:
              a = list(ccx.keys())[0]
              b = min( [x[1] for x in ccts[(v,e)] ] )
              if type(a) == type( [] ):
                l2ts[v][e] = a + [b,g,]
              elif type(a) == type( () ):
                l2ts[v][e] = list(a) + [b,g,]
              elif a == None:
                l2ts[v][e] = [None,b,g]
              else:
                assert False, 'Bad type for ccts record: %s' % type( a)
      return l2, l2ts
    else:
      l2 = sorted( [i for i in [self.dq.inx.uid[i] for i in ss] if i._h.label != 'remarks'], key=lambda x: x.label )
      return l2

  def exptFilterList(self,val,option,ret='uid'):
    if type( val ) not in [[],()]:
      val = [val,]

    if option == 'lab':
      v0 = val[:]
      val = []
      mm = []
      for v in v0:
        if v not in self.exptByLabel:
          mm.append( v )
        else:
          val.append( self.exptByLabel[v] )

      assert len(mm) == 0, 'Experiment names not all recognised: %s' % str(mm)

    oo = set()
    for v in val:
      i = self.dq.inx.uid[v]
      if i._h.label in ['exptgroup','mip']:
        if 'experiment' in self.dq.inx.iref_by_sect[i.uid].a:
          for u in self.dq.inx.iref_by_sect[i.uid].a['experiment']:
            oo.add( u )
      elif i._h.label == 'experiment':
            oo.add( i.uid )
      else:
        print ('WARNING .. skipping request for experiment which links to record of type %s' % i._h.label )
    return oo
    
  def getFreqStrSummary(self,mip,pmax=1):
##
## get a dictionary keyed on CMORvar uid, containing dictionary keyed on (experiment, grid) with value as number of years.
##
    if not self.uniqueRequest:
      cmv, self.cmvts = self.cmvByMip(mip,pmax=pmax,includeYears=True,exptFilter=self.exptFilter,exptFilterBlack=self.exptFilterBlack)
    else:
      cmv1, cmvts1 = self.cmvByInvMip(mip,pmax=pmax,includeYears=True,exptFilter=self.exptFilter,exptFilterBlack=self.exptFilterBlack)
      cmv2, cmvts2 = self.cmvByMip('TOTAL',pmax=pmax,includeYears=True,exptFilter=self.exptFilter,exptFilterBlack=self.exptFilterBlack)
      cmv = self.differenceSelectedCmvDict(  cmv1, cmv2 )

    if not self.retainRedundantRank:
      len1 = len(cmv)
      self.cmvFilter.filterByChoiceRank(cmv=cmv,asDict=True)
      len2 = len(cmv)
      ##print 'INFO.redundant.0001: length %s --> %s' % (len1,len2)
 
    self.selectedCmv = cmv
    return self.cmvByFreqStr( cmv )

  def differenceSelectedCmvDict( self, cmv1, cmv2 ):
      """Return the diffence between two dictionaries of cmor variables returned by self.cmvByMip.
         The dictionaries contain dictionaries of values. Differences may be subdictionaries not present,
         elements of sub-dictionaries not present, or elements of sub-dictionaries present with different values.
         A one sided difference is returned."""

      cmv = {}
      for i in cmv2:
        if i not in cmv1:
          cmv[i] = cmv2[i]
        else:
          eei = {}
          for t in cmv2[i]:
            if t not in cmv1[i]:
              eei[t] = cmv2[i][t]
            else:
              if cmv2[i][t] > cmv1[i][t]:
                 eei[t] = cmv2[i][t] - cmv1[i][t]
          if len( eei.keys() ) != 0:
            cmv[i] = eei
      return cmv

  def cmvByFreqStr(self,cmv,asDict=True,exptFilter=None,exptFilterBlack=None):
    if exptFilter != None:
      assert type(exptFilter) == type( set() ), 'Argument exptFilter must be None or a set: %s' % str(exptFilter)
    if exptFilterBlack != None:
      assert type(exptFilterBlack) == type( set() ), 'Argument exptFilterBlack must be None or a set: %s' % str(exptFilterBlack)
      if exptFilter != None:
        assert len( exptFilter.difference( exptFilterBlack ) ) > 0, 'If exptFilter and exptFilterBlack are both set, exptFilter must have non-black listed elements' 

    cc = collections.defaultdict( list )
    for i in cmv:
      if asDict:
        ii = self.dq.inx.uid[i]
        if ii._h.label != 'remarks':
         st = self.dq.inx.uid[ ii.stid ]
         if st._h.label != 'remarks':
          cc0 = collections.defaultdict( float )
          cc1 = collections.defaultdict( int )
          se = collections.defaultdict( set )
          for e,g in cmv[i]:
            cc0[g] += cmv[i][(e,g)]
            cc1[g] += 1
            se[g].add(e)
          for g in cc0:
            g1 = g
            if self.isLatLon[st.spid] != False:
              g1 = g
              if g1 == 'DEF' and self.isLatLon[st.spid] == 'o':
                  if self.gridPolicyDefaultNative:
                     g1 = 'native'
                  else:
                     g1 = '1deg'
              elif g == 'native:01':
                gflg = {'si':'','li':''}.get( self.cmvGridId[i], self.cmvGridId[i] )
                if gflg == 'o' and not self.gridOceanStructured:
                  g1 = '1deg'
                else:
                  g1 = 'native'
              elif g1 in ['1deg','2deg','native']:
                pass
              else:
                print ( 'WARNING --- blind default to native: %s' % g )
                g1 = 'native'
            elif g == 'native:01':
                g1 = 'native'

            cc[ (st.spid,st.__dict__.get('odims',''),ii.frequency,g1) ].append( (i,cc0[g],cc1[g],se[g]) )

      else:
        st = self.dq.inx.uid[ i.stid ]
        cc[ (st.spid,st.__dict__.get('odims',''),i.frequency) ].append( i.label )

    self.thiscmvset = set()
    c2 = collections.defaultdict( dict )
    sf = set()
    if asDict:
      for s,o,f,g in cc.keys():
        c2[(s,o,g)][f] = cc[ (s,o,f,g) ]
        sf.add( f )
    else:
      for s,o,f in cc.keys():
        c2[(s,o)][f] = cc[ (s,o,f) ]
        sf.add( f )
    lf = sorted( list(sf) )
    c3 = collections.defaultdict( dict )

    for tt in sorted( c2.keys() ):
      if asDict:
        s,o,g = tt
      else:
        s,o = tt
        g = 'native'
      i = self.dq.inx.uid[ s ]

      if asDict:
        for f in c2[tt]:
            isClim = f.lower().find( 'clim' ) != -1
            ny = 0
            expts = set()
            labs = []
            labs = collections.defaultdict( int )
            ccx = collections.defaultdict( list )
            for cmvi, ny1, ne, eset in c2[tt][f]:
              ccx[cmvi].append( (ny1, ne, eset) )
            net = 0
            for cmvi in ccx:
              if len( ccx[cmvi] ) == 1:
                 ny1, ne, eset = ccx[cmvi][0]
              else:
                 ny1, ne, eset = ( 0,0,set() )
                 for a,b,s in ccx[cmvi]:
                   ny1 += a
                   ne += b
                   eset = eset.union(  s )
              
              net += ne
              if len(eset) != ne:
                print ( 'WARNING: inconsistency in volume estimate ... possible duplication for %s,%s' % (cmvi,f) )
              for e in eset:
                elab = self.dq.inx.uid[e].label
                expts.add(elab)

              if exptFilter != None:
                expts = exptFilter.intersection( expts )
              if exptFilterBlack != None:
                expts = expts.difference( exptFilterBlack )

              if len(expts) > 0:
                lab = self.dq.inx.uid[cmvi].label
                self.thiscmvset.add( cmvi )
                ny += ny1
                labs[cmvi] += ny1
            ne = len( expts )
            nn = len( labs.keys() )
              
            if isClim:
              ny = net/float(nn)
            else:
              ny = ny/float(nn)
            assert tt[2] in ['native','1deg','2deg','native:01'], 'BAD grid identifier: %s' % str(tt)
            c3[tt][f] = (nn,ny,ne, labs,expts)
    return (sf,c3)

  def getStrSz( self, g, stid=None, s=None, o=None, tt=False, cmv=None ):
    assert stid == None or (s==None and o==None), 'Specify either stid or s and o'
    assert stid != None or (s!=None and o!=None), 'Specify either stid or s and o'

    if stid != None:
      st = self.dq.inx.uid[stid]
      if st._h.label != 'remarks':
        s = st.spid
        o = st.__dict__.get( 'odims', '' )
      else:
        self.strSz[ (stid,g) ] = (False,0)
        if tt:
          return (self.strSz[ (stid,g) ], None)
        else:
          return self.strSz[ (stid,g) ]

    g1 = g
    if g1 == 'DEF':
          if self.isLatLon[s] == 'o':
             g1 = '1deg'
          else:
             g1 = 'native'
    elif g1 == 'native:01':
      assert cmv != None, 'Need a valid cmor variable id  .... '
      gflg = {'si':'','li':''}.get( self.cmvGridId[cmv], self.cmvGridId[cmv] )
      if gflg == 'o' and not self.gridOceanStructured:
                  g1 = '1deg'
      else:
                  g1 = 'native'
    if (s,o,g) not in self.strSz:

        if o == '':
           sf = 1
        elif o in self.odsz:
           sf = self.odsz[o]
        else:
           sf = 5

        if type( sf ) == type( () ):
           sf = sf[0]

        try:
          if g1 != 'native' and self.isLatLon[s] != False:
            szg = self.szgss[g1][s]
          else:
            szg = self.szss[s]
        except:
          print ( 'Failed to get size for: %s, %s, %s' % (g,g1,s ) )
          raise

        szg = szg * sf
        self.strSz[ (s,o,g) ] = (True,szg)

    if tt:
      return (self.strSz[ (s,o,g) ], (s,o,g1) )
    else:
      return self.strSz[ (s,o,g) ]

  def rvgByMip( self, mip, years=False, includePreset=False, returnLinks=False ):
    l1 = self.rqlByMip( mip )
    if includePreset:
      cc = collections.defaultdict( set )
      ss = set()
      for i in l1:
        if 'requestItem' in self.dq.inx.iref_by_sect[i.uid].a:
          prs = set()
          for x in self.dq.inx.iref_by_sect[i.uid].a['requestItem']:
             prs.add(self.dq.inx.uid[x].preset)

          for p in prs:
            assert p in [-1,1,2,3], 'Bad preset value'
            cc[p].add( i.refid )
      ee = {}
      for p in cc:
        l2 = sorted( [self.dq.inx.uid[i] for i in cc[p]], key=lambda x: x.label )
        ee[p] = l2
      if returnLinks:
        return (l1,ee)
      else:
        return ee
    else:
      ss = set( [i.refid for i in l1] )
      l2 = sorted( [self.dq.inx.uid[i] for i in ss], key=lambda x: x.label )
      if returnLinks:
        return (l1,l2)
      else:
        return l2

  def volByMip2( self, mip, pmax=2, intersection=False, adsCount=False, exptid=None,makeTabs=False, odir='xls'):
      vs = volsum.vsum( self, odsz, npy )
      rqf = 'dummy'
      vsmode='short'
      if makeTabs:
        mlab = misc_utils.setMlab( mip )
        rqf = '%s/requestVol_%s_%s_%s' % (odir,mlab,self.tierMax,pmax)
        vsmode='full'
      vs.run( mip, rqf, pmax=pmax, doxlsx=makeTabs ) 
      vs.anal(olab='dummy', doUnique=False, mode=vsmode, makeTabs=makeTabs)
      self.vf = vs.res['vf'].copy()
      for f in sorted( vs.res['vf'].keys() ):
           mlg.prnt ( 'Frequency: %s: %s' % (f, vs.res['vf'][f]*2.*1.e-12 ) )
      ttl = sum( [x for k,x in vs.res['vu'].items()] )
      self.res = vs.res
      self.indexedVol = collections.defaultdict( dict )
      for u in vs.res['vu']:
        cmv = self.dq.inx.uid[u]
        self.indexedVol[cmv.frequency]['%s.%s' % (cmv.mipTable,cmv.label)] = vs.res['vu'][u]
      return ttl

  def volByMip( self, mip, pmax=2, intersection=False, adsCount=False, exptid=None):

    l1 = self.rqiByMip( mip )
      
    #### The set of experiments/experiment groups:
    if exptid == None:
      exps = self.experiments
    elif type( exptid ) == type(''):
      exps = set( [exptid,] )
    else:
      assert type( exptid ) == type( set() ),'exptid arg to volByMip must be None, string or set: %s' % type( exptid )
      exps = exptid
    
    self.volByE = {}
    vtot = 0
    cc = collections.defaultdict( col_count )
    self.allVars = set()
    for e in exps:
      expts = self.esid_to_exptList(e,deref=True,full=False)
      if expts not in  [None,[]]:
        for ei in expts:
          self.volByE[ei.label] = self.volByExpt( l1, ei.uid, pmax=pmax, cc=cc, intersection=intersection, adsCount=adsCount )
          vtot += self.volByE[ei.label][0]
        self.allVars = self.allVars.union( self.vars )
    self.indexedVol = cc

    return vtot

  def listIndexDual(self, ll, a1, a2, acount=None, alist=None, cdict=None, cc=None ):
    do_count = acount != None
    do_list = alist != None
    assert not (do_count and do_list), 'It is an error to request both list and count'
    if not (do_count or do_list):
      acount = '__number__'
      do_count = True

    if cc == None:
      if do_count:
        cc = collections.defaultdict( col_count )
      elif do_list:
        cc = collections.defaultdict( col_list )

    if do_count:
      for l in ll:
        if cdict != None:
          v = cdict[l.uid]
        elif acount == '__number__':
          v = 1
        else:
          v = l.__dict__[acount]

        cc[ l.__dict__[a1] ].a[ l.__dict__[a2] ] += v
    elif do_list:
      for l in ll:
        if cdict != None:
          v = cdict[l.uid]
        elif alist == '__item__':
          v = l
        else:
          v = l.__dict__[alist]
        cc[ l.__dict__[a1] ].a[ l.__dict__[a2] ].append( v )

    od = {}
    for k in cc.keys():
      d2 = {}
      for k2 in cc[k].a.keys():
        d2[k2] = cc[k].a[k2]
      od[k] = d2
    return od

class dreqUI(object):
  """Data Request Command line.
-------------------------
      -v : print version and exit;
      --unitTest : run some simple tests;
      -m <mip>:  MIP of list of MIPs (comma separated; use '_all_' for all;  for objective selection see note [1] below);
      -l <options>: List for options: 
              o: objectives
              e: experiments
      -q <options>: List information about the schema:
              s: sections
              <section>: attributes for a section
              <section:attribute>: definition of an attribute.
      -h :       help: print help text;
      -e <expt>: experiment;
      -t <tier> maxmum tier;
      -p <priority>  maximum priority;
      --xls : Create Excel file with requested variables;
      --sf : Print summary of variable count by structure and frequency [default];
      --legacy : Use legacy approach to volume estimation (deprecated);
      --xfr : Output variable lists in sheets organised by frequency and realm instead of by MIP table;
      --SF : Print summary of variable count by structure and frequency for all MIPs;
      --grdpol <native|1deg> :  policy for default grid, if MIPs have not expressed a preference;
      --grdforce <native|1deg> :  force a specific grid option, independent of individual preferences;
      --ogrdunstr : provide volume estimates for unstructured ocean grid (interpolation requirements of OMIP data are different in this case);
      --omitCmip : omit the CMIP core data request (included by default);
      --allgrd :  When a variable is requested on multiple grids, archive all grids requested (default: only the finest resolution);
      --unique :  List only variables which are requested uniquely by this MIP, for at least one experiment;
      --esm :  include ESM experiments (default is to omit esm-hist etc from volume estimates; over-ridden by --mcat);
      --txt : Create text (tab seperated variables) file with requested variables; the files are placed in the same directory as xls files;
      --mcfg : Model configuration: 7 integers, comma separated, 'nho','nlo','nha','nla','nlas','nls','nh1'
                 default: 259200,60,64800,40,20,5,100
      --mcat [none]: Source types inlcuded in model, as comma separated list: only experiments with all required source types are included in volume estimates. Set to 'none' to turn off filtering;
      --mcat-strict : if present, the experiments are filtered to those with the specified configuration, not allowing components to be switched off;
      --txtOpts : options for content of text file: (v|c)[(+|-)att1[,att2[...]]]
      --xlsDir <directory> : Directory in which to place variable listing [xls];
      --xmlVersion <version> : version number of XML document [only with extension enabled -- not stable];
      --printLinesMax <n>  : Maximum number of lines to be printed (default 20)
      --printVars    : If present, a summary of the variables (see --printLinesMax) fitting the selection options will be printed
      --intersection : Analyse the intersection of requests rather than union.

NOTES
-----
[1] A set of objectives within a MIP can be specified in the command line. The extended syntax of the "-m" argument is:
-m <mip>[:objective[.obj2[.obj3 ...]]][,<mip2]...]

e.g.
drq -m HighResMIP:Ocean.DiurnalCycle
"""
  def __init__(self,args):
    self.adict = {'mcatStrict':False}
    self.knownargs = {'-m':('m',True), '-p':('p',True), '-e':('e',True), '-t':('t',True), \
                      '-h':('h',False), '--printLinesMax':('plm',True), \
                      '-l':('l',True),
                      '-q':('q',True),
                      '--printVars':('vars',False), '--intersection':('intersection',False), \
                      '--count':('count',False), \
                      '--txt':('txt',False), \
                      '--sf':('sf',False), \
                      '--legacy':('legacy',False), \
                      '--xfr':('xfr',False), \
                      '--SF':('SF',False), \
                      '--esm':('esm',False), \
                      '--grdpol':('grdpol',True), \
                      '--ogrdunstr':('ogrdunstr',False), \
                      '--grdforce':('grdforce',True), \
                      '--omitCmip':('omitcmip',False), \
                      '--allgrd':('allgrd',False), \
                      '--unique':('unique',False), \
                      '--mcfg':('mcfg',True), \
                      '--mcat':('mcat',True), \
                      '--mcatStrict':('mcatStrict',False), \
                      '--txtOpts':('txtOpts',True), \
                      '--xmlVersion':('xmlVersion',True), \
                      '--xlsDir':('xlsdir',True), '--xls':('xls',False) \
                       } 
    aa = args[:]
    notKnownArgs = []
    while len(aa) > 0:
      a = aa.pop(0)
      if a in self.knownargs:
        b = self.knownargs[a][0]
        if self.knownargs[a][1]:
          v = aa.pop(0)
          self.adict[b] = v
        else:
          self.adict[b] = True
      else:
        notKnownArgs.append(a)

    assert self.checkArgs( notKnownArgs ), 'FATAL ERROR 001: Arguments not recognised: %s' % (str(notKnownArgs) )

    if self.adict.get('mcat','none') != 'none':
      self.adict['esm'] = True

    if 'm' in self.adict:
      if self.adict['m'] == '_all_':
        pass
      elif self.adict['m'].find( ':' ) != -1:
        ee = {}
        for i in self.adict['m'].split(','):
          bits =  i.split( ':' )
          if len( bits ) == 1:
             ee[bits[0]] = []
          else:
             assert len(bits) == 2, 'Cannot parse %s' % self.adict['m']
             ee[bits[0]] = bits[1].split( '.' )
        self.adict['m'] = ee
      else:
        self.adict['m'] = set(self.adict['m'].split(',') )
        if 'omitcmip' not in self.adict and 'CMIP' not in self.adict['m']:
          self.adict['m'].add( 'CMIP' )

    if self.adict.get('mcat','none') != 'none':
      stys = self.adict['mcat'].split(',')
      stys_pp = stys[:]
      if 'AOGCM' in stys:
         stys_pp.append( 'AGCM' )
      if 'AGCM' in stys_pp:
         stys_pp += ['LAND','RAD'] 
      self.adict['_mcat'] = (stys,stys_pp)
    if 'grdpol' in self.adict:
      assert self.adict['grdpol'] in ['native','1deg'], 'Grid policy argument --grdpol must be native or 1deg : %s' % self.adict['grdpol']

    if 'grdforce' in self.adict:
      assert self.adict['grdforce'] in ['native','1deg'], 'Grid policy argument --grdforce must be native or 1deg : %s' % self.adict['grdforce']

    integerArgs = set( ['p','t','plm'] )
    for i in integerArgs.intersection( self.adict ):
      self.adict[i] = int( self.adict[i] )

    self.intersection = self.adict.get( 'intersection', False )

  
  def checkArgs( self, notKnownArgs ):
    if len( notKnownArgs ) == 0:
      return True
    print ('--------------------------------------')
    print ('------------  %s Arguments Not Recognised ------------' % len(notKnownArgs) )
    k = 0
    for x in notKnownArgs:
      k += 1
      if x[1:] in self.knownargs:
        print ( '%s PERHAPS %s instead of %s' % (k, x[1:],x) )
      elif '-%s' % x in self.knownargs:
        print ( '%s PERHAPS -%s instead of %s' % (k, x,x) )
      elif x[0] == '\xe2':
        print ( '%s POSSIBLY -- (double hyphen) instead of long dash in %s' % (k, x) )
    print ('--------------------------------------')

    return len( notKnownArgs ) == 0
      
  def run(self, dq=None):
    if 'h' in self.adict:
      mlg.prnt ( self.__doc__ )
      return

    xmlVersion = self.adict.get( 'xmlVersion', None )
    if 'q' in self.adict:
      if dq == None:
        dq = dreq.loadDreq(configOnly=True, xmlVersion=xmlVersion)
      s = self.adict['q']
      if self.adict['q'] == 's':
        ss = sorted( [(i.title,i.label) for i in dq.coll['__sect__'].items] )
        for s in ss:
          mlg.prnt( '%16s:: %s' % (s[1],s[0]) )
      else:
        ss = [i.label for i in dq.coll['__sect__'].items]
        if s.find( ':' ) != -1:
          s,a = s.split( ':' )
        else:
          a = None
        if s not in ss:
          mlg.prnt( 'ERROR: option must be a section; use "-q s" to list sections' )
        elif a == None:
          x = [i for i in dq.coll['__sect__'].items if i.label == s]
          s1 = [i for i in  dq.coll['__main__'].items if 'ATTRIBUTE::%s' % s in i.uid]
          mlg.prnt( x[0].title )
          mlg.prnt( ' '.join( sorted  ([i.label for i in s1] ) ))
        else:
          x = [i for i in dq.coll['__main__'].items if i.uid == 'ATTRIBUTE::%s.%s' % (s,a) ]
          if len(x) == 0:
            mlg.prnt( 'ERROR: attribute not found' )
            s1 = [i for i in  dq.coll['__main__'].items if 'ATTRIBUTE::%s' % s in i.uid]
            mlg.prnt( 'ATTRIBUTES: ' + ' '.join( sorted  ([i.label for i in s1] ) ))
          else:
            mlg.prnt( 'Section %s, attribute %s' % (s,a) )
            mlg.prnt( x[0].title )
            mlg.prnt( x[0].description )
      return

    if not ('m' in self.adict or 'SF' in self.adict):
      mlg.prnt ( 'Current version requires -m or --SF argument'  )
      mlg.prnt ( self.__doc__ )
      sys.exit(0)

    if dq == None:
      self.dq = dreq.loadDreq(xmlVersion=xmlVersion)
    else:
      self.dq = dq

    if 'l' in self.adict:
      self.printList()
      return

    if 'mcfg' in self.adict:
      ll = self.adict['mcfg'].split( ',' )
      assert len(ll) == 7, 'Length of model configuration argument must be 7 comma separated integers: %s' %  self.adict['mcfg']
      lli = [ int(x) for x in ll]

    self.sc = dreqQuery( dq=self.dq )
    self.sc.intersection = self.intersection

    
    if 'grdforce' in self.adict:
      self.sc.gridPolicyForce = self.adict['grdforce']
    if 'grdpol' in self.adict:
      self.sc.gridPolicyDefaultNative = self.adict['grdpol'] == 'native'
      print ( 'SETTING grid policy: %s' % self.sc.gridPolicyDefaultNative )
    if 'allgrd' in self.adict:
      self.sc.gridPolicyTopOnly = False
      print ( 'SETTING grid policy for multiple preferred grids: %s' % self.sc.gridPolicyTopOnly )
    if 'unique' in self.adict:
      self.sc.uniqueRequest = True
    self.sc.gridOceanStructured = not self.adict.get( 'ogrdunstr', False )

    if 'mcfg' in self.adict:
      self.sc.setMcfg( lli )

    tierMax = self.adict.get( 't', 1 )
    self.sc.setTierMax(  tierMax )
    pmax = self.adict.get( 'p', 1 )

    makeXls = self.adict.get( 'xls', False )
    makeTxt = self.adict.get( 'txt', False )
    ##doSf = 'SF' in self.adict or 'sf' in self.adict
    doSf = 'legacy' not in self.adict
    if doSf:
      self.adict['sf'] = True
    assert not ('legacy' in self.adict and 'sf' in self.adict), "Conflicting command line argument, 'legacy' and 'sf': use only one of these"

    if makeXls or makeTxt or doSf:
      xlsOdir = self.adict.get( 'xlsdir', 'xls' )
      self.sc.checkDir( xlsOdir, 'xls files' )

    tabByFreqRealm = self.adict.get( 'xfr', False )
    if 'SF' in self.adict:
      self.sc.gridPolicyDefaultNative = True
      vs = volsum.vsum( self.sc, odsz, npy, odir=xlsOdir, tabByFreqRealm=tabByFreqRealm )
      vs.analAll(pmax)

      self.sc.gridPolicyDefaultNative = False
      vs = volsum.vsum( self.sc, odsz, npy, odir=xlsOdir, tabByFreqRealm=tabByFreqRealm )
      vs.analAll(pmax)

      self.sc.setTierMax( 3 )
      vs = volsum.vsum( self.sc, odsz, npy, odir=xlsOdir, tabByFreqRealm=tabByFreqRealm )
      vs.analAll(3)
      return

    ok = True
    if self.adict['m'] == '_all_':
      self.adict['m'] = set(self.sc.mips )
      mlab = 'TOTAL'
    else:
      for i in self.adict['m']:
        if i not in self.sc.mips:
          ok = False
          tt = misc_utils.mdiff().diff( i,self.sc.mips )
          assert not tt[0], 'Bad logic ... unexpected return from misc_utils.mdiff'
          ##cms = difflib.get_close_matches(i,self.sc.mips )
          if tt[1] == 0:
            mlg.prnt ( 'NOT FOUND: %s' % i )
          else:
            msg = []
            for ix in tt[2]:
              msg.append( '%s [%4.1f]' % (','.join( ix[1] ),ix[0]) ) 

            mlg.prnt( '----------------------------------------' )
            if tt[1] == 1 and len(tt[2][0][1]) == 1:
              mlg.prnt ( 'NOT FOUND: %s:  SUGGESTION: %s' % (i,msg[0]) )
            else:
              mlg.prnt ( 'NOT FOUND: %s:  SUGGESTIONS: %s' % (i,'; '.join( msg ) ) ) 
            mlg.prnt( '----------------------------------------' )
      mlab = misc_utils.setMlab( self.adict['m'] )
    assert ok,'Available MIPs: %s' % str(self.sc.mips)

    eid = None
    ex = None
    if 'e' in self.adict:
      ex = self.adict['e']
      if ex in self.sc.mipsp:
        eid = set( self.dq.inx.iref_by_sect[ex].a['experiment'] )
        self.sc.exptFilter = eid
      elif self.adict['e'] in self.sc.exptByLabel:
        eid = self.sc.exptByLabel[ self.adict['e'] ]
        self.sc.exptFilter = set( [eid,] )
      else:
        ns = 0
        md =  misc_utils.mdiff()
        ttm = md.diff( self.adict['e'],self.sc.mipsp )
        tte = md.diff( self.adict['e'],self.sc.exptByLabel.keys() )
        if ttm[1] > 0 and tte[1] == 0 or (ttm[2][0][0] > 0.6*tte[2][0][0]):
          oo =  md.prntprep( self.adict['e'], ttm )
          for l in oo:
            mlg.prnt( l )
        if tte[1] > 0 and ttm[1] == 0 or (tte[2][0][0] > 0.6*ttm[2][0][0]):
          oo =  md.prntprep( self.adict['e'], tte )
          for l in oo:
            mlg.prnt( l )
        assert False, 'Experiment/MIP %s not found' % self.adict['e']

    if not self.adict.get( 'esm', False ):
      ss = set()
      for e in ['esm-hist','esm-hist-ext','esm-piControl','piControl-spinup','esm-piControl-spinup']:
        ss.add( self.sc.exptByLabel[ e ] )
      self.sc.exptFilterBlack = ss

    if self.sc.exptFilterBlack != None and self.sc.exptFilter != None:
      ss = [x for x in self.sc.exptFilter if x not in self.sc.exptFilterBlack]
      if len(ss) == 0:
          print ( """WARNING: filter settings give no experiments: try using --esm flag: by default esm experiments are filtered out""" )
          return


    makeTxt = self.adict.get( 'txt', False )
    makeXls = self.adict.get( 'xls', False )
    if 'txtOpts' in self.adict:
        if self.adict['txtOpts'][0] == 'v':
          txtOpts = NT_txtopts( 'var' )
        else:
          txtOpts = NT_txtopts( 'cmv' )
    else:
        txtOpts=None


    exptFilters = collections.defaultdict( set )
    for i in self.dq.coll['experiment'].items:
## required
       tt = tuple( i.mcfg.split( '|' )[0].strip().split(' ')  )
## allowed
       uu = tuple( i.mcfg.split( '|' )[1].strip().split(' ')  )
       exptFilters[(tt,uu)].add(i.uid)
## NB this is the default##
    if 'sf' in self.adict:
      if self.adict.get('mcat','none') != 'none':
        thisFilter = set()
        ##self.sc.exptFilter = set()
        for tt,uu in exptFilters:
          t1 = all( [x in self.adict['_mcat'][1] for x in tt] )
          if self.adict['mcatStrict']:
            t1 = t1 and all( [x in (tt + uu) for x in self.adict['_mcat'][0] ] )
          if t1:
            thisFilter = thisFilter.union( exptFilters[(tt,uu)] )
        if self.sc.exptFilter == None:
           self.sc.exptFilter = thisFilter
        else:
           self.sc.exptFilter = thisFilter.intersection( self.sc.exptFilter )
        if len( self.sc.exptFilter ) == 0:
          print ( 'WARNING: filter settings give no experiments' )
          return
        
      ##vs = volsum.vsum( self.sc, odsz, npy, odir=xlsOdir, tabByFreqRealm=tabByFreqRealm, txt=makeTxt,txtOpts=txtOpts, exptFilter=exptFilters['AOGCM'] )
      vs = volsum.vsum( self.sc, odsz, npy, odir=xlsOdir, tabByFreqRealm=tabByFreqRealm, txt=makeTxt,txtOpts=txtOpts )
      self.vs = vs
      vs.run( self.adict['m'], '%s/requestVol_%s_%s_%s' % (xlsOdir,mlab,tierMax,pmax), pmax=pmax, doxlsx=makeXls ) 
      totalOnly = False
      if len( self.adict['m'] ) == 1 or totalOnly:
        if makeXls:
          vsmode='full'
        else:
          vsmode='short'
        vs.anal(olab=mlab,doUnique=False, mode=vsmode, makeTabs=makeXls)
        for f in sorted( vs.res['vf'].keys() ):
           mlg.prnt ( 'Frequency: %s: %s' % (f, vs.res['vf'][f]*2.*1.e-12 ) )
        ttl = sum( [x for k,x in vs.res['vu'].items()] )*2.*1.e-12
        mlg.prnt( 'TOTAL volume: %8.2fTb' % ttl )
        self.printListCc(vs.res['vu'])
        return
      
      mips = self.adict['m']
      if type(mips) in [type(set()),type(dict())]:
          mips = self.adict['m'].copy()
          if len(mips) > 1:
            if type(mips) == type(set()):
               mips.add( '*TOTAL' )
            else:
               mips['*TOTAL'] = ''

      vs.analAll(pmax,mips=mips,html=False,makeTabs=makeXls)
      thisd = {}
      for m in sorted( self.adict['m'] ) + ['*TOTAL',]:
        for f in sorted( vs.rres[m].keys() ):
           mlg.prnt ( '%s:: Frequency: %s: %s' % (m,f, vs.rres[m][f]*2.*1.e-12 ) )
      for m in sorted( self.adict['m'] ) + ['*TOTAL',]:
        thisd[m] = sum( [x for k,x in vs.rres[m].items()] )
        mlg.prnt( '%s:: TOTAL volume: %8.2fTb' % (m, thisd[m]*2.*1.e-12 )  )
      self.printListCc(vs.rresu['*TOTAL'])
      return

    adsCount = self.adict.get( 'count', False )

    self.getVolByMip(pmax,eid,adsCount)

    if makeXls or makeTxt:
      mips = self.adict['m']

      self.sc.xlsByMipExpt(mips,eid,pmax,odir=xlsOdir,xls=makeXls,txt=makeTxt,txtOpts=txtOpts)

  def printListCc(self,cc):
    if self.adict.get( 'vars', False ):
      if python2:
            vl = sorted( cc.keys(), cmp=cmpd(cc).cmp, reverse=True )
      else:
            vl = sorted( cc.keys(), key=lambda x: cc[x], reverse=True )
      printLinesMax = self.adict.get( 'plm', 20 )
      if printLinesMax > 0:
        mx = min( [printLinesMax,len(vl)] )
      else:
        mx = len(vl)

      for k in vl[:mx]:
            cmv = self.dq.inx.uid[k]
            print ('%s.%s::   %sTb' % (cmv.mipTable, cmv.label, cc[k]*2.*1.e-12) )

  def printList(self):
    mips = self.adict['m']
    ee = {}
    for i in self.dq.coll['mip'].items:
      if i.label in mips:
        ee[i.label] = i
    if self.adict['l'] in ['o','e']:
      targ = {'o':'objective', 'e':'experiment' }[self.adict['l']]
      for k in sorted( ee.keys() ):
        if targ in self.dq.inx.iref_by_sect[ee[k].uid].a:
          for u in self.dq.inx.iref_by_sect[ee[k].uid].a[targ]:
            print ( '%s: %s' % (ee[k].label, self.dq.inx.uid[u].label) )
    else:
      print ('list objective *%s* not recognised (should be e or o)' % self.adict['l'] )
      
  def getVolByMip(self,pmax,eid,adsCount):

    v0 = self.sc.volByMip( self.adict['m'], pmax=pmax, intersection=self.intersection, adsCount=adsCount, exptid=eid )
    mlg.prnt ( 'getVolByMip: %s [%s]' % (v0,misc_utils.vfmt(v0*2.)) )
    cc = collections.defaultdict( int )
    for e in self.sc.volByE:
      for v in self.sc.volByE[e][2]:
          cc[v] += self.sc.volByE[e][2][v]
    x = 0
    for v in cc:
      x += cc[v]
    
    if python2:
      vl = sorted( cc.keys(), cmp=cmpd(cc).cmp, reverse=True )
    else:
      vl = sorted( cc.keys(), key=lambda x: cc[x], reverse=True )
    if self.adict.get( 'vars', False ):
      printLinesMax = self.adict.get( 'plm', 20 )
      if printLinesMax > 0:
        mx = min( [printLinesMax,len(vl)] )
      else:
        mx = len(vl)

      for v in vl[:mx]:
        mlg.prnt ( '%s.%s: %s' % (self.dq.inx.uid[v].mipTable,self.dq.inx.uid[v].label, misc_utils.vfmt( cc[v]*2. ) ) )
      if mx < len(vl):
        mlg.prnt ( '%s variables not listed (use --printLinesMax to print more)' % (len(vl)-mx) )

