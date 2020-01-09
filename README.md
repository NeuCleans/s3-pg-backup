# Container to create PostgreSQL Backups
Minimalisitic container (only 25MB) for backing up Postgres databases. 

## Goal

Easily backup your PostgreSQL Database. 

Intended to be used with: 
1. Kubernetes for creating CronJobs that periodically back up your database.
2. Container Instances (e.g Azure Container Instances, AWS Fargate, and Kubernetes) that can be scheduled at specified times.
3. Your computer! It's smaller than pgAdmin.  

## Running the Backup CronJob in a Kubernetes Cluster
