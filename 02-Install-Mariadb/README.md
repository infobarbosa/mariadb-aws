# Instalação do Mariadb
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

Nesta sessão vamos instalar o Mariadb. Temos duas possibilidades: a instalação automatizada via script `setup_mariadb.sh` e a instalação passo-a-passo.

## Instalação automática
Caso você opte pela instalação automatizada, basta executar o script abaixo no terminal.
> Atenção! Esse script presume que o sistema operacional de instalação seja Ubuntu.

```
sh scripts/setup_mariadb.sh
```

### Instalação passo-a-passo

#### Removendo instalação do MySQL

Matando o processo
```
sudo pkill mysql
```

```
sudo apt remove -y mysql-server
```

```
sudo apt autoremove -y
```

```
sudo rm -r /var/lib/mysql
```

#### Atualizando o sistema
```
sudo apt update -y 
```

#### Instalando dependências
```
sudo apt install -y wget software-properties-common dirmngr ca-certificates apt-transport-https 
```

#### Executando a instalação
```
sudo apt install mariadb-server -y
```

#### Ativando o serviço
```
sudo systemctl enable mariadb
```

#### Inicializando o serviço"
```
sudo systemctl start mariadb
```

##### Criando o usuário barbosa"
```
sudo mariadb -e "CREATE USER 'barbosa'@localhost IDENTIFIED BY 'pessimasenha';"
```

##### Concedendo acesso administrativo"
```
sudo mariadb -e "GRANT ALL ON *.* TO 'barbosa'@'localhost' IDENTIFIED BY 'pessimasenha' WITH GRANT OPTION;"
```

```
sudo mariadb -e "FLUSH PRIVILEGES;"
```


### Instalação do engine ColumnStore

##### Baixando o pacote de configuração do repositório do MariaDB"
```
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
```

##### Tornando o pacote executável
```
chmod +x mariadb_repo_setup
```

##### Setup de repositório para a versão mariadb-11.1
```
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-11.1"
```

##### Atualizando a biblioteca de pacotes
```
sudo apt update -y
```

##### Instalando o plugin mariadb-plugin-columnstore
```
sudo apt install -y libjemalloc2 mariadb-backup libmariadb3 mariadb-plugin-columnstore
```

##### Reiniciando o serviço
```
sudo systemctl restart mariadb
```

Parabéns! Instalação finalizada.