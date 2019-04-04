import string

def uniCleanFunc(ss,jsFilt=False):
      if type(ss) in [type('x'),type(u'x')]:
          ss = string.replace( ss, u'\u2013', '-' )
          ss = string.replace( ss, u'\u2014', '-' )
          ss = string.replace( ss, u'\u201c', '"' )
          ss = string.replace( ss, u'\u201d', '"' )
          ss = string.replace( ss, u'\u2018', "'" )
          ss = string.replace( ss, u'\u2019', "'" )
          ss = string.replace( ss, u'\u2026', '...' )
          ss = string.replace( ss, u'\u25e6', 'o' )
          ss = string.replace( ss, u'\xb2', '2' )
          ss = string.replace( ss, u'\xb3', '3' )
          if jsFilt:
            ss = string.replace( ss, '"', "'" )
            ss = string.replace( ss, '\n', ";;" )
          return ss
      else:
          return ss
    

