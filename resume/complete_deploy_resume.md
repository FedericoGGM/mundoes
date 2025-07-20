## Complete DevOps Integrator Project - Step by Step

### **Phase 1: Infrastructure Setup**
1. **Generate SSH Key Pair**
   ```bash
   ssh-keygen -t rsa -b 2048 -f pin
   ```

2. **Deploy EC2 with Terraform**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Connect to EC2**
   ```bash
   ssh -i pin.pem ubuntu@<PUBLIC_IP>
   ```

### **Phase 2: EKS Cluster Setup**
4. **Create EKS Cluster**
   ```bash
   ./create-cluster.sh
   ```

5. **Verify Cluster**
   ```bash
   kubectl get nodes
   ```

6. **Deploy Test Application**
   ```bash
   kubectl apply -f nginx-deployment.yaml
   ```

### **Phase 3: Storage Configuration**
7. **Install EBS CSI Driver**
   ```bash
   kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.20"
   ```

8. **Verify Storage**
   ```bash
   kubectl get storageclass
   kubectl get pods -n kube-system -l app=ebs-csi-controller
   ```

### **Phase 4: Monitoring Stack**
9. **Install Prometheus**
   ```bash
   ./prometheus-deploy-fixed.sh
   ```

10. **Install Grafana**
    ```bash
    ./grafana-deploy-corrected.sh
    ```

11. **Access Monitoring**
    - Prometheus: `kubectl port-forward -n prometheus svc/prometheus-server 9090:80`
    - Grafana: Get LoadBalancer URL or port-forward to 3000

### **Phase 5: Cleanup (When Done)**
12. **Complete Cleanup**
    ```bash
    ./complete-cleanup.sh
    ```

---

**Key Files Required:**
- `main.tf` (Terraform config)
- `user_data.sh` (EC2 setup script)
- `create-cluster.sh` (EKS creation)
- `nginx-deployment.yaml` (Test workload)
- `grafana.yaml` (Grafana config with dashboards)
- `pin` & `pin.pub` (SSH key pair)

**End Result:** Full monitoring stack with Kubernetes dashboards 6417 & 3119 displaying cluster metrics.