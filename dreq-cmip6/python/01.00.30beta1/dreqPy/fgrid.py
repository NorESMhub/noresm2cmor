knowna = [ 'LS3MIP [LWday]', 'LS3MIP [LEday]', 'CFMIP [cf1hrClimMon]', 'HighResMIP [3hr_cloud]', 'CFMIP [cf3hr_sim_new]', 'C4MIP [L_3hr]', 'DAMIP [DAMIP_day]', 'DAMIP [DAMIP_3hr_p2]', 'DynVar [DYVR_daily_c]', 'PMIP [PMIP-6hr]', 'HighResMIP [1hrLev]']
knowno = [ 'DAMIP [DAMIP_Omon_p2]', 'FAFMIP [fafOyr]']

def fgrid( dq ):
  ii = [i for i in dq.coll['CMORvar'].items if 'requestVar' in dq.inx.iref_by_sect[i.uid].a]
  ee = dict()
  i1 = []
  for i in ii:
    if i.modeling_realm.find('ocean') != -1 or 'ocnBgchem' != -1:
      ee[i.uid] = 'o'
    elif i.modeling_realm.find('seaIce' ) != -1:
      ee[i.uid] = 'si'
    elif i.modeling_realm == 'landIce':
      ee[i.uid] = 'li'
    elif i.modeling_realm in ['','__unset__']:
      i1.append( i )
    else:
      ee[i.uid] = 'a'

  i2 = []
  for i in i1:
    st = dq.inx.uid[i.stid]
    if st.odims in ['','?']:
      i2.append((i,st))
    elif st.odims == 'iceband':
      ee[i.uid] = 'si'
    else:
      ee[i.uid] = 'a'

  i3 = []
  for i,st in i2:
    sp = dq.inx.uid[st.spid]
    if sp.label == 'XY-na':
      i3.append( i )
    elif sp.label in ['TR-na','XY-O', 'YB-O', 'YB-R']:
      ee[i.uid] = 'o'
    else:
      ee[i.uid] = 'a'

  i4 = []
  for i in i3:
    if i.prov in knowna:
      ee[i.uid] = 'a'
    elif i.prov in knowno:
      ee[i.uid] = 'o'
    else:
      i4.append(i)

  if len(i4) > 0:
    print ( 'SEVERE.cmvgrid.00001: unidentified grids for %s variables' % len(i4) )
    for i in i4:
      print ( '%s: %s   %s' % (i.label, i.title, i.prov))

  return ee,i4
  
