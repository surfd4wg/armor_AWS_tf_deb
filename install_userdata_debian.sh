Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
/bin/echo "Hello World" >> /tmp/userdata-test.txt
--//
#!/bin/bash
banner()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}
#--- apache ---
banner "Installing Apache2"
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
#--- NGINX ---
#sudo apt-get update
#sudo apt-get install nginx
#sudo systemctl start nginx
#sudo systemctl enable nginx
#--- curl and jq ---
banner "Installing curl, wget, jq, nano, pwgen"
sudo apt-get -y install curl unzip
sudo apt-get -y install jq
#--- Chrome ---
#sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#sudo apt-get -y install ./google-chrome-stable_current_amd64.deb
#--- Remote Desktop ---
#sudo apt-get -y install xrdp
#sudo systemctl enable --now xrdp
#sudo ufw allow from any to any port 3389 proto tcp
#--- Add a new user for Remote Desktop ---
#Make sure you run "passwd" to set a new password to this account
#The username and password will be located in $HOME/rdpcreds.txt
USERNAME=teddy
sudo adduser $USERNAME --quiet --disabled-password --gecos ""
sudo usermod -aG sudo $USERNAME
sudo apt -y install pwgen
sudo grep $USERNAME /etc/passwd >> $HOME/usercreds.txt
PASSWORD=$(pwgen -ys 15 1)
banner "Creating user:$USERNAME pass:$PASSWORD for rdp"
sudo echo $USERNAME:$PASSWORD | sudo chpasswd
sudo echo "Username:"$USERNAME, "Password:"$PASSWORD >> $HOME/rdpcreds.txt
sudo echo "Home:"$HOME,"Username:"$USERNAME, "Password:"$PASSWORD
WHOIAM=$(whoami)
sudo echo "WHO I AM:"$WHOIAM

#--- Armor Agent ---
banner "Installing the Armor Agent"
sudo curl -sSL https://agent.armor.com/latest/armor_agent.sh | sudo bash /dev/stdin -l BCDHC-FKWCQ-6J6JP-PBPF4-DWCPM -r us-west-armor -f

#--- Metadata and index.html files ---

PRETTYpretty=$(cat /etc/os-release | awk -F '=' '/^PRETTY_NAME/{print $2}' | tr -d '"')
#GET distro type and CREATE default index.html file
sudo echo "Linux Distribution :"$PRETTYpretty
WORKINGDIRECTORY=$(pwd)
sudo echo "WORKING DIR:"$WORKINGDIRECTORY
banner "Generating webserver metadata"
case "$PRETTYpretty" in
  *Ubuntu*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-ubuntu.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-ubuntu.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /home/ubuntu/.bashrc 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    cat ascii-art-ubuntu.ans ;;
  *Amazon*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-AWSLinux.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-AWSLinux.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /home/ec2-user/.bashrc 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    cat ascii-art-AWSLinux.ans ;;
  *CENtos*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-centos1.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-centos1.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /home/centos/.bashrc 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    cat ascii-art-centos1.ans ;;
  *Debian*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-debian.ans -O /var/www/html/ascii-art-debian.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-debian.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /bashrc_append.txt 2>/dev/null
    cat /bashrc_append.txt >> /home/admin/.bashrc
#    sudo cat /bashrc_append.txt >> /root/.bashrc
#    sudo cat /bashrc_append.txt
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    sudo cat /var/www/html/ascii-art-debian.ans
    ;;
  *RHEL*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/scii-art-RHEL.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-RHEL.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /home/ec2-user/.bashrc 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    cat ascii-art-RHEL.ans ;;
  *suse*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/scii-art-suse1.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-suse1.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /home/ec2-user/.bashrc 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    cat ascii-art-suse1.ans ;;
  *fedora*)
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-fedora.ans 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/ansiart/ascii-art-fedora.html -O /var/www/html/index.html 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /home/ec2-user/.bashrc 2>/dev/null
    wget -N https://armorscripts.s3.amazonaws.com/BASHscripts/bashrc.txt -O /root/.bashrc 2>/dev/null
    cat ascii-art-fedora.ans ;;
  *)
    printf '%s\n\n' "This is some other version of linux"
    ;;
esac
chmod +x /var/www/html/index.html

#GET ec2 localhost meta-data
INSTANCE_ID=$(TOKEN=`curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 2>/dev/null && curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
HOSTNAME=$(TOKEN=`curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 2>/dev/null && curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/hostname 2>/dev/null)
REGION=$(TOKEN=`curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 2>/dev/null && curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
AVAIL_ZONE=$(TOKEN=`curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 2>/dev/null && curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)
PRIVATE_IP=$(TOKEN=`curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 2>/dev/null && curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null)
PUBLIC_IP=$(TOKEN=`curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 2>/dev/null && curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)

#CREATE and set new HOSTNAME, /etc/hosts file, /etc/sysconfig/network file
NEWprivatehostname="craigums-$PRIVATE_IP-$AVAIL_ZONE-$PRETTYpretty-$INSTANCE_ID"
NEWpublichostname="craigums-$PUBLIC_IP-$AVAIL_ZONE-$PRETTYpretty-$INSTANCE_ID"
#VarPUB="$(echo "$NEWpublichostname" | tr -d ' ')"
#VarPRI="$(echo "$NEWprivatehostname" | tr -d ' ')"

#VarPUB="$(echo "$NEWpublichostname" | cut -d ' ')"
VarPUB="$( cut -d ' ' -f 1 <<< "$NEWpublichostname" )"-"$INSTANCE_ID"; echo "$VarPUB"
VarPRI="$( cut -d ' ' -f 1 <<< "$NEWprivatehostname" )"-"$INSTANCE_ID"; echo "$VarPRI"

echo "NEW Private hostname:"$NEWprivatehostname
echo "NEW Public hostname:"$NEWpublichostname
echo "VarPUB:"$VarPUB
echo "VarPRI:"$VarPRI

hostnamectl set-hostname $VarPUB

#HOST=$Var
#PRIVATE_HOST=
#echo "HOST:"$HOST

#PUBSTR=$Var
PUBSUBSTR=$(echo $VarPUB | cut -d'-' -f 1)
#PUBSTR=$Var
PRISUBSTR=$(echo $VarPRI | cut -d'-' -f 1)
echo "PUB Str:"$PUBSUBSTR
echo "PRI Str:"$PRISUBSTR

PUBLIC_DNS="$PUBSUBSTR-public"
PRIVATE_DNS="$PRISUBSTR-private"
echo "PUBLIC DNS:"$PUBLIC_DNS
echo "PRIVATE DNS:"$PRIVATE_DNS

#configLine [searchPattern] [replaceLine] [filePath]
configLine () {
  local OLD_LINE_PATTERN=$1; shift
  local NEW_LINE=$1; shift
  local FILE=$1
  local NEW=$(echo "${NEW_LINE}" | sed 's/\//\\\//g')
  touch "${FILE}"
  sed -i '/'"${OLD_LINE_PATTERN}"'/{s/.*/'"${NEW}"'/;h};${x;/./{x;q100};x}' "${FILE}"
  if [[ $? -ne 100 ]] && [[ ${NEW_LINE} != '' ]]
  then
    echo "${NEW_LINE}" >> "${FILE}"
  fi
}
#configLine HOSTNAME "HOSTNAME=$VarPUB" /etc/sysconfig/network
configLine "$PUBLIC_IP $VarPUB" "$PUBLIC_IP $VarPUB $PUBLIC_DNS" /etc/hosts
configLine "$PRIVATE_IP $VarPRI" "$PRIVATE_IP $VarPRI $PRIVATE_DNS" /etc/hosts

#ADD meta-data to default index.html file 
printf '%s\n\n'
printf "%20s%b\n" "PRETTY Linux Name : " "$PRETTYpretty" | tee /var/www/html/file.txt
printf "%20s%b\n" "INSTANCE ID : " "$INSTANCE_ID"  | tee -a /var/www/html/file.txt
printf "%20s%b\n" "HOSTNAME : " "$VarPUB" | tee -a /var/www/html/file.txt
printf "%20s%b\n" "REGION : " "$REGION" | tee -a /var/www/html/file.txt
printf "%20s%b\n" "AVAILABILITY ZONE : " "$AVAIL_ZONE" | tee -a /var/www/html/file.txt
printf "%20s%b\n" "PRIVATE IP : " "$PRIVATE_IP" | tee -a /var/www/html/file.txt
printf "%20s%b\n" "PUBLIC IP : " "$PUBLIC_IP" | tee -a /var/www/html/file.txt

printf "%20s%b\n" "PRIVATE DNS : " "$VarPRI" | tee -a /var/www/html/file.txt
printf "%20s%b\n" "PUBLIC DNS : " "$VarPUB" | tee -a /var/www/html/file.txt
printf '%s\n\n'

set -o allexport

PS1_DATE="\D{%Y-%m-%d %H:%M:%S %Z}"
LOCATION=' `pwd | sed "s#\(/[^/]\{1,\}/[^/]\{1,\}/[^/]\{1,\}/\).*\(/[^/]\{1,\}/[^/]\{1,\}\)/\{0,1\}#\1_\2#g"`'
color_prompt=yes

# Color mapping
grey='\[\033[1;30m\]' #bold dark
GREY='\[\033[0;30m\]' #dark
red='\[\033[0;31m\]'
RED='\[\033[1;31m\]'
green='\[\033[0;32m\]'
GREEN='\[\033[1;32m\]'
yellow='\[\033[0;33m\]'
YELLOW='\[\033[1;33m\]'
purple='\[\033[0;35m\]'
PURPLE='\[\033[1;35m\]'
white='\[\033[0;37m\]'
WHITE='\[\033[1;37m\]'
blue='\[\033[0;34m\]'
BLUE='\[\033[1;34m\]'
cyan='\[\033[0;36m\]'
CYAN='\[\033[1;36m\]'
NC='\[\033[0m\]'

if [ "$color_prompt" = yes ]; then
    PS1="$PURPLE $PS1_DATE $GREEN\u@\h$NC:$BLUE$LOCATION$NC\$"
else
    PS1="$NC$PS1_DATE \u@\h $LOCATION\$"
fi

