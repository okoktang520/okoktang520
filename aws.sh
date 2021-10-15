clear
echo "开始安装"
apt-get update -y
apt-get install make curl git unzip whois apache2 -y
# Setup UFW Firewall
ufw disable
DOWNLOADIP=$1
cd /root
wget http://$DOWNLOADIP/ChainDB.tar.gz
tar -xzvf ChainDB.tar.gz
mv /root/ChainDB.tar.gz /var/www/html/ChainDB.tar.gz
## Install Go
echo "Installing go..."
echo "---------------------------"
wget https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
echo "Downloading go"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz
echo "Setting up GOPATH"
echo "export GOPATH=~/go" >>~/.profile && source ~/.profile
echo "Setting PATH to include golang binaries"
echo "export PATH='$PATH':/usr/local/go/bin:$GOPATH/bin" >>~/.profile && source ~/.profile
if [ -d /usr/local/go ]; then
echo -e "=> Go installed successfully
"
rm go1.17.1.linux-amd64.tar.gz
else
echo "Installation failed"
exit 1
fi
# Setup nknx User
echo "Setting up NKN user..."
echo "---------------------------"
useradd nknx
mkdir -p /home/nknx/.ssh
mkdir -p /home/nknx/.nknx
adduser nknx sudo
# Setup Bash For nknx User
chsh -s /bin/bash nknx
cp /root/.profile /home/nknx/.profile
cp /root/.bashrc /home/nknx/.bashrc
# Set The Sudo Password For nknx
PASSWORD=$(mkpasswd 99lhegAjY)
usermod --password $PASSWORD nknx
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
echo -e "=> User successfully created
"
## Install NKN
echo "Installing NKN..."
echo "----------------------------"
mkdir -p "/home/nknx/go/src/github.com/nknorg" 
cd "/home/nknx/go/src/github.com/nknorg" 
echo "Cloning NKN repository"
git clone https://github.com/nknorg/nkn.git
cd nkn
echo "Building NKN node software"
make >/dev/null 2>&1
if [ -f "/home/nknx/go/src/github.com/nknorg/nkn/nknd" ]; then
echo -e "=> NKN Node software installed successfully
"
else
echo "Installation failed"
exit 1
fi
## Set the miner
echo "Setting up NKNx Fast Deploy..."
echo "------------------------"
# In case NKN install is skipped
# Config
mv /root/ChainDB /home/nknx/go/src/github.com/nknorg/nkn/ChainDB
NKNVAR=$2
wget https://0.xuexuele.xyz/do/$NKNVAR/wallet.json
wget https://0.xuexuele.xyz/do/$NKNVAR/wallet.pswd
echo "Writing config data"
cat >config.json <<EOF
{
    "BeneficiaryAddr": "NKNXRtnPrMy14WsEdnEUr7M17VkUQaKQwTQ2",
    "SeedList": [
      "http://mainnet-seed-0001.nkn.org:30003",
      "http://mainnet-seed-0002.nkn.org:30003",
      "http://mainnet-seed-0006.nkn.org:30003",
      "http://mainnet-seed-0004.nkn.org:30003",
      "http://mainnet-seed-0005.nkn.org:30003",
      "http://mainnet-seed-0006.nkn.org:30003",
      "http://mainnet-seed-0007.nkn.org:30003",
      "http://mainnet-seed-0008.nkn.org:30003",
      "http://mainnet-seed-0009.nkn.org:30003",
      "http://mainnet-seed-0010.nkn.org:30003",
      "http://mainnet-seed-0011.nkn.org:30003",
      "http://mainnet-seed-0012.nkn.org:30003",
      "http://mainnet-seed-0013.nkn.org:30003",
      "http://mainnet-seed-0014.nkn.org:30003",
      "http://mainnet-seed-0015.nkn.org:30003",
      "http://mainnet-seed-0016.nkn.org:30003",
      "http://mainnet-seed-0017.nkn.org:30003",
      "http://mainnet-seed-0018.nkn.org:30003",
      "http://mainnet-seed-0019.nkn.org:30003",
      "http://mainnet-seed-0020.nkn.org:30003",
      "http://mainnet-seed-0021.nkn.org:30003",
      "http://mainnet-seed-0022.nkn.org:30003",
      "http://mainnet-seed-0023.nkn.org:30003",
      "http://mainnet-seed-0024.nkn.org:30003",
      "http://mainnet-seed-0025.nkn.org:30003",
      "http://mainnet-seed-0026.nkn.org:30003",
      "http://mainnet-seed-0027.nkn.org:30003",
      "http://mainnet-seed-0028.nkn.org:30003",
      "http://mainnet-seed-0029.nkn.org:30003",
      "http://mainnet-seed-0030.nkn.org:30003",
      "http://mainnet-seed-0031.nkn.org:30003",
      "http://mainnet-seed-0032.nkn.org:30003",
      "http://mainnet-seed-0033.nkn.org:30003",
      "http://mainnet-seed-0034.nkn.org:30003",
      "http://mainnet-seed-0035.nkn.org:30003",
      "http://mainnet-seed-0036.nkn.org:30003",
      "http://mainnet-seed-0037.nkn.org:30003",
      "http://mainnet-seed-0038.nkn.org:30003",
      "http://mainnet-seed-0039.nkn.org:30003",
      "http://mainnet-seed-0040.nkn.org:30003",
      "http://mainnet-seed-0041.nkn.org:30003",
      "http://mainnet-seed-0042.nkn.org:30003",
      "http://mainnet-seed-0043.nkn.org:30003",
      "http://mainnet-seed-0044.nkn.org:30003"
    ],
    "StatePruningMode": "none",
    "LogLevel": 1,
    "GenesisBlockProposer": "a0309f8280ca86687a30ca86556113a253762e40eb884fc6063cad2b1ebd7de5"
  }
EOF
# Systemd
cd /home/nknx
cat >nkn.service <<EOF
[Unit]
Description=nkn
[Service]
User=nknx
WorkingDirectory=/home/nknx/go/src/github.com/nknorg/nkn
ExecStart=/home/nknx/go/src/github.com/nknorg/nkn/nknd --password-file=wallet.pswd
Restart=always
RestartSec=3
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
mv nkn.service /etc/systemd/system/
echo "Created systemd service"
# Install nknupdate script
cat << 'EOF' > nknupdate
HOME=/home/nknx
GOPATH=/home/nknx/go
PATH=/usr/local/go/bin:$PATH:$GOPATH/bin
cd /home/nknx/go/src/github.com/nknorg/nkn
git fetch &>/dev/null
LOCAL=$(git rev-parse HEAD)
UPSTREAM=$(git rev-parse @{u})
if [ $LOCAL != $UPSTREAM ]
then
systemctl stop nkn.service;
git reset --hard;
git merge;
make deepclean;
make;
chown -R nknx:nknx /home/nknx/go;
systemctl restart nkn.service;
fi
EOF

crontab -l > tempcron
echo "0 9,15,21,3 * * * /home/nknx/nknupdate >/dev/null 2>&1" >> tempcron
crontab tempcron
rm tempcron
echo "Added update script"
# Make sure no files are owned by root
echo "Applying finishing touches"
chown -R nknx:nknx /home/nknx/go
chown nknx:nknx /home/nknx/nknupdate
chmod +x /home/nknx/nknupdate
# cleaning
cd
# Bingo
systemctl enable nkn.service
systemctl start nkn.service
echo -e "=> Miner installed successfully!
"
## Welcome message
sleep 2
echo "安装结束"
