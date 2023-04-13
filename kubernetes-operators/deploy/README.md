### Получаю имя POD:
kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}"
```
mysql-instance-5686fc5b4d-xxddd
```
### Создаю таблицу в БД:
kubectl exec -it mysql-instance-5686fc5b4d-xxddd -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );" otus-database

### Добавляю данные:
1. kubectl exec -it mysql-instance-5686fc5b4d-xxddd -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (null, 'some data' );" otus-database
2. kubectl exec -it mysql-instance-5686fc5b4d-xxddd -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (null, 'some data-2' );" otus-database

### Получаю данные из таблицы:
kubectl exec -it mysql-instance-5686fc5b4d-xxddd -- mysql -potuspassword -e "select * from test;" otus-database
```
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data   |
|  3 | some data-2 |
+----+-------------+
```

### Удаляю CR:
kubectl delete mysqls.otus.homework mysql-instance

### Проверяю создание backup:
kubectl get jobs.batch
```
NAME                        COMPLETIONS   DURATION   AGE
backup-mysql-instance-job   1/1           5s         31s
```

### Вновь создаю CR:
kubectl apply -f cr.yaml


### Получчаю имя нового POD:
kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}"
```
mysql-instance-5686fc5b4d-p59gj
```

### Получаю данные из нового POD:
kubectl exec -it mysql-instance-5686fc5b4d-p59gj -- mysql -potuspassword -e "select * from test;" otus-database
```
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data   |
|  3 | some data-2 |
+----+-------------+
```

### Проверяю, что отработали обе JOB:
kubectl get jobs
```
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           4s         2m52s
restore-mysql-instance-job   1/1           2m21s      2m42s
```