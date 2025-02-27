resource "hcloud_server" "worker-node" {
  for_each = toset([for i in range(1, 3) : tostring(i)])
  # The name will be worker-node-0, worker-node-1, worker-node-2...
  name        = "worker-node-${each.key}"
  image       = "ubuntu-24.04"
  server_type = "cx22"
  location    = var.location
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.private_network.id
    ip         = "10.0.0.2${each.key}"
  }
  user_data = file("${path.module}/cloudinit/cloud-init-worker.yaml")

  depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_server.master-node]
  firewall_ids = [hcloud_firewall.workerfirewall.id]
}


resource "hcloud_firewall" "workerfirewall" {
  name = "worker-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "any"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "any"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
