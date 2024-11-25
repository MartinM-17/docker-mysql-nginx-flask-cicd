from flask import Flask, request, jsonify
import mysql.connector
from dotenv import load_dotenv
import os

# Cargar variables de entorno desde el archivo .env
load_dotenv()

# Configuración de la conexión a la base de datos
db_config = {
    'host': os.getenv('DB_HOST'),       # Dirección del servidor MySQL
    'user': os.getenv('DB_USER'),       # Usuario de MySQL
    'password': os.getenv('DB_PASSWORD'),  # Contraseña del usuario
    'database': os.getenv('DB_NAME'),      # Nombre de la base de datos
}

# Inicialización de la aplicación Flask
app = Flask(__name__)

# Ruta principal
@app.route('/', methods=['GET', 'POST'])
def manage_data():
    try:
        # Conexión a la base de datos
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        if request.method == 'POST':
            data = request.json
            name = data.get('name')

            # Insertar datos en la tabla
            cursor.execute("INSERT INTO users (name) VALUES (%s)", (name,))
            conn.commit()
            return jsonify({"message": "Usuario insertado con éxito."}), 201

        if request.method == 'GET':
            # Recuperar datos de la tabla
            cursor.execute("SELECT * FROM users")
            users = cursor.fetchall()
            return jsonify({"users": [{"id": user[0], "name": user[1]} for user in users]}), 200

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        cursor.close()
        conn.close()

# Punto de entrada
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
