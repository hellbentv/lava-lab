if test -z "$base"; then
  base="http://validation.linaro.org"
fi

passed=0
failed=0

pass() {
  local testname="$1"
  passed=$(($passed + 1))
  echo "\033[0;32;40m$testname: PASS\033[m"
}

fail() {
  local testname="$1"
  failed=$(($failed + 1))
  echo "\033[0;31;40m$testname: FAIL\033[m"
}

check_redirect() {
  local from="$1"
  local to="$2"
  local testname="${from} -> ${to}"
  if wget -S -O /dev/null "${base}${from}" 2>&1 | grep -q "Location: ${base}${to}\$"; then
    pass "${testname}"
  else
    fail "${testname}"
  fi
}

check_command() {
  local testname="$1"
  shift
  if $@; then
    pass "$testname"
  else
    fail "$testname"
  fi
}

################################################################

check_redirect /lava-server /
check_redirect /lava-server/ /
check_redirect /lava-server/foo /foo
check_redirect /lava-server/scheduler/device/vexpress-tc2-01 /scheduler/device/vexpress-tc2-01
check_redirect /lava-server/scheduler/job/63277 /scheduler/job/63277
check_redirect /lava-server/static/lava-server/css/default.css /static/lava-server/css/default.css
check_command "API: /RPC2/" python apitest.py "${base}/RPC2/"
check_command "API: /RPC2" python apitest.py "${base}/RPC2"
check_command "API: /lava-server/RPC2/" python apitest.py "${base}/lava-server/RPC2/"
check_command "API: /lava-server/RPC2" python apitest.py "${base}/lava-server/RPC2"

################################################################

exit $failed

