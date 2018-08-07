#!/bin/bash

# generate ssh-key for cluster nodes
ssh-keygen -t rsa -C "email@email.com" -N "somepassphrase" -f id_rsa
public_key=$(<id_rsa.pub)
# private key into keyvault?

resource_name=$1
subscription_id=$2
client_id=$3
client_secret=$4
tenant_id=$5

az account set --subscription $subscription_id

terraform init ../env
terraform apply -auto-approve \
    -var "subscription_id=$subscription_id" \
    -var "resource_name=$resource_name" \
    -var "client_id=$client_id" \
    -var "client_secret=$client_secret" \
    -var "tenant_id=$tenant_id" \
    -var "public_key=$public_key" \
    ../env

# install helm and teller
wget https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get

./get

kube_config=$(terraform output -json kube_config | jq '.value' | tr -d '"')

echo -e "$kube_config">$HOME/.kube/kube.config

$KUBECONFIG_old=$KUBECONFIG

export KUBECONFIG=$HOME/.kube/kube.config

helm init
helm init --upgrade

acr_server=$(terraform output -json acr_server | jq '.value' | tr -d '"')
acr_username=$(terraform output -json acr_username | jq '.value' | tr -d '"')
acr_password=$(terraform output -json acr_password | jq '.value' | tr -d '"')

sudo service docker start
sudo docker pull nginx
sudo docker login --username $acr_username --password $acr_password
sudo docker tag nginx "$acr_username/$acr_server/examples/nginx"
sudo docker push "$acr_username/$acr_server/examples/nginx"

sed -i "s|{imagelocation}|$acr_server|g" ./example/values.yaml

helm install ./example

export KUBECONFIG=$KUBECONFIG_old