---
name: azure-pr-workflow
description: "Flujo operativo para crear y actualizar pull requests en Azure DevOps. Trigger: cuando se crea o actualiza un PR en Azure DevOps."
license: Apache-2.0
metadata:
 author: gentleman-programming
 version: "1.0"
---

## When to Use

- Abrir un PR nuevo en Azure DevOps.
- Actualizar un PR existente con cambios o rebase.
- Resolver conflictos y dejar el branch listo para merge seguro.

## Critical Patterns

1. **Naming de branch alusivo y consistente**
  - Formato recomendado: `feat/<work-item-id>-<descripcion-corta>` o `fix/<work-item-id>-<descripcion-corta>`.
  - Siempre minúsculas y guiones.

2. **Completar `pull_request_template.md` sin dejar secciones vacías**
  - Problema / contexto.
  - Alcance del cambio.
  - Test plan real ejecutado.
  - Riesgos y rollback.

3. **Reviewer requerido antes de avanzar**
  - Definir al menos 1 reviewer obligatorio (`required reviewer policy`).
  - No pedir auto-approve ni merge sin revisión humana.

4. **Link obligatorio a work items (US + tasks)**
  - Vincular la User Story principal.
  - Vincular tasks técnicas relacionadas.
  - Verificar que el PR cierre/traccione los work items correctos.

5. **Conflictos: resolver local, validar, y re-publicar**
  - Rebase o merge desde target branch.
  - Resolver conflicto archivo por archivo (sin aceptar todo ciego).
  - Ejecutar tests/lint antes de `push`.

6. **Verificación post-merge obligatoria**
  - Confirmar estado de pipeline.
  - Confirmar cierre/transición de work items.
  - Confirmar que el branch mergeado quedó alineado con target.

## Preflight Hard Gates (Blocking)

Ejecutar estos gates en orden. Si falla uno, cortar al instante.

### Formato estándar de error bloqueante

```text
PR_BLOCKED: <gate> | fix: <action>
```

### Gate 1 — Contrato de template (obligatorio)

- El body del PR debe usar `pull_request_template.md` del repo **exactamente**.
- Si falta el template, faltan secciones o hay secciones incompletas/vacías, bloquear creación/actualización del PR.

Ejemplos:
- `PR_BLOCKED: template_missing | fix: crear pull_request_template.md en el repo y reintentar preflight`
- `PR_BLOCKED: template_incomplete | fix: completar todas las secciones requeridas sin borrar encabezados`

### Gate 2 — Contrato de idioma (obligatorio)

- Para este usuario, el body debe estar en es-AR rioplatense (voseo natural).
- Si está en otro idioma o estilo neutro no solicitado, bloquear.

Ejemplo:
- `PR_BLOCKED: language_mismatch | fix: reescribir el body en es-AR rioplatense respetando el template`

### Gate 3 — Contrato de branch (scope + naming)

- El source branch debe respetar naming policy y scope activo del cambio.
- Bloquear reutilización de ramas legacy/no relacionadas.

Ejemplos:
- `PR_BLOCKED: branch_name_invalid | fix: crear branch nueva con policy type/descripcion`
- `PR_BLOCKED: branch_scope_mismatch | fix: crear branch nueva alineada al scope activo y mover commits relevantes`

### Gate 4 — Fail-fast obligatorio

- Si falla cualquier gate, no ejecutar `az repos pr create` ni `az repos pr update`.
- Solo continuar cuando todos los gates pasan.

### Nota de paridad cross-platform

- Misma policy para Azure DevOps y GitHub.
- Cambian comandos/herramientas, no los gates.

## Minimal PR Checklist

- [ ] Branch naming alusivo y válido.
- [ ] `pull_request_template.md` usado exacto y completo (sin secciones vacías).
- [ ] Body en es-AR rioplatense (voseo natural).
- [ ] Reviewer requerido asignado.
- [ ] User Story + tasks linkeadas.
- [ ] Conflictos resueltos y verificados localmente.
- [ ] Post-merge verificado (pipeline + work items).

## Commands

```bash
# Sincronizar branch con target antes de actualizar PR
git fetch origin
git rebase origin/<target-branch>

# Verificar estado local y publicar
git status
git push --force-with-lease

# Crear PR solo si preflight hard-gates pasó
az repos pr create --source-branch <source-branch> --target-branch <target-branch> --title "<titulo>" --description @pull_request_template.md

# Actualizar PR solo si preflight hard-gates pasó
az repos pr update --id <pr-id> --title "<titulo>" --description @pull_request_template.md
```

## Resources

- **Template base**: `pull_request_template.md`
- **Flujo repo**: ver skill `repo-workflow-ops`
