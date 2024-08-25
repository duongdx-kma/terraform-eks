resource "kubernetes_storage_class_v1" "ebs_gp3_storage_class" {
  metadata {
    name = "ebs-gp3-storage-class"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type = "gp3"
  }

  mount_options = ["debug"]

  allowed_topologies {
    match_label_expressions {
      key = "topology.kubernetes.io/zone"
      values = [
        "ap-southeast-1a",
        "ap-southeast-1b",
        "ap-southeast-1c"
      ]
    }
  }
}

# STORAGE CLASS
# 1. A StorageClass provides a way for administrators
# to describe the "classes" of storage they offer.
# 2. Here we are offering EBS Storage for EKS Cluster
