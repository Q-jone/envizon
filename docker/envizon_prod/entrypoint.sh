#!/bin/sh
if [ -z "$SSL_KEY_PATH" ]
then
  if [[ -f .ssl/localhost.key && -f .ssl/localhost.crt ]]
  then
    echo "Certificates found in .ssl/."
  else
    echo "No certificates provided and none in .ssl/, generating some for you"
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
      -subj "/C=DE/ST=None/L=None/O=evait/CN=None" \
      -keyout .ssl/localhost.key  -out .ssl/localhost.crt
  fi
else
  echo "Using certificates provided by environment variables."
fi

if [ -z "$SECRET_KEY_BASE" ]
then
  echo "No rails secret provided via '\$SECRET_KEY_BASE'."
  if [[ -f config/secret ]]
  then
    echo "Found a previous secret in 'config/secret:'"
    export SECRET_KEY_BASE=$(cat config/secret)
  else
    echo "Generating one for you and placing it in 'config/secret':"
    export SECRET_KEY_BASE=$(rails secret)
    echo "$SECRET_KEY_BASE" > config/secret
  fi
fi

if [[ ! -f report-templates/envizon_template.docx ]]; then
  mkdir -p report-templates
  cp report-templates/envizon_template.docx.example report-templates/envizon_template.docx
fi

rm -f /usr/src/app/envizon/tmp/pids/server.pid
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails assets:precompile
exec bundle exec rails server
