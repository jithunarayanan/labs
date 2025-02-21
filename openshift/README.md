# Kubernetes Lab Environment

### Introduction
This Kubernetes learning environment provides a solid foundation for hands-on exploration. By following these steps and leveraging the provided resources, you can effectively learn and master Kubernetes concepts.

Deploy the lab on AWS using Terraform or locally using Vagrant. Ansible is employed to automate the configuration of both the Kubernetes cluster and the workstation.

Utilized [K3s](https://k3s.io/), the lightweight Kubernetes distribution from Rancher, for this lab environment.

## Deployment

### AWS Deployment using Terraform

**Prerequisites**
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS Account and configured access key](https://docs.aws.amazon.com/cli/v1/userguide/cli-authentication-user.html#cli-authentication-user-create)
- [Terraform](https://developer.hashicorp.com/terraform/install)

**Usage**
Set up AWS credentials in your Terraform configuration or environment variables and execute the following commands in your terminal from the project root directory:

```sh
terraform init
terraform apply
```

### Local Deployment using Vagrant

**Prerequisites**
- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- [VirtualBox and Extension Pack](https://www.virtualbox.org/wiki/Download_Old_Builds_7_0)

**Usage**
Run Vagrant by executing the following command from the project root directory:

```sh
vagrant up
```

After the successful deployment, you can access your Kubernetes cluster.

### Sign in to the Environment

Once the environment is deployed, use SSH to connect to the workstation.

- In AWS deployment:
```sh
ssh ubuntu@<workstation_public_ip>
```
> **Note:** The workstation public IP will be displayed after the Terraform execution.

- In Local deployment:
```sh
vagrant ssh proxy
```

Check the Kubernetes Cluster using:

```sh
kubectl get nodes
kubectl get pods -A
```

### Destroy the Lab

To destroy the lab after the practice session:

- **Terraform:**
```sh
terraform destroy --auto-approve
```

- **Vagrant:**
```sh
vagrant destroy -f
```

*Happy learning!*
