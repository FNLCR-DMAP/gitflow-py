#!/bin/bash

# ─── Prepare docs directory ────────────────────────────────────────────────
rm -rf docs
mkdir docs
cd docs

theme="sphinx_rtd_theme"
SRC_DIR="../src/spac"
DOC_DIR="./source"

# ─── Parse setup.py for metadata ───────────────────────────────────────────
echo "Parsing setup.py..."
setup_file="../setup.py"
version=$(grep -oP "version=['\"]\K[^'\"]+" "$setup_file")
name=$(grep -oP "name=['\"]\K[^'\"]+" "$setup_file")
authors=$(grep -oP "author=['\"]\K[^'\"]+" "$setup_file")
echo "Package Name: $name"
echo "Version:     $version"
echo "Authors:     $authors"

# ─── sphinx-quickstart ─────────────────────────────────────────────────────
echo "Running sphinx-quickstart..."
sphinx-quickstart -q --sep \
    --ext-autodoc \
    --makefile \
    -p="$name" \
    -a="$authors" \
    -v="$version" \
    -r="" \
    -l="en"

pip install m2r

# ─── Update conf.py ────────────────────────────────────────────────────────
echo "Updating conf.py..."
conf=source/conf.py

# add imports & sys.path
cat >> $conf <<'EOF'
import os
import sys
path = os.path.abspath('../../src')
sys.path.insert(0, path)
EOF

# append extensions, suffixes, autosummary, theme options
cat >> $conf <<EOF

extensions = [
    'sphinx.ext.napoleon',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosectionlabel',
    'sphinx.ext.todo',
    'sphinx.ext.viewcode',
    'sphinx.ext.githubpages',
    'sphinx.ext.autosummary',
    'm2r'
]
autosummary_generate  = True
source_suffix        = ['.rst', '.md']
html_theme           = "$theme"
html_theme_options   = {
    'collapse_navigation': False,
    'navigation_depth': 3,
    'sticky_navigation': True,
    'titles_only': True,
    'style_external_links': True,
}

# add our custom CSS
html_static_path = ['_static']
html_css_files  = ['custom.css']
EOF

# ─── 3b) Write the custom.css ──────────────────────────────────────────
mkdir -p source/_static
cat > source/_static/custom.css <<'EOF'
/* bold & fully opaque the level-2 toctree links */
.wy-nav-content ul.toctree-l2 li a {
    font-weight: 600 !important;
    opacity: 1 !important;
}
EOF

# ─── Generate module stubs under source/modules ────────────────────────────
echo "Generating API docs under source/modules..."
rm -rf source/modules
sphinx-apidoc \
  --force \
  --module-first \
  --separate \
  -o source/modules \
  "$SRC_DIR"

# ─── 5) Append a “Functions” toctree + emit per‐function stubs ───────────
echo "Adding Functions sections…"
for module_py in $SRC_DIR/*.py; do
  mod=$(basename "$module_py" .py)
  mod_rst="$DOC_DIR/modules/spac.$mod.rst"

  # only if sphinx-apidoc actually created it
  if [[ -f "$mod_rst" ]]; then
    funcs=$(grep -Po '^def \K\w+' "$module_py" || true)
    if [[ -n "$funcs" ]]; then
      cat >> "$mod_rst" <<EOF

Functions
---------

.. toctree::
   :maxdepth: 1

EOF
      for f in $funcs; do
        echo "   ${mod}.${f}" >> "$mod_rst"

        # create a stub file with an explicit heading (no parentheses)
        stub="$DOC_DIR/modules/${mod}.${f}.rst"
        underline="$(printf '%*s' "${#f}" '' | tr ' ' '-')"
        cat > "$stub" <<EOF
${f}
${underline}

.. autofunction:: spac.${mod}.${f}
EOF
      done
    fi
  fi
done

# ─── 6) Build an index of sub-modules ───────────────────────────────────
cat > $DOC_DIR/modules/index.rst <<EOF
spac modules
============

.. toctree::
   :maxdepth: 1

EOF

for f in $DOC_DIR/modules/spac.*.rst; do
  name=$(basename "$f" .rst)
  echo "   $name" >> $DOC_DIR/modules/index.rst
done

# ─── 7) Rewrite the root index.rst ─────────────────────────────────────
cat > $DOC_DIR/index.rst <<EOF
.. mdinclude:: ../../README.md

API Reference
=============

.. toctree::
   :maxdepth: 2

   modules/index
EOF

# ─── 8) Build the HTML + copy to docs root ─────────────────────────────
echo "Building HTML…"
make html

echo "Copying HTML + assets…"
cp -r build/html/* ./

# ensure GitHub Pages serves the _static folder
cp build/html/.nojekyll ./

echo "✅ Documentation updated."
