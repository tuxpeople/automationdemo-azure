#!/usr/bin/env bash
mv ~/id_rsa ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" tfout.txt | sort -u > ~/kuberneteshosts
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
export SERVER_IP=$(sed -n '1p' ~/kuberneteshosts)
export USER=$(whoami)
export VERSION="v1.21.0+k3s1"

k3sup install \
  --ip $SERVER_IP \
  --user $USER \
  --cluster \
  --k3s-version $VERSION

export NEXT_SERVER_IP=$(sed -n '2p' ~/kuberneteshosts)

k3sup join \
  --ip $NEXT_SERVER_IP \
  --user $USER \
  --server-user $USER \
  --server-ip $SERVER_IP \
  --server \
  --k3s-version $VERSION

export NEXT_SERVER_IP=$(sed -n '3p' ~/kuberneteshosts)

k3sup join \
  --ip $NEXT_SERVER_IP \
  --user $USER \
  --server-user $USER \
  --server-ip $SERVER_IP \
  --server \
  --k3s-version $VERSION