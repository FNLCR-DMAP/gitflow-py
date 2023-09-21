#!/bin/sh -l
# 5/22/23 Rui He
# rui.he@nih.gov

cd $1

current_dir="$1"

# Find all files under the /tests directory
all_test_files=($(find ./tests \
                      -type f \
                      -name "*.py" \
                      ! -name "*__*"))

# Print all the test to run file by file
echo -e "\nTests to run are: "
for test in ${all_test_files[@]};
do
  echo $test
done

test_records=()

for test_to_run in "${all_test_files[@]}"
do 
  echo "====================================================================="
  echo -e "\nTesting: $test_to_run"
  
  pytest_output=$(pytest $test_to_run 2>&1)

  # Check if "ERROR" is in the output
  if echo "$pytest_output" | grep -q "ERRORS"; then
      echo -e "\nTest failed\n"
      test_records+=("$test_to_run : Failed. ")
  else
      echo -e "\nTest passed\n"
      test_records+=("$test_to_run : Passed. ")
  fi

  echo "====================================================================="

done

echo "\n\nTseting Finished!"

for record in "${test_records[@]}";
do
  echo $record
done

# Check if any test has failed
if printf '%s\n' "${test_records[@]}" | grep -iE "failed"; then
    echo "At least one test has failed."
    # Exit with a non-zero status code indicating test failure
    exit 1
fi
