# ##############################################
# # Flux CD Installation via Helm
# ##############################################

# resource "helm_release" "flux" {
#   name             = "flux2"
#   repository       = "https://fluxcd-community.github.io/helm-charts"
#   chart            = "flux2"
#   version          = "2.13.0"
#   namespace        = "flux-system"
#   create_namespace = true

#   values = [
#     yamlencode({
#       imageReflectionController = {
#         create = false
#       }
#       imageAutomationController = {
#         create = false
#       }
#     })
#   ]

#   depends_on = [
#     aws_eks_node_group.eks_node_group
#   ]
# }

# ##############################################
# # Flux Git Repository Secret
# # GitHub PAT token for Flux to pull manifests
# ##############################################

# resource "kubernetes_secret_v1" "flux_git_auth" {
#   metadata {
#     name      = "flux-git-auth"
#     namespace = "flux-system"
#   }

#   data = {
#     username = "git"
#     password = var.flux_github_token
#   }

#   type = "Opaque"

#   depends_on = [helm_release.flux]
# }
