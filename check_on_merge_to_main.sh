#!/bin/sh -l

cd $1

current_dir="$1"

# Gather all python script except for 
# __init__.py under test dir
all_test_files=($(find ./tests \
                      -type f \
                      -name "*.py" \
                      ! -name "*__*"))

echo -e "\nTests to run are: "
for test in ${all_test_files[@]};
do
  echo $test
done

test_records=()

# Use pytest to perform unit tests
for test_to_run in "${all_test_files[@]}"
do 
  echo "\nTesting: $test_to_run"
  
  echo "====================================================================="
  
  pytest $test_to_run
  
  echo "====================================================================="

  pytest_exit_status=$?

  if [ $pytest_exit_status -eq 0 ]; then
      echo "\nTest passed\n"
      test_records+=("$test_to_run : Passed. ")
  else
      echo "\nTest failed\n"
      test_records+=("$test_to_run : Failed. ")
  fi
done

echo "\n\nTseting Finished!"

for record in "${test_records[@]}";
do
  echo $record
done

# Raise error on failure
if printf '%s\n' "${test_records[@]}" | grep -q "Failed\."; then
    echo "At least one test has failed."
    exit 1
fi
