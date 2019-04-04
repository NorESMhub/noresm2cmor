import codecs
import os, sys
import re

from setuptools import setup, find_packages

####################################################################

NAME = "dreqPy"
python2 = True
if sys.version_info[0] == 3:
  PACKAGES = find_packages(exclude=["tests*","dreqPy.utilP2"])
  python2 = False
else:
  PACKAGES = find_packages(exclude=["tests*"])

META_PATH = os.path.join("dreqPy", "packageConfig.py")
KEYWORDS = ["CMIP6"]
CLASSIFIERS = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "Natural Language :: English",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
    "Programming Language :: Python",
    "Programming Language :: Python :: 2",
    "Programming Language :: Python :: 2.7",
    "Programming Language :: Python :: 3",
    "Topic :: Software Development :: Libraries :: Python Modules",
]
INSTALL_REQUIRES = []

###################################################################

HERE = os.path.abspath(os.path.dirname(__file__))


def read(*parts):
    """
    Build an absolute path from *parts* and and return the contents of the
    resulting file.  Assume UTF-8 encoding.
    """
    with codecs.open(os.path.join(HERE, *parts), "rb", "utf-8") as f:
        return f.read()


META_FILE = read(META_PATH)

def find_meta(meta):
    """
    Extract __*meta*__ from META_FILE.
    """
    import dreqPy.packageConfig as pcfg
    if '__%s__' % meta in pcfg.__dict__:
      return pcfg.__dict__[ '__%s__' % meta ]

    raise RuntimeError("Unable to find __{meta}__ string.".format(meta=meta))

def find_meta0(meta):
    """
    Extract __*meta*__ from META_FILE.
    """
    meta_match = re.search(
        r"^__{meta}__ = ['\"]([^'\"]*)['\"]".format(meta=meta),
        META_FILE, re.M
    )
    if meta_match:
        return meta_match.group(1)
    raise RuntimeError("Unable to find __{meta}__ string.".format(meta=meta))

class test(object):
  def __init__(self):
    for v in ['license','uri','version']:
      print ( '%s: %s' % (v,find_meta(v) ) )
      assert os.path.isfile( 'LICENSE' ), 'License file not found'
      assert os.path.isfile( 'README.txt' ), 'README file not found'

if __name__ == "__main__":
   if len(sys.argv) > 1 and sys.argv[1] == '-t':
      t = test()
   else:
      setup(
        name=NAME,
        description=find_meta("description"),
        license=find_meta("license"),
        url=find_meta("uri"),
        version=find_meta("version"),
        author=find_meta("author"),
        author_email=find_meta("email"),
        maintainer=find_meta("author"),
        maintainer_email=find_meta("email"),
        keywords=KEYWORDS,
        include_package_data=True,
        long_description=read("README.txt"),
        packages=PACKAGES,
        zip_safe=False,
        classifiers=CLASSIFIERS,
        install_requires=INSTALL_REQUIRES,
        data_files = [("", ["LICENSE"])],
        entry_points= {
        'console_scripts': ['drq = dreqPy.dreqCmdl:main_entry'],
        },
    )
