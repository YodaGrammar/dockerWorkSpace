#!/bin/sh

SUDO="sudo"
BACKEND_SPACE_PATH="backendSpace/"
FRONTEND_SPACE_PATH="frontendSpace/"
PROJECT_FIELD_NAME=2
TYPE="Local"

if [[ $CONTAINER_NAME =~ ^yg_.+ ]];
then
	SUDO=""
	BACKEND_SPACE_PATH="/app/"
	FRONTEND_SPACE_PATH="/backendSpace"
	PROJECT_FIELD_NAME=5
	TYPE="Docker"
fi

echo -e "\e[1;33mHosts Domains init ($TYPE $CONTAINER_NAME)\e[0m:"

### Make a backup of the original hosts file
# Will use the original file if exists
# else, create one
if [ -f /etc/hosts.origin ];
then
	$SUDO cp -f /etc/hosts.origin /etc/hosts
else
	$SUDO cp -f /etc/hosts /etc/hosts.origin
fi

if [ "$TYPE" = "Local" ];
then
	CONTAINERS=`cat compose.yml | yq -r ".services | keys[]"`
	for CONTAINER in `echo "$CONTAINERS"`
	do
		[[ "$CONTAINER" == "php" || "$CONTAINER" == "frontend" ]] && continue 
		echo -en "\e[36m${CONTAINER}\e[0m: "
		echo "127.0.0.1 $CONTAINER.yg.docker" | $SUDO tee -a /etc/hosts
	done
fi

### Give make the command using element containing the built-in resolver of docker works
# Having a container named 'hypecode_database' is handled in all containers, thanks to the network defined
# The ip of theses type of container needs to be defined in the /etc/hosts of the host machine
# This allow us to use commands like `symfony console doctrine:migration:diff`
if [ "$TYPE" = "Local" ];
then
	CONTAINERS="yg_php yg_next yg_traefik yg_whoami yg_adminer"
	if command -v yq &> /dev/null; then
		CONTAINERS=`cat compose.yml | yq -r ".services | .[] | .container_name"`
	fi
	for CONTAINER in `echo "$CONTAINERS"`
	do
		echo -en "\e[36m${CONTAINER}\e[0m: "
		CONTAINER_IP=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER`
		echo "$CONTAINER_IP $CONTAINER" | sudo tee -a /etc/hosts
	done
fi


### For each project in '$PROJECT_PATH' folder, create entry
# Will use the name of the project (e.g. 'api-test')
# and create and entry that redirect to localhost
# e.g. api-test.hypecode.docker -> localhost
if [[ "$TYPE" = "Local" || $CONTAINER_NAME = "yg_php" ]];
then
	for PROJECT in `ls $BACKEND_SPACE_PATH`
	do
		BACKEND_SPACE_PATH=`echo $PROJECT | cut -d '/' -f $PROJECT_FIELD_NAME`
		echo -en "\e[36m${PROJECT}\e[0m: "
		echo "127.0.0.1 $BACKEND_SPACE_PATH.byg.docker" | $SUDO tee -a /etc/hosts
	done
fi

### For each project in '$PROJECT_PATH' folder, create entry
# Will use the name of the project (e.g. 'api-test')
# and create and entry that redirect to localhost
# e.g. api-test.hypecode.docker -> localhost
if [[ "$TYPE" = "Local" || $CONTAINER_NAME = "yg_next" ]];
then
	for PROJECT in `ls $FRONTEND_SPACE_PATH`
	do
		FRONTEND_SPACE_PATH=`echo $PROJECT | cut -d '/' -f $PROJECT_FIELD_NAME`
		echo -en "\e[36m${PROJECT}\e[0m: "
		echo "127.0.0.1 $FRONTEND_SPACE_PATH.fyg.docker" | $SUDO tee -a /etc/hosts
	done
fi