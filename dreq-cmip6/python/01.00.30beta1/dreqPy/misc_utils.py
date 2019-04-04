import collections, os, sys
import logging
import time
import difflib 

python2 = True
if sys.version_info[0] == 3:
  python2 = False

def vfmt( x ):
            if x < 1.e9:
              s = '%sM' % int( x*1.e-6 )
            elif x < 1.e12:
              s = '%sG' % int( x*1.e-9 )
            elif x < 1.e13:
              s = '%3.1fT' % ( x*1.e-12 )
            elif x < 1.e15:
              s = '%3iT' % int( x*1.e-12 )
            elif x < 1.e18:
              s = '%3iP' % int( x*1.e-15 )
            else:
              s = '{:,.2f}'.format( x*1.e-9 )
            return s


class mdiff(object):
  """Compare a string against a list, using the difflib library, with an extension to look at case insensitive matches.
     Lower case matches are weighted by 90% .. i.e. an exact match scores 1, an exact match after conversion to lower case score 0.90"""

  def __init__(self,nmax=3,cut=0.3):
    self.n = nmax
    self.c = cut

  def diff(self,s,targ):
    if s in targ:
      return (True, None)
    targl = collections.defaultdict( set )
    for x in targ:
      targl[ x.lower() ].add( x )

    l1 = difflib.get_close_matches(s,targ,self.n,self.c)
    l1s = difflib.get_close_matches(s.lower(),targl,self.n,self.c)
    if len( l1 ) == 0 and len(l1s) == 0:
      return (False, 0)
    cc = collections.defaultdict( set )
    for k in l1:
      r = difflib.SequenceMatcher(None, s, k ).ratio()
      cc[r].add( k )

    for k in l1s:
      r = difflib.SequenceMatcher(None, s.lower(), k ).ratio()
      r1 = 0.90*r
      for x in targl[k]:
        cc[r1].add( x )
    ks = sorted( cc.keys() )
    ks.reverse()
    ll = []
    for k in  ks:
      ll.append( (k,tuple( cc[k] )) )
    return (False, len(ll), ll )

  def prntprep(self,i,tt):
          oo = []
          if tt[1] == 0:
            oo.append ( 'NOT FOUND: %s' % i )
          else:
            msg = []
            for ix in tt[2]:
              msg.append( '%s [%4.1f]' % (','.join( ix[1] ),ix[0]) )

            oo.append( '----------------------------------------' )
            if tt[1] == 1 and len(tt[2][0][1]) == 1:
              oo.append ( 'NOT FOUND: %s:  SUGGESTION: %s' % (i,msg[0]) )
            else:
              oo.append ( 'NOT FOUND: %s:  SUGGESTIONS: %s' % (i,'; '.join( msg ) ) )
            oo.append( '----------------------------------------' )
          return oo
          
def setMlab( m ):
      if type(m) == type(''):
        if m == '_all_':
          mlab = 'TOTAL'
        else:
          mlab = m
      else:
        ll = sorted( [x.lower() for x in list(m)] )
        if len(ll) == 1:
          mlab = list(m)[0]
        else:
          mlab='.'.join( [ x[:2].lower() for x in ll ] )
      return mlab

class dreqLog(object):
  def __init__(self, dir='.'):
    self.tstring2 = '%4.4i%2.2i%2.2i' % time.gmtime()[0:3]
    self.logdir = dir
    if not os.path.isdir( dir ):
      os.mkdir(dir )
      print ( 'dreqLog: making a new directory fr log files: %s' % dir )

  def getLog(self,name,dir=None):
    if dir == None:
      dir = self.logdir
    testLogFile = '%s/dreq_%s_%s.txt' % (dir,name,self.tstring2)
    log = logging.getLogger(testLogFile)
    fHdlr = logging.FileHandler(testLogFile,mode='w')
    fileFormatter = logging.Formatter('%(message)s')
    fHdlr.setFormatter(fileFormatter)
    log.addHandler(fHdlr)
    log.setLevel(logging.INFO)
    return log

def rankCMORvars(dq):
  """Unused in 01.beta.32"""
  cc = collections.defaultdict( set )
  ee = {}
  kd = 0
  ff = {}
  for ic in dq.coll['CMORvar'].items:
    s = set()
    r = set()
    i = dq.inx.uid[ ic.vid ]
    if i._h.label != 'remarks':
      kk = '%s.%s' % (ic.mipTable, ic.label)
      if i.title != ic.title:
        print ( '%s: %s, %s' % (kk, ic.title, i.title) )
        kd += 1
      if ic.modeling_realm.find( ' ' ) != -1:
         for x in ic.modeling_realm.split( ):
            r.add( x.strip( ) )
      elif ic.modeling_realm not in ['__unset__','']:
          r.add( ic.modeling_realm )
      if 'requestVar' in dq.inx.iref_by_sect[ic.uid].a:
          for x in dq.inx.iref_by_sect[ic.uid].a['requestVar']:
            s.add(x)

    if len(s) > 0:
      ee[kk] = r
      ff[kk] = i
      ss = sorted( [dq.inx.uid[x].priority for x in s] )
      if len(ss) > 1:
        kk = '%s-%s' % (ss[0],ss[1])
        sn = dq.inx.uid[i.sn]
        if sn._h.label == 'remarks':
          kk += 'x'
        cc[kk].add( i.label )
    else:
      print ( '%s not used' % i.label )
  print ( kd )
  return (cc,ee,ff)

def rankVars(dq):
  """Find the maximal priorities at which variables are requested ... to prioritise checking .. called by sm1"""
  cc = collections.defaultdict( set )
  ee = {}
  ff = {}
  for i in dq.coll['var'].items:
    s = set()
    r = set()
    if 'CMORvar' in  dq.inx.iref_by_sect[i.uid].a:
      for cmv in dq.inx.iref_by_sect[i.uid].a['CMORvar']:
        ic = dq.inx.uid[cmv]
        if ic.modeling_realm.find( ' ' ) != -1:
          for x in ic.modeling_realm.split( ):
            r.add( x.strip( ) )
        elif ic.modeling_realm not in ['__unset__','']:
          r.add( ic.modeling_realm )
        if 'requestVar' in dq.inx.iref_by_sect[cmv].a:
          for x in dq.inx.iref_by_sect[cmv].a['requestVar']:
            s.add(x)

    if len(s) > 0:
      ee[i.label] = r
      ff[i.label] = i
      ss = sorted( [dq.inx.uid[x].priority for x in s] )
      if len(ss) > 0:
        kk = '%s' % (ss[0])
        sn = dq.inx.uid[i.sn]
        if sn._h.label == 'remarks':
          kk += 'x'
        cc[kk].add( i.label )
    else:
      print ( '%s not used' % i.label )
  return (cc,ee,ff)

def getExptSum(dq,mip,rqi):
  """Return a dictionary of experiment uids keyed on MIPs, from list of request items (used in makeTables)"""
  cc = collections.defaultdict( set )
  for i in rqi:
    es = dq.inx.uid[i.esid]
    if es._h.label == 'experiment':
      cc[es.mip].add(es.uid)
    elif es._h.label in ['exptgroup','mip']:
      if 'experiment' in dq.inx.iref_by_sect[i.esid].a:
        for id in dq.inx.iref_by_sect[i.esid].a['experiment']:
          ex = dq.inx.uid[id]
          cc[ex.mip].add(id)

  return cc

class rqiSet(object):
  """Unused in 01.beta.32"""
  npy = {'1hrClimMon':24*12, 'daily':365, u'Annual':1, u'fx':0.01, u'1hr':24*365, u'3hr':8*365,
       u'monClim':12, u'Timestep':100, u'6hr':4*365, u'day':365, u'1day':365, u'mon':12, u'yr':1,
       u'1mon':12, 'month':12, 'year':1, 'monthly':12, 'hr':24*365, 'other':24*365,
        'subhr':24*365, 'Day':365, '6h':4*365, '3 hourly':8*365, '':1, 'dec':0.1, 
        '1hrCM':24*12, '1hrPt':24*365, '3hrPt':8*365, '6hrPt':4*365, 'monPt':12, 'monC':12, 'subhrPt':24*365, 'yrPt':1 }
  def __init__(self,dq,rqi=None,byMip=None):
    self.dq = dq
    if rqi != None:
      assert byMip == None, 'ERROR.rqiSet.001: Cannot have rqi and byMip both assigned'
      self.rqi = rqi
    elif byMip != None:
      self.rqi = [i for i in dq.coll['requestItem'].items if i.mip == byMip]
    else:
      self.rqi = dq.coll['requestItem'].items

    self.verbose = False
    if self.verbose:
      print ( 'INFO.rqiSet.00001: initialised, len(rqi) = %s' % len(self.rqi) )

  def run(self,vsz,rqi=None,pmax=1,tiermax=1,plist=False):
    self.exptVarSum(pmax=pmax,plist=plist,tiermax=tiermax)
    self.exptVarVol(vsz,plist=plist,tiermax=tiermax)

  def getVarList(self,rqi,pmax=1):
    cc = collections.defaultdict( list )
    for i in rqi:
      rl = self.dq.inx.uid[i.rlid]
      if 'requestVar' in self.dq.inx.iref_by_sect[rl.refid].a:
        for id in self.dq.inx.iref_by_sect[rl.refid].a['requestVar']:
          rq = self.dq.inx.uid[id]
          if rq.priority <= pmax:
            cc[rq.vid].append( (i.ny, i.nymax, i.nenmax,rl.grid,i.uid) )
    ee = {}
    for vid in cc.keys():
      if len( cc[vid] ) == 1:
        ee[vid] = cc[vid][0]
      else:
        ll = [x[0] for x in cc[vid] if x[0] > 0]
        if len(ll) == 0:
          ny = -1
        else:
          ny = max(ll)
        ll = [x[1] for x in cc[vid] if x[1] > 0]
        if len(ll) == 0:
          nymax = -1
        else:
          nymax = max(ll)
        ll = [x[2] for x in cc[vid] if x[2] > 0]
        if len(ll) == 0:
          nenmax = -1
        else:
          nenmax = max(ll)
        ss = set( [x[3] for x in cc[vid]] )
        rqil =  [x[4] for x in cc[vid] ] 
        ee[vid] = (ny,nymax,nenmax,list(ss),rqil )

    return ee

  def exptVarSum(self,exptsOk=False,pmax=1,plist=True,tiermax=1):
    if not exptsOk:
      self.exptByMip(tiermax=tiermax)

    self.exvars = {}
    for m in sorted( self.expts.keys() ):
      for i in self.expts[m]:
        rqi = [self.dq.inx.uid[x] for x in self.exrqi[i] ]

## obtain dictionary, keyed om CMORvar uid, of variables requested
        ee = self.getVarList( rqi, pmax=pmax )
        ex = self.dq.inx.uid[i]
        if plist:
          print ( 'exptVarSum: %s, %s, %s (%s)' % (m,ex.label,len( ee.keys() ), len( rqi)) )
        self.exvars[i] = ee

  def exptVarVol(self,vsz,plist=True,tiermax=1):
    nttt = 0
##
## exvarvol is a dictionary of dictionaries. key 1: experiment uid.
##                                           key 2: cmor variable uid
##                               content: 5-tuple: ntot: floats requested
##                                                    s: floats per time instant
##                                                  npy: number of outputs per year
##                                                   ny: number of years of output
##                                                  nen: number of ensembles 
####################################################################################
    self.exvarvol = {}
    for m in sorted( self.expts.keys() ):
      for i in self.expts[m]:
        ee = self.exvars[i]
        ex = self.dq.inx.uid[i]
##
## experiment has list of ensemble size (ensz) against tier (tier)
## max ensz st. tier <= tiermax
##
        l = [x for x in ex.tier if x <= tiermax]
        exensz = ex.ensz[len(l)-1]

        cmvd = {}
        nn = 0
        nerr = 0
        for k in ee:
          cmv = self.dq.inx.uid[k]
          if cmv._h.label == 'CMORvar':
            s = vsz[cmv.stid]
            npy = self.npy[cmv.frequency]
            nyi = ee[k][0]
            if ex.yps < 0:
              ny = nyi
            else:
              ny = min( [ex.yps,nyi] )
            ne = ee[k][2]
            if ne < 0:
              nen = exensz
            else:
              nen = min( [ne,exensz] )
            ntot = s*npy*ny*nen
##
## need to do more on various options here 
##
            cmvd[k] = (ntot,s,npy,ny,nen)
            nn += ntot
          else:
            nerr += 1
        if plist:
          print ( 'exptVarVol: %s, %s, %s[%s]: %9.4fTb' % (m,ex.label,len( ee.keys() ), nerr, nn*2.*1.e-12) )
        nttt += nn
        self.exvarvol[i] = cmvd

    if plist:
      print ( 'TOTAL: %9.3fTb' % (nttt*2*1.e-12) )
        
  def exptByMip(self,tiermax=1):
    cc = collections.defaultdict( list )
    for i in self.rqi:
      cc[i.mip].append( i )

    ks = sorted( list( cc.keys() ) )
    for k in ks:
      self.getExptByThisMip(k,cc[k],tiermax=tiermax)

  def getExptByThisMip(self,mip,rqi,tiermax=1):
    self.expts = collections.defaultdict( set )
    self.exrqi = collections.defaultdict( set )
    for i in rqi:
      es = self.dq.inx.uid[i.esid]

## check to see if "treset" override is present and below tiermax
      tover = False
      if 'treset' in i.__dict__ and i.treset != '__unset__':
        tover = i.treset <= tiermax
        
      if es._h.label == 'experiment':
        if es.tier[0] <= tiermax or tover:
          self.expts[es.mip].add(es.uid)
          self.exrqi[es.uid].add( i.uid )
      elif es._h.label in ['exptgroup','mip']:
        if 'experiment' in self.dq.inx.iref_by_sect[i.esid].a:
          for id in self.dq.inx.iref_by_sect[i.esid].a['experiment']:
            ex = self.dq.inx.uid[id]
            if ex.tier[0] <= tiermax or tover:
              self.expts[ex.mip].add(id)
              self.exrqi[id].add( i.uid )
    ks = sorted( list( self.expts.keys() ) )
    xx = ', '.join( ['%s: %s' % (k,len(self.expts[k])) for k in ks] )
    print ( '%s:: %s' % (mip,xx) )

class c1(object):
  def __init__(self):
    self.a = collections.defaultdict( int )
