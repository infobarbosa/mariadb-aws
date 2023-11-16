# Comparação de performances
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Objetivo
Avaliar de forma rudimentar as performances do modelo de linha versus modelo colunar de armazenamento.

## A base de dados
Vamos criar um database `ecommerce`:
```plain
mariadb -e "CREATE DATABASE ecommerce;"
```{{exec}}

## Tabelas
### `ecommerce.invoices` com engine **InnoDB**
```plain
mariadb -e "
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
```{{exec}}

Verificando se deu certo:
```plain
mariadb -e "DESCRIBE ecommerce.invoices;"
```{{exec}}

### `ecommerce.invoices_cs` com engine **ColumnStore**
```plain
mariadb -e "
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
```{{exec}}

Verificando se deu certo:
```plain
mariadb -e "DESCRIBE ecommerce.invoices_cs;"
```{{exec}}

## Carga das tabelas

##### Voltando ao diretório `home`
```
cd ~
```{{exec}}

##### O arquivo `invoices.csv`
```plain
ls -latr invoices.tar.gz
```{{exec}}

```plain
tar -xzf invoices.tar.gz -C /tmp/
```{{exec}}

Examinando a estrutura do arquivo
```plain
head /tmp/invoices.csv
```{{exec}}

Número de linhas
```plain
wc -l /tmp/invoices.csv
```{{exec}}

### `invoices`
```plain
mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;"
```{{exec}}

Verificando a carga:
```plain
mariadb -e "select * from ecommerce.invoices limit 10;"
```{{exec}}

### `invoices_cs`
```plain
mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices_cs
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;"
```{{exec}}

Verificando a carga:
```plain
mariadb -e "select * from ecommerce.invoices_cs limit 10;"
```{{exec}}

### Teste 1 
#### Consulta analítica
```plain
mariadb -e "
    select count(distinct StockCode)
          ,max(UnitPrice) mx
          ,min(UnitPrice) mn
          ,avg(UnitPrice) average
    from ecommerce.invoices;"
```{{exec}}

```plain
mariadb -e "
    select count(distinct StockCode)
          ,max(UnitPrice) mx
          ,min(UnitPrice) mn
          ,avg(UnitPrice) average
    from ecommerce.invoices_cs;"
```{{exec}}

Medindo o tempo:
```plain
time { 
    mariadb -e "
        select count(distinct StockCode)
            ,max(UnitPrice) mx
            ,min(UnitPrice) mn
            ,avg(UnitPrice) average
        from ecommerce.invoices;"
}
```{{exec}}

```plain
time { 
    mariadb -e "
        select count(distinct StockCode)
            ,max(UnitPrice) mx
            ,min(UnitPrice) mn
            ,avg(UnitPrice) average
        from ecommerce.invoices_cs;"
}
```{{exec}}

### Teste 2 
#### Busca linha completa com restrição de valor
```plain
mariadb -e "
    select * 
    from ecommerce.invoices 
    where InvoiceNo='536365';"
```{{exec}}

```plain
mariadb -e "
    select * 
    from ecommerce.invoices_cs 
    where InvoiceNo='536365';"
```{{exec}}

```plain
time { 
    mariadb -e "
        select * 
        from ecommerce.invoices 
        where InvoiceNo='536365';"; 
}
```{{exec}}

```plain
time { 
    mariadb -e "
        select * 
        from ecommerce.invoices_cs 
        where InvoiceNo='536365';"; 
}
```{{exec}}

> Ops! O teste não foi necessariamente justo uma vez que a tabela `invoices` não tem um índice definido. 

#### Criando um índice na tabela `ecommerce.invoices`:
```plain
mariadb -e "ALTER TABLE ecommerce.invoices ADD INDEX invoices_i1 (InvoiceNo);"
```{{exec}}

### Teste 3 

#### Consulta indexada
Repetindo o teste:
```plain
mariadb -e "
    select * 
    from ecommerce.invoices
    where InvoiceNo='536365';"
```{{exec}}

```plain
mariadb -e "
    select * 
    from ecommerce.invoices_cs 
    where InvoiceNo='536365';"
```{{exec}}

```plain
time {  
    mariadb -e "
        select * 
        from ecommerce.invoices
        where InvoiceNo='536365';";
}
```{{exec}}

```plain
time {  
    mariadb -e "
        select * 
        from ecommerce.invoices_cs
        where InvoiceNo='536365';";
}
```{{exec}}
