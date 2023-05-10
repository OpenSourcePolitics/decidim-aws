REGISTRY := rg.fr-par.scw.cloud
NAMESPACE := decidim-an
VERSION := latest
PREVIOUS_VERSION := oldest
IMAGE_NAME := decidim-an
TAG := $(REGISTRY)/$(NAMESPACE)/$(IMAGE_NAME):$(VERSION)
PREVIOUS_TAG := $(REGISTRY)/$(NAMESPACE)/$(IMAGE_NAME):$(PREVIOUS_VERSION)

login:
	docker login $(REGISTRY) -u nologin -p $(SCW_SECRET_TOKEN)

build-classic:
	docker build -t $(IMAGE_NAME):$(VERSION) . --compress

build-scw:
	docker build -t $(TAG) .

push:
	@make login
	@make pull
	@make rename
	@make build-scw
	docker push $(TAG)

rename:
	docker tag $(TAG) $(PREVIOUS_TAG)
	docker push $(PREVIOUS_TAG)

pull:
	docker pull $(TAG)

redis-setup:
	helm install redis-cluster bitnami/redis \
	  --set auth.enabled=false \
      --set cluster.slaveCount=3 \
      --set securityContext.enabled=true \
      --set securityContext.fsGroup=2000 \
      --set securityContext.runAsUser=1000 \
      --set volumePermissions.enabled=true \
      --set master.persistence.enabled=true \
      --set master.persistence.path=/data \
      --set master.persistence.size=8Gi \
      --set master.persistence.storageClass="scw-bssd-retain" \
      --set slave.persistence.enabled=true \
      --set slave.persistence.path=/data \
      --set slave.persistence.size=8Gi \
      --set slave.persistence.storageClass="scw-bssd-retain"

apply:
	kubectl apply -f kube

restart:
	kubectl rollout restart deployment