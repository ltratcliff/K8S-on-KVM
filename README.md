# Create a K8S cluster on KVM/QEMU


## Prerequisites
Must have KVM/QEMU installed on your machine. If not, you can install it by running the following command:
```bash
sudo apt-get install qemu-kvm libvirt-bin bridge-utils virt-manager
```

Must have a RHEL KVM (qcow2) image. If not, you can download it from the following link: [RHEL KVM Image](https://access.redhat.com/downloads/content/rhel)

Must have a RHEL subscription. If not, you can get a free developer subscription from the following link: [RHEL Developer Subscription](https://developers.redhat.com/articles/getting-red-hat-developer-subscription-what-rhel-users-need-know)

Must have Terraform (or opentofu) installed on your machine. If not, you can install it by running the following command:
```bash
sudo apt-get install opentofu
```

Must have Ansible installed on your machine. If not, you can install it by running the following command:
```bash
sudo apt-get install ansible
```

Must have the community.general collection installed. If not, you can install it by running the following command:
```bash
ansible-galaxy collection install community.general
```

## Steps
1. Clone the repository
```bash
git clone ${URL}
```

2. Change directory to the cloned repository
```bash
cd ${REPO}
```

3. Terraform init
```bash
terraform init
```

4. Terraform plan
```bash
terraform plan
```

5. Terraform apply
```bash
terraform apply
```

6. Run post_tf.sh to create ansible inventory file
```bash
./post_tf.sh
```

7. Run ansible playbook
```bash
ansible-playbook -i inventory setup_k8s.yml -extra-vars 
"subscription_username=${SUBSCRIPTION_USERNAME} subscription_password=${SUBSCRIPTION_PASSWORD}"
```

8. Profit
