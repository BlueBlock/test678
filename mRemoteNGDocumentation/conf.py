project = 'mRemoteNG'
copyright = '2022, The mRemoteNG Team'
author = 'The mRemoteNG Team'
language = 'en'
master_doc = 'index'
source_suffix = '.rst'
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
templates_path = ['_templates']
htmlhelp_basename = 'mRemoteNGdoc'
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_logo = 'logo.png';
html_theme_options = {'logo_only': True, 'display_version': True}
html_css_files = ['css/custom.css']
man_pages = [(master_doc, 'mremoteng', 'mRemoteNG Documentation', [author], 1)]
pygments_style = None
todo_include_todos = True
html_show_sourcelink = False