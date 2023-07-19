#!/bin/bash

mkdir docs/
cd docs/
theme="sphinx_rtd_theme"

# This is step to use the sphinx-quickstart tool
# to setup the project, and generate html files
# for GitHub page.

echo "Parsing pyproject.toml..."
raw_author_array=()
counter=0
while IFS= read -r line && [ $counter -lt 8 ]; do
  raw_author_array+=("$line")
  ((counter++))
done < ../pyproject.toml

name=$(echo "${raw_author_array[1]}" | cut -d '=' -f 2)
name=${name//\"/}
name=${name//, /,}
echo $name

version=$(echo "${raw_author_array[2]}" | cut -d '=' -f 2)
version=${version//\"/}
version=${version//, /,}
echo $version

authors=$(echo "${raw_author_array[4]}" | cut -d '=' -f 2)
authors=$(echo "$authors" | sed 's/^ \+\[//')
authors=${authors%\]}
authors=${authors//\"/}
authors=$(echo "$authors")
echo $authors

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


###################### Generalized Method #########################
# echo "Updating documentation..."
# sphinx-apidoc -f -o source ../src/spac

# echo "Generating html now..."
# make html

# cp -r build/html/* .
####################################################################

################### Independent Module Method ######################

echo "Updating documentation..."
# Generate individual .rst files for each module
sphinx-apidoc -f -o source --separate ../src/spac

echo "Updating index.rst..."
# Add module links to the index page
echo "   :caption: Contents:" >> source/index.rst
echo "" >> source/index.rst

# Generate a list of module names
modules=$(find source -name "*.rst" -type f | sed -e "s/^source\///" -e "s/\.rst$//")

for module in $modules; do
  echo "   $module" >> source/index.rst
done

echo "Generating HTML for each module..."
# Generate HTML for each module
for module in $modules; do
  echo "Generating HTML for $module..."
  make html MOD=$module
done

echo "Copying generated HTML for each module..."
# Copy generated HTML for each module
for module in $modules; do
  echo "Copying HTML for $module..."
  cp -r build/html/$module/* .
done

echo "Documentation generation completed."
