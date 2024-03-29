# is-gorusmesi-once-hazirlik

## Virtualbox IP aralığı

### networks.conf
/etc/vbox/networks.conf içine IP aralığını denetimini kapatmak için aşağıdaki satırı ekledim. [Kaynak](https://forums.virtualbox.org/viewtopic.php?p=527225&hilit=networks.conf#p527225)
```
* 0.0.0.0/0 ::/0
```
Ancak okudupum kadarıyla Virtualbox 6.1 üstü sürümlerinde IP aralığında 198.162.63.254'in üstünü kabûl etmiyor. [Kaynak](https://stackoverflow.com/questions/69728426/e-accessdenied-when-creating-a-host-only-interface-on-virtualbox-via-vagrant) Kendi denememde 198.162.56.255'in üstünü yine kabûl etmedi. Hata kodu:
```bash
VBoxManage: error: Code E_ACCESSDENIED (0x80070005) - Access denied
```

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
 cd Applications/
 cd VirtualBoxMachines/
 cd ubuntu/
 vagrant up ubuntum
 vagrant ssh ubuntum
```
## Ubuntu
### DNS
nameservers: altına address: [8.8.8.8. 8.8.4.4] eklendi.
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
### docker ve docker stable
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
#### docker yükleme
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```
#### docker compose yükleme
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
#### docker compose çalıştırabilmek için binary
```bash
sudo chmod +x /usr/local/bin/docker-compose
```
#### versiyon
```bash
docker --version
docker-compose --version
```
#### Busybox kurulumu
```bash
sudo docker pull busybox:1.35.0
```
### wordpress
Docker github'ındaki hazır [wordpress'i](https://github.com/docker/awesome-compose/blob/master/official-documentation-samples/wordpress/README.md) kullandım.
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
#### docker-compose servisi başlatma
```bash
sudo docker-compose -f docker-compose-wordpress.yaml up -d
```
#### wordpress konteynır id
```bash
WP_CONTAINER_ID=$(sudo docker-compose -f docker-compose-wordpress.yaml ps -q wordpress)
```
#### wordpress servie loglarını ekrana yazdırma
```bash
sudo docker logs $WP_CONTAINER_ID
```
#### imaj bilgilerini ekrana yazdırma
```bash
sudo docker images
```
#### database konteynır id
```bash
DB_CONTAINER_ID=$(sudo docker-compose -f docker-compose-wordpress.yaml ps -q db)
```
#### veritabanı konteynırına giriş ve tablolaları yazdırma
```bash
sudo docker exec -it $DB_CONTAINER_ID bash
mysql -u root -p wordpress
```
Şifremiz: `somewordpress`
```bash
show tables;
exit;
exit;
```

#### servisi durdurma
```bash
sudo docker-compose -f docker-compose-wordpress.yaml down
```
#### imajları silme
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
-Host makine
```bash
 cd Applications/
 cd VirtualBoxMachines/
 cd rockyLinux/
 vagrant up rockym
 vagrant ssh rockym
```
### LinuxAdmin user
`LinuxAdmin`  kullanıcısı ekle
```bash
sudo useradd LinuxAdmin
sudo passwd LinuxAdmin
```
Şifremiz: `SysAdmin99`
### `LinuxAdmin`  root şifresi kaldırma
```bash
sudo nano /etc/sudoers
```
Dosyanın sonuna eklenecek
```bash
LinuxAdmin ALL=(ALL) NOPASSWD:ALL
```
### tarih bas
```bash
mkdir files/
cd files/
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
Root yetkisi ver
```bash
sudo chown root tarih-bas.sh
```
İzinleri 777 olarak değiştir
```bash
sudo chmod 777 tarih-bas.sh
```


### Error anahtar kelimesini filtreleme
```bash
username=$(whoami)
sudo chown $username:$username /home/LinuxAdmin
grep -i "error" /var/log/syslog | sudo tee /home/LinuxAdmin/error.logs
```
### k3s

```bash
# firewalld durdur
systemctl disable firewalld --now
```
Burda bir hata alıyorum çözemedim.
```bash
curl -sfL https://get.k3s.io | sh -
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
sudo k3s kubectl get node
# Burada hata veriyor. Henüz çözemedim.
```
Hata kodu:
```bash
E0324 16:40:43.718588   33368 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp [::1]:8080: connect: connection refused
```
