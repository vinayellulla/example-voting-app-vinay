output "cluster_name" {
  description = "Name of the cluster"
  value       = aws_eks_cluster.solid_cluster.name
}

output "cluster_endpoint" {
  description = "Name of the Endpoint"
  value       = aws_eks_cluster.solid_cluster.endpoint
}

output "cluster_certificate" {
  description = "Name of the certificate"
  value       = aws_eks_cluster.solid_cluster.certificate_authority[0].data

  sensitive = true


}


output "vote_repository_url" {
  description = "URL for the vote repository"
  value       = aws_ecr_repository.vote.repository_url
}

output "result_repository_url" {
  description = "URL for the result repository"
  value       = aws_ecr_repository.result.repository_url
}

output "worker_repository_url" {
  description = "URL for the worker repository"
  value       = aws_ecr_repository.worker.repository_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.solid_vpc.id
}
