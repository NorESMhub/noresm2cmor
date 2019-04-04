import collections, os, sys

try:
    import xlsxwriter
except:
    print ('No xlsxwrite: will not make tables ...')

try:
  import vrev
  import misc_utils
except:
  import dreqPy.vrev as vrev
  import dreqPy.misc_utils as misc_utils

def realmFlt( ss ):
  if ss == '':
    return ss
  if ss.find( ' ' ) == -1:
    return ss
  return ss.split( ' ' )[0]

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

if sys.version_info >= (2,7):
  from functools import cmp_to_key
  oldpython = False
else:
  oldpython = True

class cmpdn(object):
  def __init__(self,kl):
    self.kl = kl
  def cmp(self,x,y):
    for k in self.kl:
      if x.__dict__[k] != y.__dict__[k]:
        return cmp( x.__dict__[k], y.__dict__[k] )

    return cmp( 0,0 )

def cmpAnnex( x, y ):
  ax = len(x) > 2 and x[:2] == 'em'
  ay = len(y) > 2 and y[:2] == 'em'
  bx = len(x) > 5 and x[:5] in ['CMIP5','CORDE','SPECS']
  by = len(y) > 5 and y[:5] in ['CMIP5','CORDE','SPECS']
  if ax  == ay and bx == by:
    return cmp(x,y)
  elif ax:
    if by:
      return cmp(0,1)
    else:
      return cmp(1,0)
  elif ay:
    if bx:
      return cmp(1,0)
    else:
      return cmp(0,1)
  elif bx:
      return cmp(1,0)
  else:
    return cmp(0,1)

if not oldpython:
  kAnnex = cmp_to_key( cmpAnnex )
  kCmpdn = cmp_to_key( cmpdn(['sn','label']).cmp )
  kCmpdnPrl = cmp_to_key( cmpdn(['prov','rowIndex','label']).cmp )


class xlsx(object):
  def __init__(self,fn,xls=True,txt=False,txtOpts=None):
    self.xls=xls
    self.txt=txt
    self.txtOpts = txtOpts
    self.mcfgNote = 'Reference Volume (1 deg. atmosphere, 0.5 deg. ocean)'
    if xls:
      self.wb = xlsxwriter.Workbook('%s.xlsx' % fn)
      self.hdr_cell_format = self.wb.add_format({'text_wrap': True, 'font_size': 14, 'font_color':'#0000ff', 'bold':1, 'fg_color':'#aaaacc'})
      self.hdr_cell_format.set_text_wrap()
      self.sect_cell_format = self.wb.add_format({'text_wrap': True, 'font_size': 14, 'font_color':'#0000ff', 'bold':1, 'fg_color':'#ccccbb'})
      self.sect_cell_format.set_text_wrap()
      self.cell_format = self.wb.add_format({'text_wrap': True, 'font_size': 11})
      self.cell_format.set_text_wrap()

    if txt:
      self.oo = open( '%s.csv' % fn, 'w' )

  def header(self,tableNotes,collected):
    if self.xls:
      sht = self.newSheet( 'Notes' )
      sht.write( 0,0, '', self.hdr_cell_format )
      sht.write( 0,1, 'Notes on tables', self.hdr_cell_format )
      ri = 0
      sht.set_column(0,0,30)
      sht.set_column(1,1,60)
      self.sht = sht
      for t in tableNotes:
        ri += 1
        for i in range(2):
          sht.write( ri,i, t[i], self.cell_format )

      if collected != None:
        ri += 2
        sht.write( ri, 0, 'Table', self.sect_cell_format )
        sht.write( ri, 1, self.mcfgNote, self.sect_cell_format )
        ttl = 0.
        for k in sorted( collected.keys() ):
          ri += 1
          sht.write( ri, 0, k )
          sht.write( ri, 1, misc_utils.vfmt( collected[k]*2. ) )
          ttl += collected[k]

        ri += 1
        sht.write( ri, 0, 'TOTAL' )
        sht.write( ri, 1, misc_utils.vfmt( ttl*2. ) )

    if self.txt:
      self.oo.write( '\t'.join( ['Notes','','Notes on tables']) + '\n' )
      for t in tableNotes:
        self.oo.write( '\t'.join( ['Notes',] + list(t)) + '\n' )

      if collected != None:
        self.oo.write( '\t'.join( ['Notes','Table','Reference Volume (1 deg. atmosphere, 0.5 deg. ocean)']) + '\n')
        for k in sorted( collected.keys() ):
          self.oo.write( '\t'.join( ['Notes',k,misc_utils.vfmt( collected[k]*2. )]) + '\n' )

  def cmvtabrec(self,j,t,orec):
     if self.xls:
        for i in range(len(orec)):
           if str( type(orec[i]) ) == "<class 'dreq.dreqItem_CoreAttributes'>":
             self.sht.write( j,i, '', self.cell_format )
           else:
             ##print i, orec[i], type( orec[i] )
             try:
                self.sht.write( j,i, orec[i], self.cell_format )
             except:
               print ('FAILED TO WRITE RECORD: %s' % str(orec))
               print ('FAILED TO WRITE RECORD: %s' % str(orec[i]))
               raise

     if self.txt:
        self.oo.write( '\t'.join( [t,] + [x.replace('"',"'") for x in orec]) + '\n' )

  def varrec(self,j,orec):
     if self.xls:
        for i in range(len(orec)):
           self.sht.write( j,i, orec[i], self.cell_format )

     if self.txt:
        self.oo.write( '\t'.join( orec, '\t') + '\n' )

  def var(self):
      if self.xls:
       self.sht = self.newSheet( 'var' )
      j = 0
      hrec = ['Long name', 'units', 'description', 'Variable Name', 'CF Standard Name' ]
      if self.xls:
          self.sht.set_column(1,1,40)
          self.sht.set_column(1,2,30)
          self.sht.set_column(1,3,60)
          self.sht.set_column(1,4,40)
          self.sht.set_column(1,5,40)
          self.sht.set_column(1,20,40)
          self.sht.set_column(1,21,40)

      if self.xls:
        for i in range(len(hrec)):
          self.sht.write( j,i, hrec[i], self.hdr_cell_format )

      if self.txt:
        for i in range(len(hrec)):
          self.oo.write( hrec[i] + '\t' )
        self.oo.write( '\n' )

  def cmvtab(self,t,addMips,mode='c',tslice=False,byFreqRealm=False,truePriority=False):
      if self.xls:
        self.sht = self.newSheet( t )
      j = 0
      ncga = 'NetCDF Global Attribute'
      if mode == 'c':
        hrec = ['Default Priority','Long name', 'units', 'description', 'comment', 'Variable Name', 'CF Standard Name', 'cell_methods', 'positive', 'type', 'dimensions', 'CMOR Name', 'modeling_realm', 'frequency', 'cell_measures', 'prov', 'provNote','rowIndex','UID','vid','stid','Structure Title','valid_min', 'valid_max', 'ok_min_mean_abs', 'ok_max_mean_abs']
        hcmt = ['Default priority (generally overridden by settings in "requestVar" record)',ncga,'','','Name of variable in file','','','CMOR directive','','','CMOR name, unique within table','','','','','','','','','','CMOR variable identifier','MIP variable identifier','Structure identifier','','','','','']
        if truePriority:
           hrec[0] = 'Priority'
           hcmt[0] = 'Lowest priority value set in request for this variable for this experiment'
        if self.xls:
          self.sht.set_column(1,1,40)
          self.sht.set_column(1,3,50)
          self.sht.set_column(1,4,30)
          self.sht.set_column(1,5,50)
          self.sht.set_column(1,6,30)
          self.sht.set_column(1,9,40)
          self.sht.set_column(1,18,40)
          self.sht.set_column(1,19,40)
          self.sht.set_column(1,20,40)
          self.sht.set_column(1,21,40)
          self.sht.set_column(1,26,40)
          self.sht.set_column(1,27,40)
          self.sht.set_column(1,30,40)
      else:
        hrec = ['','Long name', 'units', 'description', '', 'Variable Name', 'CF Standard Name', '','', 'cell_methods', 'valid_min', 'valid_max', 'ok_min_mean_abs', 'ok_max_mean_abs', 'positive', 'type', 'dimensions', 'CMOR name', 'modeling_realm', 'frequency', 'cell_measures', 'flag_values', 'flag_meanings', 'prov', 'provNote','rowIndex','UID']
      if addMips:
        hrec.append( 'MIPs (requesting)' )
        hrec.append( 'MIPs (by experiment)' )

      if byFreqRealm:
        hrec = ['Table',] + hrec
        hcmt = ['CMOR table',] + hcmt
      if tslice:
          hrec += ['Number of Years','Slice Type','Years','Grid']
          hcmt += ['','','','']

      if self.xls:
        for i in range(len(hrec)):
          self.sht.write( j,i, hrec[i], self.hdr_cell_format )
          if hcmt[i] != '':
            self.sht.write_comment( j,i,hcmt[i])

      if self.txt:
        self.oo.write( 'MIP table\t' )
        for i in range(len(hrec)):
          self.oo.write( hrec[i] + '\t' )
        self.oo.write( '\n' )
        self.oo.write( t + '\t' )
        for i in range(len(hrec)):
          if hcmt[i] != '':
            self.oo.write( hcmt[i] + '\t')
          else:
            self.oo.write( '\t')
        self.oo.write( '\n' )

  def newSheet(self,name):
    self.worksheet = self.wb.add_worksheet(name=name)
    return self.worksheet

  def close(self):
    if self.xls:
      self.wb.close()
    if self.txt:
      self.oo.close()

###
### need to have name of experiment here, for the aggregation over MIPs to work ... in the column of request by MIPs
###
class makeTab(object):
  def __init__(self, sc, subset=None, mcfgNote=None, dest='tables/test', skipped=set(), collected=None,xls=True,txt=False,txtOpts=None,byFreqRealm=False, tslice=None, exptUid=None, tabMode=None, pdict=None):
    """txtOpts: gives option to list MIP variables instead of CMOR variables"""
    self.sc = sc
    dq = sc.dq
    if subset != None:
      cmv = [x for x in dq.coll['CMORvar'].items if x.uid in subset]
    else:
      cmv = dq.coll['CMORvar'].items
    self.byFreqRealm=byFreqRealm

    ixt = collections.defaultdict(list)
    if not byFreqRealm:
      for i in cmv:
        ixt[i.mipTable].append( i.uid )
    else:
      for i in cmv:
        ixt['%s.%s' % (i.frequency,realmFlt( i.modeling_realm) )].append( i.uid )

    if oldpython:
        tables = sorted( ixt.keys(), cmp=cmpAnnex )
    else:
        tables = sorted( ixt.keys(), key=kAnnex )

    addMips = True
    if addMips:
      chkv = vrev.checkVar(dq)
      chkv.sc = self.sc
    mode = 'c'
    tableNotes = [
       ('Request Version',str(dq.version)),
       ('MIPs (...)','The last two columns in each row list MIPs associated with each variable. The first column in this pair lists the MIPs which are requesting the variable in one or more experiments. The second column lists the MIPs proposing experiments in which this variable is requested. E.g. If a variable is requested in a DECK experiment by HighResMIP, then HighResMIP appears in the first column and DECK in the second')]

    wb = xlsx( dest, xls=xls, txt=txt )
    if mcfgNote != None:
      wb.mcfgNote = mcfgNote
    wb.header( tableNotes, collected)
    truePriority = tabMode == 'e' and pdict != None

    if txtOpts != None and txtOpts.mode == 'var':
      vl =  list( set( [v.vid for v in cmv] )  )
      vli = [dq.inx.uid[i] for i in vl]
      if oldpython:
        thisvli =  sorted( vli, cmp=cmpdn(['sn','label']).cmp )
      else:
        thisvli = sorted( vli, key=kCmpdn )
      wb.var()
      
      j = 0
      for v in thisvli:
      ###hrec = ['Long name', 'units', 'description', 'Variable Name', 'CF Standard Name' ]
         orec = [v.title, v.units, v.description, v.label, v.sn]
         j += 1
         wb.varrec( j,orec )
    else:
      withoo = False
      for t in tables:
        if withoo:
          oo = open( 'tables/test_%s.csv' % t, 'w' )
        wb.cmvtab(t,addMips,mode='c',tslice=tslice != None,byFreqRealm=byFreqRealm,truePriority = truePriority)

        j = 0
        if oldpython:
          thiscmvlist =  sorted( [dq.inx.uid[u] for u in ixt[t]], cmp=cmpdn(['prov','rowIndex','label']).cmp )
        else:
          thiscmvlist = sorted( [dq.inx.uid[u] for u in ixt[t]], key=kCmpdnPrl )

        for cmv in thiscmvlist:
          var = dq.inx.uid[ cmv.vid ]
          strc = dq.inx.uid[ cmv.stid ]
          if strc._h.label == 'remarks':
            print ( 'ERROR: structure not found for %s: %s .. %s (%s)' % (cmv.uid,cmv.label,cmv.title,cmv.mipTable) )
            ok = False
          else:
            sshp = dq.inx.uid[ strc.spid ]
            tshp = dq.inx.uid[ strc.tmid ]
            ok = all( [i._h.label != 'remarks' for i in [var,strc,sshp,tshp]] )
          #[u'shuffle', u'ok_max_mean_abs', u'vid', '_contentInitialised', u'valid_min', u'frequency', u'uid', u'title', u'rowIndex', u'positive', u'stid', u'mipTable', u'label', u'type', u'description', u'deflate_level', u'deflate', u'provNote', u'ok_min_mean_abs', u'modeling_realm', u'prov', u'valid_max']

          if not ok:
            if (t,cmv.label) not in skipped:
              ml = []
              for i in range(4):
                 ii = [var,strc,sshp,tshp][i]
                 if ii._h.label == 'remarks':
                   ml.append( ['var','struct','time','spatial'][i] )
              print ( 'makeTables: skipping %s %s: %s' % (t,cmv.label,','.join( ml)) )
              skipped.add( (t,cmv.label) )
          else:
            dims = []
            dims +=  sshp.dimensions.split( '|' )
            if 'odims' in strc.__dict__:
              dims +=  strc.odims.split( '|' )
            dims +=  tshp.dimensions.split( '|' )
            if 'coords' in strc.__dict__:
              dims +=  strc.coords.split( '|' )
            dims = ' '.join( dims )
            if "qcranges" in dq.inx.iref_by_sect[cmv.uid].a:
              u = dq.inx.iref_by_sect[cmv.uid].a['qcranges'][0]
              qc = dq.inx.uid[u]
              ll = []
              for k in ['valid_min', 'valid_max', 'ok_min_mean_abs', 'ok_max_mean_abs']:
                if qc.hasattr(k):
                  ll.append( '%s %s' % (qc.__dict__[k],qc.__dict__['%s_status' % k][0]) )
                else:
                  ll.append( '' )
              valid_min, valid_max, ok_min_mean_abs, ok_max_mean_abs = tuple( ll )
            else:
              valid_min, valid_max, ok_min_mean_abs, ok_max_mean_abs = ('','','','')
               
            if mode == 'c':
              try:
                if tabMode == 'e' and pdict != None:
                  if cmv.uid in pdict:
                    thisp = str( min( pdict[cmv.uid] ) )
                  else:
                    thisp = str(cmv.defaultPriority)
                    print ('ERROR.priority.0101: %s, %s ' % (cmv.label,dest) )
                else:
                  thisp = str(cmv.defaultPriority)
#
# avoid duplication of information (added in 01.00.29)
##
                if cmv.description != var.description:
                  cmmt = cmv.description
                else:
                  cmmt = ''
                orec = [thisp,var.title, var.units, var.description, cmmt, var.label, var.sn, strc.cell_methods, cmv.positive, cmv.type, dims, cmv.label, cmv.modeling_realm, cmv.frequency, strc.cell_measures, cmv.prov,cmv.provNote,str(cmv.rowIndex),cmv.uid,cmv.vid,cmv.stid,strc.title, valid_min, valid_max, ok_min_mean_abs, ok_max_mean_abs]

##
              except:
                print ('FAILED TO CONSTRUCT RECORD: %s [%s], %s [%s]' % (cmv.uid,cmv.label,var.uid,var.label) )
                raise
            else:
              orec = ['',var.title, var.units, cmv.description, '', var.label, var.sn, '','', strc.cell_methods, valid_min, valid_max, ok_min_mean_abs, ok_max_mean_abs, cmv.positive, cmv.type, dims, cmv.label, cmv.modeling_realm, cmv.frequency, strc.cell_measures, strc.flag_values, strc.flag_meanings,cmv.prov,cmv.provNote,str(cmv.rowIndex),var.uid]

            if byFreqRealm:
              orec = [cmv.mipTable,] + orec

##!
# CHECK -- ERROR HERE FOR "TOTAL" ROW --spurious mips in thismips ---
##!
## change "c" to something searchable
            if addMips:
##
## union of all mips interested in this variable
##
              thismips = chkv.chkCmv( cmv.uid )
##
## all mips requesting this variable for this experiment
##
              thismips2 = chkv.chkCmv( cmv.uid, byExpt=True, expt=exptUid )
              orec.append( ','.join( sorted( list( thismips) ) ) )
              orec.append( ','.join( sorted( list( thismips2) ) ) )

            if tslice != None:
              msgLevel = 0
              if cmv.uid in tslice and msgLevel > 1:
                print ( 'INFO.table_utils.01001: slice 3: %s : %s' % ( str( tslice[cmv.uid] ), cmv.label ) )
              if cmv.uid not in tslice:
                orec += ['All', '','','']
              elif type( tslice[cmv.uid] ) == type( 0 ):
                print ( 'ERROR: unexpected tslice type: %s, %s' % (cmv.uid, tslice[cmv.uid] ) )
              elif len(  tslice[cmv.uid] ) == 3:
                x,priority,grid = tslice[cmv.uid]
                orec[0] = priority
                if x != None:
                   tslab,tsmode,a,b = x
                   orec += [tslab,tsmode,'',grid]
                else:   
                   print ( 'WARN.table_utils.01001: slice 3: %s : %s' % ( str( tslice[cmv.uid] ), cmv.label ) )
                   orec += ['*unknown*','','',grid]
              else:
                tslab,tsmode,a,b,priority,grid = tslice[cmv.uid]
                if type( priority ) != type(1):
                  thisp = priority
                  priority = thisp[1]
                orec[0] = '%s' % priority
                     
                if tsmode[:4] in ['simp','bran']:
                   nys = b + 1 - a
                   ys = range(a,b+1)
                   orec += [str(nys), '',str(ys)]
                elif tsmode in ['rangeplus']:
                   nys = b + 1 - a + 0.01
                   ys = [1850,] + range(a,b+1)
                   orec += [str(nys), 'Partial 1850 + %s to %s' % (a,b),'%6.2f' % ys]
                elif tsmode[:4] in ['YEAR']:
                   nys = a
                   ys = b
                   orec += [str(nys), '',str(ys)]
                else:
                   orec += ['slice', tslab,'']
                orec.append( grid )
                
            if orec[0] in [0,'0',None]:
                  print ('ERROR.priority.006: %s, %s ' % (orec,dest))
            if withoo:
              oo.write( '\t'.join(orec ) + '\n' )
            j+=1
            wb.cmvtabrec( j,t,orec )

        if withoo:
          oo.close()
    wb.close()

class tables(object):
  def __init__(self,sc, odir='xls',xls=True,txt=False,txtOpts=None):
      self.sc = sc
      self.dq = sc.dq
      ##self.mips = mips
      self.odir = odir
      self.accReset()
      self.doXls = xls
      self.doTxt = txt
      self.txtOpts = txtOpts

  def accReset(self):
    self.acc = [0.,collections.defaultdict(int),collections.defaultdict( float ) ]

  def accAdd(self,x):
    self.acc[0] += x[0]
    for k in x[2]:
       self.acc[2][k] += x[2][k]


  def doTable(self,m,l1,m2,pmax,collector,acc=True, mlab=None,exptids=None,cc=None):
      """*acc* allows accumulation of values to be switched off when called in single expt mode"""
      
      self.verbose = False
      if mlab == None:
        mlab = misc_utils.setMlab( m )

      cc0 = misc_utils.getExptSum( self.dq, mlab, l1 )
      ks = sorted( list( cc0.keys() ) )
      if self.verbose:
        print ('Experiment summary: %s %s' % (mlab,', '.join( ['%s: %s' % (k,len(cc0[k])) for k in ks] ) ) )

      if m2 in [None, 'TOTAL']:
        x = self.acc
      else:
        x = self.sc.volByExpt( l1, m2, pmax=pmax )

##self.volByExpt( l1, e, pmax=pmax, cc=cc, retainRedundantRank=retainRedundantRank, intersection=intersection, adsCount=adsCount )
        v0 = self.sc.volByMip( m, pmax=pmax,  exptid=m2 )
####
        if cc==None:
          cc = collections.defaultdict( int )
        for e in self.sc.volByE:
          if self.verbose:
             print ('INFO.mlab.... %s: %s: %s' % ( mlab, e, len( self.sc.volByE[e][2] ) ) )
          for v in self.sc.volByE[e][2]:
             cc[v] += self.sc.volByE[e][2][v]
        xxx = 0
        for v in cc:
          xxx += cc[v]
####
        if acc:
          for e in self.sc.volByE:
            self.accAdd(self.sc.volByE[e])

      if m2 not in [ None, 'TOTAL']:
          im2 = self.dq.inx.uid[m2]
          ismip = im2._h.label == 'mip'
          mlab2 = im2.label

          x0 = 0
          for e in self.sc.volByE:
            if exptids == None or e in exptids:
              x = self.sc.volByE[e]
              if x[0] > 0:
                collector[mlab].a[mlab2] += x[0]
                x0 += x[0]
      else:
          ismip = False
          mlab2 = 'TOTAL'
          x0 = x[0]

      if mlab2 == 'TOTAL' and x0 == 0:
        print ( 'no data detected for %s' % mlab )

      if x0 > 0:
#
# create sum for each table
#
        xs = 0
        kkc = '_%s_%s' % (mlab,mlab2)
        kkct = '_%s_%s' % (mlab,'TOTAL')
        if m2 in [None, 'TOTAL']:
          x = self.acc
          x2 = set(x[2].keys() )
          for k in x[2].keys():
           i = self.dq.inx.uid[k]
           xxx =  x[2][k]
           xs += xxx
        else:
          x2 = set()
          for e in self.sc.volByE:
            if exptids == None or e in exptids:
              x = self.sc.volByE[e]
              x2 = x2.union( set( x[2].keys() ) )
              for k in x[2].keys():
               i = self.dq.inx.uid[k]
               xxx =  x[2][k]
               xs += xxx
               if xxx > 0:
                collector[kkc].a[i.mipTable] += xxx
                if ismip:
                  collector[kkct].a[i.mipTable] += xxx

##
## One user was getting false error message here, with ('%s' % x0) == ('%s' % xs)
##
        if abs(x0 -xs) > 1.e-8*( abs(x0) + abs(xs) ):
          print ( 'ERROR.0088: consistency problem %s  %s %s %s' % (m,m2,x0,xs) )
        if x0 == 0:
          print ( 'Zero size: %s, %s' % (m,m2) )
          if len( x[2].keys() ) > 0:
             print ( 'ERROR:zero: %s, %s: %s' % (m,m2,str(x[2].keys()) ) )

        if acc and m2 not in [ None, 'TOTAL']:
          collector[mlab].a['TOTAL'] += x0

        dd = collections.defaultdict( list )
        lll = set()
        for v in x2:
          vi = self.sc.dq.inx.uid[v]
          if vi._h.label != 'remarks':
            f,t,l,tt,d,u = (vi.frequency,vi.mipTable,vi.label,vi.title,vi.description,vi.uid)
            lll.add(u)
            dd[t].append( (f,t,l,tt,d,u) )

        if len( dd.keys() ) > 0:
          collector[mlab].dd[mlab2] = dd
          if m2 not in [ None, 'TOTAL']:
            if im2._h.label == 'experiment':
              dothis = self.sc.tierMax >= min( im2.tier )
###
### BUT ... there is a treset in the request item .... it may be that some variables are excluded ...
###         need the variable list itself .....
###
          makeTab( self.sc, subset=lll, dest='%s/%s-%s_%s_%s' % (self.odir,mlab,mlab2,self.sc.tierMax,pmax), collected=collector[kkc].a,
              mcfgNote=self.sc.mcfgNote,
              txt=self.doTxt, xls=self.doXls, txtOpts=self.txtOpts, exptUid=self.sc.exptByLabel.get(mlab2,mlab2) )
