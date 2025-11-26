# Getting Started - Inicializar Terraform

## 📋 Estructura Creada

```
terraform/
├── backend.tf                  ✅ Backend S3 con DynamoDB locking
├── provider.tf                 ✅ Provider AWS (us-east-2 y us-east-1)
├── versions.tf                 ✅ Versiones de Terraform y providers
├── variables.tf                ✅ Variables esenciales
├── data.tf                     ✅ Data sources (account, region)
├── locals.tf                   ✅ Variables locales calculadas
├── outputs.tf                  ✅ Outputs básicos
├── terraform.tfvars.example    ✅ Template de variables
└── README.md                   ✅ Documentación del proyecto
```

## 🚀 Pasos para Inicializar

### 1. Crear archivo de variables

Copia el archivo de ejemplo y personalízalo:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores (este archivo NO se sube a git):

```hcl
aws_region   = "us-east-2"
stack_id     = "ebook-app"
environment  = "prod"
project_name = "ebook-app"
```

### 2. Configurar credenciales AWS

Asegúrate de tener credenciales AWS configuradas. Opciones:

**Opción A: AWS CLI**
```bash
aws configure
# Ingresa: Access Key ID, Secret Access Key, Region
```

**Opción B: Variables de entorno**
```bash
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_REGION="us-east-2"
```

**Opción C: AWS Profile**
```bash
export AWS_PROFILE="tu-perfil"
```

### 3. Verificar acceso al backend S3

```bash
# Verificar que el bucket existe
aws s3 ls s3://tfstate-ebook-app --region us-east-2

# Verificar que la tabla DynamoDB existe
aws dynamodb describe-table --table-name tfstate-ebook-app-lock --region us-east-2
```

### 4. Inicializar Terraform

```bash
cd terraform
terraform init
```

Este comando:
- ✅ Descarga el provider de AWS
- ✅ Configura el backend S3
- ✅ Crea el archivo `.terraform.lock.hcl`

**Salida esperada:**
```
Initializing the backend...
Successfully configured the backend "s3"!

Initializing provider plugins...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### 5. Validar la configuración

```bash
# Validar sintaxis
terraform validate

# Ver el plan (debería estar vacío por ahora)
terraform plan
```

## 📚 Conceptos que Aprendiste

### 1. **Backend S3**
- **¿Qué es?** Almacenamiento remoto del estado de Terraform
- **¿Por qué?** Permite colaboración en equipo y versionado
- **Archivo:** `backend.tf`

### 2. **State Locking con DynamoDB**
- **¿Qué es?** Previene ejecuciones simultáneas de `terraform apply`
- **¿Por qué?** Evita corrupción del estado
- **Tabla DynamoDB:** `tfstate-ebook-app-lock`

### 3. **Data Sources**
- **¿Qué son?** Obtienen información de recursos existentes en AWS
- **Ejemplos:** `aws_caller_identity`, `aws_region`
- **Archivo:** `data.tf`

### 4. **Locals**
- **¿Qué son?** Variables calculadas que se reutilizan en el código
- **Ejemplos:** `name_prefix`, `common_tags`
- **Archivo:** `locals.tf`

### 5. **Providers**
- **¿Qué son?** Plugins que conectan Terraform con AWS
- **Múltiples providers:** `us-east-2` (principal) y `us-east-1` (para CloudFront)
- **Archivo:** `provider.tf`

## 🔄 Próximos Pasos

1. ✅ Estructura base creada
2. ✅ Backend S3 configurado
3. ⏳ **SIGUIENTE:** Crear módulos (Lambda, DynamoDB, CloudFront, etc.)
4. ⏳ Configurar GitHub Actions para CI/CD
5. ⏳ Primer despliegue de recursos

## 🛠️ Comandos Útiles

```bash
# Ver estado actual
terraform show

# Ver outputs
terraform output

# Formatear código
terraform fmt -recursive

# Ver qué recursos se crearán/modificarán
terraform plan

# Aplicar cambios
terraform apply

# Destruir todo (¡cuidado!)
terraform destroy
```

## ⚠️ Importante

- **NUNCA** subas `terraform.tfvars` a git (contiene valores específicos)
- **NUNCA** subas `*.tfstate` a git (se guarda en S3)
- **SIEMPRE** ejecuta `terraform plan` antes de `apply`
- **SIEMPRE** revisa los cambios antes de confirmar

## 🆘 Troubleshooting

### Error: "Error loading state: AccessDenied"
- Verifica tus credenciales AWS
- Verifica permisos en el bucket S3

### Error: "Error acquiring the state lock"
- Alguien más está ejecutando terraform
- O un proceso anterior no terminó correctamente
- Ver tabla DynamoDB para el lock ID

### Error: "Backend initialization required"
- Ejecuta `terraform init` nuevamente
