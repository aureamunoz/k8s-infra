#!/bin/bash

version=3.11
hostIP=$(hostname -I | awk '{print $1}')

echo "Install needed yum packages: docker git wget ansible NetworkManager"
yum install -y -q docker git wget ansible NetworkManager

echo "Enable docker and Network manager"
systemctl enable NetworkManager
systemctl start NetworkManager

systemctl enable docker
systemctl start docker

until [ "$(systemctl is-active docker)" = "active" ]; do echo "Wait till docker daemon is running"; sleep 10; done;

echo "Cloning Snowdrop Infra Playbook"
git clone https://github.com/snowdrop/openshift-infra.git /tmp/infra 2>&1

echo "Creating Ansible inventory file"
echo -e "[masters]\nlocalhost ansible_connection=local ansible_user=root" > /tmp/infra/ansible/inventory/hetzner_vm

echo "Pulling Origin docker images for version v${version}"
docker pull quay.io/openshift/origin-node:v${version}
docker pull quay.io/openshift/origin-control-plane:v${version}
docker pull quay.io/openshift/origin-haproxy-router:v${version}
docker pull quay.io/openshift/origin-hyperkube:v${version}
docker pull quay.io/openshift/origin-deployer:v${version}
docker pull quay.io/openshift/origin-pod:v${version}
docker pull quay.io/openshift/origin-hypershift:v${version}
docker pull quay.io/openshift/origin-cli:v${version}
docker pull quay.io/openshift/origin-docker-registry:v${version}
docker pull quay.io/openshift/origin-web-console:v${version}
docker pull quay.io/openshift/origin-service-serving-cert-signer:v${version}

echo "Starting playbook"
cd /tmp/infra/ansible
ansible-playbook -i ./inventory/hetzner_vm playbook/cluster.yml \
    -e openshift_release_tag_name="v${version}.0" \
    -e public_ip_address="${hostIP}" \
    -e cluster_cmd_log_level=2 \
    -e cluster_skip_registry_check="false" \
    --tags "up" \
    2>&1

echo "Enable cluster-admin role for admin user"
ansible-playbook -i ./inventory/hetzner_vm playbook/post_installation.yml \
     -e openshift_admin_pwd=admin \
     --tags "enable_cluster_role"

exit 0
