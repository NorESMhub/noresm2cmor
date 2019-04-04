"""This module has a class which will analyse the usage of variables in the data request"""
import operator
import collections

class checkVar(object):
  """checkVar
--------
Class to analyse the usage of variables in the data request.
"""
  errorLog = collections.defaultdict( set )
  def __init__(self,dq,errorMode='aggregate'):
    self.errorMode = errorMode
    self.dq = dq
    self.mips = set( [i.label for i in  dq.coll['mip'].items] )
    for i in ['PDRMIP', 'DECK', 'VIACSAB', 'SolarMIP', 'CMIP6' ]:
      self.mips.discard(i)

  def chk2(self,vn,byExpt=False, byBoth=False):
    dq = self.dq
    ks = [i for i in dq.coll['var'].items if i.label == vn ]

    v = ks[0]
    cc = {}
    l = dq.inx.iref_by_sect[v.uid].a['CMORvar']
    for i in l:
      try:
        r = dq.inx.uid[i]
        kk = '%s.%s' % (r.mipTable, r.label )
        cc[i] = (kk,self.chkCmv( i, byExpt=byExpt, byBoth=byBoth ) )
      except:
        print ( 'failed at uid = %s' % i )
        raise

    return cc

  def chk(self,vn):
    ks = [i for i in dq.coll['var'].items if i.label == vn ]

    v = ks[0]
    l = dq.inx.iref_by_sect[v.uid].a['CMORvar']

## set of all request variables 
    s = set()
    for i in l:
      for j in dq.inx.iref_by_sect[i].a['requestVar']:
        s.add(j)

## filter out the ones which link to a remark
    s0 = set( [i for i in s if dq.inx.uid[dq.inx.uid[i].vgid]._h.label != 'remarks' ] )

## set of request groups

    s1  = set( [dq.inx.uid[i].vgid for i in s0 ] )

    #s2 = set()
#for i in s1:
  #for j in dq.inx.iref_by_sect[i].a['requestLink']:
    #s2.add(j)
    s2 = reduce( operator.or_, [set(dq.inx.iref_by_sect[i].a['requestLink']) for i in s1 if 'requestLink' in dq.inx.iref_by_sect[i].a] )

    mips = set( [dq.inx.uid[i].mip for i in s2 ] )
    self.missing = self.mips.difference( mips )
    self.inc = mips

#############
  def chkCmv(self,cmvid, byExpt=False, byBoth=False,expt=None):
    dq = self.dq
##
## find set of requestVar records referring to this CMORvar
##
    s = set( dq.inx.iref_by_sect[cmvid].a['requestVar'] )

## filter out the ones which link to a remark

# s0: set of requestVars

    s0 = set( [i for i in s if dq.inx.uid[dq.inx.uid[i].vgid]._h.label != 'remarks' ] )

## set of request groups
## dictionary, keyed on variable group uid, with values set to priority of variable
##

    cc1 = collections.defaultdict( set )
    for i in s0:
      cc1[ dq.inx.uid[i].vgid ].add( dq.inx.uid[i].priority )
    ##s1  = set( [dq.inx.uid[i].vgid for i in s0 ] )
    
##
## loop over requestGroups, find requestLink records, filtered by priority
##
    s2 = set()
    for i in cc1:
      if 'requestLink' in dq.inx.iref_by_sect[i].a:
        for l in dq.inx.iref_by_sect[i].a['requestLink']:
          lr = dq.inx.uid[l]
          if lr.opt == 'priority':
            p = int( float( lr.opar ) )
            if max( cc1[i] ) <= p:
              s2.add(l)
          else:
            s2.add( l )

    if len( s2 ) == 0:
      if byBoth:
        return (set(),set())
      else:
        return s2

##
## logic here omits a filter on experiment name .... and hence gives too many MIPs when aggregated over mIPSs
##
    if byBoth or not byExpt:
      mips0 = set( [dq.inx.uid[i].mip for i in s2] )
    if byExpt or byBoth:
      s3 = set()

      if expt != None and expt in self.sc.rqLinkByExpt:
        for i in s2:
          if i in self.sc.rqLinkByExpt[expt]:
            s3.add(i)
      else:
        s3 = s2
##  set of esid values
      ##esids = set()
      ##for i in s2:
        ##for u in dq.inx.iref_by_sect[i].a['requestItem']:
          ##if expt != None:
            ##esid = dq.inx.uid[u].esid
            ##if esid == expt or 'experiment' in dq.inx.iref_by_sect[expt].a and esid in dq.inx.iref_by_sect[expt].a['experiment']:
              ##esids.add( esid )
              ##s3.add( i )
              ##print 'TMP001: filteron:',expt
            ##else:
              ##print 'TMP001: filteroff:',expt
          ##else:
            ##esids.add( dq.inx.uid[u].esid )

      mips = set( [dq.inx.uid[i].mip for i in s3] )

###
### CHECK: not clear what this was for ..... 
###    appears to give meaningless output 
###
      doThisObsolete = False
      if doThisObsolete:
        mips = set()
        for e in esids:
          if e == '':
            ##print 'WARNING: empty esid encountered'
            pass
          else:
            r = dq.inx.uid[e]
            if r._h.label == 'mip':
              mips.add(e)
            else:
              if r._h.label == 'exptgroup':
                if 'experiment' in dq.inx.iref_by_sect[e].a:
                  r = dq.inx.uid[  dq.inx.iref_by_sect[e].a['experiment'][0] ]
                else:
                  ei = dq.inx.uid[e]
                  if self.errorMode != 'aggregate':
                    print ( 'ERROR.exptgroup.00001: empty experiment group: %s: %s' % (ei.label, ei.title) )
                  self.errorLog['ERROR.exptgroup.00001'].add( 'empty experiment group: %s: %s' % (ei.label, ei.title) )
              if r._h.label in [ 'remarks','exptgroup']:
                ##print 'WARNING: link to remarks encountered'
                pass
              else:
                assert r._h.label == 'experiment', 'LOGIC ERROR ... should have an experiment record here: %s' % r._h.label
                mips.add(r.mip)
      if byBoth:
        return (mips0,mips)
      else:
        return mips
    else:
      return mips0

if __name__ == '__main__':
  try:
    import dreq
  except:
    import dreqPy.dreq as dreq
  dq = dreq.loadDreq()
  c = checkVar(dq)
  c.chk( 'tas' )
  print ( '%s, %s' % (c.inc, c.missing))
