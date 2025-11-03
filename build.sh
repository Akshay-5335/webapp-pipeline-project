chmod 400 KUBE-INFRA-KP.pem
mkdir -p ~/.ssh
echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null\n" > ~/.ssh/config
chmod 600 ~/.ssh/config
scp -i KUBE-INFRA-KP.pem web/* ubuntu@3.110.179.144:/usr/share/nginx/html/
ssh -i KUBE-INFRA-KP.pem ubuntu@3.110.179.144 'sudo systemctl restart nginx'
scp -i KUBE-INFRA-KP.pem -r app/* ubuntu@3.111.150.180:/app/
ssh -i KUBE-INFRA-KP.pem ubuntu@3.111.150.180 '
  cd /app &&
  source venv/bin/activate &&
  fuser -k 8000/tcp || true &&
  nohup venv/bin/uvicorn app:app --host 0.0.0.0 --port 8000 --workers 1 >/dev/null 2>&1 &
  disown
  exit 0
'
echo "✅ Deployment completed successfully"
exit 0