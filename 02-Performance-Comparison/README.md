# Comparação de performances
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Objetivo
Avaliar de forma rudimentar as performances do modelo de linha versus modelo colunar de armazenamento.

## A base de dados
Vamos criar um database `ecommerce`:
```
mariadb -e "CREATE DATABASE ecommerce;"
```

## Tabelas
### `ecommerce.invoices` com engine **InnoDB**
```
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
```

Verificando se deu certo:
```
mariadb -e "DESCRIBE ecommerce.invoices;"
```

### `ecommerce.invoices_cs` com engine **ColumnStore**
```
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
```

Verificando se deu certo:
```
mariadb -e "DESCRIBE ecommerce.invoices_cs;"
```

## Carga das tabelas

##### Voltando ao diretório `home`
```
cd ~
```

##### O arquivo `invoices.csv`
```
ls -latr invoices.tar.gz
```

```
tar -xzf invoices.tar.gz -C /tmp/
```

Examinando a estrutura do arquivo
```
head /tmp/invoices.csv
```

Número de linhas
```
wc -l /tmp/invoices.csv
```

### `invoices`
```
mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;"
```

Verificando a carga:
```
mariadb -e "select * from ecommerce.invoices limit 10;"
```

### `invoices_cs`
```
mariadb -e "
    LOAD DATA INFILE '/tmp/invoices.csv'
    INTO TABLE ecommerce.invoices_cs
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;"
```

Verificando a carga:
```
mariadb -e "select * from ecommerce.invoices_cs limit 10;"
```

### Teste 1 
#### Consulta analítica
```
mariadb -e "
    select count(distinct StockCode)
          ,max(UnitPrice) mx
          ,min(UnitPrice) mn
          ,avg(UnitPrice) average
    from ecommerce.invoices;"
```

```
mariadb -e "
    select count(distinct StockCode)
          ,max(UnitPrice) mx
          ,min(UnitPrice) mn
          ,avg(UnitPrice) average
    from ecommerce.invoices_cs;"
```

Medindo o tempo:
```
time { 
    mariadb -e "
        select count(distinct StockCode)
            ,max(UnitPrice) mx
            ,min(UnitPrice) mn
            ,avg(UnitPrice) average
        from ecommerce.invoices;"
}
```

```
time { 
    mariadb -e "
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
mariadb -e "
    select * 
    from ecommerce.invoices 
    where InvoiceNo='536365';"
```

```
mariadb -e "
    select * 
    from ecommerce.invoices_cs 
    where InvoiceNo='536365';"
```

```
time { 
    mariadb -e "
        select * 
        from ecommerce.invoices 
        where InvoiceNo='536365';"; 
}
```

```
time { 
    mariadb -e "
        select * 
        from ecommerce.invoices_cs 
        where InvoiceNo='536365';"; 
}
```

> Ops! O teste não foi necessariamente justo uma vez que a tabela `invoices` não tem um índice definido. 

#### Criando um índice na tabela `ecommerce.invoices`:
```
mariadb -e "ALTER TABLE ecommerce.invoices ADD INDEX invoices_i1 (InvoiceNo);"
```

### Teste 3 

#### Consulta indexada
Repetindo o teste:
```
mariadb -e "
    select * 
    from ecommerce.invoices
    where InvoiceNo='536365';"
```

```
mariadb -e "
    select * 
    from ecommerce.invoices_cs 
    where InvoiceNo='536365';"
```

```
time {  
    mariadb -e "
        select * 
        from ecommerce.invoices
        where InvoiceNo='536365';";
}
```

```
time {  
    mariadb -e "
        select * 
        from ecommerce.invoices_cs
        where InvoiceNo='536365';";
}
```
