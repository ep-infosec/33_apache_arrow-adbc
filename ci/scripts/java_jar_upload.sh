#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -ex

main() {
    local -r source_dir="${1}"
    local settings_file=$(mktemp adbc.settingsXXXXXXXX.xml --tmpdir)
    trap 'rm -f "$settings_file"' ERR EXIT INT TERM

    if [[ -z "${GEMFURY_PUSH_TOKEN}" ]]; then
        echo "GEMFURY_PUSH_TOKEN must be set"
        exit 1
    fi

    pushd "${source_dir}/java"

    cat <<SETTINGS > "${settings_file}"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>fury</id>
      <username>${GEMFURY_PUSH_TOKEN}</username>
      <password>NOPASS</password>
      <configuration>
        <httpConfiguration>
          <all>
            <usePreemptive>true</usePreemptive>
          </all>
        </httpConfiguration>
      </configuration>
    </server>
  </servers>
</settings>
SETTINGS

    mvn \
        -Dmaven.install.skip=true \
        -Drat.skip=true \
        -DskipTests \
        --settings "${settings_file}" \
        deploy

    popd
}

main "$@"
