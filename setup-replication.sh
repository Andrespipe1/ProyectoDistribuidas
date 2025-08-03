#!/bin/bash

# Script para configurar automáticamente la replicación MySQL Master-Slave
# Se ejecuta después de que ambos contenedores estén listos

echo "🔄 Configurando replicación MySQL Master-Slave..."

# Esperar a que MySQL Master esté listo
echo "⏳ Esperando a que MySQL Master esté listo..."
until mysql -h db -u root -proot -e "SELECT 1" >/dev/null 2>&1; do
    sleep 2
done
echo "✅ MySQL Master está listo"

# Esperar a que MySQL Slave esté listo
echo "⏳ Esperando a que MySQL Slave esté listo..."
until mysql -h db-slave -u root -proot -e "SELECT 1" >/dev/null 2>&1; do
    sleep 2
done
echo "✅ MySQL Slave está listo"

# Obtener información del Master
echo "📊 Obteniendo información del Master..."
MASTER_INFO=$(mysql -h db -u root -proot -e "SHOW MASTER STATUS\G" 2>/dev/null)

if [ $? -eq 0 ]; then
    # Extraer File y Position del Master
    MASTER_LOG_FILE=$(echo "$MASTER_INFO" | grep "File:" | awk '{print $2}')
    MASTER_LOG_POS=$(echo "$MASTER_INFO" | grep "Position:" | awk '{print $2}')
    
    echo "📁 Master Log File: $MASTER_LOG_FILE"
    echo "📍 Master Log Position: $MASTER_LOG_POS"
    
    # Configurar el Slave
    echo "🔧 Configurando Slave..."
    mysql -h db-slave -u root -proot << EOF
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='db',
  MASTER_USER='replicador',
  MASTER_PASSWORD='replicapass',
  MASTER_LOG_FILE='$MASTER_LOG_FILE',
  MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
EOF

    # Verificar estado de la replicación
    echo "🔍 Verificando estado de la replicación..."
    SLAVE_STATUS=$(mysql -h db-slave -u root -proot -e "SHOW SLAVE STATUS\G" 2>/dev/null)
    
    IO_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_IO_Running:" | awk '{print $2}')
    SQL_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_SQL_Running:" | awk '{print $2}')
    
    if [ "$IO_RUNNING" = "Yes" ] && [ "$SQL_RUNNING" = "Yes" ]; then
        echo "✅ Replicación configurada exitosamente!"
        echo "   - Slave_IO_Running: $IO_RUNNING"
        echo "   - Slave_SQL_Running: $SQL_RUNNING"
    else
        echo "❌ Error en la configuración de replicación"
        echo "   - Slave_IO_Running: $IO_RUNNING"
        echo "   - Slave_SQL_Running: $SQL_RUNNING"
    fi
else
    echo "❌ No se pudo obtener información del Master"
fi 