Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

iam_role_arn = "arn:aws:iam::183295451532:role/ec2-admin-role"
instance_id = "i-0366490b54eaebb16"
instance_public_dns = "ec2-54-166-136-182.compute-1.amazonaws.com"
instance_public_ip = "54.166.136.182"
key_pair_name = "pin"
ssh_command = "ssh -i pin.pem ubuntu@54.166.136.182"

---

02_logc_ec2_internal_vars.sh

01_create_eks_cluster.sh

02_delete_eks_cluster.sh

2025-07-20 05:44:28 [!]  recommended policies were found for "vpc-cni" addon, but since OIDC is disabled on the cluster, eksctl cannot configure the requested permissions; the recommended way to provide IAM permissions for "vpc-cni" addon is via pod identity associations; after addon creation is completed, add all recommended policies to the config file, under `addon.PodIdentityAssociations`, and run `eksctl update addon`

2025-07-20 05:51:58 [✖]  getting Kubernetes version on EKS cluster: error running `kubectl version`: exit status 1 (check 'kubectl version')
2025-07-20 05:51:58 [ℹ]  cluster should be functional despite missing (or misconfigured) client binaries
2025-07-20 05:51:58 [✔]  EKS cluster "eks-mundos-e" in "us-east-1" region is ready


ubuntu@ip-172-31-41-129:~$ kubectl get nodes
E0720 05:57:29.225249    5048 memcache.go:238] couldn't get current server API group list: Get "https://74192FCCF01F3B5AA3651E36F4BFDF93.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"
E0720 05:57:29.742506    5048 memcache.go:238] couldn't get current server API group list: Get "https://74192FCCF01F3B5AA3651E36F4BFDF93.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"
E0720 05:57:30.249559    5048 memcache.go:238] couldn't get current server API group list: Get "https://74192FCCF01F3B5AA3651E36F4BFDF93.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"
E0720 05:57:30.762555    5048 memcache.go:238] couldn't get current server API group list: Get "https://74192FCCF01F3B5AA3651E36F4BFDF93.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"
E0720 05:57:31.268451    5048 memcache.go:238] couldn't get current server API group list: Get "https://74192FCCF01F3B5AA3651E36F4BFDF93.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"
Unable to connect to the server: getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"


ubuntu@ip-172-31-41-129:~$ aws eks list-clusters --region us-east-1
{
    "clusters": [
        "eks-mundos-e"
    ]
}
ubuntu@ip-172-31-41-129:~$ aws eks update-kubeconfig --region us-east-1 --name eks-mundos-e
Added new context arn:aws:eks:us-east-1:183295451532:cluster/eks-mundos-e to /home/ubuntu/.kube/config


Hello Edwards the issue seems to be because of awscli version.

As I can see you are still using awscli v1, Please migrate to awscli v2 following the documentation https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration-instructions.html and then run update kubeconfig command again aws eks update-kubeconfig --region eu-central-1 --name cluster07.

---

- Relanzar EC2, con user_data modificado para que no instale aws cli
- Verificar si la instancia se crea con la última versión de cli v2+
- Sí tiene la última versión, crear cluster
- Sino, crear cluster por fuera de la instancia