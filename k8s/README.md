## Cluster

How to setup a new cluster:

### Prerequisites

You first need to install flux in the cluster:

- installe flux cli in your machine
- having kubectl pointing to the right cluster

And then, just run:

```
flux install
```

### Setup Infra in cluster:

Create secret for monitoring:

```
kubectl create secret generic monitoring -n flux-system --from-literal=grafana_host=none --from-literal=grafana_password=`openssl rand -base64 14`
```

Common folder is for staging and prod.
Apply common.yml:

```
kubectl apply -f ./cluster/common/common.yml
```

And deploy each folder on each cluster. For instance, for prod:

```
kubectl apply -f ./cluster/prod/prod.yml
```

Then, you also need to deploy dashboards and datasources:

```
kubectl apply -k ./cluster/common/datasources
kubectl apply -k ./cluster/common/dashboards
```

### How to connect to grafana

```
kubectl port-forward --namespace monitoring service/prometheus-stack-grafana 3000:80
```

Then, find the admin secret in:
```
kubectl get secret -n monitoring prometheus-stack-grafana
```

And connect to grafana on:
http://localhost:3000

## Decidim

How to deploy, and admin decidim.
All the ressources are located in `decidim` folder.

### Pg bouncer

#### Prerequisites

- deploy pg in managed db in scaleway
- create a node pool for pg bouncer
- add the label to this node pool: `security-group=postgres-an`
- configure pg allowed IP to match the one from this node pool

Create the secret named `pgbouncer` with the following env vars:
```
PGBOUNCER_DATABASE
POSTGRESQL_DATABASE
POSTGRESQL_PORT
POSTGRESQL_USERNAME
POSTGRESQL_HOST
POSTGRESQL_PASSWORD
```

Then you can deploy the pg-bouncer yaml.

#### Debug Helm Release

Somtimes, it happens that the helm release gets stuck.
(It would be in error in someway)

A good debugging step is to "restart" the release with this command, for instance, for redis:
```
flux -n default suspend hr redis
flux -n default resume hr redis
```

### App

#### Secret

You need to create a secret with the following env vars:

```
PREPARED_STATEMENTS
RDS_HOSTNAME
RDS_DB_NAME
RDS_PASSWORD
RDS_PORT
RDS_USERNAME
FRANCE_CONNECT_PROFILE_IDENTIFIER
FRANCE_CONNECT_PROFILE_SECRET
FRANCE_CONNECT_UID_IDENTIFIER
FRANCE_CONNECT_UID_SECRET
RAILS_ENV
REDIS_URL
SCALEWAY_BUCKET_NAME
SCALEWAY_ID
SCALEWAY_TOKEN
SECRET_KEY_BASE
SESSION_DAYS_TRIM_THRESHOLD
```

#### Manage deploy

You need to deploy the different yml.

When you want to update the nginx cm, first check the diff, and then apply:

```
kubectl -n default diff -f app-nginx-conf-cm.yml
kubectl -n default apply -f app-nginx-conf-cm.yml
```

After changing a secret or a cm, you need to triggger a rollout:

```
kubectl -n default rollout restart deploy decidim-an-deployment
kubectl -n default rollout restart deploy decidim-an-sidekiq-deployment
```

### ToDo

- have an image tag to avoid deploy latest
- improve caching mechanism between app and nginx (check the ideas folder)
- store secret in git with https://github.com/mozilla/sops
- create an other git repo with a decidim heml chart
- decide on 1 cluster/customer vs 1 cluster for all, or something in between
- discuss for CI/CD (cluster/decidim helm chart/decidim docker image/staging and prod)
