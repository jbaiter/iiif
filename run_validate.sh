#!/bin/bash
#
# Designed to be run by Travis CI and so accumulates any error responses
# in $errors which is then used as the exit code. Exit code will be 
# zero for no errors.
#
# -v to be more verbose
# -d for debugging info
#
# See http://tldp.org/LDP/abs/html/arithexp.html for bash arithmetic

verbosity='--quiet'
show_test_name=false
while getopts "vd" opt; do
  case $opt in
    v)
      verbosity=''
      show_test_name=true
      ;;
    d)
      verbosity='--verbose'
      show_test_name=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Set up test server
./iiif_testserver.py --quiet 2>&1 > /dev/null &

# Run validations against test server
errors=0
if $show_test_name; then
  echo "Testing PIL manipulator, level 1.1"
fi
iiif-validate.py -s localhost:8000 -p 1.1_pil_none -i 67352ccc-d1b0-11e1-89ae-279075081939.png --version=1.1 --level 1 $verbosity
((errors+=$?))
if $show_test_name; then
  echo "Testing PIL manipulator, level 2.0"
fi
iiif-validate.py -s localhost:8000 -p 2.0_pil_none -i 67352ccc-d1b0-11e1-89ae-279075081939.png --version=2.0 --level 2 $verbosity
((errors+=$?))
#iiif-validate.py -s localhost:8000 -p 1.1_netpbm_none -i 67352ccc-d1b0-11e1-89ae-279075081939.png --version=1.1 --level 1 $verbosity
#((errors+=$?))
if $show_test_name; then
  echo "Testing netpbm manipulator, level 2.0"
fi
iiif-validate.py -s localhost:8000 -p 2.0_netpbm_none -i 67352ccc-d1b0-11e1-89ae-279075081939.png --version=2.0 --level 1 $verbosity
((errors+=$?))

# Kill test server
kill `cat iiif_testserver.pid`

if test $errors -eq 0; then
  msg="no errors"
else
  msg="$errors errors, use -v or -d for details"
fi
echo "$0 finished ($msg)"
exit $errors
