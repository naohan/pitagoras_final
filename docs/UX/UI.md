# UX / UI — Implementación Flutter

**Proyecto:** Pitágoras IA  
**Guía de diseño:** [`../UI_UX_PLAN.md`](../UI_UX_PLAN.md)  
**Plan técnico:** [`../FLUTTER_IMPLEMENTATION_PLAN.md`](../FLUTTER_IMPLEMENTATION_PLAN.md)

Este documento registra el estado de implementación visual por pantalla (complemento del plan de diseño).

---

## Fase 1 — Autenticación

### Login (`LoginPage`)

**Fecha:** 2026-06-26  
**Estado:** ✅ Funcional

| Aspecto | Detalle |
|---------|---------|
| Ruta | `/login` (`RoutePaths.login`) |
| Provider | `authProvider.login()` → `AuthRepository` → JWT en `SessionManager` |
| Diseño | Conservado: gradiente, `LoginHeader`, `MascotHero`, card inferior |
| Formulario | Email + contraseña en `LoginBottomCard` |
| Eliminado | Botones Google y teléfono (sin backend) |
| Post-login | `context.go(RoutePaths.simulacro)` |

#### Estados del formulario

| Estado | Comportamiento UI |
|--------|-------------------|
| **Idle** | Campos editables; botón «Iniciar sesión» activo |
| **Loading** | Campos deshabilitados; spinner en botón |
| **Success** | Transición inmediata a Elegir simulacro |
| **Error** | Mensaje en rojo bajo los campos (401 → credenciales incorrectas; 403 → cuenta inactiva) |

#### Archivos tocados

- `lib/core/router/app_router.dart` — rutas `login` y `simulacro`
- `lib/screens/auth/widgets/login_bottom_card.dart` — formulario + `AuthProvider`
- `lib/core/constanst/app_strings.dart` — copy del formulario
- `lib/screens/exam/simulacro_page.dart` — placeholder destino post-login

#### Pendiente (fuera de este alcance)

- Pantalla funcional Elegir simulacro

---

### Splash (`SplashScreen`)

**Fecha:** 2026-06-26  
**Estado:** ✅ Funcional

| Aspecto | Detalle |
|---------|---------|
| Ruta | `/` (`RoutePaths.splash`) — pantalla inicial de la app |
| Provider | `authProvider.hasSession()` + `authProvider.getMe()` → `GET /api/v1/auth/me` |
| Diseño | Gradiente de marca, `LoginHeader`, slogan, `CircularProgressIndicator` |
| Sin token | Navega a `/login` (sin llamar API) |
| Token válido | `getMe()` exitoso → `/simulacro` |
| Token inválido | `logout()` + navega a `/login` (401 limpia sesión vía interceptor) |
| Duración mínima | 1,2 s de visualización de marca |

#### Flujo

```
Splash
 ├─ sin JWT → Login
 └─ con JWT → GET /auth/me
       ├─ 200 → Elegir simulacro
       └─ error → logout → Login
```

#### Archivos

- **Creado:** `lib/screens/splash/splash_screen.dart`
- **Eliminado:** `lib/core/router/bootstrap_shell.dart`
- **Modificado:** `lib/core/router/app_router.dart`, `lib/core/router/route_paths.dart`

---

### Registro (`RegisterPage`)

**Fecha:** 2026-06-26  
**Estado:** ✅ Funcional

| Aspecto | Detalle |
|---------|---------|
| Ruta | `/register` (`RoutePaths.register`) |
| Provider | `authProvider.register()` → `POST /api/v1/auth/register` → JWT en `SessionManager` |
| Diseño | `AuthScaffold` + `LoginHeader` + `MascotHero` + `RegisterBottomCard` |
| Widgets compartidos | `AuthScaffold`, `AuthBottomCardShell`, `authInputDecoration`, `AuthPrimaryButton` (mismo estilo que Login) |
| Formulario | Nombre, email, contraseña, confirmar contraseña |
| Post-registro | `context.go(RoutePaths.simulacro)` |
| Navegación | Enlace «¿Ya tienes cuenta?» → `/login` |

#### Validaciones

| Campo | Regla |
|-------|-------|
| Nombre | Obligatorio, mínimo 2 caracteres |
| Email | Obligatorio, formato válido |
| Contraseña | Obligatoria, mínimo 8 caracteres |
| Confirmar | Obligatoria, debe coincidir con contraseña |

#### Estados del formulario

| Estado | Comportamiento UI |
|--------|-------------------|
| **Idle** | Campos editables; botón «Crear cuenta» activo |
| **Loading** | Campos deshabilitados; spinner en botón |
| **Success** | Transición inmediata a Elegir simulacro |
| **Error** | Mensaje en rojo bajo los campos (409 → correo ya registrado) |

#### Archivos creados

- `lib/screens/auth/register_page.dart`
- `lib/screens/auth/widgets/register_bottom_card.dart`
- `lib/screens/auth/widgets/auth_scaffold.dart`
- `lib/screens/auth/widgets/auth_bottom_card_shell.dart`
- `lib/screens/auth/widgets/auth_form_widgets.dart`

#### Archivos tocados

- `lib/core/router/app_router.dart` — ruta `register`
- `lib/core/constanst/app_strings.dart` — copy de registro

---

*Última actualización: 2026-06-26 — Splash con validación de sesión.*
