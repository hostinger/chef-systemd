#
# Cookbook Name:: systemd
# Recipe:: coredump
#
# Copyright 2015 The Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

c = node['systemd']['coredump']

systemd_coredump 'coredump' do
  drop_in false
  storage c['storage']
  compress c['compress']
  process_size_max c['process_size_max']
  external_size_max c['external_size_max']
  journal_size_max c['journal_size_max']
  max_use c['max_use']
  keep_free c['keep_free']
end
