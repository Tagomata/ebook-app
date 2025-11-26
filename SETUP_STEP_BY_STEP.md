# Guía Paso a Paso - ¿Qué hacer AHORA?

## 📦 ¿Qué tenemos hasta ahora?

```
├── terraform/
│   ├── backend.tf          ✅ Backend S3 configurado
│   ├── provider.tf         ✅ Provider AWS
│   ├── versions.tf         ✅ Versiones
│   ├── variables.tf        ✅ Variables básicas
│   ├── data.tf             ✅ Data sources
│   ├── locals.tf           ✅ Variables locales
│   ├── outputs.tf          ✅ Outputs
│   ├── terraform.tfvars.example  ✅ Template de variables
│   │
│   └── iam-bootstrap/      ✅ Configuración de OIDC + IAM Role
│       ├── main.tf         (crea OIDC provider y role para GitHub Actions)
│       ├── provider.tf
│       ├── versions.tf
│       └── outputs.tf
│
├── docs/
│   └── AWS_OIDC_SETUP.md   ✅ Documentación de OIDC
│
└── .gitignore              ✅ Protege archivos sensibles
```

## 🎯 ¿Cuál es el orden correcto?

Hay **DOS Terraform separados**:

### 1. **IAM Bootstrap** (terraform/iam-bootstrap/)
- **Propósito**: Crear el OIDC Provider y IAM Role para GitHub Actions
- **Se ejecuta**: UNA SOLA VEZ, de forma LOCAL con tus credenciales
- **Backend**: ❌ NO necesita backend S3 (usa backend local)
- **Cuándo**: AHORA (primer paso)

### 2. **Infraestructura Principal** (terraform/)
- **Propósito**: Crear Lambda, DynamoDB, CloudFront, etc.
- **Se ejecuta**: Por ti localmente O por GitHub Actions
- **Backend**: ✅ SÍ usa backend S3 (tfstate-ebook-app)
- **Cuándo**: DESPUÉS de crear el IAM Role

## 🚀 PASO 1: Ejecutar IAM Bootstrap

### A. Verificar credenciales AWS locales

```bash
# ¿Tienes AWS CLI configurado?
aws sts get-caller-identity
```

**Si sale error:**
```bash
aws configure
# Ingresa tu Access Key ID
# Ingresa tu Secret Access Key
# Region: us-east-2
# Output format: json
```

### B. Ejecutar el IAM Bootstrap

```bash
# Ir al directorio de bootstrap
cd terraform/iam-bootstrap

# Inicializar Terraform (NO usa S3, usa backend local)
terraform init

# Ver qué se va a crear
terraform plan

# Leer el plan:
# - aws_iam_openid_connect_provider.github (nuevo)
# - aws_iam_role.github_actions (nuevo)
# - aws_iam_policy.terraform_permissions (nuevo)

# Crear los recursos
terraform apply
```

**Terraform te preguntará:** `Do you want to perform these actions?`
- Escribe: `yes`
- Presiona Enter

### C. Copiar el Role ARN

Después del `apply`, verás un output como:

```
Outputs:

github_actions_role_arn = "arn:aws:iam::123456789012:role/github-actions-terraform-role"
```

**📝 COPIA Y GUARDA ESE ARN** - Lo necesitaremos para GitHub Actions más tarde.

## ✋ DETENTE AQUÍ

**NO HAGAS NADA MÁS HASTA COMPLETAR EL PASO 1**

Cuando termines el Paso 1, dime:
- ✅ "Listo, ejecuté el iam-bootstrap"
- ✅ Muéstrame el Role ARN que te dio

Entonces continuaremos con:
- Paso 2: Inicializar el Terraform principal (con backend S3)
- Paso 3: Crear los workflows de GitHub Actions
- Paso 4: Hacer tu primer despliegue

## ❓ Preguntas Frecuentes

### ¿Por qué el iam-bootstrap no usa backend S3?
Porque necesitas crear el IAM Role PRIMERO antes de que GitHub Actions pueda acceder a S3. Es como crear la llave antes de poder abrir la puerta.

### ¿Puedo destruir el iam-bootstrap después?
NO. El IAM Role debe existir siempre para que GitHub Actions funcione. Solo lo destruyes si dejas de usar GitHub Actions.

### ¿Necesito ejecutar iam-bootstrap cada vez?
NO. Solo UNA VEZ. Una vez creado, el IAM Role permanece en AWS.

### ¿Y si ya tengo un IAM Role?
Entonces puedes skipear el iam-bootstrap y usar tu Role existente. Solo necesito el ARN.

## 🆘 Si algo sale mal

**Error: "AccessDenied"**
- Tu usuario AWS no tiene permisos de administrador
- Necesitas permisos para crear IAM roles

**Error: "EntityAlreadyExists"**
- El OIDC provider o role ya existe
- Puede que lo hayas creado antes
- Puedes obtener el ARN con: `aws iam get-role --role-name github-actions-terraform-role`

**No tengo AWS CLI configurado**
- Instala AWS CLI: https://aws.amazon.com/cli/
- Obtén tus Access Keys desde AWS Console → IAM → Users → Security credentials
