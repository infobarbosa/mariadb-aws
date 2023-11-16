#!/bin/sh

echo "Instalação iniciada em `date -Is`" >> /tmp/install.log
echo "Instalação iniciada em `date -Is`" >> /root/status-instalacao.txt
sudo apt update -y >> /tmp/install.log

# Pré-requisitos
sudo apt update -y >> /tmp/install.log
sudo apt install -y wget software-properties-common dirmngr ca-certificates apt-transport-https >> /tmp/install.log

# Executando a instalação
sudo apt install mariadb-server -y >> /tmp/install.log

# Ativando o serviço
sudo systemctl enable mariadb >> /tmp/install.log

# Inicializando o serviço
sudo systemctl start mariadb >> /tmp/install.log

# Criando o usuário `barbosa`

mariadb -e "CREATE USER 'barbosa'@localhost IDENTIFIED BY 'inseguro';" >> /tmp/install.log

# Concedendo acesso administrativo
mariadb -e "GRANT ALL ON *.* TO 'barbosa'@'localhost' IDENTIFIED BY 'inseguro' WITH GRANT OPTION;" >> /tmp/install.log

mariadb -e "FLUSH PRIVILEGES;" >> /tmp/install.log

####################################
# Instalação do engine ColumnStore #
####################################

#Baixando o pacote de configuração do repositório do MariaDB
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup >> /tmp/install.log

# Tornando o pacote executável
chmod +x mariadb_repo_setup >> /tmp/install.log

# Setup de repositório para a versão `mariadb-10.6`
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6" >> /tmp/install.log

# Atualizando a biblioteca de pacotes
sudo apt update -y >> /tmp/install.log

# Instalando o plugin `mariadb-plugin-columnstore`
sudo apt install -y libjemalloc2 mariadb-backup libmariadb3 mariadb-plugin-columnstore >> /tmp/install.log

### Reiniciando o serviço
systemctl restart mariadb >> /tmp/install.log

echo "Instalação finalizada em `date -Is`" >> /tmp/install.log
echo "Instalação finalizada em `date -Is`" >> /root/status-instalacao.txt