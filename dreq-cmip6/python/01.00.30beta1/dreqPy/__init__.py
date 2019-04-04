
try:
  import packageConfig
  from packageConfig import *
except:
  #from dreqPy import packageConfig
  from .packageConfig import *
