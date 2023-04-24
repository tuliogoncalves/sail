command="./bin/sail exec ${APP_SERVICE:-"app"} php "$@""
echo "Running php on docker in container '${APP_SERVICE:-"app"}'"
$command