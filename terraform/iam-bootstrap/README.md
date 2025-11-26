# IAM Bootstrap para GitHub Actions OIDC

## ⚠️ Importante: Ejecutar UNA SOLA VEZ

Este directorio contiene la configuración de Terraform para crear:
1. **OIDC Provider**: Conexión entre GitHub y AWS
2. **IAM Role**: Role que asumirá GitHub Actions
3. **IAM Policy**: Permisos para ejecutar Terraform

**Solo necesitas ejecutar esto UNA VEZ de forma local con tus credenciales AWS.**

## 🚀 Pasos de Ejecución

### 1. Verificar credenciales AWS locales

```bash
# Verificar que tienes credenciales configuradas
aws sts get-caller-identity

# Deberías ver tu Account ID, User ID, y ARN
```

### 2. Inicializar y aplicar Terraform

```bash
cd terraform/iam-bootstrap

# Inicializar Terraform
terraform init

# Ver el plan
terraform plan

# Aplicar (crear recursos)
terraform apply
```

### 3. Copiar el Role ARN

Después del `terraform apply`, verás un output como:

```
Outputs:

github_actions_role_arn = "arn:aws:iam::123456789012:role/github-actions-terraform-role"
```

**¡COPIA ESTE ARN!** Lo necesitarás para los workflows de GitHub Actions.

## 📦 Recursos que se crean

### 1. OIDC Provider
- **Nombre**: `token.actions.githubusercontent.com`
- **Función**: Permite que GitHub genere tokens temporales de AWS

### 2. IAM Role
- **Nombre**: `github-actions-terraform-role`
- **Trust Policy**: Solo permite acceso desde `Tagomata/ebook-app`
- **Descripción**: Role para ejecutar Terraform

### 3. IAM Policy
- **Nombre**: `github-actions-terraform-policy`
- **Permisos incluidos**:
  - S3 (state backend)
  - DynamoDB (state locking)
  - Lambda
  - CloudFront
  - Route53
  - CloudWatch
  - IAM (crear roles para Lambda)
  - ACM (certificados)
  - API Gateway

## 🔐 Seguridad

### Trust Policy
El role solo puede ser asumido por:
- Repositorio específico: `Tagomata/ebook-app`
- Cualquier rama o PR del repositorio
- Con tokens generados por GitHub

### Restricciones
- Tokens temporales (expiran en 1 hora)
- No funciona fuera de GitHub Actions
- No se necesitan access keys permanentes

## 🧪 Verificar la Configuración

Después de aplicar, verifica que todo está correcto:

```bash
# Listar OIDC providers
aws iam list-open-id-connect-providers

# Ver detalles del role
aws iam get-role --role-name github-actions-terraform-role

# Ver políticas del role
aws iam list-attached-role-policies --role-name github-actions-terraform-role
```

## ⏭️ Próximos Pasos

1. ✅ Aplicar este Terraform
2. ✅ Copiar el Role ARN
3. ⏭️ Crear workflows de GitHub Actions (ver `/.github/workflows/`)
4. ⏭️ Agregar el Role ARN a los workflows
5. ⏭️ Push al repositorio y ver el pipeline en acción

## 🗑️ Destruir Recursos (si es necesario)

Si necesitas destruir estos recursos:

```bash
cd terraform/iam-bootstrap
terraform destroy
```

**⚠️ Cuidado:** Destruir estos recursos deshabilitará GitHub Actions.

## 🆘 Troubleshooting

### Error: "AccessDenied"
- Verifica que tienes permisos de administrador en AWS
- Verifica que `aws configure` está configurado

### Error: "EntityAlreadyExists"
- El OIDC provider o role ya existe
- Puedes importarlo: `terraform import aws_iam_role.github_actions github-actions-terraform-role`

### No aparecen outputs
- Ejecuta: `terraform output`
