1. Установил CSI driver для Host Path по инструкции с GIT
2. Написал манифест создания StorageClass с именем csi-hostpath-sc
3. Написал манифест создания PVC с именем storage-pvc
4. Написал манифест создания pod с именем storage-pod к которому монтируется хранилище в директорию /data
5. Проверил работоспособность