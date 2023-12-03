#!/bin/sh

echo "Instalação iniciada em `date -Is`" >> /tmp/install.log

echo "`date -Is` - Removendo instalação do MySQL"
sudo pkill mysql
sudo apt remove -y mysql-server
sudo apt autoremove -y
sudo rm -r /var/lib/mysql

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
sudo mariadb -e "CREATE USER 'barbosa'@localhost IDENTIFIED BY 'pessimasenha';" >> /tmp/install.log

echo "`date -Is` - Concedendo acesso administrativo" >> /tmp/install.log
sudo mariadb -e "GRANT ALL ON *.* TO 'barbosa'@'localhost' IDENTIFIED BY 'pessimasenha' WITH GRANT OPTION;" >> /tmp/install.log

sudo mariadb -e "FLUSH PRIVILEGES;" >> /tmp/install.log


echo "`date -Is` - Instalação do engine ColumnStore" >> /tmp/install.log


echo "`date -Is` - Baixando o pacote de configuração do repositório do MariaDB" >> /tmp/install.log
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup >> /tmp/install.log

echo "`date -Is` - Tornando o pacote executável" >> /tmp/install.log
chmod +x mariadb_repo_setup >> /tmp/install.log

echo "`date -Is` - Setup de repositório para a versão mariadb-11.2" >> /tmp/install.log
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-11.2" >> /tmp/install.log

echo "`date -Is` - Atualizando a biblioteca de pacotes" >> /tmp/install.log
sudo apt update -y >> /tmp/install.log

echo "`date -Is` - Instalando o plugin mariadb-plugin-columnstore" >> /tmp/install.log
sudo apt install -y libjemalloc2 mariadb-backup libmariadb3 mariadb-plugin-columnstore >> /tmp/install.log

echo "`date -Is` - Reiniciando o serviço" >> /tmp/install.log
sudo systemctl restart mariadb >> /tmp/install.log

echo "`date -Is` - Instalação finalizada." >> /tmp/install.log

echo "`date -Is` - Iniciando setup de schema e carga de dados." >> /tmp/install.log

echo "`date -Is` - Criando o database ecommerce."  >> /tmp/install.log

sudo mariadb -e "CREATE DATABASE ecommerce;" >> /tmp/install.log

echo "`date -Is` - Tabela ecommerce.invoices com engine InnoDB" >> /tmp/install.log

sudo mariadb -e "
    CREATE TABLE ecommerce.invoices(
        InvoiceDate text,
        Country text,
        InvoiceNo text,
        StockCode text,
        Description text,
        CustomerID text,
        Quantity float,
        UnitPrice float
    ) engine=InnoDB;"

## verificando se deu certo
echo "`date -Is` - DESCRIBE ecommerce.invoices;"  >> /tmp/install.log
sudo mariadb -e "DESCRIBE ecommerce.invoices;"  >> /tmp/install.log

echo "`date -Is` - Table ecommerce.invoices_cs com engine ColumnStore" >> /tmp/install.log

sudo mariadb -e "
    CREATE TABLE ecommerce.invoices_cs(
        InvoiceDate text,
        Country text,
        InvoiceNo text,
        StockCode text,
        Description text,
        CustomerID text,
        Quantity float,
        UnitPrice float
    ) engine=ColumnStore;"

## verificando se deu certo:
echo "`date -Is` - DESCRIBE ecommerce.invoices_cs;" >> /tmp/install.log
sudo mariadb -e "DESCRIBE ecommerce.invoices_cs;" >> /tmp/install.log

echo "`date -Is` - Desempacotando invoices.tar.gz"  >> /tmp/install.log
tar -xzf assets/data/invoices.tar.gz -C /tmp/ >> /tmp/install.log

echo "`date -Is` - Examinando a estrutura do arquivo" >> /tmp/install.log
head /tmp/invoices.csv /tmp/install.log >> /tmp/install.log

echo "`date -Is` - Carga de dados invoices" >> /tmp/install.log

sudo mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;" >> /tmp/install.log

echo "`date -Is` - Verificando a carga invoices" >> /tmp/install.log

sudo mariadb -e "select * from ecommerce.invoices limit 10;" >> /tmp/install.log

echo "`date -Is` - Carga de dados invoices_cs" >> /tmp/install.log

sudo mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices_cs
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;" >> /tmp/install.log

echo "`date -Is` - Verificando a carga invoices_cs."  >> /tmp/install.log

sudo mariadb -e "select * from ecommerce.invoices_cs limit 10;" >> /tmp/install.log

echo "`date -Is` - Setup de schema e carga de dados finalizada." >> /tmp/install.log
