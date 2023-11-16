DROP TABLE pedido;

create table faturamento(
    InvoiceDate timestamp,
    Country     varchar(100),
    InvoiceNo   varchar(100),
    StockCode   varchar(100),
    Description varchar(1000),
    CustomerID  bigint,
    Quantity    bigint,
    UnitPrice   double    
);

LOAD DATA INFILE '/tmp/faturamento.csv' 
INTO TABLE faturamento 
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

-- Clientes "heavy"
select "CustomerID", count(1) 
from pedido 
group by "CustomerID"
HAVING count(1) > 100 
order by 2 desc;

--  CustomerID | count
-- ------------+--------
--             | 135080
--       17841 |   7983
--       14911 |   5903
--       14096 |   5128
--       12748 |   4642
--       14606 |   2782
--       15311 |   2491
--       14646 |   2085
--       13089 |   1857
--       13263 |   1677
--       14298 |   1640
--       15039 |   1508
--       14156 |   1420
--       18118 |   1284
--       14159 |   1212
--       14796 |   1165
--       15005 |   1160
--       16033 |   1152
--       14056 |   1128
--       14769 |   1094
--       17511 |   1076
--       13081 |   1061
--       14527 |   1011

-- Faturamentos com mais de 1 item
select p."InvoiceNo",
    count(p."InvoiceNo") qtt
from pedido p
group by p."InvoiceNo"
having count(p."InvoiceNo") > 1
order by 2 desc;
-- InvoiceNo | qtt
-----------+------
-- 573585    | 1114
-- 581219    |  749
-- 581492    |  731
-- 580729    |  721
-- 558475    |  705
-- 579777    |  687
-- 581217    |  676
-- 537434    |  675
-- 580730    |  662
-- 538071    |  652
-- 580367    |  650
-- 580115    |  645
-- 581439    |  635

SELECT p."InvoiceNo",
    count(p."InvoiceNo") qtt
FROM pedido p
WHERE p."CustomerID" IS NOT NULL
GROUP BY p."InvoiceNo"
HAVING COUNT(p."InvoiceNo") > 1
ORDER BY 2 DESC;
-- InvoiceNo | qtt
-------------+-----
-- 576339    | 542
-- 579196    | 533
-- 580727    | 529
-- 578270    | 442
-- 573576    | 435
-- 567656    | 421
-- 567183    | 399
-- 575607    | 377
-- 571441    | 364
-- 570488    | 353
-- 572552    | 352
-- 568346    | 335
-- 547063    | 294
-- 569246    | 285
-- 562031    | 277
-- 554098    | 264
-- 543040    | 259
-- 570672    | 259

SELECT  p."StockCode",
        p."Description",
        count("InvoiceNo") qtt
FROM public.pedido p
GROUP BY p."StockCode",
        p."Description"
ORDER BY 3 DESC;

-- Itens com maior faturamento e cliente válido
SELECT  p."StockCode",
        p."Description",
        count(p."InvoiceNo") qtt
FROM pedido p
WHERE p."CustomerID" IS NOT NULL
GROUP BY p."StockCode",
        p."Description"
HAVING COUNT(p."InvoiceNo") > 1000
ORDER BY 3 DESC;
--  StockCode |            Description             | qtt
-- -----------+------------------------------------+------
--  85123A    | WHITE HANGING HEART T-LIGHT HOLDER | 2070
--  22423     | REGENCY CAKESTAND 3 TIER           | 1905
--  85099B    | JUMBO BAG RED RETROSPOT            | 1662
--  84879     | ASSORTED COLOUR BIRD ORNAMENT      | 1418
--  47566     | PARTY BUNTING                      | 1416
--  20725     | LUNCH BAG RED RETROSPOT            | 1358
--  22720     | SET OF 3 CAKE TINS PANTRY DESIGN   | 1232
--  POST      | POSTAGE                            | 1196
--  20727     | LUNCH BAG  BLACK SKULL.            | 1126
--  21212     | PACK OF 72 RETROSPOT CAKE CASES    | 1080
--  22086     | PAPER CHAIN KIT 50'S CHRISTMAS     | 1029
--  23298     | SPOTTY BUNTING                     | 1029
--  22382     | LUNCH BAG SPACEBOY DESIGN          | 1021
--  20728     | LUNCH BAG CARS BLUE                | 1012
-- (14 rows)


SELECT p."Country",
    count("InvoiceNo") qtt
FROM pedido p
WHERE p."CustomerID" IS NOT NULL
GROUP BY p."Country"
ORDER BY 2 DESC;

--        Country        |  qtt
-- ----------------------+--------
--  United Kingdom       | 361878
--  Germany              |   9495
--  France               |   8491
--  EIRE                 |   7485
--  Spain                |   2533
--  Netherlands          |   2371
--  Belgium              |   2069
--  Switzerland          |   1877
--  Portugal             |   1480
--  Australia            |   1259
--  Norway               |   1086
--  Italy                |    803
--  Channel Islands      |    758

select p."Country",
    p."Description",
    count(p."InvoiceNo") qtt
from pedido p
group by p."Country",
    p."Description"
order by 3 desc;
select p."Country",
    p."Description",
    count(p."InvoiceNo") qtt
from pedido p
group by p."Country",
    p."Description"
having count(p."InvoiceNo") > 1000
order by 3 desc;