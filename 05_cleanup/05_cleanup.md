helm uninstall prometheus --namespace
prometheus kubectl delete ns prometheus
helm uninstall grafana --namespace
grafana kubectl delete ns grafana
rm -rf ${HOME}/environment/grafana

eksctl delete cluster --name eks-mundos-e

---

==========================================
STEP 1: CLEANING UP KUBERNETES RESOURCES
==========================================

Kubernetes cluster detected. Starting cleanup...
Deleting Grafana...
release "grafana" uninstalled
namespace "grafana" deleted
Deleting Prometheus...
release "prometheus" uninstalled
namespace "prometheus" deleted
Deleting nginx deployment...
Nginx deployment not found
Deleting test resources...
persistentvolumeclaim "test-ebs-claim" deleted
Test PVC file not found
Deleting custom storage classes...
Custom storage class not found
Deleting EBS CSI driver...
serviceaccount "ebs-csi-controller-sa" deleted
serviceaccount "ebs-csi-node-sa" deleted
role.rbac.authorization.k8s.io "ebs-csi-leases-role" deleted
clusterrole.rbac.authorization.k8s.io "ebs-csi-node-role" deleted
clusterrole.rbac.authorization.k8s.io "ebs-external-attacher-role" deleted
clusterrole.rbac.authorization.k8s.io "ebs-external-provisioner-role" deleted
clusterrole.rbac.authorization.k8s.io "ebs-external-resizer-role" deleted
clusterrole.rbac.authorization.k8s.io "ebs-external-snapshotter-role" deleted
rolebinding.rbac.authorization.k8s.io "ebs-csi-leases-rolebinding" deleted
clusterrolebinding.rbac.authorization.k8s.io "ebs-csi-attacher-binding" deleted
clusterrolebinding.rbac.authorization.k8s.io "ebs-csi-node-getter-binding" deleted
clusterrolebinding.rbac.authorization.k8s.io "ebs-csi-provisioner-binding" deleted
clusterrolebinding.rbac.authorization.k8s.io "ebs-csi-resizer-binding" deleted
clusterrolebinding.rbac.authorization.k8s.io "ebs-csi-snapshotter-binding" deleted
deployment.apps "ebs-csi-controller" deleted
poddisruptionbudget.policy "ebs-csi-controller" deleted
daemonset.apps "ebs-csi-node" deleted
csidriver.storage.k8s.io "ebs.csi.aws.com" deleted
Waiting for LoadBalancers to be terminated...
Kubernetes resources cleanup completed.

Cluster context not found in kubectl config
Removing Helm repositories...
"prometheus-community" has been removed from your repositories
"grafana" has been removed from your repositories