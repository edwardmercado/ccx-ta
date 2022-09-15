# ccx-ta
**URL:** http://35.241.98.136/

## Ingress Controller

### Installation 

```
helm repo add ingress-nginx \
  https://kubernetes.github.io/ingress-nginx
```
```
helm install my-ing ingress-nginx/ingress-nginx \
  --namespace ingress \
  --version 4.0.17 \
  --values nginx.yaml \
  --create-namespace
```

### Configuration
See `k8s/nginx.yml` file.