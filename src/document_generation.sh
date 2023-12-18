#!/bin/bash

mkdir docs/
cd docs/
theme="sphinx_rtd_theme"

# Define the source and destination directories
SRC_DIR="../src/spac"
DOC_DIR="./source"

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

pip install m2r

echo "Updating Configuration..."

# Update Sphinx configuration
echo "import os" >> source/conf.py
echo "import os" >> source/conf.py
echo "import sys" >> source/conf.py
echo "path = os.path.abspath('../../src')" >> source/conf.py
echo "sys.path.insert(0,path)" >> source/conf.py
echo "extensions = [
	'sphinx.ext.napoleon',
	'sphinx.ext.autodoc',
	'sphinx.ext.autosectionlabel',
	'sphinx.ext.todo',
	'sphinx.ext.viewcode',
	'sphinx.ext.githubpages',
	'm2r']" >> source/conf.py
echo "source_suffix = ['.rst', '.md']" >> source/conf.py
sed -i "s/^html_theme = .*/html_theme = \"$theme\"/" source/conf.py
echo "html_theme_options = {
    'collapse_navigation': False,
    'navigation_depth': 4,
    'sticky_navigation': True,
    'titles_only': False,
    'style_external_links': True,
}" >> source/conf.py

###################### Generalized Method #########################
echo "Updating documentation..."
sphinx-apidoc -f -o source "$SRC_DIR"

# sed -i 's/:maxdepth: 2/:maxdepth: 3/' source/index.rst

# # Include README.md on the landing page
# echo ".. mdinclude:: ../../README.md" >> source/index.rst

cat > source/index.rst <<EOF
${name^^} Documentation
===============================

.. mdinclude:: ../../README.md

.. toctree::
   :maxdepth: 4

   self
   modules

EOF

# Loop through the Python module files in the source directory
for MODULE in $(find "$SRC_DIR" -type f -name "*.py" ! -name "__init__.py"); do
  # Extract the module name without the path and .py extension
  MODULE_NAME=$(basename "$MODULE" .py)
  # Define the path to the rst file
  RST_FILE="$DOC_DIR/${MODULE_NAME}.rst"

  # Write the automodule directive to the rst file
  echo ".. automodule:: spac.$MODULE_NAME" > "$RST_FILE"
  echo "   :members:" >> "$RST_FILE"
  echo "   :undoc-members:" >> "$RST_FILE"
  echo "   :show-inheritance:" >> "$RST_FILE"
  echo "" >> "$RST_FILE"

  # Optionally, add the module to the main index.rst toctree
  # You can uncomment the following line if you want to do this automatically
  # echo "   ${MODULE_NAME}" >> "$DOC_DIR/index.rst"

  echo "Updated documentation for $MODULE_NAME"
done

echo "All submodules have been updated."

echo "Generating html now..."
make html

cp -r build/html/* ./

echo "Documentation generation completed."
###################################################################
