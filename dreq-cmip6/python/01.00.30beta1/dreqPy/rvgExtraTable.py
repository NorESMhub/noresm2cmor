import collections

def wrap(s,a,b):
  if type(s) == type( '' ):
    return a + s + b
  elif type(s) in [type([]), type(())]:
    return [a + x + b for x in s]

class vgx1(object):
  def __init__(self,dq,nmx=-1,run=False):
    self.dq = dq
    if run:
      for i in dq.coll['requestVarGroup'].items[:nmx]:
        self.mxoGet(i)
        if self.mxo == None:
          print ( '%s, %s%s' % (i.label, i.title, ':: NONE') )
        else:
          self.present(i,self.mxo)

  def present( self, rvg,mxo,odir='html/u' ):
        print ( '%s, %s' % (rvg.label, rvg.title ) )
        cc = collections.defaultdict( dict )
        s1 = set()
        s2 = set()
        mm = ['<h1>%s</h1>' % rvg.title, 'Summary of requests for Request Variable Group <a href="%s.html">%s</a>.<br/>' % (rvg.uid,rvg.title), '<table>']
        for mip,eid in sorted( self.mxo.keys() ):
          ei =  self.dq.inx.uid[eid]
          el = ei.label
          sect = ei._h.label
          elb = '%s:: %s' % (sect,el)
          cc[ mip ]['%s:: %s' % (sect,el) ] = ','.join( sorted( list(self.mxo[(mip,eid)]) ) )
          s1.add(mip)
          s2.add(elb)
        ml = sorted( list( s1 ) )
        el = sorted( list( s2 ) )
        hr = ['<tr>']  + wrap( ['',] + ml, '<th>', '</th>') + ['</tr>']
        mm.append( ' '.join(hr)  )
        
        for e in el:
          rr = []
          for m in ml:
            if e in cc[m]:
              rr.append( cc[m][e] )
            else:
              rr.append('')
          rr = ['<tr><th>%s</th>' % e,] + wrap( rr, '<td>', '</td>') + ['</tr>']
          mm.append( ' '.join( rr ) )
        mm.append( '</table>' )
        bdy = '\n'.join( mm )
    
        oo = open( '%s/%s__xx.html' % (odir,rvg.uid), 'w' )
        oo.write( self.dq.pageTmpl % (rvg.title, '', '../', '../index.html', bdy ) )
        oo.close()

  def mxoGet(self,i,present=True):
    """Find MIPs and experiments associated with a request variable group, and associated objectives"""
    if 'requestLink' not in self.dq.inx.iref_by_sect[i.uid].a:
      self.mxo = None
      return (False, '','')
    else:
      self.mxo = collections.defaultdict( set )
      for u in self.dq.inx.iref_by_sect[i.uid].a['requestLink']:
        j = self.dq.inx.uid[u]
        mip = j.mip
        obj = j.objective
        if 'requestItem' in self.dq.inx.iref_by_sect[u].a:
          for uri in self.dq.inx.iref_by_sect[u].a['requestItem']:
            eid = self.dq.inx.uid[uri].esid
            self.mxo[(mip,eid)].add( obj )

    if present:
      self.present(i, self.mxo ) 
    return (True, '%s__xx.html' % i.uid, 'Usage summary for %s [%s]' % (i.title, i.label) )
            
      
