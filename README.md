# docker-mysql-nginx-flask-cicd
Crear una aplicación web en Flask que use MySQL como base de datos (con replicas), Nginx como balanceador de carga y configurar un flujo de CI/CD con GitHub Actions para realizar el build y despliegue automático sobre una máquina virtual, exponiéndola mediante ngrok.


docker-mysql-nginx-flask-cicd/
├── .github/               # Configuración para GitHub Actions
│   └── workflows/         # Archivos de pipelines de CI/CD
│       └── deploy.yml     # Workflow de despliegue automático
├── app/                   # Código fuente de la aplicación Flask
│   ├── app.py             # Archivo principal de la aplicación
│   ├── requirements.txt   # Dependencias de Python
│   └── .env               # Variables de entorno (no se sube a GitHub)
├── db/                    # Configuración y datos de la base de datos
│   └── init.sql           # Script de inicialización para MySQL
├── nginx/                 # Configuración del servidor Nginx
│   └── nginx.conf         # Archivo de configuración de Nginx
├── docker-compose.yml     # Orquestador de servicios con Docker Compose
├── Dockerfile             # Configuración de la imagen Docker para Flask
└── README.md              # Documentación del proyecto
