# is-gorusmesi-once-hazirlik

Home dizini içinde:
 ```bash
 mkdir Applications
 cd Applications/
 mkdir VirtualBoxMachines
 cd VirtualBoxMachines/
 cd ubuntu/
 vagrant box add ubuntu/focal64
 vagrant up
 ```
 ```bash
 logout
 vagrant halt
 ```

Host makine
```bash
 vagrant up machine1
 vagrant ssh machine1
```
## Ubuntu
 Update
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
DB_CONTAINER_ID=$(docker-compose -f docker-compose-wordpress.yaml ps -q db)
```
### veritabanı konteynırına giriş ve tablolaları yazdırma
```bash
sudo docker exec -it $DB_CONTAINER_ID bash
mysql -u root -p wordpress
```
```bash
show tables;
```
```bash
exit;
```
```bash
exit;
```

### servisi durdurma
```bash
sudo docker-compose -f docker-compose-wordpress.yaml down
```
### imajları silme
```bash
chmod +x remove-images.sh
```
```bash
./remove-images.sh
```
