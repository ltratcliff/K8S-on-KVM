#!/bin/bash
kubectl create deployment test --image nginx --replicas 3

cat testsvc.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: testsvc
spec:
  type: NodePort
  selector:
    app: test
  ports:
    - port: 80
      nodePort: 30001
EOF

kubectl apply -f testsvc.yaml

curl localhost:30001