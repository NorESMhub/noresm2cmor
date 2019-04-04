import collections
try:
  import table_utils
except:
  import dreqPy.table_utils as table_utils

##NT_txtopts = collections.namedtuple( 'txtopts', ['mode'] )

mips = ['ScenarioMIP', 'VIACSAB', 'AerChemMIP', 'CDRMIP', 'C4MIP', 'CFMIP', 'DAMIP', 'DCPP', 'FAFMIP', 'GeoMIP', 'GMMIP', 'HighResMIP', 'ISMIP6', 'LS3MIP', 'LUMIP', 'OMIP', 'PAMIP', 'PMIP', 'RFMIP', 'VolMIP', 'CORDEX', 'DynVarMIP',  'SIMIP' ]

class c1(object):
  def __init__(self):
    self.a = collections.defaultdict( int )

class xlsTabs(object):
  """used in scope.py; uses table_utils.py"""
  def __init__(self,sc,tiermax=1,pmax=1,xls=True, txt=False, txtOpts=None, odir='xls'):
    self.pmax=pmax
    self.tiermax=tiermax
    self.sc = sc
    sc.setTierMax( tiermax )
    self.cc = collections.defaultdict( c1 )
    self.dq = sc.dq
    self.doXls = xls
    self.doTxt = txt

    self.mips = mips
    self.mipsp = ['DECK','CMIP6',] + self.mips[:-4]

    self.tabs = table_utils.tables( sc, xls=xls, txt=txt, txtOpts=txtOpts, odir=odir )

  def run(self,m,colCallback=None,verb=False,mlab=None,exid=None):
      if m == 'TOTAL':
        l1 = self.sc.rqiByMip( set( self.mips ) )
      else:
        l1 = self.sc.rqiByMip( m )

      if mlab == None:
        mlab = m

      verb = False
      if verb:
        print ( 'r1: m=%s, len(l1)=%s' % (mlab,len(l1)) )

      self.cc[mlab].dd = {}
      self.cc[mlab].ee = {}
      self.tabs.accReset()
      vcc = collections.defaultdict( int )
      for m2 in self.mipsp + ['TOTAL',]:
        if m2 == 'TOTAL':
          xx = self.dq.coll['experiment'].items
        else:
          xx = [i for i in self.dq.coll['experiment'].items if i.mip == m2]
        if exid != None:
          xxx = [i for i in xx if i.uid == exid]
          if len(xxx) == 0:
            break
          xx = xxx
        self.cc[mlab].ee[m2] = xx
        xxi = set( [i.label for i in xx] )
##
## need to check this option, and add a template for a view summarising the experiments for each mip-mip combinations
##
        if m2 != 'TOTAL':
          for i in xx:
            self.tabs.doTable(m,l1,i.uid,self.pmax,self.cc,acc=False,cc=vcc,exptids=xxi,mlab=None)

        self.tabs.doTable(m,l1,m2,self.pmax,self.cc,cc=vcc,exptids=xxi,mlab=None)

        if verb:
          print ( 'r1: mlab=%s,m2=%s, len(l1)=%s, len(xxi)=%s' % (mlab,m2,len(l1),len(xxi)) )

        if colCallback != None:
          colCallback( m,m2,mlab=mlab )


