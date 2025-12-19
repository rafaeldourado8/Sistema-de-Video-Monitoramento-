#!/bin/sh

# Se o comando for para rodar o servidor, aguarda o PgBouncer
if [ "$1" = "python" ] && [ "$2" = "manage.py" ] && [ "$3" = "runserver" ]; then
    echo "🟡 Aguardando o PgBouncer na porta 6432..."
    
    # Loop até conseguir conectar no host 'pgbouncer' porta 6432
    while ! nc -z pgbouncer 6432; do
      sleep 0.5
    done

    echo "🟢 PgBouncer iniciado! Subindo Django..."
fi

exec "$@"