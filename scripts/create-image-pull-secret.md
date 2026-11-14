`kubectl create secret docker-registry ecr-registry-secret \`  
`  --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \`  
`  --docker-username=AWS \`  
`  --docker-password=$(aws ecr get-login-password --region <AWS_REGION>) \`  
`  --namespace=<namespace>`  