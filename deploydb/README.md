Kubernetes provides ways to provision stateful container using persistent volumes, statefulsets, etc.

Prerequisites::

Working Kubernetes Cluster

# To Deploy PostgreSQL on Kubernetes we need to follow below steps:

Postgres Docker Image latest version

Config Maps for storing Postgres configurations

Create Postgres config maps resource
  kubectl create -f postgres-configmap.yaml 
  
Persistent Storage Volume

PostgreSQL Deployment

PostgreSQL Service

