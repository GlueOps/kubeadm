all:
  children:
    loadbalancer:
      hosts:
      %{ for index, vm in loadbalancer_ipv4_address }
        lb-node-${index}:
          ansible_host: ${vm.public}
          ansible_user: haproxyadmin
          ip: ${vm.private}
          ansible_ssh_private_key_file: ./keys/lb_node
      %{ endfor }
    masters:
      hosts:
      %{ for index, vm in master_ipv4_addresses }
        master-node-${index}:
          ansible_host: ${vm.public}
          ansible_user: cluster
          ip: ${vm.private}
          ansible_ssh_private_key_file: ./keys/master_node
          extra:
            taints:
              - node-role.kubernetes.io/control-plane:NoSchedule-
      %{ endfor }
    workers:
      hosts:
      %{ for index, vm in worker_ipv4_addresses }
        worker-node-${index}:
          ansible_host: ${vm.public}
          ansible_user: cluster
          ip: ${vm.private}
          ansible_ssh_private_key_file: ./keys/worker_node
          extra:
            taints:
              - glueops.dev/role=glueops-platform:NoSchedule
      %{ endfor }