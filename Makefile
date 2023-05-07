.PHONY: app-build app-docker-build app-docker-push app-run app-watch argo-dependency argo-diff argo-portforward argo-upgrade-install k8s-list-nodes-ext-ip terraform-apply

CTX=k8s-operator
IMAGE_NAME=ghcr.io/m-wrzesien/infoshare-2023:latest
PORT=8088
SHELL:=/bin/bash

app-build:
	cd app/src && \
	CGO_ENABLED=0 go build

app-docker-build:
	cd app/src && \
	docker build -t ${IMAGE_NAME} .

app-docker-push: app-docker-build
	docker push ${IMAGE_NAME}

app-run: app-build
	cd app/src && \
	./app --name "appka"

app-watch:
	find . -name '*.go' -or -name '*.html' -or -name 'Makefile' | entr -r make app-run

argo-dependency:
	cd argo-cd && \
	helm dependency update

argo-diff:
	cd argo-cd && \
	helm diff -C5 upgrade --install --namespace=argocd argo -f <(sops -d values.key.enc.yaml) . --kube-context ${CTX}

argo-portforward:
	kubectl port-forward --context ${CTX} service/argo-argocd-server ${PORT}:80 -n argocd

argo-upgrade-install:
	cd argo-cd && \
	helm upgrade --install --create-namespace --namespace=argocd argo -f <(sops -d values.key.enc.yaml) . --kube-context ${CTX}

k8s-list-nodes-ext-ip:
	./listNodesExtIP.sh

terraform-apply:
	cd terraform && \
	terraform apply