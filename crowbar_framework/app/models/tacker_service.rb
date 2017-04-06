#
# Copyright 2016, SUSE LINUX Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class TackerService < ServiceObject
  def initialize(thelogger)
    super(thelogger)
    @bc_name = "tacker"
  end

  class << self
    def role_constraints
      {
        "tacker" => {
          "unique" => false,
          "count" => -1,
          "admin" => false,
          "exclude_platform" => {
            "windows" => "/.*/"
          }
        }
      }
    end
  end

  def create_proposal
    @logger.debug("tacker create_proposal: entering")
    base = super

    nodes = NodeObject.all
    # Don't include the admin node by default, you never know...
    nodes.delete_if { |n| n.nil? || n.admin? }

    @logger.debug("Do we arrive here?")
    # Ignore nodes that are being discovered
    controller_nodes = nodes.select { |n| n.intended_role == "controller" }
    base["deployment"]["tacker"]["elements"] = {
      "tacker" => controller_nodes.map { |x| x[:fqdn] }
    }

    base["attributes"][@bc_name]["db"]["password"] = random_password

    @logger.debug("tacker create_proposal: exiting")
    base
  end
end
