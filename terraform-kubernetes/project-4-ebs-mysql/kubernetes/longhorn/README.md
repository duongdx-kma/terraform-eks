# Longhorn configuration

### 1. install prerequisite

```
sudo apt-get update


apt-get install open-iscsi
apt-get install nfs-common

sudo systemctl enable iscsid
sudo systemctl start iscsid

sudo systemctl enable rpcbind
sudo systemctl start rpcbind
```

### 2. verify prerequisite for longhorn (only MASTER NODE)

```
apt-get install jq


curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/scripts/environment_check.sh | bash
```

### 3. add longhorn helm repository
```
helm repo add longhorn https://charts.longhorn.io

helm repo update
```

### 4. get longhorn values and override some config
```
helm show values longhorn/longhorn > longhorn.values.yml
```

### 5. install longhorn:
```
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --values longhorn.values.yml
```

### 6. create longhorn user:
```
USER=<USERNAME_HERE>; PASSWORD=<PASSWORD_HERE>; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth


USER=duongdx; PASSWORD=123456; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth

kubectl -n longhorn-system create secret generic basic-auth --from-file=auth
```

### 7. install nginx-ingress for expose longhorn
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx \
--create-namespace \
--set controller.ingressClassResource.name=longhorn-storage-ingress

# for verify
kubectl get ingressclass
```

### 8. expose:

##### 8.1 get external-ip
```
kubectl get services -n ingress-nginx

kubectl get ingress-nginx-controller EXTERNAL-IP
```

##### 8.2 edit /etc/hosts:
```
    ...
    192.168.56.201 (ingress-nginx-controller EXTERNAL-IP)  longhorn.ui.duongdx.com
    ...
```
