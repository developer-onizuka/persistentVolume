# persistentVolume

# 0. Create Ubuntu containers with Persistent Volume Craim
```
# git clone https://github.com/developer-onizuka/persistentVolume.git
# cd persistentVolume
# kubectl apply -f sc.yaml ubuntu1.yaml ubuntu2.yaml
# kubectl get pods -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE      NOMINATED NODE   READINESS GATES
ubuntu1-6d947cb98f-9hktf   2/2     Running   0          20m   10.10.189.74    worker2   <none>           <none>
ubuntu2-85c46bf867-mtvs8   2/2     Running   0          17m   10.10.199.142   worker4   <none>           <none>
```

# 1. Create a new file in Persistent Volume on Ubuntu1
```
# kubectl exec -i ubuntu1-6d947cb98f-9hktf -- bash <<EOC
echo \$HOSTNAME \$(date) >> /mnt/ubuntu1_in_persistent_volume.txt
EOC

# kubectl exec -i ubuntu1-6d947cb98f-9hktf -- bash <<EOC
cat /mnt/ubuntu1_in_persistent_volume.txt
EOC
ubuntu1-6d947cb98f-9hktf Sat Mar 5 13:14:40 UTC 2022
```

# 2. Create a new file in Persistent Volume on Ubuntu2
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

# 4. Check Persistent Volume on Ubuntu1 again
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

# 5. Check Persistent Volume on Ubuntu2 again
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
