"""collect: extensions to create frequently used collections of objects."""

import collections

class GenIsUsed(object):
  def __init__(self,parent,callers=[]):
    self.c = callers
    self.pa = parent._inx.iref_by_sect[parent.uid].a
  def __call__(self):
    if len(self.c ) == 0:
       return True
    for c in self.c:
      if c in self.pa and len( self.pa[c] ) > 0:
        return True
    return False
    
def _count(self,sect=None):
  if sect != None:
    if sect in self.coll.keys():
      return len( self.coll[sect].items )
    else:
      print ("INVALID SECTION: %s" % ', '.join( sorted( self.coll.keys() ) ) )
  for k in sorted( self.coll.keys() ):
     print ("%16s:: %s" % (k,len( self.coll[k].items ) ) )

def _isLinked(self):
  """Return True if another record links to this record"""
  if len( self._inx.iref_by_sect[self.uid].a.keys() ) == 0:
    return False
  for k in self._inx.iref_by_sect[self.uid].a.keys():
    if len( self._inx.iref_by_sect[self.uid].a[k] ) > 0:
      return True
  return False

def _var__mips(self):
    """Return set of mip item identifiers for MIPs requesting this var"""
    mips = set()
    for i in self._inx.iref_by_sect[self.uid].a['CMORvar']:
      cmv = self._inx.uid[i]
      mips = mips.union( cmv._get__mips() )
    return mips

def _CMORvar__mips(self):
    """Return set of mip item identifiers for MIPs requesting this CMORvar"""
    mips = set()
    for i in self._inx.iref_by_sect[self.uid].a['requestVar']:
      rqv = self._inx.uid[i]
      mips = mips.union( rqv._get__mips() )
    return mips

def _rqv__mips(self):
    """Return set of mip item identifiers for MIPs requesting this requestVar"""
    mips = set()
    for i in self._inx.iref_by_sect[self.vgid].a['requestLink']:
      rql = self._inx.uid[i]
      mips.add(rql.mip)
    return mips

def _expt__CMORvar(self):
    """Return set of CMORvar item identifiers for CMORvars requested for this experiment"""
    cmv = set()
    for u in self._get__requestItem():
      ri = self._inx.uid[u]
      rl = self._inx.uid[ri.rlid]
      for i in rl._get__CMORvar():
        cmv.add(i)
    return cmv

def _expt__requestItem(self):
    """Return set of request item item identifiers for request items linked directly or indirectly to this experiment"""

    s = set()
    for u in [self.uid,self.mip,self.egid]:
      if 'requestItem' in self._inx.iref_by_sect[u].a:
        for x in self._inx.iref_by_sect[u].a['requestItem']:
          s.add(x)
    return s
    
def _requestItem__expt(self,tierMax=None,esid=None):
    """Return set of experiment item identifiers for experiments linked directly or indirectly to this requestItem:
          tierMax: maximum experiment tier: if set, only return experiments with tier <= tierMax;
          esid: set of esid values: if set, return experiments for specified set, rather than self.esid"""

    assert self._h.label == 'requestItem', 'collect._requestItem__expt attached to wrong object: %s [%s]' % (self._h.title,self._h.label)

    if esid != None:
      es = self._inx.uid[esid]
    else:
      es = self._inx.uid[self.esid]
    s = set()

###
### checking tierMax and treset. If tierMax is None, there is nothing to do.
### otherwise, return empty or full list (tierResetPass True) depending on relation between treset and tiermax.

    tierResetPass = False
    if esid == None and 'treset' in self.__dict__ and tierMax != None:
      if tierMax <= self.treset:
        return s
      else:
        tierResetPass = True

    if es._h.label == 'experiment':
      if tierMax == None or tierResetPass or es.tier[0] <= tierMax:
        s.add(es.uid)
    elif es._h.label in ['exptgroup','mip']:
      if 'experiment' in self._inx.iref_by_sect[es.uid].a:
        for id in self._inx.iref_by_sect[es.uid].a['experiment']:
          s.add(id)
      if not( tierMax == None or tierResetPass ):
        s = set( [x for x in s if self._inx.uid[x].tier[0] <= tierMax] )
    return s

def _requestLink__expt(self,tierMax=None, rql=None):
    """Return set of experiment item identifiers for experiments linked to this requestLink:
          tierMax: maximum experiment tier: if set, only return experiments with tier <= tierMax;
          rql: set of requestLink uid values: if set, return experiments for specified set."""
    assert self._h.label == 'requestLink', 'collect._requestLink__expt attached to wrong object: %s [%s]' % (self._h.title,self._h.label)
    s = set()
    if rql == None:
      rql = [self.uid,]
    
## generate set of "esid" values (pointing to experiments, experiment groups, or MIPs)
    sesid = collections.defaultdict( set )
    rqil = []
    for u in rql:
      if 'requestItem' in self._inx.iref_by_sect[u].a:
        for id in self._inx.iref_by_sect[u].a['requestItem']:
          rqil.append( id )
          rqi = self._inx.uid[id]
##
## if a "treset" value is encountered and the reset value passes the filter, indicate with a value "1", and this will prevent later
## filtering on experiment tier;
## 
          if tierMax == None or 'treset' not in rqi.__dict__ or rqi.treset < 0:
            sesid[self._inx.uid[id].esid ].add( 0 )
          elif rqi.treset <= tierMax:
            sesid[self._inx.uid[id].esid ].add( 1 )

    if len( rqil ) > 0:
      rqi = self._inx.uid[rqil[0]]

## flatten to list of experiments.
      for u in sesid:
        if 1 in sesid[u]:
          thisTierMax = None
        else:
          thisTierMax = tierMax

        for x in rqi._get__expt(tierMax=thisTierMax,esid=u):
           s.add( x )
    return s

def _mip__expt(self,tierMax=None,mips=None):
    """Return set of experiment item identifiers for experiments linked to this mip:
          tierMax: maximum experiment tier: if set, only return experiments with tier <= tierMax;
          mips: set of mip uid values: if set, return experiments for specified set."""

    assert self._h.label == 'mip', 'collect._mip__expt attached to wrong object: %s [%s]' % (self._h.title,self._h.label)
    s = set()
    if mips == None:
      mips = [self.uid,]
    
    for u in mips:
      if 'requestLink' in self._inx.iref_by_sect[u].a:
        for id in self._inx.iref_by_sect[self.uid].a['requestLink']:
          rl = self._inx.uid[id]
          xx = rl._get__expt()
          for x in xx:
            s.add( x )
    return s

def _mip__CMORvar(self,mips=None,pmax=None):
    """Return set of CMORvar item identifiers for CMORvar requested by this mip:
          pmax: maximum variable priority: if set, only return variables requested with priority <= pmax;
          mips: set of mip uid values: if set, return variables for specified set."""
    assert self._h.label == 'mip', 'collect._mip__CMORvar attached to wrong object: %s [%s]' % (self._h.title,self._h.label)
    s = set()
    if mips == None:
      mips = [self.uid,]
    
    for u in mips:
      if 'requestLink' in self._inx.iref_by_sect[u].a:
        for id in self._inx.iref_by_sect[self.uid].a['requestLink']:
          for x in self._inx.uid[id]._get__CMORvar(pmax=pmax):
            s.add( x )
    return s

def _requestLink__CMORvar(self,rql=None,pmax=None):
    """Return set of CMORvar item identifiers for CMORvar linked to this requestLink, or to set of requestlinks in argument rql:
          pmax: maximum variable priority: if set, only return variables requested with priority <= pmax;
          rql: set of requestLink uid values: if set, return variables for specified set."""

    assert self._h.label == 'requestLink', 'collect._requestLink__CMORvar attached to wrong object: %s [%s]' % (self._h.title,self._h.label)
    s = set()

    if rql == None:
      rql = [self.uid,]
    
## get set of requestVarGroups
    rvg = set( [self._inx.uid[u].refid for u in rql] )

    for u in rvg:
      if 'requestVar' in self._inx.iref_by_sect[u].a:
        for id in self._inx.iref_by_sect[u].a['requestVar']:
          this = self._inx.uid[id]
          if pmax == None or this.priority <= pmax:
            s.add( this.vid )
    return s


def _check__args(x,validItems=['dreqItem_mip',]):
  if type(x) == type('x'):
    return (1,'str')
  elif type(x) == type(u'x'):
    return (1,'unicode')
  elif type(x) not in [type([]), type((1,))]:
    if x.__class__.__name__ in validItems:
      return (2,x.__class__.__name__)
    else:
      return (-2,'Object type not accepted' )
  else:
    if all( [type(i) == type('x') for i in x] ):
      return (10,'str')
    elif all( [type(i) == type(u'x') for i in x] ):
      return (10,'unicode')
    else:
      s = set( [i.__class__.__name__ for i in x] )
      if len(s) > 1:
        return (-1,'Multiple object types in list' )
      else:
        this = list(s)[0]
        if this in validItems:
          return (20,this)
        else:
          return (-3,'Listed object type not accepted' )
 


### need dq here ...... or at least timeslice collection object ...
def _timeSlice__compare(self,other):
    """Compare two time slices, returning tuple (<return code>, <slice>, <comment>), with the larger slice if succesful.
      If return code is negative, no solution is found. If return code is 2, the slices are disjoint and both returned."""
 
    assert self._h.label == 'timeSlice', 'collect._timeSlice__compare attached to wrong object: %s [%s]' % (self._h.title,self._h.label)
    if self.label == other.label:
      return (0,self,'Slices equal')

    sl = sorted( [self.label, other.label] )

## label dict allows look-up of objects by label ....
    ee = self._labelDict

    map = {('RFMIP','RFMIP2'):('RFMIPunion', 'Taking union of slices'),
            ('RFMIP', 'hist55'):('hist55plus', 'Taking ad-hoc union with extra ...'),
            ('RFMIP2', 'hist55'):('hist55plus', 'Taking ad-hoc union with extra ...'),
            ('DAMIP20','DAMIP40'):('DAMIP40', 'Taking larger containing slice') }
##
## handle awkward cases
##
    if self.type != other.type or self.type == 'dayList':
      if tuple( sl ) in map:
        targ, msg = map[tuple(sl)]
        return (1,ee[targ],msg)
      else:
        return (-1,None,'Multiple slice types: %s' % sorted(ee.keys()))
###
#     if sl in [['piControl030a','piControl200'],['piControl030', 'piControl200']]:
#       return (1,ee['piControl200'],'Taking preferred slice (possible alignment issues)')
###
#     elif sl == ['piControl030', 'piControl030a']:
#       return (1,ee['piControl30'],'Taking preferred slice (possible alignment issues)')
###
#     elif sl == ['RFMIP','RFMIP2']:
##
#       return (1,ee['RFMIPunion', 'Taking union of slices')
##
#     elif sl == ['RFMIP', 'hist55']:
###
#       return (1,ee['hist55plus'], 'Taking ad-hoc union with extra ...')
##
#     elif sl == ['RFMIP2', 'hist55']:
#       return (1,ee['hist55'], 'Taking larger containing slice')
##
#     elif sl == ['DAMIP20','DAMIP40']:
#       return (1,ee['DAMIP40'], 'Taking larger containing slice')
##

    if not ( self.type in ['simpleRange','relativeRange'] or (len(self.type) > 13 and self.type[:13] == 'branchedYears') ):
      return (-2,None,'slice type aggregation not supported')

    sa,ea = (self.start, self.end)
    sb,eb = (other.start, other.end )
    if sa <= sb and ea >= eb:
        return (1,self, 'Taking largest slice')
    if sb <= sa and eb >= ea:
        return (1,other, 'Taking largest slice')
    if ea < sb or eb < sa:
        return (2,(self,other), 'Slices are disjoint')
    return (-3,None, 'Overlapping slices')


def _append_to_item_list(self,idict):
   self._sectionList.append( self.__class__( idict=idict, id='auto' ) )

def  add(dq):
   """Add extensions to data request section classes."""
   dq.coll['mip'].items[0].__class__._get__expt = _mip__expt
   dq.coll['experiment'].items[0].__class__._get__requestItem = _expt__requestItem
   dq.coll['experiment'].items[0].__class__._get__CMORvar = _expt__CMORvar
   dq.coll['requestItem'].items[0].__class__._get__expt = _requestItem__expt
   dq.coll['requestLink'].items[0].__class__._get__expt = _requestLink__expt
   dq.coll['requestLink'].items[0].__class__._get__CMORvar = _requestLink__CMORvar
   dq.coll['var'].items[0].__class__._get__mips = _var__mips
   dq.coll['CMORvar'].items[0].__class__._get__mips = _CMORvar__mips
   dq.coll['requestVar'].items[0].__class__._get__mips = _rqv__mips
   dq.coll['mip'].items[0].__class__._get__CMORvar = _mip__CMORvar
   dq.coll['timeSlice'].items[0].__class__.__compare__ = _timeSlice__compare

   dq.__class__._count = _count

   for k in dq.coll.keys():
     if len( dq.coll[k].items ) > 0:
       dq.coll[k].items[0].__class__._sectionList = dq.coll[k].items
       dq.coll[k].items[0].__class__._sectionObj = dq.coll[k]
       dq.coll[k].items[0].__class__._append = _append_to_item_list
       dq.coll[k].items[0].__class__._isLinked = _isLinked

   for i in dq.coll['cellMethods'].items:
     i._isUsed = GenIsUsed(i,['structure',])

   for k in ['var','experiment','timeSlice','mip','spatialShape','structure','grids','__sect__']:
     dq.coll[k].items[0].__class__._labelDict = dict()
     for i in dq.coll[k].items:
       dq.coll[k].items[0].__class__._labelDict[i.label] = i
   for k in dq.coll:
     if len( dq.coll[k].items ) > 0:
       dq.coll[k].items[0].__class__._uidDict = dict()
       for i in dq.coll[k].items:
         dq.coll[k].items[0].__class__._uidDict[i.uid] = i
   dq._extensions_['collect'] = True

    
    
