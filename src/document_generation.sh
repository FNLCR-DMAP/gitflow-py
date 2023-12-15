#!/bin/bash

mkdir docs/
cd docs/
theme="sphinx_rtd_theme"

# This is step to use the sphinx-quickstart tool
# to setup the project, and generate html files
# for GitHub page.

echo "Parsing setup.py..."

setup_file="../setup.py"

# Extract the version field
version=$(grep -oP "version=['\"]\K[^'\"]+" "$setup_file")

# Extract the package name field
name=$(grep -oP "name=['\"]\K[^'\"]+" "$setup_file")

# Extract the author field
authors=$(grep -oP "author=['\"]\K[^'\"]+" "$setup_file")

# Print the extracted values
echo "Package Name: $name"
echo "Version: $version"
echo "AUthors: $authors"

echo "Running Quickstart..."

sphinx-quickstart -q --sep \
	--ext-autodo \
	--makefile \
	-p="$name" \
	-a="$authors" \
	-v="$version" \
	-r="" \
	-l="en";

echo "Quickstart Configured..."


echo "Updating Configuration..."

# Update Sphinx configuration
cat <<EOL >> "${source_dir}/conf.py"
import os
import sys

path = os.path.abspath('../../${modules_dir}')
sys.path.insert(0, path)

extensions = ['sphinx.ext.napoleon', 'sphinx.ext.autodoc', 'sphinx.ext.autosectionlabel']
html_theme = "${theme}"
html_theme_options = {
    'collapse_navigation': False,    # Keep navigation expanded by default
    'navigation_depth': 6,
    'style_nav_header_background': '#333',  # Background color for the navigation header
    'sticky_navigation': True,       # Enable sticky navigation bar on the right
}
html_sidebars = {'**': ['localtoc.html', 'relations.html', 'searchbox.html']}
EOL


###################### Generalized Method #########################
echo "Updating documentation..."
sphinx-apidoc -f -o source ../src/spac

sed -i 's/:maxdepth: 2/:maxdepth: 4/' source/index.rst

# Include README.md on the landing page
echo ".. include:: ../README.md" >> source/index.rst

echo "Generating html now..."
make html

cp -r build/html/* ./

echo "Documentation generation completed."
###################################################################
