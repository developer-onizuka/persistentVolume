# persistentVolume

# 0. Create NFS server
NFS server is convenient to mount filesystem over worker nodes as a persistent volume. You may use attached [Vagrantfile](https://github.com/developer-onizuka/persistentVolume/blob/main/Vagrantfile) to create NFS server as a Virtual Machine.
```
# git clone https://github.com/developer-onizuka/persistentVolume.git
# cd persistentVolume
# vagrant up --provider=libvirt
```
Install nfs-client and Mount the NFS directory on each worker node. In my case, the IP of NFS server is 192.168.33.11.
```
# sudo apt-get -y install nfs-client
# sudo mount -v 192.168.33.11:/ /mnt
```

# 1-1. Create Storage Class
A StorageClass provides a way for administrators to describe the "provisioner" and its parameter for storage they offer such as premium or standard in case of Azure.<br>
If using a provisioner plugin, you can add it to the provisioner parameter in the configuration, something like kubernetes.io/aws-ebs or kubernetes.io/azure-file. But please note no plugin for NFS is provided. So use anything like "kubernetes.io/no-provisioner" instead.
> https://kubernetes.io/docs/concepts/storage/storage-classes
```
# kubectl apply -f sc.yaml 
```
```
# kubectl get sc
NAME          PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-storage   kubernetes.io/no-provisioner   Retain          Immediate           false                  89m
```
# 1-2. Create Ubuntu containers with Persistent Volume Craim
```
# kubectl apply -f ubuntu1.yaml ubuntu2.yaml
# kubectl get pods -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE      NOMINATED NODE   READINESS GATES
ubuntu1-6d947cb98f-9hktf   2/2     Running   0          20m   10.10.189.74    worker2   <none>           <none>
ubuntu2-85c46bf867-mtvs8   2/2     Running   0          17m   10.10.199.142   worker4   <none>           <none>
```
```
# kubectl get pv 
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
ubuntu1-pv   1Gi        RWO            Retain           Bound    default/ubuntu1-pvc   nfs-storage             80m
ubuntu2-pv   1Gi        RWO            Retain           Bound    default/ubuntu2-pvc   nfs-storage             67m

# kubectl get pvc
NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
ubuntu1-pvc   Bound    ubuntu1-pv   1Gi        RWO            nfs-storage    80m
ubuntu2-pvc   Bound    ubuntu2-pv   1Gi        RWO            nfs-storage    67m
```

# 2-1. Create a new file in Persistent Volume on Ubuntu1
```
# kubectl exec -i ubuntu1-6d947cb98f-9hktf -- bash <<EOC
echo \$HOSTNAME \$(date) >> /mnt/ubuntu1_in_persistent_volume.txt
EOC

# kubectl exec -i ubuntu1-6d947cb98f-9hktf -- bash <<EOC
cat /mnt/ubuntu1_in_persistent_volume.txt
EOC
ubuntu1-6d947cb98f-9hktf Sat Mar 5 13:14:40 UTC 2022
```

# 2-2. Create a new file in Persistent Volume on Ubuntu2
```
# kubectl exec -i ubuntu2-85c46bf867-mtvs8 -- bash <<EOC
echo \$HOSTNAME \$(date) >> /mnt/ubuntu2_in_persistent_volume.txt
EOC

# kubectl exec -i ubuntu2-85c46bf867-mtvs8 -- bash <<EOC
cat /mnt/ubuntu2_in_persistent_volume.txt
EOC
ubuntu2-85c46bf867-mtvs8 Sat Mar 5 13:07:20 UTC 2022
```

# 3. Delete pods
```
# kubectl delete pods ubuntu1-6d947cb98f-9hktf ubuntu2-85c46bf867-mtvs8 
pod "ubuntu1-6d947cb98f-9hktf" deleted
pod "ubuntu2-85c46bf867-mtvs8" deleted
```
You can find each pod starting on different node soon.
```
# kubectl get pods -o wide 
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE      NOMINATED NODE   READINESS GATES
ubuntu1-6d947cb98f-85z8f   2/2     Running   0          63s   10.10.235.141   worker1   <none>           <none>
ubuntu2-85c46bf867-lsd6g   2/2     Running   0          63s   10.10.182.7     worker3   <none>           <none>
```

# 4-1. Check Persistent Volume on Ubuntu1 again
You can find the file is remaining in the persistent volume even after restart pod. 
```
# kubectl exec -i ubuntu1-6d947cb98f-85z8f -- bash <<EOC
echo \$HOSTNAME \$(date) >> /mnt/ubuntu1_in_persistent_volume.txt
EOC

# kubectl exec -i ubuntu1-6d947cb98f-85z8f -- bash <<EOC
cat /mnt/ubuntu1_in_persistent_volume.txt
EOC
ubuntu1-6d947cb98f-9hktf Sat Mar 5 13:16:50 UTC 2022
ubuntu1-6d947cb98f-85z8f Sat Mar 5 13:23:41 UTC 2022
```

# 4-2. Check Persistent Volume on Ubuntu2 again
You can find the file is remaining in the persistent volume even after restart pod and it is also separated from the volume of Ubuntu1.
```
# kubectl exec -i ubuntu2-85c46bf867-lsd6g -- bash <<EOC
echo \$HOSTNAME \$(date) >> /mnt/ubuntu2_in_persistent_volume.txt
EOC

# kubectl exec -i ubuntu2-85c46bf867-lsd6g -- bash <<EOC
cat /mnt/ubuntu2_in_persistent_volume.txt
EOC
ubuntu2-85c46bf867-mtvs8 Sat Mar 5 13:07:20 UTC 2022
ubuntu2-85c46bf867-lsd6g Sat Mar 5 13:24:18 UTC 2022
```

# 5. Can Ubuntu3 simultaneously mount the filesystem which is already mounted by Ubuntu1?
Yes it can.
```
# kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubuntu3
spec:
  selector:
    matchLabels:
      app: ubuntu3
  replicas: 1
  template:
    metadata:
      labels:
        app: ubuntu3
    spec:
      containers:
      - name: ubuntu
        image: ubuntu:20.04
        command:
          - sleep
          - infinity
        volumeMounts:
        - name: ubuntu3-data
          mountPath: /mnt
      volumes:
        - name: ubuntu3-data
          persistentVolumeClaim:
           claimName: ubuntu1-pvc
EOF
```
```
# kubectl get pods -o wide 
NAME                       READY   STATUS    RESTARTS   AGE     IP              NODE      NOMINATED NODE   READINESS GATES
ubuntu1-6d947cb98f-85z8f   2/2     Running   0          63m     10.10.235.141   worker1   <none>           <none>
ubuntu2-85c46bf867-lsd6g   2/2     Running   0          63m     10.10.182.7     worker3   <none>           <none>
ubuntu3-5498c5db47-zgbl7   2/2     Running   0          3m55s   10.10.189.76    worker2   <none>           <none>
```
```
# kubectl exec -it ubuntu3-5498c5db47-zgbl7 -- /bin/bash
root@ubuntu3-5498c5db47-zgbl7:/# 
root@ubuntu3-5498c5db47-zgbl7:/# cd /mnt
root@ubuntu3-5498c5db47-zgbl7:/# 
root@ubuntu3-5498c5db47-zgbl7:/mnt# cat ubuntu1_in_persistent_volume.txt 
ubuntu1-6d947cb98f-9hktf Sat Mar 5 13:16:50 UTC 2022
ubuntu1-6d947cb98f-85z8f Sat Mar 5 13:23:41 UTC 2022
root@ubuntu3-5498c5db47-zgbl7:/mnt#
```

