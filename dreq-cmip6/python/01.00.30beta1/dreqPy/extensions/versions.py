import hashlib, requests, os, collections

def compare(self, oth,count=True,lst='short',sect='CMORvar' ):
    n0 = 0
    n1 = 0
    n2 = 0
    this = self.coll[sect].items[0]
    that = oth.coll[sect].items[0]
    lstValid = [None,'short','long']
    assert lst in lstValid, 'Value of lst [%s] not valid, one of: %s' % (lst,str(lstValid))
    cc = collections.defaultdict( int )
    for k in sorted( that._uidDict.keys() ):
      if k not in this._uidDict:
        n0 += 1
        if lst != None:
          print ( 'Only in %s: %s [%s]' % (oth.version, k, that._uidDict[k].label ) ) 

    for k in sorted( this._uidDict.keys() ):
      if k not in that._uidDict:
        n1 += 1
        if lst != None:
          print ( 'Only in %s: %s [%s]' % (self.version, k, this._uidDict[k].label ) )
      elif this._uidDict[k].__dict__ != that._uidDict[k].__dict__:
        n2 += 1
        
        s1 = [kk for kk in this._uidDict[k].__dict__ if kk not in that._uidDict[k].__dict__]
        s2 = [kk for kk in that._uidDict[k].__dict__ if kk not in this._uidDict[k].__dict__]
        s3 = [kk for kk in that._uidDict[k].__dict__ if kk in this._uidDict[k].__dict__ and that._uidDict[k].__dict__[kk] != this._uidDict[k].__dict__[kk]]
        for i in s1 + s2 + s3:
          cc[i] += 1
        if lst == 'long':
          print ('Changed in %s -- %s: %s [%s], {%s|%s|%s}' % (self.version,oth.version, k, this._uidDict[k].label, str(s1),str(s2),str(s3) ) )

    if n0 == 0 and n1 == 0:
      print ('%s (%s --> %s):: No additons or removals' % (sect,oth.version,self.version) )
    else:
      print ('%s (%s --> %s):: Added %s, Removed %s' % (sect,oth.version,self.version,n1,n0) )
    print ('%s:: Number changed in %s -- %s: %s' % (sect, self.version,oth.version,n2) )
    if n2 > 0:
      msg = '; '.join( ['%s: %s' % (k,cc[k]) for k in sorted(cc.keys())] )
      print ('%s:: Attribute changes: %s' % (sect,msg) )

def fetch(self,version=None, vdir=None):
    files = ['dreq.xml', 'dreq2Defn.xml', 'dreqSupp.xml', 'dreqSuppDefn.xml']
    utmpl = 'http://proj.badc.rl.ac.uk/svn/exarch/CMIP6dreq/tags/%s/dreqPy/docs/%s'
    if version == None:
      version = self.version
    if vdir == None:
      vdir = self._VERSION_DIR_
    if not os.path.isdir( '%s/%s' % (vdir,version) ):
      os.mkdir( '%s/%s' % (vdir,version) )
    for f in files:
      u = utmpl % (version,f)
      page = requests.get(u)
      md5 = hashlib.md5(page.text.encode('utf-8')).hexdigest()
      print ( (version, f, md5 ) )
      oo = open( '%s/%s/%s' % (vdir,version,f), 'w' )
      oo.write( page.text.encode('utf-8') )
      oo.close()
   
def  add(dq):
   """Add extensions."""
   dq.__class__._fetch_ = fetch
   dq.__class__._compare_ = compare
   dq._extensions_['versions'] = True
