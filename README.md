K8S on Azure: Terraform & Network Policies
Project Goal
Automated, production-ready AKS cluster with NGINX and Bitcoin Monitor services. Features Ingress routing and strict bidirectional Network Policy isolation between services, while maintaining external access. Includes Liveness/Readiness Probes for robust pod management.

Setup & Deployment
Build & Push Docker Image:

Bash

docker build -t YOUR_REGISTRY_NAME/monitor-bitcoin:v4 .
docker push YOUR_REGISTRY_NAME/monitor-bitcoin:v4
Deploy Azure Infrastructure (Terraform):
(Navigate to terraform/)

Bash

terraform init
terraform plan
terraform apply -auto-approve
Deploy K8s Applications (YAMLs):
(Navigate to kubernetes/ or YAML directory)

Bash

kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f bitcoin-deployment.yaml
kubectl apply -f bitcoin-service.yaml
kubectl apply -f ingress-rules.yaml
kubectl apply -f network-policy.yaml
Verification
Pods Running: kubectl get pods
Get Ingress IP: kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
External Access: Browse http://<EXTERNAL_IP>/nginx & http://<EXTERNAL_IP>/bitcoin
Network Policy Blocking (Verify both fail):
NGINX to Bitcoin: kubectl exec -it <NGINX_POD_NAME> -- curl -v http://bitcoin-service:80
Bitcoin to NGINX: kubectl run temp-bitcoin-test-pod --image=alpine/curl --rm -it --labels="app=bitcoin" -- curl -v http://nginx-service:80
