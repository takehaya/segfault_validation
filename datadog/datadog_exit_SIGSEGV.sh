#!/bin/bash
set -eu

API_KEY=""

k8s_state_data=$(kube sandbox -n kube-go get po -o json | jq '[.items[] | (.metadata.namespace + "/" + .metadata.name) as $slug | [.status.containerStatuses[]| { slug: $slug, container: .name, state: .state }|select(.state|has("terminated"))]]|flatten|{series: [.[]|{metric: "test.metric", points: [[.state.terminated.finishedAt|fromdate, 1]], type: "count", host: .slug, tags:["exitcode:" + (.state.terminated.exitCode|tostring), "container:" + (.container)]}]}')

# kubectl get pod -o json |jq '.items[]|[.metadata.namespace+"/"+.metadata.name,[.status.containerStatuses[]|[.name,.state]]]'
# kube sandbox -n wantedly get po -o json | jq '.items[] | (.metadata.namespace + "/" + .metadata.name) as $slug | .status.containerStatuses[] | { slug: $slug, container: .name, state: .state }|select(.state|has("terminated"))'
curl -X POST -H "Content-type: application/json" -d "{$k8s_state_data}" 'https://app.datadoghq.com/api/v1/series?api_key=$API_KEY'
