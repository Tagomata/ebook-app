# Configuración de AWS OIDC para GitHub Actions

## 📚 ¿Qué vamos a configurar?

**OIDC (OpenID Connect)** permite que GitHub Actions se autentique con AWS sin usar access keys permanentes. Es más seguro porque:
- ✅ No hay credenciales hardcodeadas
- ✅ Tokens temporales que expiran
- ✅ Permisos específicos por repositorio

## 🎯 Arquitectura de Autenticación

```
GitHub Actions Workflow
        ↓ (solicita token)
GitHub OIDC Provider
        ↓ (valida y genera token temporal)
AWS IAM Role (con trust policy)
        ↓ (asume role)
Permisos para Terraform (S3, DynamoDB, Lambda, etc.)
```

## 🛠️ Pasos de Configuración

### Paso 1: Crear OIDC Provider en AWS

Vamos a usar Terraform para crear el OIDC provider. He creado los archivos en `terraform/iam-bootstrap/`

```bash
cd terraform/iam-bootstrap
terraform init
terraform plan
terraform apply
```

**¿Qué crea esto?**
1. **OIDC Provider**: Conecta AWS con GitHub
2. **IAM Role**: `github-actions-terraform-role` con permisos de administrador
3. **Trust Policy**: Solo permite acceso desde tu repo `Tagomata/ebook-app`

### Paso 2: Configurar GitHub Repository

No necesitas agregar secrets! OIDC funciona automáticamente. Solo necesitas:

1. **Ir a tu repositorio:** `https://github.com/Tagomata/ebook-app`
2. **Settings → Actions → General**
3. **Workflow permissions → Read and write permissions** ✅

### Paso 3: Verificar la Configuración

Después de aplicar el Terraform del paso 1:

```bash
# Ver el ARN del role creado
terraform output github_actions_role_arn

# Verificar el OIDC provider
aws iam list-open-id-connect-providers
```

Copia el **Role ARN** - lo usaremos en GitHub Actions.

## 📋 Permisos Incluidos en el Role

El role tiene una política de administrador para Terraform que incluye:

- ✅ **S3**: Leer/escribir state file
- ✅ **DynamoDB**: State locking
- ✅ **Lambda**: Crear/actualizar funciones
- ✅ **CloudFront**: Crear distribuciones
- ✅ **Route53**: Gestionar DNS
- ✅ **CloudWatch**: Logs y métricas
- ✅ **IAM**: Crear roles para Lambda
- ✅ **ACM**: Certificados SSL

## 🔐 Trust Policy Explicado

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:Tagomata/ebook-app:*"
        }
      }
    }
  ]
}
```

**¿Qué significa?**
- Solo el repo `Tagomata/ebook-app` puede asumir este role
- Funciona en cualquier rama (`*`)
- GitHub genera un token temporal cuando se ejecuta el workflow

## 🚀 Uso en GitHub Actions

Ejemplo de cómo se usa en el workflow:

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/github-actions-terraform-role
    aws-region: us-east-2
```

**No se necesitan secrets!** GitHub y AWS negocian el acceso automáticamente.

## ⚠️ Importante

1. **Primera vez**: Debes ejecutar el bootstrap con credenciales locales (AWS CLI)
2. **Después**: GitHub Actions usa el role OIDC
3. **Seguridad**: El role solo funciona desde tu repositorio específico

## 🔄 Próximos Pasos

1. ✅ Ejecutar terraform en `iam-bootstrap/`
2. ✅ Copiar el Role ARN del output
3. ✅ Agregar el ARN al workflow de GitHub Actions
4. ✅ Hacer push y ver el pipeline en acción

## 🆘 Troubleshooting

### Error: "Not authorized to perform sts:AssumeRoleWithWebIdentity"
- Verifica que el OIDC provider está creado
- Verifica el trust policy del role
- Verifica el nombre del repositorio en el trust policy

### Error: "No valid credential sources"
- Verifica que el workflow usa `aws-actions/configure-aws-credentials@v4`
- Verifica que el `role-to-assume` es correcto

### Error: "Access Denied" en S3
- Verifica que el role tiene permisos en la política de permisos
- Verifica que el bucket S3 existe
