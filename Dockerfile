# Imagen base de Python
FROM python:3.9-slim

# Configuración de directorio de trabajo
WORKDIR /app

# Copiar dependencias e instalarlas
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY . .

# Exponer el puerto de la aplicación
EXPOSE 5000

# Comando por defecto
CMD ["python", "app.py"]
