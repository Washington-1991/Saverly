# Saverly – Gestión de finanzas personales con partida doble

Aplicación web desarrollada con **Ruby on Rails 7.2+** y **PostgreSQL** para la gestión de finanzas personales utilizando el principio de **partida doble** (origen → destino). Permite llevar control de cuentas, movimientos (ingresos, gastos, transferencias), generar reportes y administrar usuarios con roles.

---

## 🚀 Estado actual del proyecto

**✅ Funcionalidades completas:**
- Autenticación de usuarios (login con email/username, registro desactivado).
- Roles: **admin** y **user** con panel de administración de usuarios.
- CRUD completo de **cuentas** (nombre y saldo).
- CRUD completo de **movimientos** con lógica de partida doble:
  - Tipos: `transfer`, `income`, `expense`.
  - Validaciones contables (saldo suficiente, origen ≠ destino, propiedad).
  - Actualización automática de saldos con transacciones y bloqueos pesimistas.
  - **Vista de detalle (`show`)** para cada movimiento.
  - **Listado con filtros** por tipo de movimiento y rango de fechas.
  - **Orden descendente** por fecha y hora de creación.
  - **Confirmación al eliminar** con Turbo (evita borrados accidentales).
- Dashboard con resumen de cuentas y últimos movimientos.
- API REST JSON para cuentas, movimientos y reportes.
- Reportes: balance general, ingresos vs gastos, movimientos recientes, resumen mensual.
- Caching de reportes con invalidación automática.
- Rate limiting (rack-attack) para prevenir abusos.
- Logging de auditoría de cambios en cuentas y movimientos.
- Documentación de API con **Swagger/OpenAPI** (disponible en `/api-docs`).
- Pruebas automatizadas con **RSpec**, integración continua con **GitHub Actions**.
- Seeds con usuarios iniciales (admin y usuarios de prueba).

**⏳ Pendiente (mejoras futuras):**
- Mejorar el diseño visual (Bootstrap/Tailwind).
- Gráficos interactivos (Chartkick).
- Preparación para móviles (responsive o PWA).
- Despliegue en Fly.io (o similar).
- Exportación de datos (CSV, PDF).

---

## 📦 Tecnologías utilizadas

- **Ruby 3.1+**
- **Ruby on Rails 7.2.2**
- **PostgreSQL** (base de datos)
- **bcrypt** (autenticación)
- **pagy** (paginación)
- **rack-attack** (rate limiting)
- **rswag** (Swagger/OpenAPI)
- **RSpec**, **FactoryBot**, **Faker** (pruebas)
- **RuboCop**, **Brakeman** (análisis estático)
- **GitHub Actions** (CI/CD)

---

## 📋 Requisitos previos

- Ruby 3.1+
- PostgreSQL 12+
- Node.js (para assets)
- Bundler

---

## 🛠️ Configuración e instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/Washington-1991/Saverly.git
cd Saverly