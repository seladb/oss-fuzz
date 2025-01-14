#!/bin/bash -eu
#
# Copyright 2020 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

PCAPPLUSPLUS_BUILD_DIR=build
TARGETS_DIR=$PCAPPLUSPLUS_BUILD_DIR/Tests/Fuzzers

# Build libpcap
cd $SRC/libpcap/
./configure --enable-shared=no
make -j$(nproc)

# Build PcapPlusPlus linking statically against the built libpcap
cd $SRC/PcapPlusPlus
cmake -S . -B $PCAPPLUSPLUS_BUILD_DIR -DPCAPPP_BUILD_FUZZERS=ON -DPCAPPP_BUILD_EXAMPLES=OFF -DPCAP_ROOT=$SRC/libpcap/
cmake --build $PCAPPLUSPLUS_BUILD_DIR -j$(nproc)

# Copy target and options
cp $TARGETS_DIR/FuzzTarget $OUT
cp $(ldd $OUT/FuzzTarget | cut -d" " -f3) $OUT
cp $SRC/default.options $OUT/FuzzTarget.options

# Copy corpora
cd $SRC/tcpdump
zip -jr FuzzTarget_seed_corpus.zip tests/*.pcap
cp FuzzTarget_seed_corpus.zip $OUT/
