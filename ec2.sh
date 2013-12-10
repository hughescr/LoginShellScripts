# Setup Amazon EC2 Command-Line Tools
export EC2_HOME="$HOME/.ec2"
export EC2_URL=https://us-west-1.ec2.amazonaws.com/
export PATH="$PATH:$EC2_HOME/bin"
export EC2_PRIVATE_KEY="${EC2_HOME}/pk-craig-iam.pem"
export EC2_CERT="${EC2_HOME}/cert-craig-iam.pem"
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
export AWS_IAM_HOME="${EC2_HOME}"
export AWS_CREDENTIAL_FILE="${EC2_HOME}/aws-credentials"
