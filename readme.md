# to install kubernetes
run the following things need to be added before 

inventory/groups_vars

certificate_key: 
random_token: 


`export ANSIBLE_ROLES_PATH=$PWD/roles`
`export ANSIBLE_HOST_KEY_CHECKING=False`


create a folder keys that contains ssh_keys and replace public_key for each host with your public_key 

first  add taints and labels to your nodes, for each node you need to have the following format:

```yaml
masters:
    hosts:
    master-node-1:
        ansible_host: 138.199.157.180
        ansible_user: cluster
        ip: 10.0.0.31
        ansible_ssh_private_key_file: ./keys/master_node
        extra:
        taints:
            - node-role.kubernetes.io/control-plane:NoSchedule-
        labels:
            - glueops.dev/role=glueops-platform
```

Now to setup the cluster run:

`ansible-playbook -i inventory/hosts.yaml playbooks/setup-cluster.yaml`

after the playbook run successfully, you will kubeconfig file in `ansible/playbooks/.kube/config`


# scale the nodes

we treat the hosts.yaml as the source of truth to our resources, so to scale up or down the nodes, it will be enough to modify the follow the hosts.yaml file

example, the current hosts.yaml is:

```yaml

workers:
    hosts:
        worker-node-1:
            ansible_host: 138.199.157.195
            ansible_user: cluster
            ip: 10.0.0.21
            ansible_ssh_private_key_file: ./keys/worker_node
            extra:
            taints:
                - glueops.dev/role=glueops-platform:NoSchedule

        worker-node-2:
            ansible_host: 138.199.163.163
            ansible_user: cluster
            ip: 10.0.0.22
            ansible_ssh_private_key_file: ./keys/worker_node
            extra:
            taints:
                - glueops.dev/role=glueops-platform:NoSchedule

```

If we need to scale it up, we can just add another worker node

```yaml
workers:
    hosts:
        worker-node-1:
            ansible_host: 138.199.157.195
            ansible_user: cluster
            ip: 10.0.0.21
            ansible_ssh_private_key_file: ./keys/worker_node
            extra:
                taints:
                    - glueops.dev/role=glueops-platform:NoSchedule

        worker-node-2:
            ansible_host: 138.199.163.163
            ansible_user: cluster
            ip: 10.0.0.22
            ansible_ssh_private_key_file: ./keys/worker_node
            extra:
                taints:
                    - glueops.dev/role=glueops-platform:NoSchedule

        worker-node-3:
            ansible_host: 138.199.163.164
            ansible_user: cluster
            ip: 10.0.0.23
            ansible_ssh_private_key_file: ./keys/worker_node
            extra:
                taints:
                    - glueops.dev/role=glueops-platform:NoSchedule

```

or to scale down we remove the desired worker node

Note: you can both scale up and down at the same time, but if you do it, we will run the scale up first then scale down

Note: the number of control-plane nodes need to be odd number 

Now to run the syncing process, use the following command:

`ansible-playbook  -i inventory/hosts.yaml playbooks/sync-resources.yaml`

you will prompted with following message:

```txt
ok: [master-node-1] => {
    "msg": [
        "Nodes to remove: '[]'.",
        "Nodes to add '['worker-node-3']'."
    ]
}

TASK [master : pause] ****************************************************************************************************************************************************************************************************************************************
[master : pause]
Do you want to apply the above changes? (Y/n):

```

after you accept changes the kubernetes cluster will scale up/down depends on your desired state, also it will update the loadbalancer haproxyconfig file to the desired workloads

to verify, run `kubectl get nodes`


# upgrade cluster

## rotate certs

ansible-playbook  -i inventory/hosts.yaml playbooks/upgrade-cluster.yaml --tags rotate-certs


## upgrade versions

this will update the whole cluster versions

ansible-playbook  -i inventory/hosts.yaml playbooks/upgrade-cluster.yaml --tags upgrade


## OS security patch

to patch os with the security patches run :
`ansible-playbook  -i inventory/hosts.yaml playbooks/os-patch.yaml`

## updates