Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9090


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9091

kubectl port-forward -n prometheus svc/prometheus-server 9090:80


ubuntu@ip-172-31-34-116:~$ kubectl describe serviceaccount ebs-csi-controller-sa -n kube-system
Name:                ebs-csi-controller-sa
Namespace:           kube-system
Labels:              app.kubernetes.io/component=csi-driver
                     app.kubernetes.io/managed-by=EKS
                     app.kubernetes.io/name=aws-ebs-csi-driver
                     app.kubernetes.io/version=1.45.0
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::183295451532:role/eksctl-eks-mundos-e-addon-iamserviceaccount-kub-Role1-*
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>



29m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: cf9d8f2b-37f1-4ee1-b694-b2b22304a72b, api error ValidationError: Request ARN is invalid
29m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: eff186a8-82f5-45ac-a67a-8773a95442d5, api error ValidationError: Request ARN is invalid
29m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 282074d2-9762-4f9a-8320-980fd421a608, api error ValidationError: Request ARN is invalid
29m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: b05d198a-1a31-407d-9b12-e2e561342154, api error ValidationError: Request ARN is invalid
28m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 2b876eac-8d7d-4034-bfca-917a08ad5b71, api error ValidationError: Request ARN is invalid
27m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 0efff67c-fc51-4b64-a317-6070a5a6bfa0, api error ValidationError: Request ARN is invalid
25m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 29caf1ea-0f5c-4acc-9a06-f9910a55fb5a, api error ValidationError: Request ARN is invalid
14m         Normal    FailedBinding          persistentvolumeclaim/storage-prometheus-alertmanager-0   no persistent volumes available for this claim and no storage class is set
14m         Warning   FailedScheduling       pod/prometheus-alertmanager-0                             0/3 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
12m         Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   (combined from similar events): failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: a08380a7-d531-426d-b2bd-9f2f46ea4328, api error ValidationError: Request ARN is invalid
11m         Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 6993bced-c022-4bbd-b9ae-a41a516f7c5a, api error ValidationError: Request ARN is invalid
10m         Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 98d8574a-f1cb-4cec-b020-dce39f7a8ee9, api error ValidationError: Request ARN is invalid
10m         Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: ef2651b5-c590-4530-97ff-2a48fa947b52, api error ValidationError: Request ARN is invalid
10m         Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 2180f8e5-c5ad-475b-a7f5-e671e892bf0b, api error ValidationError: Request ARN is invalid
10m         Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: bd440572-3b17-4744-a5d3-c3ccc0c437a3, api error ValidationError: Request ARN is invalid
10m         Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: b7abe1e9-5c5f-4d81-9762-edeed63c4a7a, api error ValidationError: Request ARN is invalid
9m56s       Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 841b586c-35fd-45c9-9117-8495cdf6f28e, api error ValidationError: Request ARN is invalid
9m38s       Warning   FailedScheduling       pod/prometheus-server-6bc5fc7bc7-wfkvl                    running PreBind plugin "VolumeBinding": binding volumes: context deadline exceeded
8m52s       Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 3c393fe5-0d03-49be-8154-c5167542e3b4, api error ValidationError: Request ARN is invalid
6m44s       Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: 13b1a29a-262a-4872-bab1-7eee39d472ca, api error ValidationError: Request ARN is invalid
4m33s       Normal    ExternalProvisioning   persistentvolumeclaim/prometheus-server                   Waiting for a volume to be created either by the external provisioner 'ebs.csi.aws.com' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
4m33s       Normal    ExternalProvisioning   persistentvolumeclaim/storage-prometheus-alertmanager-0   Waiting for a volume to be created either by the external provisioner 'ebs.csi.aws.com' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
2m14s       Normal    Provisioning           persistentvolumeclaim/prometheus-server                   External provisioner is provisioning volume for claim "prometheus/prometheus-server"
2m14s       Warning   ProvisioningFailed     persistentvolumeclaim/prometheus-server                   failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-c91b3140-9a95-40a8-8532-729aac34fac8": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: e39681d5-b981-4c29-bc44-d3aeb88e717f, api error ValidationError: Request ARN is invalid
2m14s       Normal    Provisioning           persistentvolumeclaim/storage-prometheus-alertmanager-0   External provisioner is provisioning volume for claim "prometheus/storage-prometheus-alertmanager-0"
2m14s       Warning   ProvisioningFailed     persistentvolumeclaim/storage-prometheus-alertmanager-0   (combined from similar events): failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-b8d405c8-3ecd-4f79-a865-191b02c6ea0d": could not create volume in EC2: operation error EC2: CreateVolume, get identity: get credentials: failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, https response error StatusCode: 400, RequestID: e39681d5-b981-4c29-bc44-d3aeb88e717f, api error ValidationError: Request ARN is invalid
60s         Warning   FailedScheduling       pod/prometheus-alertmanager-0                             running PreBind plugin "VolumeBinding": binding volumes: context deadline excee



---

Thanks for sharing your command history. It gives a clear picture of what happened and **why the last two commands fixed the issue**.

---

### 🧠 Short answer:

> The EBS CSI driver pods (which manage EBS volumes in AWS) needed to be **restarted** to recognize the **new IAM role** you configured.
> Before that, they were still running with **no or wrong permissions**, so they couldn’t create the volumes.

---

### 🔍 Let's break it down:

#### 🔸 Steps 16–31:

You were:

* Checking pods, logs, storage classes, PVCs, PVs, etc.
* Trying to figure out why the `storage-prometheus-alertmanager-0` PVC wasn’t getting bound to a volume.
* The PVC was **stuck**, and the error was:

  ```
  failed to provision volume ... api error ValidationError: Request ARN is invalid
  ```

#### 🔸 Steps 32:

You patched the PVC to explicitly use the `gp2` storage class, which is okay — but the problem wasn't the storage class. It was **EBS CSI driver permissions**.

#### 🔸 Steps 38–41:

You investigated the CSI driver:

* Checked pods in `kube-system`
* Looked at the service account `ebs-csi-controller-sa`
* Confirmed that it was **missing or had incorrect annotations** (likely added via your script later).

#### 🔸 Step 46:

You ran `./fix-ebs-csi.sh`, which:

* Created the correct IAM policy and role
* Annotated the service account with the IAM role (i.e., added permission for the CSI driver)

**BUT:** the CSI controller and node pods were **still running** from before the annotation — so they **didn’t pick up the new IAM role**.

---

### ✅ What fixed it

#### 🔹 Step 48–49:

```bash
kubectl rollout restart deployment ebs-csi-controller -n kube-system
kubectl rollout restart daemonset ebs-csi-node -n kube-system
```

This **restarted the CSI pods**, and now:

* The **new pods inherited the updated service account IAM role**
* They could finally **authenticate with AWS STS**
* And could **create EBS volumes** successfully

---

### ✅ Step 51: Success confirmed

```bash
kubectl get all -n prometheus
```

You saw the pods running and PVCs bound — because volume provisioning finally worked.

---

### 🧠 Final Summary

> Restarting the `ebs-csi` controller and node was like "reloading" the driver with the new AWS permissions.
> Until that happened, it was still using the old (broken) credentials — that’s why the IAM role fix **only worked after the restart**.

Let me know if you want a Markdown version of this explanation for documentation or onboarding.


---
Forwarding port:

   16  kubectl get all -n prometheus
   17  kubectl port-forward -n prometheus svc/prometheus-server 9090:80
   18  kubectl port-forward -n prometheus svc/prometheus-server 8080:9090 --address 0.0.0.0
   19  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
   20  kubectl --namespace prometheus port-forward $POD_NAME 9090
   21  kubectl get all -n prometheus
   22  kubectl port-forward -n prometheus svc/prometheus-server 9090:80
   23  kubectl port-forward -n prometheus svc/prometheus-server 8080:9090 --address 0.0.0.0
   24  kubectl get all -n prometheus
   25  kubectl port-forward -n prometheus service/prometheus-server 9090:80
   26  kubectl patch service prometheus-server -n prometheus -p '{"spec":{"type":"NodePort"}}'
   27  kubectl get service prometheus-server -n prometheus
   28  kubectl port-forward -n prometheus service/prometheus-server 9090:80 --address 0.0.0.0

This worked:

kubectl port-forward -n prometheus service/prometheus-server 9090:80 --address 0.0.0.0


---

http://aacea05671f084bb49ecdb9e946abd3b-103890818.us-east-1.elb.amazonaws.com/dashboards

