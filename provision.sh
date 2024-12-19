# MIT License

# Original work copyright (c) 2024 MATSUU Takuto
# Original source: https://github.com/matsuu/aws-isucon/blob/main/isucon14/provision.sh
# Original repo: https://github.com/matsuu/aws-isucon/

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/bin/bash

set -ex

GITDIR="/tmp/isucon14"

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y --no-install-recommends ansible apt-utils curl make sudo
sudo snap install go --classic
sudo snap install node --classic
sudo npm install -g pnpm

sudo rm -rf ${GITDIR}
git clone --depth=1 https://github.com/isucon/isucon14.git ${GITDIR}

sed -i -e "s/_linux_amd64//" ${GITDIR}/provisioning/ansible/roles/bench/tasks/main.yaml
sed -i -e "/isuadmin-user/d" -e "/envcheck/d" ${GITDIR}/provisioning/ansible/application.yml
mkdir -p /etc/ssh/sshd_config.d

(
  cd ${GITDIR}/frontend
  make
  cp -r ./build/client ../webapp/public/
)
(

  cd ${GITDIR}/bench
  go build -buildvcs=false -ldflags "-s -w" -o ../provisioning/ansible/roles/bench/files/bench
)
(
  cd ${GITDIR}
  tar zcf provisioning/ansible/roles/webapp/files/webapp.tar.gz webapp
)

sudo npm uninstall -g pnpm
sudo snap remove node
sudo snap remove go

(
  cd ${GITDIR}/provisioning/ansible
  ansible-playbook -i inventory/localhost application-base.yml
  ansible-playbook -i inventory/localhost application.yml
  ansible-playbook -i inventory/localhost benchmark.yml
)
sudo rm -rf ${GITDIR}
sudo apt-get purge -y ansible
sudo apt-get autoremove -y
