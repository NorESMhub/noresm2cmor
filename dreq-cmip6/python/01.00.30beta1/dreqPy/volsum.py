import xlsxwriter
from xlsxwriter.utility import xl_rowcol_to_cell
import collections, os


try:
  import dreq
  imm=1
except:
  import dreqPy.dreq  as dreq
  imm=2

if imm == 1:
  import misc_utils
  import table_utils
  import overviewTabs
  from extensions import collect as extCollect
##
## the double underscore causes some confusion, creating an error message _vsum__requestLink__expt not found.
  from extensions.collect import _requestLink__expt as requestLink__expt
else:
  import dreqPy.misc_utils as misc_utils
  import dreqPy.table_utils as table_utils
  import dreqPy.overviewTabs as overviewTabs
  from dreqPy.extensions import collect as extCollect
  from dreqPy.extensions.collect import _requestLink__expt as requestLink__expt



class xlsx(object):
  def __init__(self,fn,txtOpts=None):
    """Class to write spreadsheets of CMOR variables"""
    self.txtOpts = txtOpts
    self.mcfgNote = 'Reference Volume (1 deg. atmosphere, 0.5 deg. ocean)'
    self.wb = xlsxwriter.Workbook('%s.xlsx' % fn)
    self.hdr_cell_format = self.wb.add_format({'text_wrap': True, 'font_size': 14, 'font_color':'#0000ff', 'bold':1, 'fg_color':'#aaaacc'})
    self.hdr_cell_format.set_text_wrap()
    self.sect_cell_format = self.wb.add_format({'text_wrap': True, 'font_size': 14, 'font_color':'#0000ff', 'bold':1, 'fg_color':'#ccccbb'})
    self.sect_cell_format.set_text_wrap()
    self.cell_format = self.wb.add_format({'text_wrap': True, 'font_size': 11})
    self.cell_format.set_text_wrap()

  def newSheet(self,name):
    self.sht = self.wb.add_worksheet(name=name)
    return self.sht

  def tabrec(self,j,orec):
        for i in range(len(orec)):
          if orec[i] != '' and type( orec[i] ) == type( '' ) and orec[i][0] == '$':
             self.sht.write_formula(j,i, '{=%s}' % orec[i][1:])
          else:
             if j == 0:
               self.sht.write( j,i, orec[i], self.hdr_cell_format )
             else:
               self.sht.write( j,i, orec[i], self.cell_format )

  def close(self):
      self.wb.close()

class vsum(object):
  def __init__(self,sc,odsz,npy,exptFilter=None, odir='xls', tabByFreqRealm=False,txt=False,txtOpts=None):
    self.tabByFreqRealm = tabByFreqRealm
    self.doTxt = txt
    self.txtOpts = txtOpts
    idir = dreq.DOC_DIR
    if 'collect' not in sc.dq._extensions_:
      extCollect.add(sc.dq)
    self.sc = sc
    self.exptMipRql = collections.defaultdict( set )
    if exptFilter != None:
      assert type( exptFilter ) == type( set() ), 'FATAl.vsum.001: exptFilter argument must be type set: %s' % type( exptFilter )
    for i in self.sc.dq.coll['requestLink'].items:
      expts = requestLink__expt(i,rql=[i.uid,])
      if exptFilter != None:
        expts = exptFilter.intersection( expts )
      for e in expts:
        self.exptMipRql[ (i.mip,self.sc.dq.inx.uid[e].label) ].add( i.uid)
    self.odsz=odsz
    self.npy = npy
    self.exptFilter = exptFilter
    self.strSz = dict()
    self.accum = False
    self.odir = odir
    self.efnsfx = ''
    self.accPdict = collections.defaultdict( set )
    if sc.gridPolicyForce == 'native':
      self.efnsfx = '_fn'
    elif sc.gridPolicyForce == '1deg':
      self.efnsfx = '_f1'
    elif sc.gridPolicyDefaultNative:
      self.efnsfx = '_dn'
    if not os.path.isdir( odir ):
      print ( 'Creating new directory for xlsx output: %s' % odir )
      os.mkdir( odir )

    self.xlsPrefixM = 'cmvmm'
    self.xlsPrefixE = 'cmvme'
    self.xlsPrefixU = 'cmvume'
    if tabByFreqRealm:
      self.xlsPrefixM += 'fr'
      self.xlsPrefixE += 'fr'
      self.xlsPrefixU += 'fr'
    ii = open( '%s/sfheadings.csv' % idir, 'r' )
    self.infoRows = []
    for l in ii.readlines():
      ll = l.strip().split( '\t' )
      assert len(ll) == 2, 'Failed to parse info row: %s' % l
      self.infoRows.append( ll )
    ii.close()

  def analAll(self,pmax,mips=None,html=True,makeTabs=True):
      volsmm={}
      volsmmt={}
      volsme={}
      volsue={}
      if mips == None:
        theseMips =  ['TOTAL',] + self.sc.mips
      else:
        theseMips = list(mips)

## move *TOTAL to end of list.
      if '*TOTAL' in theseMips:
         theseMips.remove( '*TOTAL' )
         theseMips.append( '*TOTAL' )

      self.rres = {}
      self.rresu = {}
    
      for m in theseMips:
        olab = m
        useAccPdict = False
        if m == '*TOTAL':
            thism = theseMips[:]
            if type( thism ) == type( set() ):
              thism.remove( '*TOTAL' )
            else:
              thism.remove( '*TOTAL' )
            olab = misc_utils.setMlab( thism )
            useAccPdict = True
        elif type( theseMips ) == type( dict() ):
            thism = {m:theseMips[m]}
        else:
            thism = m

        if m != 'TOTAL' and 'TOTAL' in theseMips:
          cmv1, cmvts = self.sc.cmvByInvMip(thism,pmax=pmax,includeYears=True)
          self.uniqueCmv = self.sc.differenceSelectedCmvDict(  cmv1, cmvTotal )

        self.run( thism, '%s/requestVol_%s_%s_%s' % (self.odir,olab,self.sc.tierMax,pmax), pmax=pmax,doxlsx=makeTabs )

        self.anal(olab=olab,doUnique='TOTAL' in theseMips, makeTabs=makeTabs, useAccPdict=useAccPdict)
        ttl = sum( [x for k,x in self.res['vu'].items()] )*2.*1.e-12
        volsmm[m] = self.res['vm']
        volsmmt[m] = self.res['vmt']
        volsme[m] = self.res['ve']
        volsue[m] = self.res['uve']
        self.rres[m] = self.res['vf'].copy()
        self.rresu[m] = self.res['vu'].copy()
        if m == 'TOTAL':
          cmvTotal = self.sc.selectedCmv.copy()
          self.uniqueCmv =  {}
      if html:
        r1 = overviewTabs.r1( self.sc, table_utils.tables, pmax=pmax, vols=( volsmm, volsme, volsmmt,volsue ) )

  def _analSelectedCmv(self,cmv):
    lex = collections.defaultdict( list )
    vet = collections.defaultdict( int )
    vf = collections.defaultdict( int )
    vu = collections.defaultdict( float )
    mvol = collections.defaultdict( dict )

    for u in cmv:
      i = self.sc.dq.inx.uid[u]
      if i._h.label != 'remarks':
        npy = self.npy[ i.frequency ]
        isClim = i.frequency.lower().find( 'clim' ) != -1 or i.frequency in ['monC', '1hrCM']
        st = self.sc.dq.inx.uid[i.stid]
        c1 = 0
        for e,g in cmv[u]:
          ee = self.sc.dq.inx.uid[e]
          if ee.mip not in ['SolarMIP']:
            lex[e].append( u )
            t1, tt = self.sc.getStrSz( g, stid=i.stid, tt=True, cmv=u )
            np = t1[1]*npy
            if not isClim:
              np = np*cmv[u][(e,g)]
            c1 += cmv[u][(e,g)]
            vet[(e,i.mipTable)] += np
            vf[i.frequency] += np
            vu[u] += np
          else:
            print ('ERROR.obsoleteMip.00001: %s,%s,%s' % (ee.mip,ee.label,ee.uid) )
        if i.frequency in ['mon','monPt']:
            mvol[tt][u] = c1

    return dict(lex), dict(vet), dict(vf), dict(vu), dict(mvol)

  def xlsDest(self,mode,olab,lab2):
    if mode == 'e':
      return '%s/%s_%s_%s_%s_%s%s' % (self.odir,self.xlsPrefixE,olab,lab2,self.sc.tierMax,self.pmax,self.efnsfx)
    elif mode == 'u':
      return '%s/%s_%s_%s_%s_%s%s' % (self.odir,self.xlsPrefixU,olab,lab2,self.sc.tierMax,self.pmax,self.efnsfx)
    else:
      return '%s/%s_%s_%s_%s_%s%s' % (self.odir,self.xlsPrefixM,olab,lab2,self.sc.tierMax,self.pmax,self.efnsfx)

  def anal(self,olab=None,doUnique=False,makeTabs=False,mode='full',useAccPdict=False):
    vmt = collections.defaultdict( int )
    vm = collections.defaultdict( int )
    ve = collections.defaultdict( int )
    uve = collections.defaultdict( int )
    lm = collections.defaultdict( set )

    lex, vet, vf, vu, mvol = self._analSelectedCmv(self.sc.selectedCmv )
    if mode == 'short':
      self.res = { 'vet':vet,  'lex':lex, 'vu':vu, 'vf':vf}
      return

    if olab != 'TOTAL' and doUnique:
      s_lex, s_vet, s_vf, s_vu, s_mvol = self._analSelectedCmv(self.uniqueCmv )
      s_lm = set( self.uniqueCmv.keys() )
      s_cc = collections.defaultdict( int )
      for e,t in s_vet:
        s_cc[t] += s_vet[(e,t)]
        vm['Unique'] += s_vet[(e,t)]
        vmt[('Unique',t)] += s_vet[(e,t)]
        uve[e] += s_vet[(e,t)]

    checkMvol = -1
    if checkMvol > 0:
      for k in mvol:
        sp = self.sc.dq.inx.uid[k[0]]
        if k not in self.mvol:
          print ( 'INFO.volsum.01001: %s missing from mvol: ' % str(k) )
        else:
          if checkMvol > 1:
            for u in mvol[k]:
              la = self.sc.dq.inx.uid[u].label
              if self.mvol[k][u] != mvol[k][u]:
                print ( 'MISMATCH IN %s (%s): %s:: %s,%s' % (str(k),sp.label,la,mvol[k][u],self.mvol[k][u]) )
          
    for e in lex:
      ee = self.sc.dq.inx.uid[e]
      for i in lex[e]:
        lm[ee.mip].add( i )

    for e,t in vet:
      ee = self.sc.dq.inx.uid[e]
      vmt[(ee.mip,t)] += vet[(e,t)]
      vm[ee.mip] += vet[(e,t)]
      ve[e] += vet[(e,t)]
##
## makeTab needs: cc[m]: volume summary, by table,   lm[m]: list of CMOR variables
##
    cc = collections.defaultdict( dict )
    cct = collections.defaultdict( int )
    for m,t in vmt:
      cc[m][t] = vmt[(m,t) ]
    ss = set()
    for m in sorted( vm.keys() ):
      if olab != None:
        for t in cc[m]:
          cct[t] += cc[m][t]
        ss = ss.union( lm[m] )
        if makeTabs:
          ##table_utils.makeTab(self.sc.dq, subset=lm[m], dest=self.xlsDest('m',olab,m), collected=cc[m],exptUid=self.sc.exptByLabel.get(m,m) )
          table_utils.makeTab(self.sc, subset=lm[m], dest=self.xlsDest('m',olab,m), collected=cc[m], txt=self.doTxt, txtOpts=self.txtOpts )

    if olab != None and makeTabs:
        table_utils.makeTab(self.sc, subset=ss, dest=self.xlsDest('m',olab,'TOTAL'), collected=cct, txt=self.doTxt, txtOpts=self.txtOpts )
        if olab != 'TOTAL' and doUnique:
          table_utils.makeTab(self.sc, subset=s_lm, dest=self.xlsDest('m',olab,'Unique'), collected=s_cc, txt=self.doTxt, txtOpts=self.txtOpts )

    cc = collections.defaultdict( dict )
    ucc = collections.defaultdict( dict )
    cct = collections.defaultdict( int )
    for e,t in vet:
      cc[e][t] = vet[(e,t) ]
    for e in sorted( ve.keys() ):
      if olab != None and makeTabs:
        el = self.sc.dq.inx.uid[e].label

        if useAccPdict:
          pdict = collections.defaultdict( set )
          for vid, p in self.accPdict[e]:
               pdict[vid].add( p )
             
        elif olab in ['Total','TOTAL']:
          pdict = None
        elif (olab,el) in self.exptMipRql:
          pdict = collections.defaultdict( set )
          for rqlid in self.exptMipRql[(olab,el)]:
             rql = self.sc.dq.inx.uid[rqlid]
             for rqvid in self.sc.dq.inx.iref_by_sect[rql.refid].a['requestVar']:
               rqv = self.sc.dq.inx.uid[rqvid]
               pdict[rqv.vid].add( rqv.priority )
               self.accPdict[e].add( (rqv.vid,rqv.priority) )
        else:
          print ( 'INFO.00201: olab,e not found:',olab,el )
          pdict = None

        tslice = {}
        for v in self.sc.cmvts:
          if e in self.sc.cmvts[v]:
            tslice[v] = self.sc.cmvts[v][e]
        dest = self.xlsDest('e',olab,el)
        mode ='e'
        table_utils.makeTab(self.sc, subset=lex[e], dest=self.xlsDest(mode,olab,el), collected=cc[e],byFreqRealm=self.tabByFreqRealm, tslice=tslice, exptUid=e, tabMode=mode, pdict=pdict, txt=self.doTxt, txtOpts=self.txtOpts )

    if olab != 'TOTAL' and doUnique:
      for e,t in s_vet:
        ucc[e][t] = s_vet[(e,t) ]
      for e in sorted( uve.keys() ):
        if olab != None and makeTabs:
          el = self.sc.dq.inx.uid[e].label
          table_utils.makeTab(self.sc, subset=s_lex[e], dest=self.xlsDest('u',olab,el), collected=ucc[e], txt=self.doTxt, txtOpts=self.txtOpts)

    self.res = { 'vmt':vmt, 'vet':vet, 'vm':vm, 'uve':uve, 've':ve, 'lm':lm, 'lex':lex, 'vu':vu, 'cc':cc, 'cct':cct, 'vf':vf}
        
  def csvFreqStrSummary(self,mip,pmax=1):
    sf, c3 = self.sc.getFreqStrSummary(mip,pmax=pmax)
    self.c3 = c3
    self.pmax = pmax
    lf = sorted( list(sf) )
    hdr0 = ['','','','']
    hdr1 = ['','','','']
    for f in lf:
      hdr0 += [f,'','','']
      hdr1 += ['','','',str( self.npy.get( f, '****') )]
    orecs = [hdr0,hdr1,]
    crecs = [None,None,]
    self.mvol = collections.defaultdict( dict )
    self.rvol = dict()
    ix = 3
    for tt in sorted( c3.keys() ):
      s,o,g = tt
      i = self.sc.dq.inx.uid[ s ]
      if o != '' and type(o) == type('x'):
        msg = '%48.48s [%s]' % (i.title,o)
      else:
        msg = '%48.48s' % i.title
      if g != 'native':
        msg += '{%s}' % g
      szg = self.sc.getStrSz( g, s=s, o=o )[1]
      self.rvol[tt] = szg

      rec = [msg,szg,2,'']
      crec = ['','','','']
      for f in lf:
        if f in c3[tt]:
            nn,ny,ne,labs,expts = c3[tt][f]
            rec += [nn,ny,ne,'']
            clabs = [self.sc.dq.inx.uid[x].label for x in labs.keys()]
            crec += [sorted(clabs),'',expts,'']
            if f.lower().find( 'clim' ) == -1:
              assert abs( nn*ny - sum( [x for k,x in labs.items()] ) ) < .1, 'Inconsistency in year count: %s, %s, %s' % (str(tt),nn,ny)
            if f == 'mon':
              for k in labs:
                self.mvol[tt][k] = labs[k]
        else:
            rec += ['','','','']
            crec += ['','','','']
      colr = xl_rowcol_to_cell(0, len(rec))
      colr = colr[:-1]
      eq = '$SUMPRODUCT(--(MOD(COLUMN(E%(ix)s:%(colr)s%(ix)s)-COLUMN(A%(ix)s)+1,4)=0),E%(ix)s:%(colr)s%(ix)s)' % {'ix':ix,'colr':colr}
      ix += 1
      rec[3] = eq
      orecs.append( rec )
      crecs.append( crec )
    
    return (orecs, crecs)

  def byExpt(self):
    for cmv in self.sc.selectedCmv.keys():
      pass
      
  def run(self,mip='_all_',fn='test',pmax=1,doxlsx=True):
    if mip == '_all_':
      mip = set(self.sc.mips )
    self.mip = mip
    orecs, crecs = self.csvFreqStrSummary(mip,pmax=pmax)
    if not doxlsx:
      return
    print ('INFO.volsum.01002: Writing %s.xlsx' % fn )
    self.x = xlsx( fn )
    self.sht = self.x.newSheet( 'Volume' )
    oh = orecs[0]
    self.sht.set_column(0,0,60)
    self.sht.set_column(1,1,15)
    self.sht.set_column(2,2,4)
    self.sht.set_column(3,3,15)
    for k in range( int( (len(oh)-3)/4 ) ):
      self.sht.set_column((k+1)*4,(k+1)*4,4)
      self.sht.set_column((k+1)*4+1,(k+1)*4+1,8)
      self.sht.set_column((k+1)*4+2,(k+1)*4+2,4)
      self.sht.set_column((k+1)*4+3,(k+1)*4+3,12)
      
    oo = []
    for i in range( len(oh) ):
      oo.append( '' )
    kk = 0
    rr1 = 2
    rr1p = rr1 + 1
    for ix in range(len(orecs)):
      o = orecs[ix]
      kk += 1
      if kk > 2:
        for i in range( 7,len(o),4):
          frq = oh[i-3]
          
          cell = xl_rowcol_to_cell(0, i)[:-1]
          ca = xl_rowcol_to_cell(0, i-3)[:-1]
          ##if frq.lower().find( 'clim' ) == -1:
          cb = xl_rowcol_to_cell(0, i-2)[:-1]
          ##else:
          ##cb = xl_rowcol_to_cell(0, i-1)[:-1]
          eq = '$%(cell)s$%(rr1)s*%(cb)s%(kk)s*%(ca)s%(kk)s*$B%(kk)s*$C%(kk)s*0.000000001' % locals()
          o[i] = eq
        self.x.tabrec(kk-1, o )
        if crecs[ix] != None:
          crec = crecs[ix]
          for j in range(len(crec)):
            if crec[j] != '':
              self.sht.write_comment( kk-1, j, ' '.join( crec[j] ) )
      else:
        if kk == 1:
          for i in range( 4,len(o),4):
            cell = xl_rowcol_to_cell(0, i)[:-1]
            cell2 = xl_rowcol_to_cell(0, i+3)[:-1]
            self.sht.merge_range('%s1:%s1' % (cell,cell2), 'Merged Range')
        self.x.tabrec(kk-1, o )

    n = len(orecs)
    for i in range( 3,len(oo),4):
      cell = xl_rowcol_to_cell(0, i)[:-1]
      oo[i] = '$SUM(%(cell)s%(rr1p)s:%(cell)s%(n)s)*0.001' % locals()
    for i in range( 5,len(oo),4):
      oo[i] = oh[i-1]
    oo[0] = 'TOTAL VOLUME (Tb)'
    self.x.tabrec(kk, oo )

    n += 2
    for a,b in self.infoRows:
       self.sht.merge_range('B%s:H%s' % (n+1,n+1), 'Merged Range')
       self.sht.write( n,0, a )
       self.sht.write( n,1, b )
       n += 1

    self.x.close()
