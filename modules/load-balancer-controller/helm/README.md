# EKS Load Balancer Controller

### step-01: Add eks helm repository
```t
helm repo add eks https://aws.github.io/eks-charts
# If using IAM Roles for service account install as follows -  NOTE: you need to specify both of the chart values `serviceAccount.create=false` and `serviceAccount.name=aws-load-balancer-controller`
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=my-cluster -n kube-system --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
# If not using IAM Roles for service account
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=my-cluster -n kube-system
```

### step-02: Install and launching `EKS Load Balancer Controller` release
```t
# command:
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --namespace kube-system --values values.yml
```
