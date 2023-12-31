# Comparação de performances
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Objetivo
Avaliar de forma rudimentar as performances do modelo de linha versus modelo colunar de armazenamento.

>### Atenção! 
>   1. Os comandos desse tutorial presumem que você está no diretório `mariadb-aws`.
>   2. Pule direto para **Teste 1** mais adiante caso você tenha optado pela instalação automática via script

## A base de dados
Vamos criar um database `ecommerce`:
```
sudo mariadb -e "CREATE DATABASE ecommerce;"
```

## Tabelas
### `ecommerce.invoices` com engine **InnoDB**
```
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
```

Verificando se deu certo:
```
sudo mariadb -e "DESCRIBE ecommerce.invoices;"
```

### `ecommerce.invoices_cs` com engine **ColumnStore**
```
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
```

Verificando se deu certo:
```
sudo mariadb -e "DESCRIBE ecommerce.invoices_cs;"
```

## Carga das tabelas

##### Voltando ao diretório `home`
```
cd ~
```

##### O arquivo `invoices.csv`
```
ls -latr assets/data/invoices.tar.gz
```

```
tar -xzf assets/data/invoices.tar.gz -C /tmp/
```

Examinando a estrutura do arquivo
```
head /tmp/invoices.csv
```

Número de linhas
```
wc -l /tmp/invoices.csv
```

### Carga de dados `invoices`
```
sudo mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;"
```

Verificando a carga:
```
sudo mariadb -e "select * from ecommerce.invoices limit 10;"
```

### Carga de dados `invoices_cs`
```
sudo mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices_cs
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;"
```

Verificando a carga:
```
sudo mariadb -e "select * from ecommerce.invoices_cs limit 10;"
```

### Teste 1 
#### Consulta analítica
```
sudo mariadb -e "
    select count(distinct StockCode)
          ,max(UnitPrice) mx
          ,min(UnitPrice) mn
          ,avg(UnitPrice) average
    from ecommerce.invoices;"
```

```
sudo mariadb -e "
    select count(distinct StockCode)
          ,max(UnitPrice) mx
          ,min(UnitPrice) mn
          ,avg(UnitPrice) average
    from ecommerce.invoices_cs;"
```

#### Medindo o tempo:
```
time { 
    sudo mariadb -e "
        select count(distinct StockCode)
            ,max(UnitPrice) mx
            ,min(UnitPrice) mn
            ,avg(UnitPrice) average
        from ecommerce.invoices;"
}
```

```
time { 
    sudo mariadb -e "
        select count(distinct StockCode)
            ,max(UnitPrice) mx
            ,min(UnitPrice) mn
            ,avg(UnitPrice) average
        from ecommerce.invoices_cs;"
}
```

### Teste 2 
#### Busca linha completa com restrição de valor
```
sudo mariadb -e "
    select * 
    from ecommerce.invoices 
    where InvoiceNo='536365';"
```

```
sudo mariadb -e "
    select * 
    from ecommerce.invoices_cs 
    where InvoiceNo='536365';"
```

#### Medindo o tempo:
```
time { 
    sudo mariadb -e "
        select * 
        from ecommerce.invoices 
        where InvoiceNo='536365';"; 
}
```

```
time { 
    sudo mariadb -e "
        select * 
        from ecommerce.invoices_cs 
        where InvoiceNo='536365';"; 
}
```

> Ops! O teste não foi necessariamente justo uma vez que a tabela `invoices` não tem um índice definido. 

#### Criando um índice na tabela `ecommerce.invoices`:
```
sudo mariadb -e "ALTER TABLE ecommerce.invoices ADD INDEX invoices_i1 (InvoiceNo);"
```

### Teste 3 

#### Consulta indexada
Repetindo o teste:
```
sudo mariadb -e "
    select * 
    from ecommerce.invoices
    where InvoiceNo='536365';"
```

```
sudo mariadb -e "
    select * 
    from ecommerce.invoices_cs 
    where InvoiceNo='536365';"
```

#### Medindo o tempo:
```
time {  
    sudo mariadb -e "
        select * 
        from ecommerce.invoices
        where InvoiceNo='536365';";
}
```

```
time {  
    sudo mariadb -e "
        select * 
        from ecommerce.invoices_cs
        where InvoiceNo='536365';";
}
```

### Teste de carga

Limpeza das tabelas:
```
sudo mariadb -e "truncate table ecommerce.invoices;";
```
```
sudo mariadb -e "truncate table ecommerce.invoices_cs;";
```

Checagem do conteúdo após a limpeza:
```
sudo mariadb -e "select count(1) from ecommerce.invoices;";
```
```
sudo mariadb -e "select count(1) from ecommerce.invoices_cs;";
```
	

#### Medindo o tempo de carga:
```
time {
sudo mariadb -e "
	LOAD DATA INFILE '/tmp/invoices.csv'
	INTO TABLE ecommerce.invoices
	FIELDS TERMINATED BY ','
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;"
}

```

```
time {
sudo mariadb -e "
	LOAD DATA INFILE '/tmp/invoices.csv'
	INTO TABLE ecommerce.invoices_cs
	FIELDS TERMINATED BY ','
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;"
}

```
