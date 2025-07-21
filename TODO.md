- Add docker-compose (and docker) with podman
- Make hercules CI work along with Github CI
- Move to typescript(but without tsconfig first), add package.json


Make HTTP certificate:
$ mkcert -install
$ mkcert example.com "*.example.com" example.test localhost 127.0.0.1 ::1
# Creates a valid certificate for all domain names above
# The certificate is at "./example.com+5.pem" and the key at "./example.com"


