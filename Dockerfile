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

# Convertir finales de línea y hacer el script ejecutable
RUN sed -i 's/\r$//' start.sh && chmod +x start.sh

# Comando para ejecutar la aplicación usando el script de Python
CMD ["python", "run.py"] 