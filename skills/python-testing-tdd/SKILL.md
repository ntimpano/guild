---
name: python-testing-tdd
description: "Patrón estricto de testing Python con TDD aplicado a runtime e infraestructura. Trigger: cuando se pidan tests Python o se pida trabajar en modo TDD."
license: Apache-2.0
metadata:
 author: gentleman-programming
 version: "1.0"
---

## When to Use

- Implementar cambios en Python con garantía de comportamiento.
- Escribir tests primero (TDD) para bugfixes o features.
- Validar lambdas, integraciones AWS y CDK Step Functions.

## Critical Patterns

1. **TDD real: RED → GREEN → REFACTOR**
  - RED: test nuevo falla por la razón correcta.
  - GREEN: mínimo código para pasar.
  - REFACTOR: mejorar sin romper tests.
  - Si no hubo RED real, no fue TDD.

2. **Tests de runtime, no solo inspección de source**
  - Probar comportamiento observable (inputs/outputs/side effects).
  - Evitar tests que solo validan strings o AST sin ejecutar lógica.

3. **Mocking AWS: boto3/SES/Dynamo**
  - Mockear clientes boto3 en bordes del sistema.
  - Validar llamadas esperadas (payload, tabla, destinatarios, etc.).
  - No tocar recursos AWS reales en unit tests.

4. **CDK Step Functions: assertions de synth**
  - Synth de stack en test.
  - Assert sobre definición de State Machine y recursos esperados.
  - Verificar contratos críticos (timeouts, retries, permisos mínimos).

5. **Evidencia ejecutada obligatoria**
  - Guardar comando exacto corrido (`pytest ...`).
  - Guardar resultado (pass/fail + resumen).
  - No declarar “tested” sin ejecución real.

## Minimal TDD Loop

```text
1) Escribir test que falla (RED)
2) Implementar mínimo para pasar (GREEN)
3) Refactor seguro con suite verde (REFACTOR)
4) Registrar evidencia del run
```

## Commands

```bash
# Ejecutar subset rápido durante RED/GREEN
pytest tests/unit/path/test_module.py -q

# Ejecutar suite objetivo antes de cerrar
pytest tests/unit -q
```

## Resources

- **Runtime tests**: `tests/unit/`
- **Infra assertions**: `tests/unit/test_alerting_router_stack.py`
