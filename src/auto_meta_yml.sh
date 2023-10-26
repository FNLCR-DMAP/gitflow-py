#!/bin/bash

# Check for the required arguments: repo_url, branch, doc_url, maintainers
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <repo_url> <branch> <python version> <doc_url> <maintainers (comma-separated)>"
    exit 1
fi

# Arguments
REPO_URL="$1"
BRANCH="$2"
PYTHON_VERSION="$3"
DOC_URL="$4"
MAINTAINERS="$5"

# Clone the repository
rm -rf temp_repo
git clone "$REPO_URL" temp_repo
cd temp_repo
git checkout "$BRANCH"

cat > extract_info.py <<EOL
import sys
from setuptools import setup

def interceptor(**kwargs):
    print(kwargs['name'])
    print(kwargs['version'])
    print(','.join(kwargs['install_requires']) if 'install_requires' in kwargs else 'NONE')
    print(kwargs['description'] if 'description' in kwargs else 'NONE')

    license_info = 'NONE'
    for classifier in kwargs.get('classifiers', []):
        if 'License ::' in classifier:
            license_info = classifier.split('::')[-1].strip()
            break
    print(license_info)

# Redirect the setup function
sys.modules['setuptools'].setup = interceptor

with open('setup.py', 'r') as f:
    exec(f.read())

EOL

# Extract package details using the interceptor
python3 ./extract_info.py > ./extracted_info.txt

# Read the extracted details
# Initialize a counter
COUNTER=0

# Loop through each line of the file
while IFS= read -r line
do
    # Increment the counter
    COUNTER=$((COUNTER + 1))

    # Assign values based on the current line number
    case $COUNTER in
        1)
            PACKAGE_NAME="$line"
            ;;
        2)
            PACKAGE_VERSION="$line"
            ;;
        3)
            DEPENDENCIES="$line"
            ;;
        4)
            DESCRIPTION="$line"
            ;;
        5)
            LICENSE="$line"
            ;;
    esac
done < extracted_info.txt
echo "Packge: $PACKAGE_NAME"
echo "Version: $PACKAGE_VERSION"
echo "Dependencies: "
# Convert the comma-separated string to a newline-separated string
FORMATTED_DEPENDENCIES=$(echo "$DEPENDENCIES" | tr ',' '\n')

while IFS= read -r dep; do
    echo "$dep"
done <<< "$FORMATTED_DEPENDENCIES"

echo "Summary: $DESCRIPTION"
echo "Licence: $LICENSE"
export SOURCE_URL="$REPO_URL/archive/$BRANCH.tar.gz"
echo "Source: $SOURCE_URL"

# Create meta.yaml
cat > meta.yaml <<EOL
package:
  name: $PACKAGE_NAME
  version: $PACKAGE_VERSION

source:
  Path: .

build:
  noarch: python
  script: python -m pip install . --no-deps -vv

channels:
  - conda-forge
  - defaults
  - leej3

requirements:
  host:
    - python==$PYTHON_VERSION
    - pip
    - setuptools
  run:
    - python
EOL

# Then you can add this to your meta.yaml using an appropriate method, for example:
while IFS= read -r dep; do
    echo "    - $dep" >> meta.yaml
done <<< "$FORMATTED_DEPENDENCIES"

# Continue creating meta.yaml
cat >> meta.yaml <<EOL

test:
  imports:
    - $PACKAGE_NAME

about:
  home: $REPO_URL
  license: $LICENSE
  license_file: LICENSE
  summary: $DESCRIPTION
  doc_url: $DOC_URL
  dev_url: $REPO_URL

extra:
  recipe-maintainers:
EOL

# Add maintainers to meta.yaml
IFS=','
for maintainer in $MAINTAINERS; do
    echo "    - $maintainer" >> meta.yaml
done

cat > build.sh <<EOL
#!/bin/bash

python -m pip install . --no-deps -vv
EOL

cat > bld.bat <<EOL
"%PYTHON%" -m pip install . --no-deps -vv
if errorlevel 1 exit 1
EOL

