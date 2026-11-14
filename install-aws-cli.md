**Before downloading, ensure your package index is updated and you have curl and unzip installed**  
sudo apt update && sudo apt install -y curl unzip  

**Download and Run the Installer**  
**X86/X64 Architecture**    
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  
**ARM64/aarch64 Architecture**  
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"  
unzip awscliv2.zip  
sudo ./aws/install  

**Verify and clean up**  
aws --version  
rm -rf awscliv2.zip aws/  

**Configure AWS CLI (Optional)**  
aws configure  
