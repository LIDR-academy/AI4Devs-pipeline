# 🚀 Ejercicio: Creando un Pipeline en GitHub Actions

**🤖 Asistente de IA utilizado:** Gemini Pro

---

### 📝 Prompts Utilizados

1.  **💡 Prompt #1**
    Necesito tu ayuda, tengo una aplicación con las características del archivo readme.md, debo realizar lo siguiente: crear un pipeline en GitHub Actions que, tras el trigger "push a una rama con un Pull Request abierto", siga los siguientes pasos:
    1. Pase unos tests de backend.
    2. Genere un build del backend.
    3. Despliegue el backend en un EC2. 

    Para ello, debo seguir estos pasos:
    1. Configurar el workflow de GitHub Actions en un archivo .github/workflows/pipeline.yml.
    2. Documentar los prompts utilizados para generar cada paso del pipeline:
        2.1 Tests de backend.
        2.2 Generación del build del backend.
        2.3 Despliegue del backend en EC2.
    3. Asegurar de que el pipeline se dispare con un push a una rama con un Pull Request abierto.

    El problema es que soy nuevo en EC2, he tratado de configurar mi entorno siguiendo los tutoriales pero veo que están desactualizados, por lo que antes necesito tu guía paso a paso para configurar esto.

2.  **🤔 Prompt #2**
    No veo la opción "lanzar instancias"

3.  **🐛 Prompt #3**
    En la consola de Ubuntu, tengo problemas con el paso "7. Instalar Docker y Docker Compose (para la base de datos PostgreSQL)", al ejecutar: `sudo apt update`, genera "E: The repository 'https://download.docker.com/linux/ubuntu noble InRelease' is not signed.", y luego al ejecutar `sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`, genera "E: Package 'docker-ce' has no installation candidate
    E: Package 'docker-ce-cli' has no installation candidate
    E: Unable to locate package containerd.io
    E: Couldn't find any package by glob 'containerd.io'
    E: Unable to locate package docker-buildx-plugin
    E: Unable to locate package docker-compose-plugin"

4.  **❗ Prompt #4**
    Tengo problema con el paso 3: configuración inicial del proyecto en ec2, 2. configurar la base de datos. Al ejecutar "docker-compose up -d # Inicia PostgreSQL en segundo plano" me genera error "docker-compose up -d # Inicia PostgreSQL en segundo plano
    Command 'docker-compose' not found, but can be installed with:
    sudo snap install docker          # version 28.1.1+1, or
    sudo apt  install docker-compose  # version 1.29.2-6
    See 'snap info docker' for additional versions."

5.  **❌ Prompt #5**
    Tengo problema al ejecutar "npx prima generate", me genera error: "npm error could not determine executable to run"

6.  **🎯 Prompt #6**
    "Parte 1: Guía Detallada para Configurar la Instancia EC2" completada correctamente, solo debo aclararte algo, el ambiente de desarrollo y el que quiero se ejecute las Copilot Actions es el que tengo en mi computadora local, entonces, al realizar "push a una rama con un Pull Request abierto":
    1. Pase unos tests de backend con Jest.
    2. Genere un build del backend.
    3. Despliegue el backend en un EC2 si los pasos anteriores son correctos. 

7.  **✅ Prompt #7**
    ¿Cómo puedo comprobar que el github actions y el pipeline.yml hayan funcionado?