---
name: repo-workflow-ops
description: "Prácticas operativas para git/repo y promoción dev->prd. Trigger: cuando se opere sobre repo (branch, push, merge o release path dev->prd)."
license: Apache-2.0
metadata:
 author: gentleman-programming
 version: "1.0"
---

## When to Use

- Crear branches y preparar pushes.
- Validar merges/rebases antes de integrar.
- Ejecutar flujo de promoción entre entornos (`dev -> prd`).

## Critical Patterns

1. **Pre-flight checks antes de tocar historial**
  - Confirmar branch actual.
  - Confirmar upstream y remoto correcto.
  - Confirmar permisos/políticas del branch target.

2. **Status limpio antes de operaciones críticas**
  - `git status` sin cambios pendientes antes de `rebase`, `merge`, `switch` o `release`.
  - Si hay cambios, stash/commit explícito; nunca mezclar estado sucio con integración.

3. **Diff esperado, no sorpresas**
  - Revisar `git diff` y `git diff --staged` antes de commit/push.
  - Verificar que solo entre alcance esperado del trabajo.

4. **Protección contra line-ending drift**
  - Respetar `.gitattributes` y EOL del repo.
  - Si aparece drift masivo CRLF/LF, frenar y corregir config antes de commitear.
  - No mezclar normalización de EOL con cambios funcionales.

5. **Policy de no secretos**
  - Nunca commitear `.env`, credenciales, tokens o dumps.
  - Escanear cambios sensibles antes de push.
  - Si se detecta secreto, rotar credencial y limpiar historial según política del equipo.

6. **Flujo dev->prd explícito y auditable**
  - Integrar primero en `dev` con validación completa.
  - Promover a `prd` solo con evidencia de pruebas + aprobación.
  - Evitar saltos directos a `prd` sin gate intermedio.

## Minimal Operational Checklist

- [ ] Pre-flight completo (branch, remoto, políticas).
- [ ] Working tree limpio para operación crítica.
- [ ] Diff revisado y dentro de alcance.
- [ ] Sin drift de line endings.
- [ ] Sin secretos en stage/commit.
- [ ] Gate dev validado antes de promoción prd.

## Commands

```bash
# Pre-flight básico
git status
git branch --show-current
git remote -v

# Revisar alcance real
git diff
git diff --staged

# Promoción típica
git checkout dev && git pull
git checkout prd && git pull
git merge --no-ff dev
```

## Resources

- **PR discipline**: ver skill `azure-pr-workflow`
- **Testing discipline**: ver skill `python-testing-tdd`
