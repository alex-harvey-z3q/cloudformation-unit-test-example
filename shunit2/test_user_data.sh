#!/usr/bin/env bash

cloudformation_yml='cloudformation.yml'
user_data_path='.Resources.EC2Instance.Properties.UserData."Fn::Base64"'

oneTimeSetUp() {
  yq -r "$user_data_path" "$cloudformation_yml" | sed -E '
    s/\${!([^}]*)}/${\1}/g
  ' > temp.sh
}

oneTimeTearDown() {
  rm -f temp.sh
}

testMinusN() {
  assertTrue "bash -n returned an error" "bash -n temp.sh"
}

testShellCheck() {
  local exclusions='SC2154'
  shellcheck --exclude="$exclusions" temp.sh
  assertTrue "ShellCheck returned an error" "$?"
}

testConfigureIndexHtml() {
  . temp.sh
  index='./test_index.html'
  configure_index_html > /dev/null
  assertTrue "$index did not contain expected pattern" "grep -q CloudFormation $index"
  rm -f "$index"
}

. shunit2
