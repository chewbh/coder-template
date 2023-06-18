---
name: Develop in a container with VNC in a Kubernetes pod
description: Develop with VS code web IDE and VNC
tags: [cloud, kubernetes, desktop]
---

# VNC template for a workspace in a Kubernetes pod

### Apps included

1. A web-based terminal
1. A web-based VS Code
1. VNC client and server

### Additional bash scripting

1. Prompt user and clone/install a dotfiles repository (for personalization settings)
1. Clone repo

### In-cluster authentication

If the Coder host runs in a Pod on the same Kubernetes cluster as you are creating workspaces in,
you can use in-cluster authentication.

To use this authentication, set the parameter `use_kubeconfig` to false.

The Terraform provisioner will automatically use the service account associated with the pod to
authenticate to Kubernetes. Be sure to bind a [role with appropriate permission](#rbac) to the
service account. For example, assuming the Coder host runs in the same namespace as you intend
to create workspaces:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coder

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: coder
subjects:
  - kind: ServiceAccount
    name: coder
roleRef:
  kind: Role
  name: coder
  apiGroup: rbac.authorization.k8s.io
```

Then start the Coder host with `serviceAccountName: coder` in the pod spec.

### Authenticate against external clusters

You may want to deploy workspaces on a cluster outside of the Coder control plane. Refer to the [Coder docs](https://coder.com/docs/v2/latest/platforms/kubernetes/additional-clusters) to learn how to modify your template to authenticate against external clusters.

## Namespace

The target namespace in which the pod will be deployed is defined via the `coder_workspace`
variable. The namespace must exist prior to creating workspaces.

### Resources

[VNC Dockerfile](https://github.com/coder/enterprise-images/tree/main/images/vnc)

[noVNC](https://novnc.com/info.html)

[TigerVNC](https://tigervnc.org/)