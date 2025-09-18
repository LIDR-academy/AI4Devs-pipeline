

## Prompt #1: Creación de pipeline

```markdown
Eres un Devops engineer y se te ha solicitado crear un pipeline usando Github Actions para desplegar una aplicación de React en una instancia EC2. Para ello, debes crear el archivo .yml que ejecutará el pipeline cuando se genere una pull request. Ten en cuenta que este proyecto es un monorepo y que tiene el frontend y el backend en carpetas independientes, donde cada una de las capas mensionadas tienen dependencias que deben ser instaladas antes de construir y desplegar. Te dejo el listado de secretos que ya tengo creados en la configuración de mi repositorio para 
mayor claridad:

* AWS_ACCESS_ID
* AWS_ACCESS_KEY
* EC2_INSTANCE
* EC2_SSH_PRIVATE_KEY
* EC2_USER
```

## Prompt #2: Explicación del pipeline construido

```marddown
soy amateur en esto de devops e integración y despliegue contínuo, podrías por favor simplifar ese pipeline pero que al mismo tiempo sea funcional y cumpla su objetivo? También agrega la ínima documentación que me ayude a entender cada paso del job
```

## Prompt #3: Problemas con la activación del action en GitHub

```marddown
mira mi @.github/workflows/ci.yml a pesar que tengo branches: [main, develop, solved-jairopolo] y hacer un push de un commit, no se activó el action, que pasa?
```

## Prompt #3: Error en la ejecución del primer intento del job

```markdown
tengo el siguiente error en el step: 🧪 Run ${{ matrix.component }} tests para el frontend
  Run cd frontend

  > frontend@0.1.0 test
  > jest --config jest.config.js --watchAll=false --passWithNoTests --coverage

  Error: Can't find a root directory while resolving a config file path.
  Provided path to resolve: jest.config.js
  cwd: 
  /home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-jairopolo/frontend
      at resolveConfigPath (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-s
  olved-jairopolo/frontend/node_modules/jest-config/build/resolveConfigPath.js:134:11)
      at readConfig (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-j
  airopolo/frontend/node_modules/jest-config/build/index.js:220:49)
      at readConfigs (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-
  jairopolo/frontend/node_modules/jest-config/build/index.js:420:32)
      at runCLI (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-jairo
  polo/frontend/node_modules/@jest/core/build/cli/index.js:133:29)
      at Object.run (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-j
  airopolo/frontend/node_modules/jest-cli/build/cli/index.js:155:62)
      at Object.<anonymous> (/home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-
  solved-jairopolo/frontend/node_modules/jest-cli/bin/jest.js:16:17)
      at Module._compile (node:internal/modules/cjs/loader:1364:14)
      at Module._extensions..js (node:internal/modules/cjs/loader:1422:10)
      at Module.load (node:internal/modules/cjs/loader:1203:32)
      at Module._load (node:internal/modules/cjs/loader:1019:12)
  Error: Process completed with exit code 1.
```

## Prompt #3: Error en la ejecución del segundo intento del job

```markdown
ahora tengo este error en la ejecución del job: Current runner version: '2.328.0'                 │
│   Runner Image Provisioner                                                                          │
│   Operating System                                                                                  │
│   Runner Image                                                                                      │
│   GITHUB_TOKEN Permissions                                                                          │
│   Secret source: Actions                                                                            │
│   Prepare workflow directory                                                                        │
│   Prepare all required actions                                                                      │
│   Getting action download info                                                                      │
│   Error: This request has been automatically failed because it uses a deprecated version of         │
│   `actions/upload-artifact: v3`. Learn more:                                                        │
│   https://github.blog/changelog/2024-04-16-deprecation-notice-v3-of-the-artifact-actions/  
```

## Prompt #3: Error en la ejecución del tercer intento del job

```markdown
ahora tengo este error en el paso: ⚙️ Setup Node.js: Error: Dependencies lock file is not found in /home/runner/work/AI4Devs-pipeline-solved-jairopolo/AI4Devs-pipeline-solved-jairopolo. Supported file patterns: package-lock.json,npm-shrinkwrap.json,yarn.lock  
```