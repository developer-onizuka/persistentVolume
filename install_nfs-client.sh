
ssh vagrant@192.168.33.101 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.102 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.103 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.104 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.105 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.106 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.107 sudo apt-get -y install nfs-client
ssh vagrant@192.168.33.108 sudo apt-get -y install nfs-client

ssh vagrant@192.168.33.101 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.102 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.103 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.104 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.105 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.106 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.107 sudo mount -v 192.168.33.11:/ /mnt
ssh vagrant@192.168.33.108 sudo mount -v 192.168.33.11:/ /mnt
