## task01

### 01-bob.yaml
Создается Service Account с именем bob. Так как в кластере существует Cluster Role cluster-admin, то добавим для боба Cluster Role Binding c именем cluster-admin-bob. Собственно эти две сущности и описаны в манифесте.

### 02-dave.yaml
Создается Service Account с именем dave и никаких действий больше с этой сущностью не производится. dave не получит доступ к кластеру.

## task02

### 01-ns-prometheus.yaml
Применение манифеста создаст namespase с именем prometheus

### 02-sa-carol.yaml
Применение манифеста создаст Service Account carol в namespase prometheus

### 03-rbac.yaml
Применение манифеста создаст ClusterRole с именем read-only-pods и ClusterRoleBinding с именем read-pods-global. Так как в задании указано, что необходимо выдать права всем SA из NS prometheus, то в ClusterRoleBinding указаны SA carol и default (так как default создается автоматически при создании NS)

## task03

### 01-ns-dev.yaml
Применение манифеста создаст namespase с именем dev

### 02-sa-jane.yaml
Применение манифеста создаст Service Account jane в namespase dev

### 03-rolebinding-jane.yaml
Применение манифеста создаст RoleBinding которая свяжет SA jane с ClusterRole cluster-admin. Тем самым мы выдаем все возможные права в рамках ns dev. 

### 04-sa-ken.yaml
Применение манифеста создаст Service Account ken в namespase dev

### 05-rolebinding-ken.yaml
Применение манифеста создаст RoleBinding которая свяжет SA ken с ClusterRole view. Тем самым мы выдаем все возможные права на view в рамках ns dev. 
Задание имеет заковырку в том плане, что кластерная роль view существует и логично применить ее (как и было выполнено), но при создании кастомного ресурса созданного в ns dev, sa ken не получит доступ на view к этому ресурсу. 