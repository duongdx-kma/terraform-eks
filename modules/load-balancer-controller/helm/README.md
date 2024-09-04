# EKS Load Balancer Controller

### step-01: Add eks helm repository
```powershell
helm repo add eks https://aws.github.io/eks-charts
# If using IAM Roles for service account install as follows -  NOTE: you need to specify both of the chart values `serviceAccount.create=false` and `serviceAccount.name=aws-load-balancer-controller`
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=my-cluster -n kube-system --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
# If not using IAM Roles for service account
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=my-cluster -n kube-system
```

### step-02: check chart in repo:
```powershell
# command:
helm search repo eks

# Result:
# NAME                                    	CHART VERSION	APP VERSION                       	DESCRIPTION
# ...
# eks/aws-load-balancer-controller        	1.8.2        	v2.8.2                            	AWS Load Balancer Controller Helm chart for Kub...
#...
```

### step-03: Install and launching `EKS Load Balancer Controller` release
```powershell
# command:
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --namespace kube-system --values values.yml
```

### step-04: Verify `Load Balancer Controller` resources
```powershell
# command:
kubectl -n kube-system get deployment

# Result:
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           6m7s
coredns                        2/2     2            2           40m

# command:
kubectl -n kube-system get deployment aws-load-balancer-controller

# Result:
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           6m15s

# command:
kubectl -n kube-system describe deployment aws-load-balancer-controller

# Result:
Name:                   aws-load-balancer-controller
Namespace:              kube-system
CreationTimestamp:      Tue, 03 Sep 2024 18:27:50 +0900
Labels:                 app.kubernetes.io/instance=aws-load-balancer-controller
                        app.kubernetes.io/managed-by=Helm
                        app.kubernetes.io/name=aws-load-balancer-controller
                        app.kubernetes.io/version=v2.8.2
                        helm.sh/chart=aws-load-balancer-controller-1.8.2
Annotations:            deployment.kubernetes.io/revision: 1
                        meta.helm.sh/release-name: aws-load-balancer-controller
                        meta.helm.sh/release-namespace: kube-system
Selector:               app.kubernetes.io/instance=aws-load-balancer-controller,app.kubernetes.io/name=aws-load-balancer-controller
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app.kubernetes.io/instance=aws-load-balancer-controller
                    app.kubernetes.io/name=aws-load-balancer-controller
  Annotations:      prometheus.io/port: 8080
                    prometheus.io/scrape: true
  Service Account:  aws-load-balancer-controller-sa
  Containers:
   aws-load-balancer-controller:
    Image:       602401143452.dkr.ecr.ap-southeast-1.amazonaws.com/amazon/aws-load-balancer-controller:v2.8.2
    Ports:       9443/TCP, 8080/TCP
    Host Ports:  0/TCP, 0/TCP
    Args:
      --cluster-name=study-dev-eks-cluster
      --ingress-class=alb
      --aws-region=ap-southeast-1
      --aws-vpc-id=vpc-0d6be7423b378c14a
    Liveness:     http-get http://:61779/healthz delay=30s timeout=10s period=10s #success=1 #failure=2
    Readiness:    http-get http://:61779/readyz delay=10s timeout=10s period=10s #success=1 #failure=2
    Environment:  <none>
    Mounts:
      /tmp/k8s-webhook-server/serving-certs from cert (ro)
  Volumes:
   cert:
    Type:               Secret (a volume populated by a Secret)
    SecretName:         aws-load-balancer-tls
    Optional:           false
  Priority Class Name:  system-cluster-critical
  Node-Selectors:       <none>
  Tolerations:          <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   aws-load-balancer-controller-69d47f4bc5 (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  6m20s  deployment-controller  Scaled up replica set aws-load-balancer-controller-69d47f4bc5 to 2

# command:
k get svc -n kube-system

# Result
NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
aws-load-balancer-webhook-service   ClusterIP   172.20.118.92   <none>        443/TCP                  9m48s
kube-dns                            ClusterIP   172.20.0.10     <none>        53/UDP,53/TCP,9153/TCP   43m

# Verify Labels in Service and Selector Labels in Deployment
kubectl -n kube-system get svc aws-load-balancer-webhook-service -o yaml
kubectl -n kube-system get deployment aws-load-balancer-controller -o yaml
Observation:
1. Verify "spec.selector" label in "aws-load-balancer-webhook-service"
2. Compare it with "aws-load-balancer-controller" Deployment "spec.selector.matchLabels"
3. Both values should be same which traffic coming to "aws-load-balancer-webhook-service" on port 443 will be sent to port 9443 on "aws-load-balancer-controller" deployment related pods.
```

### step-05: Verify `Load Balancer Controller` resources
```powershell
# List Pods
kubectl get pods -n kube-system

# Review logs for AWS LB Controller POD-1
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f  aws-load-balancer-controller-86b598cbd6-5pjfk

# Review logs for AWS LB Controller POD-2
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f aws-load-balancer-controller-86b598cbd6-vqqsk
```

### step-06: Verify AWS Load Balancer Controller k8s `Service Account` - Internals
```powershell
# command:
k get sa -n kube-system

# Result
...
aws-load-balancer-controller-sa               0         19m
...

# command:
k describe sa aws-load-balancer-controller-sa -n kube-system

# Result
Name:                aws-load-balancer-controller-sa
Namespace:           kube-system
Labels:              app.kubernetes.io/instance=aws-load-balancer-controller
                     app.kubernetes.io/managed-by=Helm
                     app.kubernetes.io/name=aws-load-balancer-controller
                     app.kubernetes.io/version=v2.8.2
                     helm.sh/chart=aws-load-balancer-controller-1.8.2
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/aws-lbc-role
                     meta.helm.sh/release-name: aws-load-balancer-controller
                     meta.helm.sh/release-namespace: kube-system
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```

### Step-07: Verify AWS Load Balancer Controller k8s Service Account - Internals
```t
# List Service Account and its secret
kubectl -n kube-system get sa aws-load-balancer-controller
kubectl -n kube-system get sa aws-load-balancer-controller -o yaml
kubectl -n kube-system get secret <GET_FROM_PREVIOUS_COMMAND - secrets.name> -o yaml
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th 
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th -o yaml
## Decoce ca.crt using below two websites
https://www.base64decode.org/
https://www.sslchecker.com/certdecoder

## Decode token using below two websites
https://www.base64decode.org/
https://jwt.io/
Observation:
1. Review decoded JWT Token

# List Deployment in YAML format
kubectl -n kube-system get deploy aws-load-balancer-controller -o yaml
Observation:
1. Verify "spec.template.spec.serviceAccount" and "spec.template.spec.serviceAccountName" in "aws-load-balancer-controller" Deployment
2. We should find the Service Account Name as "aws-load-balancer-controller"

# List Pods in YAML format
kubectl -n kube-system get pods
kubectl -n kube-system get pod <AWS-Load-Balancer-Controller-POD-NAME> -o yaml
kubectl -n kube-system get pod aws-load-balancer-controller-65b4f64d6c-h2vh4 -o yaml
Observation:
1. Verify "spec.serviceAccount" and "spec.serviceAccountName"
2. We should find the Service Account Name as "aws-load-balancer-controller"
3. Verify "spec.volumes". You should find something as below, which is a temporary credentials to access AWS Services
CHECK-1: Verify "spec.volumes.name = aws-iam-token"
  - name: aws-iam-token
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          audience: sts.amazonaws.com
          expirationSeconds: 86400
          path: token
CHECK-2: Verify Volume Mounts
    volumeMounts:
    - mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
      name: aws-iam-token
      readOnly: true          
CHECK-3: Verify ENVs whose path name is "token"
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token          
```

### Step-08: Verify TLS Certs for AWS Load Balancer Controller - Internals
```t
# List aws-load-balancer-tls secret 
kubectl -n kube-system get secret aws-load-balancer-tls -o yaml

# Verify the ca.crt and tls.crt in below websites
https://www.base64decode.org/
https://www.sslchecker.com/certdecoder

# Make a note of Common Name and SAN from above 
Common Name: aws-load-balancer-controller
SAN: aws-load-balancer-webhook-service.kube-system, aws-load-balancer-webhook-service.kube-system.svc

# List Pods in YAML format
kubectl -n kube-system get pods
kubectl -n kube-system get pod <AWS-Load-Balancer-Controller-POD-NAME> -o yaml
kubectl -n kube-system get pod aws-load-balancer-controller-65b4f64d6c-h2vh4 -o yaml
Observation:
1. Verify how the secret is mounted in AWS Load Balancer Controller Pod
CHECK-2: Verify Volume Mounts
    volumeMounts:
    - mountPath: /tmp/k8s-webhook-server/serving-certs
      name: cert
      readOnly: true
CHECK-3: Verify Volumes
  volumes:
  - name: cert
    secret:
      defaultMode: 420
      secretName: aws-load-balancer-tls
```


## References
- [AWS Load Balancer Controller Install](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [ECR Repository per region](https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html)
