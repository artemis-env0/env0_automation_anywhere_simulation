# GKE Connectivity Test via env0 (Safe, Read-Only)

This repository validates **GCP/GKE connectivity inside env0** without changing any cloud or cluster resources.  
It uses a tiny Terraform stub (for lifecycle hooks) and an `env0.yaml` custom flow that:

- Authenticates to GCP using a **Service Account key** (recommended) or WIF (optional variant)
- (Optionally) fetches a kubeconfig for a target **GKE** cluster
- Performs **read-only** smoke checks (`kubectl get ns`, `kubectl auth can-i get pods`)
- **Never mutates resources**

---

## Prerequisites

- An env0 account/project where you can create:
  - A **Template** pointing to this repo/branch
  - An **Environment** under that Template
- A **GCP Service Account JSON key** with:
  - Project IAM: `roles/container.clusterViewer` and `roles/viewer`
  - (Recommended) Kubernetes RBAC (from an admin shell):
    ```bash
    kubectl create clusterrolebinding env0-view \
      --clusterrole=view \
      --user="YOUR_SA_EMAIL@YOUR_PROJECT.iam.gserviceaccount.com"
    ```
- Runner image with `gcloud`, `kubectl`, and the **GKE auth plugin** available  
  (the flow sets `USE_GKE_GCLOUD_AUTH_PLUGIN=True`; modern GKE requires this).

---

## Setup in env0 (fast path)

1. **Attach GCP Credential**
   - In env0, create or select a **Google Cloud** credential (Service Account JSON or WIF).
   - Attach it to your **Environment** (or ensure it’s inherited from the Project/Template).
   - During a run, env0 will:
     - For **SA key**: set `GOOGLE_APPLICATION_CREDENTIALS` to the key file path.
     - For **WIF**: place a WIF credential JSON in the workspace (often `env0_credential_configuration.json`).

2. **Create a Template**
   - **Type:** **Terraform** (or **OpenTofu**)
   - **Repository:** this repo
   - **Branch:** your branch
   - **Working Directory:** repo root (unless you moved files)

3. **Create an Environment**
   - Under your Template → **New Environment**

4. **Environment Variables** (Free Text, no quotes)
   - `GOOGLE_PROJECT = <your-gcp-project-id>`
   - (Optional, for GKE checks)
     - `GKE_CLUSTER = <your-cluster-name>`
     - **Either** `GKE_ZONE = <us-central1-a>` **or** `GKE_REGION = <us-central1>`

5. **Deploy**
   - Open logs and confirm:
     - SA key path printed (from `GOOGLE_APPLICATION_CREDENTIALS`) **or** WIF file detected
     - Active account shows your service account
     - (If set) `get-credentials` succeeds and `kubectl config current-context` is a `gke_...` context
     - Read-only checks display namespaces and RBAC status

---

## What the Flow Does (Safety)

**Auth path (SA key):**
```bash
gcloud auth activate-service-account "$SA_EMAIL" --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set account "$SA_EMAIL"
gcloud config set project "$GOOGLE_PROJECT"
