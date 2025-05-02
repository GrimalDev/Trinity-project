#sudo docker rm -f trinity-database-prod
#sudo docker image rm -f mongo:4.4
sudo docker compose -f /jail/trinity/public/docker-compose_prod.yml down -v
sudo docker compose -f /jail/trinity/public/docker-compose_prod.yml up -d --build
