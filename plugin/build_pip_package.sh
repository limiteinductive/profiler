#!/bin/bash
# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
if [ -z "${RUNFILES}" ]; then
  if [ "$(uname)" = "MSYS_NT-10.0-20348" ]; then
    runfiles_dir="$(cygpath "$0")"
    RUNFILES="$(CDPATH= cd -- "$runfiles_dir.runfiles" && pwd)"
    build_workspace="$(cygpath "$BUILD_WORKSPACE_DIRECTORY")"
    dest="/c/tmp/profile-pip"
  else
    RUNFILES="$(CDPATH= cd -- "$0.runfiles" && pwd)"
    build_workspace="$BUILD_WORKSPACE_DIRECTORY"
    dest="/tmp/profile-pip"
  fi
fi

if [ "$(uname)" = "Darwin" ]; then
  sedi="sed -i ''"
  cpio="cpio --insecure -updL"
else
  sedi="sed -i"
  cpio="cpio -updL"
fi

PLUGIN_RUNFILE_DIR="${RUNFILES}/org_xprof/plugin"
FRONTEND_RUNFILE_DIR="${RUNFILES}/org_xprof/frontend"
ROOT_RUNFILE_DIR="${RUNFILES}/org_xprof/"

mkdir -p "$dest"
cd "$dest"

# Copy root README for pip package
cp "$ROOT_RUNFILE_DIR/README.md" README.md

# Copy plugin python files.
cd ${PLUGIN_RUNFILE_DIR}
find . -name '*.py' |  $cpio $dest
cd $dest
chmod -R 755 .
cp ${build_workspace}/bazel-bin/plugin/tensorboard_plugin_profile/protobuf/*_pb2.py tensorboard_plugin_profile/protobuf/

find tensorboard_plugin_profile/protobuf -name \*.py -exec $sedi -e '
    s/^from plugin.tensorboard_plugin_profile/from tensorboard_plugin_profile/
  ' {} +

cp ${build_workspace}/bazel-bin/external/org_tensorflow/tensorflow/python/profiler/internal/_pywrap_profiler_plugin.so tensorboard_plugin_profile/convert/

# Copy static files.
cd tensorboard_plugin_profile
mkdir -p static
cd static
cp "$PLUGIN_RUNFILE_DIR/tensorboard_plugin_profile/static/index.html" .
cp "$PLUGIN_RUNFILE_DIR/tensorboard_plugin_profile/static/index.js" .
cp "$PLUGIN_RUNFILE_DIR/tensorboard_plugin_profile/static/materialicons.woff2" .
cp "$PLUGIN_RUNFILE_DIR/trace_viewer/trace_viewer_index.html" .
cp "$PLUGIN_RUNFILE_DIR/trace_viewer/trace_viewer_index.js" .
cp -LR "$FRONTEND_RUNFILE_DIR/bundle.js" .
cp -LR "$FRONTEND_RUNFILE_DIR/styles.css" .
cp -LR "$FRONTEND_RUNFILE_DIR/zone.js" .
