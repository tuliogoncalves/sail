#!/usr/bin/env bash
# SQL Server backup listing and restore helpers.

cmd_sqlserver_list() {
    docker exec -it -u root sqlserver mkdir /backup
    docker cp "./$2" "sqlserver:/backup/$2"
    docker exec -it -u root sqlserver chown root:root "/backup/$2"
    docker exec -it -u root sqlserver chmod 777 "/backup/$2"

    docker exec -it -u root sqlserver /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U SA \
    -P "Psswd#123" \
    -C \
    -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$2'" | tr -s ' ' | cut -d ' ' -f 1-2

    exit 0
}

cmd_sqlserver_restore() {
    local query="RESTORE DATABASE $3 FROM DISK = '/backup/$2' WITH MOVE '$3' TO '/var/opt/mssql/data/$3.mdf'"
    [ "$4" != "" ] && query+=", MOVE '$4' TO '/var/opt/mssql/data/$4.ldf'"
    [ "$5" != "" ] && query+=", MOVE '$5' TO '/var/opt/mssql/data/$5.ndf'"

    docker exec -it -u root sqlserver /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U SA \
    -P "Psswd#123" \
    -C \
    -Q "$query"

    exit 0
}
