# Rowstore
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Objetivo
Avaliar de forma rudimentar o comportamento do modelo colunar de armazenamento.

>### Atenção! 
>   1. Os comandos desse tutorial presumem que você está no diretório `mariadb-aws`.

## root
```
sudo -i

```

Output:
```
voclabs:~/environment $ sudo -i
root@ip-172-31-2-249:~# 
```

## A base de dados
> Atenção!
>   Pule a criação da base de dados caso você tenha optado pela criação automática no Lab 02-Install-Mariadb

Vamos criar um database `ecommerce`:
```
sudo mariadb -e "CREATE DATABASE ecommerce;"
```

## Diretório de dados
```
cd /var/lib/columnstore/data1
```

Output:
```
root@ip-172-31-2-249:~# cd /var/lib/columnstore/data1
root@ip-172-31-2-249:/var/lib/columnstore/data1# 
```

## Tabela
### `ecommerce.cliente` com engine **ColumnStore**
```
mariadb -u root -e "
    CREATE TABLE ecommerce.cliente_cs(
        id_cliente int,
        cpf text,
        nome text
    ) engine=ColumnStore;"

```

Verificando se deu certo:
```
mariadb -u root -e "DESCRIBE ecommerce.cliente_cs;";
```

Output:
```
root@ip-172-31-2-249:/var/lib/columnstore/data1# mariadb -u root -e "DESCRIBE ecommerce.cliente_cs;";
+------------+---------+------+-----+---------+-------+
| Field      | Type    | Null | Key | Default | Extra |
+------------+---------+------+-----+---------+-------+
| id_cliente | int(11) | YES  |     | NULL    |       |
| cpf        | text    | YES  |     | NULL    |       |
| nome       | text    | YES  |     | NULL    |       |
+------------+---------+------+-----+---------+-------+
root@ip-172-31-2-249:/var/lib/columnstore/data1# 

```

## Verificando o arquivo de dados
```
ls -latr
```

Output:
```
root@ip-172-31-2-249:/var/lib/columnstore/data1# ls -latr
total 340
drwxr-xr-t 3 mysql mysql   4096 Dec  3 17:56 systemFiles
-rw-r--r-- 1 root  root       0 Dec  3 17:56 dbroot1-lock
drwxr-xr-x 5 mysql mysql   4096 Dec  3 17:56 ..
drwxrwxr-x 3 mysql mysql   4096 Dec  3 17:56 000.dir
drwxr-xr-t 5 mysql mysql   4096 Dec  3 17:56 .
drwxr-xr-x 2 mysql mysql   4096 Dec  3 18:15 bulkRollback
-rw-r--r-- 1 mysql mysql 327680 Dec  3 20:48 versionbuffer.cdf
root@ip-172-31-2-249:/var/lib/columnstore/data1# 
```

```
find . -type f -name "*.cdf"
```

Output:
```
root@ip-172-31-2-249:/var/lib/columnstore/data1# find . -type f -name "*.cdf"
./versionbuffer.cdf
./000.dir/000.dir/004.dir/002.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/013.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/004.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/005.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/019.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/017.dir/000.dir/FILE000.cdf
...
./000.dir/000.dir/008.dir/022.dir/000.dir/FILE000.cdf
root@ip-172-31-2-249:/var/lib/columnstore/data1# 
...
```

### Dicionário de dados
Precisamos recorrer ao dicionário de dados para descobrir quais arquivos armazenam os dados da tabela `cliente_cs`
```
mariadb -u root -e "
    select cols.table_schema, cols.table_name, cols.column_name, files.filename
    from information_schema.columnstore_columns cols 
    left join information_schema.columnstore_files files 
    on files.object_id = cols.object_id
    where cols.table_schema = 'ecommerce'
    and cols.table_name = 'cliente_cs';"

```

Output:
```
root@ip-172-31-2-249:/var/lib/columnstore/data1/000.dir/000.dir/011.dir/213.dir/000.dir# mariadb -u root -e "
>     select cols.table_schema, cols.table_name, cols.column_name, files.filename
>     from information_schema.columnstore_columns cols 
>     left join information_schema.columnstore_files files 
>     on files.object_id = cols.object_id
>     where cols.table_schema = 'ecommerce'
>     and cols.table_name = 'cliente_cs';"
+--------------+------------+-------------+--------------------------------------------------------------------------------+
| table_schema | table_name | column_name | filename                                                                       |
+--------------+------------+-------------+--------------------------------------------------------------------------------+
| ecommerce    | cliente_cs | id_cliente  | /var/lib/columnstore/data1/000.dir/000.dir/011.dir/208.dir/000.dir/FILE000.cdf |
| ecommerce    | cliente_cs | cpf         | /var/lib/columnstore/data1/000.dir/000.dir/011.dir/209.dir/000.dir/FILE000.cdf |
| ecommerce    | cliente_cs | nome        | /var/lib/columnstore/data1/000.dir/000.dir/011.dir/210.dir/000.dir/FILE000.cdf |
+--------------+------------+-------------+--------------------------------------------------------------------------------+
root@ip-172-31-2-249:/var/lib/columnstore/data1/000.dir/000.dir/011.dir/213.dir/000.dir# 
```

## Operações em linhas (ou registros)

### 1. 1o. Cliente
```
mariadb ecommerce -Bse \
"INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1001, '98753936060', 'MARIVALDA KANAMARY');
INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1002, '12455426050', 'JUCILENE MOREIRA CRUZ');
INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1003, '32487300051', 'GRACIMAR BRASIL GUERRA');
INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1004, '59813133074', 'ALDENORA VIANA MOREIRA');
INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1005, '79739952003', 'VERA LUCIA RODRIGUES SENA');
INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1006, '66142806000', 'IVONE GLAUCIA VIANA DUTRA');
INSERT INTO cliente_cs (id_cliente, cpf, nome) VALUES (1007, '19052330000', 'LUCILIA ROSA LIMA PEREIRA');"

```

Verificando:
```
mariadb -u root -e "SELECT * FROM ecommerce.cliente_cs;";
```

Output:
```
root@ip-172-31-2-249:/var/lib/columnstore/data1# mariadb -u root -e "SELECT * FROM ecommerce.cliente_cs;";
+------------+-------------+---------------------------+
| id_cliente | cpf         | nome                      |
+------------+-------------+---------------------------+
|       1001 | 98753936060 | MARIVALDA KANAMARY        |
|       1002 | 12455426050 | JUCILENE MOREIRA CRUZ     |
|       1003 | 32487300051 | GRACIMAR BRASIL GUERRA    |
|       1004 | 59813133074 | ALDENORA VIANA MOREIRA    |
|       1005 | 79739952003 | VERA LUCIA RODRIGUES SENA |
|       1006 | 66142806000 | IVONE GLAUCIA VIANA DUTRA |
|       1007 | 19052330000 | LUCILIA ROSA LIMA PEREIRA |
+------------+-------------+---------------------------+
root@ip-172-31-2-249:/var/lib/columnstore/data1# 

```

> ### Atenção! 
>   Ajuste os comandos abaixo de acordo com o arquivo de dados correto obtido anteriormente.

Arquivo de CPF
```
head -c 271999 /var/lib/columnstore/data1/000.dir/000.dir/011.dir/209.dir/000.dir/FILE000.cdf
```

```
head -c 271999 /var/lib/columnstore/data1/000.dir/000.dir/011.dir/210.dir/000.dir/FILE000.cdf
```

### Delete
```
mariadb -u root -e "DELETE FROM ecommerce.cliente_cs WHERE id_cliente = 1006;"
```

### Update
```
mariadb ecommerce -Bse \
"UPDATE cliente_cs SET nome='MARIVALDA DE ALCÂNTARA FRANCISCO ANTÔNIO JOÃO CARLOS XAVIER DE PAULA MIGUEL RAFAEL JOAQUIM JOSÉ GONZAGA PASCOAL CIPRIANO SERAFIM DE BRAGANÇA E BOURBON KANAMARY' WHERE id_cliente = 1001"

```

Verifique os resultados dos comandos acima nos arquivos de dados.