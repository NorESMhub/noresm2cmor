import collections, os
import xlsxwriter

try:
  import dreq
  import scope_utils
  import table_utils
except:
  import dreqPy.dreq as dreq
  import dreqPy.scope_utils as scope_utils
  import dreqPy.table_utils as table_utils

jsh='''
<link type="text/css" href="/css/dreq.css" rel="Stylesheet" />
%s
''' % dreq.dreqMonitoring

##
## "T" and "G" used for "TB" and "GB" in order to squeeze table onto one page
##
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
              s = '{:,.2f}B'.format( x*1.e-9 ) 
            return s

class c1(object):
  def __init__(self):
    self.a = collections.defaultdict( int )

class c2(object):
  def __init__(self):
    self.a = collections.defaultdict( list )

hmap0 = {'CMIP6':'Historical', 'ScenarioMIP':'\cellcolor{llgray} ScenarioMIP'}
class r1(object):
  infoLog = collections.defaultdict( list )
  def __init__(self,sc,mt_tables,tiermax=1,pmax=1,only=False,vols=None,fnm='new',msgLevel=0):
    self.mt_tables = mt_tables
    self.msgLevel = msgLevel

    self.fnm = fnm
    assert vols == None or type(vols) == type( () ), 'vols argument must be none or tuple of length 2: %s' % type(vols)
    self.dq = sc.dq
    self.mips = ['CMIP'] + scope_utils.mips
    self.mipsp = self.mips[:-3]
    self.mipsp.remove( 'VIACSAB' ) 
    self.sc = sc
    self.pmax=pmax
    self.efnsfx = ''
    if sc.gridPolicyDefaultNative:
        self.efnsfx = '_dn'
    self.cc = collections.defaultdict( c1 )
    self.ee = {}
    for m2 in self.mipsp + ['TOTAL',]:
        xx = [i for i in self.dq.coll['experiment'].items if i.mip == m2]
        self.ee[m2] = xx

    if vols != None:
      assert len(vols) == 4, 'vols must be a tuple of length 4 (containing dictionaries ...): %s' % len(vols)
      self.tiermax = sc.tierMax
      vmm, vme, vmmt, vue = vols
      for m in vmm:
        for m2 in vmm[m]:
          self.cc[m].a[m2] = vmm[m][m2]
          if m2 != 'Unique':
            self.cc[m].a['TOTAL'] += vmm[m][m2]

      for m in vme:
        for e in vme[m]:
          i = sc.dq.inx.uid[e]
          if i._h.label == 'experiment':
            self.cc[m].a[i.label] = vme[m][e]

      for m in vue:
        for e in vue[m]:
          i = sc.dq.inx.uid[e]
          if i._h.label == 'experiment':
            self.cc['_%s' % m].a[i.label] = vue[m][e]

      for m in vmmt:
        for m2,t in vmmt[m]: 
           self.cc['_%s_%s' % (m,m2)].a[t] = vmmt[m][(m2,t)]
           if m2 != 'Unique':
             self.cc['_%s_%s' % (m,'TOTAL')].a[t] += vmmt[m][(m2,t)]
           self.makeMMhtml(m,m2)
        self.makeMMhtml(m,'TOTAL')

      self.writeMips(True)
      return
    self.mode = 'def'

    self.tiermax=tiermax
    sc.setTierMax( tiermax )
    tabs = self.mt_tables( sc )

    mipsToDo = self.mips + ['TOTAL',]
    assert 'SolarMIP' not in mipsToDo, 'SolarMIP error: %s ' % str(mipsToDo)
    assert 'SolarMIP' not in self.mipsp, 'SolarMIP error: %s ' % str(self.mipsp)
    if only != False:
      mipsToDo = [only,]
    for m in mipsToDo:
      if m == 'TOTAL':
        l1 = sc.rqiByMip( set( self.mips ) )
      else:
        l1 = sc.rqiByMip( m )

      self.cc[m].dd = {}
      tabs.accReset()
##
## need to check this option, and add a template for a view summarising the experiments for each mip-mip combinations
##
## sss=True not yet tested
##
      for m2 in self.mipsp + ['TOTAL',]:
        sss = True
        if sss:
          for i in xx:
            tabs.doTable(m,l1,i.uid,pmax,self.cc,acc=False)
          tabs.doTable(m,l1,m2,pmax,self.cc)
          if only == False:
            self.makeMMhtml(m,m2)
        else:
          tabs.doTable(m,l1,m2,pmax,self.cc)

    if only == False:
      self.writeMips(sss)

  def makeMMhtml(self,m,m2):
    """Make a html page for data requested by MIP 'm' from MIP 'm2' experiments"""
    if self.fnm == 'new':
      fss = 'expt_%s_%s_%s_%s%s.html' % (m,m2,self.tiermax, self.pmax,self.efnsfx)
    else:
      fss = '%s-%s_%s_%s.html' % (m,m2,self.tiermax, self.pmax)
    kc = '_%s_%s' % (m,m2)
    self.infoLog[ 'INFO.mmhtml.00001' ].append( ' %s, %s' % (kc,len( self.cc[kc].a.keys() ) ) )
    ##print ('INFO.mmhtml.00001: %s, %s' % (kc,len( self.cc[kc].a.keys() ) ) )
    if len( self.cc[kc].a.keys() ) == 0:
      return
    if not os.path.isdir( 'html/tabs03' ):
      print ( 'WARNING.makeMMhtml: creating directory for html files: tabs03' )
      os.mkdir( 'html/tabs03' )
    oo = open( 'html/tabs03/%s' % fss, 'w' )
    ttl = 'Data requested by %s from %s experiments (tier %s, priority %s)' % (m,m2,self.tiermax,self.pmax)
    jsh = ''
    pream = '<h1>%s</h1>\n' % ttl
    if self.efnsfx == '_dn':
      pream += '<p>Using the native ocean grid when no explicit preference is specified in the request.</p>\n'
    if self.fnm == 'new':
      pream += '<p>All variables in one <a href="../data/tabs02/cmvmm_%s_%s_%s_%s%s.xlsx">Excel file</a></p>\n' % (m,m2,self.tiermax, self.pmax,self.efnsfx)
    else:
      pream += '<p>All variables in one <a href="../data/tabs02/%s-%s_%s_%s.xlsx">Excel file</a></p>\n' % (m,m2,self.tiermax, self.pmax)
    pream += '<ul>'
    kc = '_%s_%s' % (m,m2)
    for k in sorted( self.cc[kc].a.keys() ):
      pream += '<li>%s: %s</li>\n' % (k,vfmt(self.cc[kc].a[k]*2.) )
    pream += '</ul>'

    bdy = pream + '<table>\n'
    bdy += '<tr><th>Experiment</th><th>Volume (and link to variable lists)</th></tr>\n'
    thisee = self.cc[m].a
    pref = 'cmvme'
    if  m2 in ['TOTAL']:
      labs = sorted( [x for x in self.cc[m].a.keys() if x in self.sc.exptByLabel] )
    elif m2 in ['Unique']:
      labs = sorted( [x for x in self.cc['_%s' % m ].a.keys() if x in self.sc.exptByLabel] )
      thisee = self.cc['_%s' % m].a
      pref = 'cmvume'
    else:
      try:
        assert m2 in self.ee, 'Argument m2:%s not in self.ee' % m2
        assert m in self.cc, 'Argument m:%s not in self.cc' % m
        labs = sorted( [i.label for i in self.ee[m2] if (i.label in self.cc[m].a and i._h.label == 'experiment')] )
      except:
        print ( 'SEVERE: failed to create labs array' )
        labs = []

    for ilab in labs:
        x = thisee[ilab]*2.
        if x > 0:
          s = vfmt( x )
          if self.fnm == 'new':
            bdy += '<tr><td>%s</td><td><a href="../data/tabs02/%s_%s_%s_%s_%s%s.xlsx">%s</a></td></tr>\n' % (ilab,pref,m,ilab,self.tiermax, self.pmax,self.efnsfx,s)
          else:
            bdy += '<tr><td>%s</td><td><a href="../data/tabs02/%s-%s_%s_%s.xlsx">%s</a></td></tr>\n' % (ilab,m,ilab,self.tiermax, self.pmax,s)

    bdy += '</table>\n'

    oo.write( self.dq.pageTmpl % (ttl, jsh, '../', '../index.html', bdy ) )
    oo.close()
    
  def writeMips(self,sss=False):

    oo = open( 'tab01_%s_%s.texfrag' % (self.tiermax,self.pmax), 'w' )
    mmh = []
    mhdr = [ '\\rot{80}{%s}' % hmap0.get(m,m) for m in self.mipsp + ['TOTAL','Unique']]
    mhdrh = [ '<th><div><span>%s</span></div></th>' % hmap0.get(m,m) for m in self.mipsp + ['TOTAL','Unique','CALC']]
    oo.write( ' & '.join(['',] + mhdr ) + '\\\\ \n\\hline\n' )
    mmh.append( '<table>\n<tr class="rotate">' + ''.join(['<th></th>',] + mhdrh ) + '</tr>\n' )
    htmltmpl_head = '<html><body>\n' 

##
## the "oo1" tables need a little more work to be useful
## not supported by the "vols" entry option of this class
##
    doOo1 = False
    rows = self.mips + ['TOTAL',]
    rows.remove( 'ScenarioMIP' )

    for m in rows:
      if m  == 'TOTAL':
        ll = ['UNION',]
        llh = ['UNION',]
      else:
        ll = [m,]
        llh = [m,]
      ttl = 0.
      cct = collections.defaultdict( int )
      xt = 0.
      for m2 in self.mipsp + ['TOTAL','Unique']:
       if doOo1:
         if m2 in self.cc[m].dd:
           oo1 = open( 'html/tt/rq-%s-expt-%s.html' % (m,m2), 'w' )
           oo1.write( htmltmpl_head  )
           oo1.write( '''<div class="demo">\n<div id="tabs">\n<ul>''' )
           ks = sorted( self.cc[m].dd[m2].keys() )
           for t in ks:
              this1 = '<li><a href="#tabs-%s">%s</a></li>' % (t,t )
              oo1.write( this1 )
           oo1.write( '</ul>' )
           for k in ks:
               oo1.write( '<div id="tabs-%s">\n' % k )
               oo1.write( '<table><tr>' )
               for h in ['Frequency','Table','Label','Title','Description','UID' ]:
                 oo1.write( '<td>%s</td>' % h )
               for t in self.cc[m].dd[m2][k]:
                 oo1.write( '\n</tr><tr>\n' )
                 oo1.write( ''.join( ['<td>%s</td>' % x for x in t ] ) + '\n' )
               oo1.write( '</tr></table></div>\n' )
   
           oo1.write( '</body></html>' )
           oo1.close()
        
       if self.cc[m].a[m2] == 0:
          ll.append( '' )
          llh.append( '' )
       else:
          try:
            if m2 == 'TOTAL':
              x = xt
            else:
              x = self.cc[m].a[m2]*2.
              xt += x

            s = vfmt( x )
            kc = '_%s_%s' % (m,m2)
            if m2 == 'TOTAL':
              sm = '; '.join( ['%s: %s' % (k,vfmt(cct[k]*2.)) for k in sorted( cct ) ] )
              if self.msgLevel > 1:
                print ( 'INFO.overviewTabs.01001: %s, %s' % (m,cct) )
              s1 = '<b><span title="%s">%s</span></b>' % (sm,s)
              s = '{\\bf %s}' % s
            else:
               for k in self.cc[kc].a.keys():
                cct[k] += self.cc[kc].a[k]
            ll.append( s )
            sm = '; '.join( ['%s: %s' % (k,vfmt(self.cc[kc].a[k]*2.)) for k in sorted( self.cc[kc].a.keys() ) ] )

            if sss:
              if self.fnm == 'new':
                fss = 'expt_%s_%s_%s_%s%s.html' % (m,m2,self.tiermax, self.pmax,self.efnsfx)
              else:
                fss = '%s-%s_%s_%s.html' % (m,m2,self.tiermax, self.pmax)
              llh.append( '<a title="By table: %s" href="tabs03/%s">%s</a>' % (sm,fss,s) )
            else:
              llh.append( '<a title="By table: %s" href="data/tabs02/%s">%s</a>' % (sm,fn,s) )
          except:
            print ( 'Failed to compute element: %s,%s  %s' % (m,m2, str(self.cc[m].a[m2]) ) )
            raise
      if m == 'VIACSAB':
        oo.write( ' & \cellcolor{llgray} '.join(ll ) + '\\\\ \n\\hline\n' )
      else:
        ll[2] = '\cellcolor{llgray} ' + ll[2]
        oo.write( ' & '.join(ll ) + '\\\\ \n\\hline\n' )

      llh.append( '<a href="data/tabs02/requestVol_%s_%s_%s.xlsx">Workings</a>' % (m,self.tiermax, self.pmax) )
      mmh.append( '<tr>' + ''.join(['<td>%s</td>' % x for x in llh] ) + '</tr>\n' )
    mmh.append( '</table>' )
    ttl = 'Data volume overview, upto tier %s and priority %s -- provisional' % (self.tiermax, self.pmax) 
    if self.sc.gridPolicyDefaultNative:
      defNat = 'For volume estimation, ocean data is assumed to be on the model native grid unless specifically requested on an interpolated grid'
    else:
      defNat = 'For volume estimation, ocean data is assumed to be on a regular 1-degree grid unless specifically requested on another grid (e.g. the native model grid)'
    bdy = '''<h1>%(ttl)s</h1>
<p>Data volumes are estimated for nominal model with 1 degree resolution and 40 levels in the atmosphere and 0.5 degrees with 60 levels in the ocean.  The "Requesting MIP" (rows) is the MIP specifying the data required to meet their scientific objectives. The "designing MIP" (columns) is the MIP specifying the experimental design. %(defNat)s <b>The figures below represent work in progress: there are still omissions and flaws, more details are on the 
<a href="https://earthsystemcog.org/projects/wip/CMIP6DataRequest" title="Data Request CoG page">Data Request home page</a>.</b></p>
''' % {'ttl':ttl, 'defNat':defNat }
    bdy += '\n'.join( mmh )
    ooh = open( 'tab01_%s_%s%s.html' % (self.tiermax,self.pmax,self.efnsfx), 'w' )
    ooh.write( self.dq.pageTmpl % (ttl, jsh, './', './index.html', bdy ) )
    ooh.close()
    oo.close()

if __name__ == "__main__":
  try:
    import makeTables
    import scope
  except:
    import dreqPy.scope as scope
    import dreqPy.makeTables as makeTables
  sc = scope.dreqQuery()
  r = r1( sc, table_utils.tables, tiermax=1, pmax=1 )
  r = r1( sc, table_utils.tables, tiermax=3, pmax=3 )
