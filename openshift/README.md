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
Once the environment is deployed,

Check the Kubernetes Cluster using:

```sh
kubectl get nodes
kubectl get pods -A
```
### Destroy the Lab

To destroy the lab after the practice session:

```sh
terraform destroy --auto-approve
```

### Local Deployment using Vagrant

**Prerequisites**
- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- [VirtualBox and Extension Pack](https://www.virtualbox.org/wiki/Download_Old_Builds_7_0)

Once the environment is deployed,

Check the Kubernetes Cluster using:

```sh
cd vagrant
vagrant up
```
After the successful deployment, you can access your Kubernetes cluster.

Check the Kubernetes Cluster using:

```sh
kubectl get nodes
kubectl get pods -A
```

### Destroy the Lab

To destroy the lab after the practice session:

```sh
vagrant destroy -f
```

*Happy learning!*