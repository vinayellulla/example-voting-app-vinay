
resource "aws_ecr_repository" "vote" {

  name                 = "voting-app/vote"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

}

resource "aws_ecr_repository" "result" {

  name                 = "voting-app/result"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

}

resource "aws_ecr_repository" "worker" {

  name                 = "voting-app/worker"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_lifecycle_policy" "vote_lifecycle" {
  repository = aws_ecr_repository.vote.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "result_lifecycle" {
  repository = aws_ecr_repository.result.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "worker_lifecycle" {
  repository = aws_ecr_repository.worker.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
