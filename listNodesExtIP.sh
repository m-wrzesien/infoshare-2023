#!/bin/bash

# list URI for each nodePort service from each cluster for one node

# Print columns
printf "%-15s | %-40s | %-30s\n" "Cluster" "Svc Name" "URL"
# For each context/cluster
for cluster in $(kubectl config get-contexts -o name 2> /dev/null); do
    # for each nodePort service
    for svc in $(kubectl get services --context "$cluster" --output jsonpath='{range .items[?(@.spec.type=="NodePort")]}{.metadata.name},{range .spec.ports[*]}{.nodePort} {end} {end}' 2> /dev/null); do
        if [ "$svc" == "," ]; then
            continue
        fi
        svcPort="${svc#*,}"
        svcName="${svc%,*}"
        for nodeIP in $(kubectl get nodes --context "$cluster"  --output jsonpath='{range .items[*]}{.status.addresses[?(@.type=="ExternalIP")].address} {end}' 2> /dev/null); do
            # Print's it URL
            printf "%-15s | %-40s | http://%s:%s\n" "$cluster" "$svcName" "$nodeIP" "$svcPort"

            # We only need 1 IP for each service
            break
        done
    done
done