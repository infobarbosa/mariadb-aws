#!/bin/sh

echo "Instalação iniciada em `date -Is`" >> /tmp/install.log

echo "`date -Is` - Removendo instalação do MySQL"
sudo apt remove -y mysql-server

echo "`date -Is` - Atualizando pacotes do sistema"
sudo apt update -y >> /tmp/install.log

echo "`date -Is` - Instalando pré-requisitos" >> /tmp/install.log
sudo apt install -y wget software-properties-common dirmngr ca-certificates apt-transport-https >> /tmp/install.log

echo "`date -Is` - Executando a instalação" >> /tmp/install.log
sudo apt install mariadb-server -y >> /tmp/install.log

echo "`date -Is` - Ativando o serviço" >> /tmp/install.log
sudo systemctl enable mariadb >> /tmp/install.log

echo "`date -Is` - Inicializando o serviço" >> /tmp/install.log
sudo systemctl start mariadb >> /tmp/install.log

echo "`date -Is` - Criando o usuário barbosa" >> /tmp/install.log
sudo mariadb -e "CREATE USER 'barbosa'@localhost IDENTIFIED BY 'inseguro';" >> /tmp/install.log

echo "`date -Is` - Concedendo acesso administrativo" >> /tmp/install.log
sudo mariadb -e "GRANT ALL ON *.* TO 'barbosa'@'localhost' IDENTIFIED BY 'inseguro' WITH GRANT OPTION;" >> /tmp/install.log

sudo mariadb -e "FLUSH PRIVILEGES;" >> /tmp/install.log


echo "`date -Is` - Instalação do engine ColumnStore" >> /tmp/install.log


echo "`date -Is` - Baixando o pacote de configuração do repositório do MariaDB" >> /tmp/install.log
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup >> /tmp/install.log

echo "`date -Is` - Tornando o pacote executável" >> /tmp/install.log
chmod +x mariadb_repo_setup >> /tmp/install.log

echo "`date -Is` - Setup de repositório para a versão mariadb-10.6" >> /tmp/install.log
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6" >> /tmp/install.log

echo "`date -Is` - Atualizando a biblioteca de pacotes" >> /tmp/install.log
sudo apt update -y >> /tmp/install.log

echo "`date -Is` - Instalando o plugin mariadb-plugin-columnstore" >> /tmp/install.log
sudo apt install -y libjemalloc2 mariadb-backup libmariadb3 mariadb-plugin-columnstore >> /tmp/install.log

echo "`date -Is` - Reiniciando o serviço" >> /tmp/install.log
sudo systemctl restart mariadb >> /tmp/install.log

echo "Instalação finalizada em `date -Is`" >> /tmp/install.log
