# Rowstore
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Objetivo
Avaliar de forma rudimentar o comportamento do modelo de linha.

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
cd /var/lib/mysql/ecommerce/
```

Output:
```
root@ip-172-31-2-249:~# cd /var/lib/mysql/ecommerce/
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
```

## Tabelas
### `ecommerce.cliente` com engine **InnoDB**
```
mariadb -u root -e "
    CREATE TABLE ecommerce.cliente(
        id int PRIMARY KEY,
        cpf text,
        nome text
    );"

```

Verificando se deu certo:
```
mariadb -u root -e "DESCRIBE ecommerce.cliente;";
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# mariadb -u root -e "DESCRIBE ecommerce.cliente;";
+-------+---------+------+-----+---------+-------+
| Field | Type    | Null | Key | Default | Extra |
+-------+---------+------+-----+---------+-------+
| id    | int(11) | NO   | PRI | NULL    |       |
| cpf   | text    | YES  |     | NULL    |       |
| nome  | text    | YES  |     | NULL    |       |
+-------+---------+------+-----+---------+-------+
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 

```

## Verificando o arquivo de dados
```
ls -latr
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# ls -latr
total 86176
drwxr-xr-x 6 mysql mysql     4096 Dec  3 17:56 ..
-rw-rw---- 1 mysql mysql       67 Dec  3 17:56 db.opt
-rw-rw---- 1 mysql mysql      700 Dec  3 17:56 invoices_cs.frm
-rw-rw---- 1 mysql mysql     1187 Dec  3 18:05 invoices.frm
-rw-rw---- 1 mysql mysql 88080384 Dec  3 18:15 invoices.ibd
-rw-rw---- 1 mysql mysql      988 Dec  3 19:01 cliente.frm
-rw-rw---- 1 mysql mysql    65536 Dec  3 19:28 cliente.ibd
drwx------ 2 mysql mysql     4096 Dec  3 19:28 .
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
```

Perceba o arquivo `cliente.ibd`.

## Operações em linhas (ou registros)

### 1. 1o. Cliente
```
mariadb -u root -e "
    INSERT INTO ecommerce.cliente(id, cpf, nome)
    VALUES (10, '11111111111', 'marcelo barbosa');"

```

Verificando:
```
mariadb -u root -e "SELECT * FROM ecommerce.cliente;";
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# mariadb -u root -e "SELECT * FROM ecommerce.cliente;";
+----+-------------+-----------------+
| id | cpf         | nome            |
+----+-------------+-----------------+
| 10 | 11111111111 | marcelo barbosa |
+----+-------------+-----------------+
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
```

### 2. FLUSH TABLES

Vamos forçar o flush dos dados da memória para o disco de forma a verificar o arquivo de dados.
```
mariadb -u root -e "FLUSH LOCAL TABLES ecommerce.cliente FOR EXPORT;";
```

Verificando o conteúdo do arquivo `cliente.ibd`
```
cat cliente.ibd
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# cat cliente.ibd 
##9*##"!#E!2infimum
                   supremum

11111111111marcelo barbosapc#Mroot@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
```

### 3. 2o. Cliente
```
mariadb -u root -e "
    INSERT INTO ecommerce.cliente(id, cpf, nome)
    VALUES (11, '22222222222', 'Juscelino Kubitschek');";
```

Faça o flush novamente e verifique o arquivo:
```
mariadb -u root -e "FLUSH LOCAL TABLES ecommerce.cliente FOR EXPORT;";
```

```
cat cliente.ibd
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# cat cliente.ibd
##9*##"!#!2infimum
                  supremum
                          3
11111111111marcelo barbosa

                          22222222222Juscelino Kubitschekpc#root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
```

### 4. Vários clientes
```
mariadb ecommerce -Bse \
"INSERT INTO cliente (id, cpf, nome) VALUES (1001, '98753936060', 'MARIVALDA KANAMARY');
INSERT INTO cliente (id, cpf, nome) VALUES (1002, '12455426050', 'JUCILENE MOREIRA CRUZ');
INSERT INTO cliente (id, cpf, nome) VALUES (1003, '32487300051', 'GRACIMAR BRASIL GUERRA');
INSERT INTO cliente (id, cpf, nome) VALUES (1004, '59813133074', 'ALDENORA VIANA MOREIRA');
INSERT INTO cliente (id, cpf, nome) VALUES (1005, '79739952003', 'VERA LUCIA RODRIGUES SENA');
INSERT INTO cliente (id, cpf, nome) VALUES (1006, '66142806000', 'IVONE GLAUCIA VIANA DUTRA');
INSERT INTO cliente (id, cpf, nome) VALUES (1007, '19052330000', 'LUCILIA ROSA LIMA PEREIRA');"

```

Verificando:
```
mariadb -u root -e "SELECT * FROM ecommerce.cliente;";
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# mariadb -u root -e "SELECT * FROM ecommerce.cliente;";
+------+-------------+---------------------------+
| id   | cpf         | nome                      |
+------+-------------+---------------------------+
|   10 | 11111111111 | marcelo barbosa           |
|   11 | 22222222222 | Juscelino Kubitschek      |
| 1001 | 98753936060 | MARIVALDA KANAMARY        |
| 1002 | 12455426050 | JUCILENE MOREIRA CRUZ     |
| 1003 | 32487300051 | GRACIMAR BRASIL GUERRA    |
| 1004 | 59813133074 | ALDENORA VIANA MOREIRA    |
| 1005 | 79739952003 | VERA LUCIA RODRIGUES SENA |
| 1006 | 66142806000 | IVONE GLAUCIA VIANA DUTRA |
| 1007 | 19052330000 | LUCILIA ROSA LIMA PEREIRA |
+------+-------------+---------------------------+
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# 
```

Faça o flush novamente e verifique o arquivo:
```
mariadb -u root -e "FLUSH LOCAL TABLES ecommerce.cliente FOR EXPORT;";
```

```
cat cliente.ibd
```

Output:
```
root@ip-172-31-2-249:/var/lib/mysql/ecommerce# cat cliente.ibd
`:##
   O#
`T\-[#(mE}
          H "2infimum
                     supremum
                             3
11111111111marcelo barbosa
                          8
                           22222222222Juscelino Kubitschek
                                                           698753936060MARIVALDA KANAMARY
                                                                                         (912455426050JUCILENE MOREIRA CRUZ
                                                                                                                           0:32487300051GRACIMAR BRASIL GUERRA
                                                                                                                                                              8:59813133074ALDENORA VIANA MOREIRA
       @=79739952003VERA LUCIA RODRIGUES SENA
                                             H=66142806000IVONE GLAUCIA VIANA DUTRA
                                                                                   P(19052330000LUCILIA ROSA LIMA PEREIRAp!c#(mroot@ip-172-31-2-249:/var/lib/mysql/ecommerce#  
```

### 5. Delete
```
mariadb -u root -e "DELETE FROM ecommerce.cliente WHERE id = 11;"
```

Faça o flush novamente e verifique o arquivo:
```
mariadb -u root -e "FLUSH LOCAL TABLES ecommerce.cliente FOR EXPORT;";
```

```
cat cliente.ibd
```

> Perceba o espaço vazio entre o registro `marcelo` e `MARIVALDA`.

### 6. Update
```
mariadb ecommerce -Bse \
"UPDATE cliente SET nome='MARIVALDA K.' WHERE id = 1001"

```

```
mariadb -u root -e "FLUSH LOCAL TABLES ecommerce.cliente FOR EXPORT;";
```

```
cat cliente.ibd
```

> Perceba que o update praticamente não alterou o layout do arquivo.

```
mariadb ecommerce -Bse \
"UPDATE cliente SET nome='MARIVALDA DE ALCÂNTARA FRANCISCO ANTÔNIO JOÃO CARLOS XAVIER DE PAULA MIGUEL RAFAEL JOAQUIM JOSÉ GONZAGA PASCOAL CIPRIANO SERAFIM DE BRAGANÇA E BOURBON KANAMARY' WHERE id = 1001"
```

```
mariadb -u root -e "FLUSH LOCAL TABLES ecommerce.cliente FOR EXPORT;";
```

```
cat cliente.ibd
```

> Perceba agora que, em razão do tamanho do nome, o banco de dados realocou o registro para um novo bloco (ou, possivelmente, outra posição no mesmo bloco)

