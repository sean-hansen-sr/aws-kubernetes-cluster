**Create the Refresh Script**  
`cat << EOF > refresh-ecr-secret.sh`  
`#!/bin/bash`  
`set -e`  

`# Ensure standard paths are available for cron`  
`export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`  

`# Optional: Explicitly set KUBECONFIG if running as root or if it's in a custom path`  
`# export KUBECONFIG=/home/ubuntu/.kube/config`  

`ECR_PASSWORD=$(aws ecr get-login-password --region <AWS_REGION>)`  

`kubectl delete secret ecr-registry-secret --namespace=default --ignore-not-found`  

`kubectl create secret docker-registry ecr-registry-secret \`  
`  --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \` 
`  --docker-username=AWS \`  
`  --docker-password="${ECR_PASSWORD}" \`  
`  --namespace=default`  
`EOF`  

**Move the script to /usr/local/bin**  
sudo mv refresh-ecr-secret.sh /usr/local/bin/  

**Make it executable**  
sudo chmod +x /usr/local/bin/refresh-ecr-secret.sh  

**Add the Cron Job**  
sudo crontab -e  

**Add the following line to end**  
`0 */4 * * * /usr/local/bin/refresh-ecr-secret.sh >> /var/log/ecr-refresh.log 2>&1`  

**Set up log file permissions**  
sudo touch /var/log/ecr-refresh.log  
`sudo chown $USER:$USER /var/log/ecr-refresh.log`  

**Run with debug mode to verify**  
bash -x /usr/local/bin/refresh-ecr-secret.sh