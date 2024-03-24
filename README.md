# is-gorusmesi-once-hazirlik

Home dizini içinde:
 ```bash
 mkdir Applications
 cd Applications/
 mkdir VirtualBoxMachines
 cd VirtualBoxMachines/
 cd ubuntu/
 vagrant box add ubuntu/focal64
 vagrant box add eurolinux-vagrant/rocky-8
 ```
Host makine
```bash
 vagrant up machine1
 vagrant ssh machine1
```
## Ubuntu
### DNS
```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```
```yaml
network:
    ethernets:
        enp0s3:
            dhcp4: true
            match:
                macaddress: 02:e9:94:e1:d4:13
            set-name: enp0s3
            nameservers:
              addresses: [8.8.8.8, 8.8.4.4]
    version: 2
```
```bash
sudo netplan apply
```
### Update
```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```
### docker
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
### docker stable
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
### docker yükleme
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```
### docker compose yükleme
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
### docker compose çalıştırabilmek için binary
```bash
sudo chmod +x /usr/local/bin/docker-compose
```
### versiyon
```bash
docker --version
docker-compose --version
```
### Busybox kurulumu
```bash
sudo docker pull busybox:1.35.0
```
### docker-compose kurulumu
```bash
mkdir wordpress/
cd wordpress/
sudo nano docker-compose-wordpress.yaml
```
```yaml
services:
  db:
    image: mariadb:10.6.4-focal
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=somewordpress
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=wordpress
    expose:
      - 3306
      - 33060
  wordpress:
    image: wordpress:latest
    volumes:
      - wp_data:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=wordpress
      - WORDPRESS_DB_PASSWORD=wordpress
      - WORDPRESS_DB_NAME=wordpress
volumes:
  db_data:
  wp_data:
```
### docker-compose servisi başlatma
```bash
sudo docker-compose -f docker-compose-wordpress.yaml up -d
```
### wordpress konteynır id
```bash
WP_CONTAINER_ID=$(sudo docker-compose -f docker-compose-wordpress.yaml ps -q wordpress)
```
### wordpress servie loglarını ekrana yazdırma
```bash
sudo docker logs $WP_CONTAINER_ID
```
### imaj bilgilerini ekrana yazdırma
```bash
sudo docker images
```
### database konteynır id
```bash
DB_CONTAINER_ID=$(sudo docker-compose -f docker-compose-wordpress.yaml ps -q db)
```
### veritabanı konteynırına giriş ve tablolaları yazdırma
```bash
sudo docker exec -it $DB_CONTAINER_ID bash
mysql -u root -p wordpress
```
Şifremiz: somewordpress
```bash
show tables;
exit;
exit;
```

### servisi durdurma
```bash
sudo docker-compose -f docker-compose-wordpress.yaml down
```
### imajları silme
```bash
sudo nano remove-images.sh
```
```bash
#!/bin/bash 

# calisan konteynirlari durdur 
docker stop $(docker ps -a -q) 

# konteynirleri kaldir
docker rm $(docker ps -a -q) 

# imajlari kaldır
docker rmi wordpress mariadb

echo "imajlar kaldirildi" 

exit 0
```
```bash
sudo chmod +x remove-images.sh
```
```bash
./remove-images.sh
```
## rockylinux

### LinuxAdmin user
Şifre koşullarını değiştir
```bash
sudo nano /etc/pam.d/system-auth
```
```bash
auth        required                                     pam_env.so
auth        required                                     pam_faildelay.so delay=2000000
auth        [default=1 ignore=ignore success=ok]         pam_usertype.so isregular
auth        [default=1 ignore=ignore success=ok]         pam_localuser.so
auth        sufficient                                   pam_unix.so nullok
auth        [default=1 ignore=ignore success=ok]         pam_usertype.so isregular
auth        sufficient                                   pam_sss.so forward_pass
auth        required                                     pam_deny.so

account     required                                     pam_unix.so
account     sufficient                                   pam_localuser.so
account     sufficient                                   pam_usertype.so issystem
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account     required                                     pam_permit.so

# password    requisite                                    pam_pwquality.so local_users_only use_authok sildim alt satirdan
password    sufficient                                   pam_unix.so sha512 shadow nullok
password    [success=1 default=ignore]                   pam_localuser.so
password    sufficient                                   pam_sss.so use_authtok
password    required                                     pam_deny.so

session     optional                                     pam_keyinit.so revoke
session     required                                     pam_limits.so
-session    optional                                     pam_systemd.so
session     [success=1 default=ignore]                   pam_succeed_if.so service in crond quiet use_uid
session     required                                     pam_unix.so
session     optional                                     pam_sss.so

```
```bash
sudo useradd LinuxAdmin
sudo passwd LinuxAdmin
```
Şifremiz: SysAdmin99
### LinuxAdmin root şifresi kaldırma
```bash
sudo nano /etc/sudoers
```
Dosyanın sonuna eklenecek
```bash
LinuxAdmin ALL=(ALL) NOPASSWD:ALL
```
### tarih bas
```bash
nano tarih-bas.sh
```
```bash
#!/bin/bash

username=$(whoami)
currenttime=$(date +"%T")
currentdate=$(date +"%D")

echo "Ad: $username"
echo "Saat: $currenttime"
echo "Tarih: $currentdate"
```
sudo chown root tarih-bas.sh
sudo chmod 777 tarih-bas.sh
sudo systemctl stop ufw
systemctl status ufw

### Error anahtar kelimesini filtreleme
```bash
username=$(whoami)
sudo chown $username:$username /home/LinuxAdmin
grep -i "error" /var/log/syslog | sudo tee /home/LinuxAdmin/error.logs
```
### k3s
Burda bir hata alıyorum çözemedim.
```bash
curl -sfL https://get.k3s.io | sh -
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```
