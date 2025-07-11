# Usar una imagen oficial de Python
FROM python:3.11-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de la aplicación
COPY app/ .

# Copiar el script de inicio
COPY start.sh .

# Instalar las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Exponer el puerto de Flask
EXPOSE 5000

# Hacer el script ejecutable
RUN chmod +x start.sh

# Comando para ejecutar la aplicación
CMD ["./start.sh"] 