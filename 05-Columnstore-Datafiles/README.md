# Observação de datafiles
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

### Objetivo
Observar como o MariaDB gera data files de colunas em disco.

Vamos navegar para o diretório onde o mariadb armazena os seus arquivos de dados.<br>
Por padrão estão no diretório `/var/lib/columnstore/data1`:
```
ls -latr /var/lib/columnstore/data1
```

Output:
```
root@mariadb-server:/var/lib/columnstore/data1# ls -latr /var/lib/columnstore/data1
total 672
drwxr-xr-t 3 mysql mysql   4096 Jul 27 16:57 systemFiles
-rw-r--r-- 1 root  root       0 Jul 27 16:58 dbroot1-lock
drwxr-xr-x 5 mysql mysql   4096 Jul 27 16:58 ..
drwxrwxr-x 3 mysql mysql   4096 Jul 27 16:58 000.dir
drwxr-xr-t 4 mysql mysql   4096 Jul 27 16:59 .
-rw-r--r-- 1 mysql mysql 671744 Jul 27 20:48 versionbuffer.cdf
root@mariadb-server:/var/lib/columnstore/data1# 

```

```
cd /var/lib/columnstore/data1
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
./000.dir/000.dir/004.dir/016.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/001.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/003.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/007.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/015.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/006.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/018.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/009.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/000.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/014.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/010.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/012.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/011.dir/000.dir/FILE000.cdf
./000.dir/000.dir/004.dir/008.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/238.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/237.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/244.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/253.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/242.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/243.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/235.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/255.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/234.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/254.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/236.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/239.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/241.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/240.dir/000.dir/FILE000.cdf
./000.dir/000.dir/003.dir/233.dir/000.dir/FILE000.cdf
./000.dir/000.dir/007.dir/209.dir/000.dir/FILE000.cdf
./000.dir/000.dir/007.dir/212.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/193.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/204.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/187.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/188.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/185.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/198.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/190.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/194.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/197.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/195.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/206.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/199.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/205.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/192.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/186.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/203.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/189.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/191.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/202.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/201.dir/000.dir/FILE000.cdf
./000.dir/000.dir/011.dir/196.dir/000.dir/FILE000.cdf
./000.dir/000.dir/008.dir/025.dir/000.dir/FILE000.cdf
./000.dir/000.dir/008.dir/013.dir/000.dir/FILE000.cdf
./000.dir/000.dir/008.dir/019.dir/000.dir/FILE000.cdf
./000.dir/000.dir/008.dir/016.dir/000.dir/FILE000.cdf
./000.dir/000.dir/008.dir/028.dir/000.dir/FILE000.cdf
./000.dir/000.dir/008.dir/022.dir/000.dir/FILE000.cdf
root@ip-172-31-2-249:/var/lib/columnstore/data1# 
. . .
```

### Dicionário de dados
Via dicionário de dados é possível identificar a relação entre uma coluna e um arquivo.
```
mariadb -u root -e "
    select cols.table_schema, cols.table_name, cols.column_name, files.filename
    from information_schema.columnstore_columns cols 
    inner join information_schema.columnstore_files files 
    on files.object_id = cols.dictionary_object_id
    where cols.table_schema = 'ecommerce'
    and cols.table_name = 'invoices_cs';"

```

Atributo `Description`:
```
grep --binary-files=text --include \*.cdf -r -l -o "WHITE" ./*
```

```
grep --binary-files=text --include \*.cdf -r -l -o "PLAYING CARDS VINTAGE" ./*
```

```
grep --binary-files=text --include \*.cdf -r -l -o "CRYSTAL EARRINGS" ./*
```


Atributo `Country`:
```
grep --binary-files=text --include \*.cdf -r -l -o "United Kingdom" ./*
```

```
grep --binary-files=text --include \*.cdf -r -l -o "Brazil" ./*
```
