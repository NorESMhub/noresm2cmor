
pageWrapper = """<html><head>
%(htmlHead)s
</head>
<body>
%(htmlBody)s
</body>
</html>
"""

indexWrapper = """
<h1>%(title)s</h1>
%(introduction)s
<ul>
%(items)s
</ul>
"""

item = """   <li>%(item)s</li>"""

attribute = '''   <li><span title="%(keyTitle)s"><b>%(key)s</b></span>: %(value)s</li>'''
