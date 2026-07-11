
Retrieve ArgoCD password with
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

RQfr9XaX5op0TzlW
