This is a Terraform script that automatically builds an Ubuntu Server in AWS EC2. It also installs various programs through a EC2 user data shell script. The various programs are: -Armor Agent 3.0 -Chrome -Apache2 -xrdp -User + Password for Remote Desktop

Change the ARMOR License Key in the install_userdata_debian.sh file.

Rename variables.example to variables.tf, in the same directory as the main.tf file.

Copy the variables.example to variables.tf.
The variables in variables.tf must be modified to contain your specific settings.

Once the Machine is running in AWS EC2... you will see the username and password credentials in the /rdpcreds.txt file. 
This user has sudo privileges so !!**** please change your password for this user, the ubuntu user and also the root user ****!!

SSH into the machine using the Public DNS (IPv4) address in the EC2 console, for the instance, and your private key. 
ssh -i ~/.ssh/(keyfile).pem admin@ec2-X-X-X-X.compute-1.amazonaws.com

If you want to RDP into the machine you will need to install debian desktop. 
https://linuxize.com/post/how-to-install-xrdp-on-debian-10/
https://wiki.debian.org/DebianDesktop
In that case you will need a machine bigger than t2.micro. You can remote desktop in using the Public DNS (IPv4) address in the EC2 console, for the instance. You will need to download an RDP client. https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-clients

To tail the Ec2 user data installation log: 
sudo tail -f /var/log/cloud-init-output.log

If the Armor Agent installed correctly, you should see the /opt/armor directory. 

If Apache installs correctly, you should be able to curl localhost.

To grep for processes, ps aux | grep armor

-----
To run this terraform script:
1) Install Terraform v 0.15 or later
2) Download the files into an Ubuntu Linux folder
3) terraform init
4) terraform plan
5) terraform apply
To destroy the same - remove everything from AWS EC2:
6) terraform destroy 
Ref: 
https://www.terraform.io/docs/cli/commands/get.html
https://registry.terraform.io/providers/hashicorp/aws/latest/docs

-----
The appropriate user names (According to AWS) are as follows:

For Amazon Linux 2 or the Amazon Linux AMI, the user name is "ec2-user".
For a CentOS AMI, the user name is "centos".
For a Debian AMI, the user name is "admin".
For a Fedora AMI, the user name is "ec2-user" or "fedora".
For a RHEL AMI, the user name is "ec2-user" or "root".
For a SUSE AMI, the user name is "ec2-user" or "root".
For an Ubuntu AMI, the user name is "ubuntu".
Otherwise, if ec2-user and root don't work, check with the AMI provider. 
Ref: 
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html
