
####################  post pypi upgrade....
# compile egg etc (inc. wheel)
python setup.py sdist bdist_wheel
python setup.py sdist upload -r https://test.pypi.org/legacy/
python setup.py sdist upload -r https://upload.pypi.org/legacy
