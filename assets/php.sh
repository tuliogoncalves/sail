echo "Running php on docker in container '${APP_SERVICE:-"app"}'"
echo
bash ~/projects/sail/bin/sail exec ${APP_SERVICE:-"app"} php $@