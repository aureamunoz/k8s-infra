# Instructions to install OpenShift using the Ansible OpenShift playbook 

## Prerequisite

  - Linux VM (CentOS7, ...) running, that you can ssh on port 22 and where your public key has been imported
  - Ansible [=2.7](http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (Note that Ansible 2.8 will **not** work properly on the `openshift-ansible` playbooks)  

## Instructions

- First git clone the `OpenShift Ansible` project locally using the branch corresponding to the version of ocp you want to install

  ```bash
  echo "#### Git clone openshift ansible"
  if [ ! -d "openshift-ansible" ]; then
    git clone -b release-3.11 https://github.com/openshift/openshift-ansible.git
  fi
  ```

- Generate the inventory host file containing the parameters used by the `openshift` like the IP address of the VM to ssh.

  ```bash
  ansible-playbook playbook/generate_inventory.yml -e ip_address=192.168.99.50
  ```
  
  **WARNING**: Take care to supply the correct IP address in the corresponding argument !
  
  The inventory is later user by the [official](https://github.com/openshift/openshift-ansible) Openshift Ansible installation playbook to customize the setup
  If you would like to change some of the options, then first modify the template file located here - `roles/generate_inventory/templates/cloud.inventory.j2`
  before running the `playbook/generate_inventory.yml` role
  
  Furthermore, the above command will generate an inventory file that will use `root` as `ansible_user`.
  If another user other than `root` is to be used for accessing the machine over ssh, you can pass the `username` variable like so:
  
  ```bash
  ansible-playbook playbook/generate_inventory.yml -e ip_address=192.168.99.50 -e username=centos
  ```
  
- Optional: Add any other user public keys to allow those users to ssh into the target machine

  The usernames supplied need to be valid GitHub usernames that have Public Keys uploaded to their accounts, 
  since those public keys will be downloaded from GitHub and added to the list of authorized keys 
  that can access the machine

  ```bash
  ansible-playbook -i inventory/cloud_host playbook/import_public_key.yml -e '{gh_usernames: [foo, bar]}'
  ```   

- Install OpenShift

  Execute the following Ansible commands to first check if the VM where OpenShift must be installed conforms to the prerequisites and next download the docker images, create the etc service, ...
  
  ```bash
  ansible-playbook -i inventory/cloud_host openshift-ansible/playbooks/prerequisites.yml
  ansible-playbook -i inventory/cloud_host openshift-ansible/playbooks/deploy_cluster.yml
  ```
  
  If the `ansible_user` that is has been set in the inventory is not `root`, then the `--become` flag needs to be added to both
  of the above commands 
  
  **REMARK** : Customization of the installation (inventory file generated) is possible by changing the variables found in `inventory/cloud_host` from the command line using Ansible's `-e` syntax.
  
- To renew the certificates

  If, when you push a binary file, you get a `Internal error occurred: error dialing backend: x509: certificate has expired or is not yet valid"`, then it is most
  probably due to certificates expired on the ocp cluster.
  
  So, check the status of the certificates using this bash command executed within the vm `for i in /etc/origin/master/*.crt; do echo $i; openssl x509 -in $i -noout -enddate; done`
  or execute the following ansible playbook which is responsible to produce a HTML report under `$HOME/cert-expiry-report.20191128T173443.html`
  ```bash
  ansible-playbook -v -i inventory/hetzner_host openshift-ansible/playbooks/openshift-checks/certificate_expiry/easy-mode.yaml
  ```
  To renew the certificates, then execute this command
  ```bash
  ansible-playbook -v -i inventory/hetzner_host openshift-ansible/playbooks/redeploy-certificates.yml
  ```
  
- Setup DNS

  Execute 

  ```bash
  ansible-playbook -i inventory/cloud_host playbook/dns.yml  
  ```
  
  If the `ansible_user` that is has been set in the inventory is not `root`, then the `--become` flag needs to be added to both
  of the above commands
  
  Check out the [docs](https://docs.okd.io/latest/install/prerequisites.html#prereq-dns) to see more about why this is needed.    
