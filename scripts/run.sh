#!/bin/bash

# generate ssh-key for cluster nodes
ssh-keygen -t rsa -C "email@email.com" -N "somepassphrase" -f id_rsa
public_key=$(<id_rsa.pub)
# private key into keyvault?

resource_name=""
subscription_id=""
client_id=""
client_secret=""
tenant_id=""

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