#!/bin/sh
set -ea

# Allow sensitive settings to be defined in a file
# in order to support Docker secrets
if [ -n "${DATABASE_PASSWORD_FILE}" ]; then
  DATABASE_PASSWORD=$(cat "$DATABASE_PASSWORD_FILE")
  export DATABASE_PASSWORD
fi
if [ -n "${DATABASE_USERNAME_FILE}" ]; then
  DATABASE_USERNAME=$(cat "$DATABASE_USERNAME_FILE")
  export DATABASE_USERNAME
fi

if [ "$1" = "strapi" ]; then

  if [ ! -f "package.json" ]; then

    DATABASE_CLIENT=${DATABASE_CLIENT:-sqlite}

    EXTRA_ARGS=${EXTRA_ARGS}

    echo "Using strapi $(strapi version)"
    echo "No project found at /srv/app. Creating a new strapi project"

    DOCKER=true strapi new . \
      --dbclient=$DATABASE_CLIENT \
      --dbhost=$DATABASE_HOST \
      --dbport=$DATABASE_PORT \
      --dbname=$DATABASE_NAME \
      --dbusername=$DATABASE_USERNAME \
      --dbpassword=$DATABASE_PASSWORD \
      --dbssl=$DATABASE_SSL \
      $EXTRA_ARGS

  elif [ ! -d "node_modules" ] || [ ! "$(ls -qAL node_modules 2>/dev/null)" ]; then

    echo "Node modules not installed. Installing..."

    if [ -f "yarn.lock" ]; then

      yarn install

    else

      npm install

    fi

  fi

fi

echo "Starting your app..."

exec "$@"