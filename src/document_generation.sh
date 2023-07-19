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
echo "extensions = ['sphinx.ext.napoleon']" >> source/conf.py

# Adding theme. Currentlu using
# Read the Docs Sphinx Theme 

sed -i "s/^html_theme = .*/html_theme = \"$theme\"/" source/conf.py

# Enable HTML theme options
echo "html_theme_options = {" >> source/conf.py
echo "    'canonical_url': ''," >> source/conf.py
echo "    'analytics_id': ''," >> source/conf.py
echo "    'logo_only': False," >> source/conf.py
echo "    'display_version': True," >> source/conf.py
echo "    'prev_next_buttons_location': 'bottom'," >> source/conf.py
echo "    'style_external_links': False," >> source/conf.py
echo "    'style_nav_header_background': '#2980B9'," >> source/conf.py
echo "    # Toc options" >> source/conf.py
echo "    'collapse_navigation': True," >> source/conf.py
echo "    'sticky_navigation': True," >> source/conf.py
echo "    'navigation_depth': 3," >> source/conf.py
echo "    'includehidden': True," >> source/conf.py
echo "    'titles_only': False" >> source/conf.py
echo "}" >> source/conf.py

sed -i '/:caption: Contents:/a \\n\tmodules' source/index.rst

echo -e ".. |home| replace:: :fontawesome-solid-home:`\uf015`" >> source/index.rst
echo -e "\n|home|_ [Return to Home](index.html)\n" >> source/index.rst


echo "Updating documentation..."
sphinx-apidoc -f -o source ../src/spac

echo "Generating html now..."
make html

cp -r build/html/* .
