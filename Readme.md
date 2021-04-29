Content  
1. [Build AWS infrastructure using Terraform](#aws-infrastructure)  
2. [Install kubernetes cluster using Ansible](#install-k8s)
3. [DEPRECATED!!! Deploy docker image to your workers (pods)](#deploy-k8s)
4. [Test AWS ELB using local nginx proxy](#nginx)

---

# <a name="aws-infrastructure"></a>1. Build AWS infrastructure using Terraform

## IMPORTANT!!! master node in AWS is of type `t3.small`  - additional costs might be charged!

### Move into terraform directory  
```shell
cd terraform
```

### Init terraform project  
```shell
terraform init
```

### Build AWS infrastructure using terraform  
```shell
terraform apply
```

confirm with `yes` the intention to build the infrastructure.

At the end it will output the IP's of the created master and nodes instances:

```
master_ip = 3.239.171.37
node1_ip = 3.235.98.92
node2_ip = 100.27.43.219
```

Update ansible hosts file `./ansible/hosts` and provide the IP's accordingly


---

# <a name="install-k8s"></a>2. Install kubernetes cluster using Ansible

Make sure you have the hosts files update with the IPs you've got from terraform infrastructure  
Make sure the ssh key `./ansible/ssh/id_rsa` has the `chmod 400`  

### Add ssh key to your known hosts  
```shell
ssh ubuntu@IP -i ssh/id_rsa
```

### Move into ansible directory  
```shell
cd ansible
```

### Creating a Non-Root User on All Remote Servers  
```shell
ansible-playbook -i ./hosts --key-file "./ssh/id_rsa" ./initial.yml
```

Install kubernetes dependencies:  
```shell
ansible-playbook -i ./hosts --key-file "./ssh/id_rsa" ./k8s-dependencies.yml
```

### Setting Up the Master Node  
```shell
ansible-playbook -i ./hosts --key-file "./ssh/id_rsa" ./k8s-master.yml
```

### To check the status of the master node, SSH into it with the following command:  
```shell
ssh ubuntu@master_ip
```
  
```shell
kubectl get nodes
```

Output

| NAME   | STATUS | ROLES  | AGE | VERSION |
| -------|--------|--------|-----|---------|
| master | Ready  | master | 1d  | v1.14.0 |


### Setting Up the Worker Nodes  
```shell
ansible-playbook -i ./hosts --key-file "./ssh/id_rsa" ./k8s-workers.yml
```

### Verifying the Cluster  
```shell
ssh ubuntu@master_ip
```
  
```shell
kubectl get nodes
```

Output

| NAME    | STATUS | ROLES        | AGE | VERSION |
| --------|--------|--------------|-----|---------|
| master  | Ready  | master       | 1d  | v1.14.0 |
| worker1 | Ready  | &lt;none&gt; | 1d  | v1.14.0 |
| worker2 | Ready  | &lt;none&gt; | 1d  | v1.14.0 |


---

# <a name="deploy-k8s"></a>3. Deploy docker image to your workers (pods)

### SSH into `master` node  
```shell
ssh ubuntu@master_ip
```

### copy the files (or create them on the instance using vim/nano) on the master node
```
./k8s/deploymeny.yaml
./k8s/db-service-external.yaml
./k8s/petclinic-service.yaml
```

### Create the deployment scenario, and deploy the docker image to your workers/pods
Update in the file `deployment.yaml` the following line:
```yaml
...
image: AWS_ECR_IMAGE:VERSION
...
```
where `AWS_ECR_IMAGE` is the endpoint of your docker image within AWS ECR service  
and `VERSION` is the version of the image to be deployed.  

Create deployment  
```shell
kubectl apply -f deploymeny.yaml
```
  
### Create a service of the deployed docker image(s) and expose it to be accessible from outside the k8s cluster  
```shell
kubectl apply -f petclinic-service.yaml
```

After this, you can check the running app using your EC2's IPs and the port `30002`: http://IP:30002  
Port is specified, and can be changed, within the file `petclinic-service.yaml` line  
```yaml
...
nodePort: 30002
...
```

  
### Some useful k8s commands:
check deployment  
```shell
kubectl get deployments
```

check pods
```shell
kubectl get pods -o wide
```

get pod logs
```shell
kubectl logs POD_NAME 
```

get pods from a specific namespace
````shell
kubectl get pods -n NAMESPACE_NAME
````

delete pod from a specific namespace
````shell
kubectl delete pod POD_NAME -n NAMESPACE_NAME
````

ssh into pod  
```shell
kubectl exec --stdin --tty POD_NAME -- /bin/bash
```
  
  
[k8s cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)


---

# <a name="nginx"></a>4. Test AWS ELB using local nginx proxy

### Add host entry into your local `hosts` file
````shell
sudo vim /etc/hosts
````
  
Add new line at teh end of the file (press `i` for insert mode)  
````shell
127.0.0.1 vh.md.md
````
press `Esc` (to exit the insert mode), and save and exit the file: `:wq` and Enter

### Move into `web` folder  
````shell
cd ./web
````

### Build docker image based using `Dockerfile`  
```shell
docker image build -t nginx-proxy .
```

### Create and run docker container for nginx-proxy  
````shell
docker container run -it -p 80:80 --name nginx-proxy nginx-proxy:latest
````

### Run already existing nginx-proxy container  
````shell
docker container start nginx-proxy
````
