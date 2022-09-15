# ccx-ta
**URL:** http://35.241.98.136/

## Details
**Project Id:** ccx-technical-assesment

## Ingress Controller

### Helm Installation 

```
helm repo add ingress-nginx \
  https://kubernetes.github.io/ingress-nginx
```
```
helm repo update
```
```
helm install my-ing ingress-nginx/ingress-nginx \
  --namespace ingress \
  --version 4.0.17 \
  --values nginx.yaml \
  --create-namespace
```

### Nginx Controller Configuration
See `k8s/nginx.yml` file.