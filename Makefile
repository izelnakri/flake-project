.PHONY: backend frontend

# TODO: move away from docker to podman

backend: 
		node backend/index.js
backend-dev:
		node --watch-path=./backend backend/index.js
docker-backend:
		sudo docker run -p "4000:4000" flake-project-backend
docker-backend-ssh:
		sudo docker run -it flake-project-backend /bin/sh

frontend:
		node frontend/index.js
frontend-dev:
		node --watch-path=./frontend frontend/index.js
docker-backend:
		sudo docker run -p "3000:3000" flake-project-frontend
docker-backend-ssh:
		sudo docker run -it flake-project-frontend /bin/sh

test:
		deno fmt backend/index.js --check
		deno fmt frontend/index.js --check
		echo "✅ Deno lint passed!"

run-both-in-nix:
		nix run .#

docker-compose:
	sudo docker-compose up 
docker-compose-watch:
	sudo docker-compose up --watch
