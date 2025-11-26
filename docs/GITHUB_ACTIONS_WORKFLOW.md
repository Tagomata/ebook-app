# GitHub Actions CI/CD Pipeline

## 🔄 Flujo de Trabajo

```
1. Developer crea feature branch
   ↓
2. Hace cambios en terraform/
   ↓
3. Crea Pull Request → main
   ↓
4. 🤖 GitHub Actions ejecuta terraform-plan.yml
   - ✅ Valida formato
   - ✅ Valida sintaxis
   - ✅ Ejecuta terraform plan
   - ✅ Verifica que plan sea exitoso
   ↓
5. Developer revisa el plan en Actions tab
   ↓
6. Aprueba y hace Merge a main
   ↓
7. 🚀 GitHub Actions ejecuta terraform-apply.yml
   - ✅ Ejecuta terraform plan
   - ✅ Ejecuta terraform apply
   - ✅ Despliega infraestructura a AWS
```

## 📋 Workflows Configurados

### 1. terraform-plan.yml

**Trigger:** Pull Request → main

**Pasos:**
1. Checkout del código
2. Autenticación AWS con OIDC
3. Setup Terraform
4. `terraform init`
5. `terraform fmt -check`
6. `terraform validate`
7. `terraform plan`
8. Verificar éxito

**Propósito:** Validar cambios antes de merge

---

### 2. terraform-apply.yml

**Trigger:** Push/Merge a main

**Pasos:**
1. Checkout del código
2. Autenticación AWS con OIDC
3. Setup Terraform
4. `terraform init`
5. `terraform plan -out=tfplan`
6. `terraform apply -auto-approve tfplan`
7. Verificar éxito

**Propósito:** Desplegar infraestructura automáticamente

## 🔐 Autenticación

Ambos workflows usan **OIDC** para autenticarse con AWS:

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::579897422919:role/github-actions-terraform-role
    aws-region: us-east-2
```

**Beneficios:**
- ✅ No hay access keys en el repositorio
- ✅ Tokens temporales (1 hora)
- ✅ Más seguro

## 🚀 Cómo Usar el Pipeline

### Primer Deploy

1. **Crear feature branch:**
   ```bash
   git checkout -b feature/initial-setup
   ```

2. **Agregar recursos en terraform/ (más adelante):**
   ```bash
   # Cuando crees módulos, los agregas aquí
   ```

3. **Commit y push:**
   ```bash
   git add .
   git commit -m "feat: initial terraform setup"
   git push origin feature/initial-setup
   ```

4. **Crear Pull Request en GitHub:**
   - Ir a: https://github.com/Tagomata/ebook-app
   - Click: "Compare & pull request"
   - Base: `main` ← Compare: `feature/initial-setup`
   - Click: "Create pull request"

5. **Ver el pipeline ejecutarse:**
   - Ir a: Actions tab
   - Ver workflow "Terraform Plan"
   - Revisar los logs

6. **Si todo está ✅, hacer Merge:**
   - Click: "Merge pull request"
   - Click: "Confirm merge"

7. **Pipeline de Apply se ejecuta automáticamente:**
   - Ir a: Actions tab
   - Ver workflow "Terraform Apply"
   - Infraestructura se despliega a AWS

### Deploys Subsecuentes

Repite el mismo proceso:
- Feature branch → cambios → PR → merge → deploy automático

## 📊 Monitorear Pipelines

### Ver workflows
```
GitHub → Tagomata/ebook-app → Actions
```

### Estados posibles:
- 🟡 **In progress**: Ejecutándose
- ✅ **Success**: Exitoso
- ❌ **Failure**: Falló (revisar logs)

### Ver logs detallados:
1. Click en el workflow
2. Click en el job "Terraform Plan" o "Terraform Apply"
3. Expandir steps para ver output

## 🛡️ Protecciones Recomendadas

### Branch Protection Rules (opcional)

En GitHub → Settings → Branches → Add rule:

```
Branch name pattern: main

☑️ Require a pull request before merging
☑️ Require status checks to pass before merging
   ☑️ Terraform Plan
☐ Require branches to be up to date before merging
☑️ Do not allow bypassing the above settings
```

**Esto previene:**
- Push directo a main (fuerza uso de PRs)
- Merge si el plan falla
- Deploys sin validación

## ⚠️ Importante

### ❌ NUNCA hacer:
- Push directo a `main` (siempre usar PRs)
- Ejecutar `terraform apply` localmente en producción
- Modificar state file manualmente

### ✅ SIEMPRE hacer:
- Crear feature branch para cambios
- Revisar el plan en Actions antes de merge
- Usar PRs para todos los cambios

## 🆘 Troubleshooting

### Error: "OpenIDConnect provider not found"
- El OIDC provider no existe
- Verifica que ejecutaste `iam-bootstrap`

### Error: "AccessDenied"
- El IAM Role no tiene permisos
- Verifica la política del role

### Error: "Error acquiring state lock"
- Alguien más está ejecutando terraform
- Espera a que termine o revisa DynamoDB

### Plan falla pero no sé por qué
- Ir a Actions → Click en workflow → Ver logs detallados
- Revisar el step "Terraform Plan" para ver el error

## 📈 Próximos Pasos

1. ✅ Workflows creados
2. ✅ OIDC configurado
3. ⏳ **SIGUIENTE:** Crear módulos de infraestructura (Lambda, DynamoDB, etc.)
4. ⏳ Probar el pipeline con primer PR
5. ⏳ Ver deploy automático en acción
