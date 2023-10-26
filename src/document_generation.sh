#!/bin/bash

mkdir docs/
cd docs/
theme="sphinx_rtd_theme"

# This is step to use the sphinx-quickstart tool
# to setup the project, and generate html files
# for GitHub page.

echo "Parsing setup.py..."
# raw_author_array=()
# counter=0
# while IFS= read -r line && [ $counter -lt 8 ]; do
#   raw_author_array+=("$line")
#   ((counter++))
# done < ../pyproject.toml
setup_file="setup.py"

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

echo "import os" >> source/conf.py
echo "import os" >> source/conf.py
echo "import sys" >> source/conf.py
echo "path = os.path.abspath('../../src')" >> source/conf.py
echo "sys.path.insert(0,path)" >> source/conf.py
echo "extensions = ['sphinx.ext.napoleon', 'sphinx.ext.autodoc', 'sphinx.ext.autosectionlabel']" >> source/conf.py

# Adding theme. Currentlu using
# Read the Docs Sphinx Theme 

sed -i "s/^html_theme = .*/html_theme = \"$theme\"/" source/conf.py

# Enable navigation bar
echo "html_theme_options = {'collapse_navigation': False, 'navigation_depth': 6}" >> source/conf.py

# Set path to logo
# echo "html_logo = 'path_to_logo.png'" >> source/conf.py

# Set path to favicon
# echo "html_favicon = 'path_to_favicon.ico'" >> source/conf.py

# Enable table of contents sidebar
# echo "html_sidebars = {'**': ['index.html', 'sourcelink.html', 'searchbox.html']}" >> source/conf.py


###################### Generalized Method #########################
echo "Updating documentation..."
sphinx-apidoc -f -o source ../src/spac

sed -i 's/:maxdepth: 2/:maxdepth: 4/' source/index.rst

echo "Generating html now..."
make html

cp -r build/html/* .
###################################################################
