# Terraform Infrastructure - Arquitectura Serverless

## Estructura del Proyecto

```
terraform/
├── backend.tf          # Configuración del backend remoto en S3
├── provider.tf         # Configuración del provider AWS
├── versions.tf         # Versiones de Terraform y providers requeridos
├── variables.tf        # Variables de entrada del proyecto
├── outputs.tf          # Outputs que se mostrarán después del apply
├── terraform.tfvars    # Valores de las variables (NO subir a git)
├── main.tf             # Orquestación de módulos principales
├── environments/       # Configuraciones por entorno (futuro)
└── modules/            # Módulos reutilizables
    ├── lambda/         # Funciones Lambda
    ├── dynamodb/       # Tablas DynamoDB
    ├── cloudfront/     # Distribuciones CloudFront
    ├── route53/        # Zonas y registros DNS
    └── cloudwatch/     # Logs, métricas y alarmas
```

## Conceptos Clave de Terraform

### 1. Backend (backend.tf)
- **¿Qué es?** Lugar donde Terraform guarda el estado de tu infraestructura
- **S3 Backend:** Permite trabajo colaborativo, bloqueo de estado, y versionado
- **State File:** Archivo que mapea tu código Terraform con recursos reales en AWS

### 2. Provider (provider.tf)
- **¿Qué es?** Plugin que permite a Terraform interactuar con APIs (AWS, Azure, etc.)
- Define credenciales, región por defecto, y configuraciones globales

### 3. Modules (modules/)
- **¿Qué son?** Contenedores reutilizables de recursos Terraform
- Permiten encapsular lógica y reutilizar código
- Cada módulo tiene sus propias variables, outputs, y recursos

### 4. Variables (variables.tf)
- Parametrizan tu código para hacerlo flexible
- Tipos: string, number, bool, list, map, object
- Se pueden pasar por CLI, archivos .tfvars, o variables de entorno

### 5. Outputs (outputs.tf)
- Exponen información después del `terraform apply`
- Útiles para conectar módulos o mostrar URLs/IDs importantes

## Comandos Básicos

```bash
# Inicializar Terraform (descargar providers, configurar backend)
terraform init

# Ver plan de ejecución (qué se va a crear/modificar/destruir)
terraform plan

# Aplicar cambios
terraform apply

# Destruir toda la infraestructura
terraform destroy

# Formatear código
terraform fmt -recursive

# Validar sintaxis
terraform validate

# Mostrar outputs
terraform output
```

## Flujo de Trabajo Recomendado

1. **Desarrollo Local:**
   - Hacer cambios en archivos .tf
   - `terraform fmt` para formatear
   - `terraform validate` para verificar sintaxis
   - `terraform plan` para ver cambios

2. **Review de Cambios:**
   - Revisar el plan cuidadosamente
   - Verificar recursos que se crearán/modificarán/destruirán

3. **Aplicación:**
   - `terraform apply` para desplegar
   - Confirmar con "yes"

4. **Git Workflow:**
   - Commit de archivos .tf
   - PR en GitHub
   - GitHub Actions ejecuta `plan` automáticamente
   - Merge → GitHub Actions ejecuta `apply`

## Archivos que NO debes subir a Git

Crea un `.gitignore` con:
```
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
.terraform.lock.hcl
crash.log
override.tf
override.tf.json
```

## Próximos Pasos

1. ✅ Estructura creada
2. ⏳ Configurar backend S3
3. ⏳ Crear módulos base
4. ⏳ Configurar GitHub Actions
5. ⏳ Primer despliegue
