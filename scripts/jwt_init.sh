#!/bin/zsh

echo -e "\e[1;33mJWT keypair init\e[0m:"

# Get a list of all project and status of their JWT keypairs
echo "Here is a list of all your project:"
AVAILABLE_PROJECT=""
for PROJECT in /app/*/
do
	PROJECT_NAME=`echo $PROJECT | cut -d '/' -f 3`
	AVAILABLE_PROJECT="$AVAILABLE_PROJECT\n$PROJECT_NAME"
	echo -en "\e[36m${PROJECT_NAME}\e[0m: "

	if [ -d $PROJECT/config/jwt ];
	then
		echo -e "\e[32mPresent\e[0m"
	else
		cd $PROJECT
		if php bin/console debug:container --env-vars --env=dev | grep -q "JWT_PASSPHRASE";
		then
			echo -e "\e[31mNeeded\e[0m"
		else
			echo -e "\e[90mUnecessary\e[0m"
		fi
		cd /app
	fi
done

echo -en "Do you want to [C]reate de new keypair or [u]se an existing one? [C/u] -> \e[90m[ ]\e[0m\b\b"
read -n1 JWT_ACTION

if [ "$JWT_ACTION" ];
then
	echo ""
fi

cd /app

# Ask for the project that need to be JWT cloned
if [ ! -z $JWT_ACTION ] && ([ $JWT_ACTION = "u" ] || [ $JWT_ACTION = "U" ])
then
	echo -e "\e[35mFrom which project?\e[0m"
	read -e FROM_PROJECT_NAME
fi

# Ask for the project where the key will be copied/generated
echo -e "\e[35mTo which project?\e[0m"
read -e TO_PROJECT_NAME

if [ ! -z $JWT_ACTION ] && ([ $JWT_ACTION = "u" ] || [ $JWT_ACTION = "U" ])
then
	# Copy an existing keypair
	su-exec 1000:1000 cp -r /app/$FROM_PROJECT_NAME/config/jwt /app/$TO_PROJECT_NAME/config/.
else
	# Generate new keypair
	cd /app/$TO_PROJECT_NAME
	echo $'\nJWT_PASSPHRASE=yoda_grammar\n' | su-exec 1000:1000 tee -a .env.local
	if [ `php bin/console | grep -q "lexik:jwt:generate-keypair"` ];
	then
		# Use command from the bundle to generate
		su-exec 1000:1000 php bin/console lexik:jwt:generate-keypair
	else
		# Fallback, will create using legacy command
		su-exec 1000:1000 mkdir -p config/jwt
		su-exec 1000:1000 openssl genpkey -pass pass:yoda_grammar -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:5096
		su-exec 1000:1000 openssl pkey -passin pass:yoda_grammar -in config/jwt/private.pem -out config/jwt/public.pem -pubout
	fi
fi
