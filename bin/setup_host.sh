DB_PASSWORD=123456
container_name=mangosteen-prod

version=$(cat mangosteen_deploy/version)

echo 'docker build ...'
docker build mangosteen_deploy -t mangosteen:$version --label "mangosteen"
if [ "$(docker ps -aq -f name=^mangosteen-prod$)" ]; then
  echo 'docker rm ...'
  docker rm -f $container_name
fi
echo 'docker run ...'
docker run -d -p 3000:3000 --network=network1 -e DB_PASSWORD=$DB_PASSWORD -e DB_HOST=$DB_HOST -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY --name=$container_name mangosteen:$version
echo 'docker image prune ...'
yes | docker image prune -a --filter="label=mangosteen"
echo 'DONE!'