output "master_ip" {
  value = aws_instance.vh_k8s_master.public_ip
}

output "worker_ip" {
  value = aws_instance.vh_k8s_worker.public_ip
}

//output "node2_ip" {
//  value = aws_instance.vh_k8s_node_2.public_ip
//}
