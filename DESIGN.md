# DESIGN.md — BUSSU

## Colores (con propósito, no solo hex)

| Token | Valor | Uso |
|---|---|---|
| `primary` | `#001B44` | Headers, texto de marca, iconografía activa, mapa/rutas |
| `secondary/accent` | `#FED000` | CTAs destacados, badge "Live", ítem activo del bottom nav, botón de pago Premium |
| `surface` | `#F8F9FA` | Fondo general |
| `surface-container-lowest` | `#FFFFFF` | Tarjetas |
| `error` | `#BA1A1A` | Alertas de alta severidad, validaciones fallidas |
| `on-surface-variant` | `#434750` | Texto secundario/subtítulos |

## Tipografía

| Token | Valor |
|---|---|
| Familia | Inter |
| `headline-lg` | 32px/40px, weight 600 (desktop) |
| `headline-lg-mobile` | 24px/32px, weight 600 |
| `title-md` | 20px/28px, weight 600 (títulos de tarjeta/sección) |
| `body-md` | 16px/24px, weight 400 (cuerpo) |
| `label-md` | 14px/20px, weight 500 (labels, botones) |
| `label-sm` | 12px/16px, weight 600, letter-spacing 0.05em (bottom nav) |

## Espaciado y forma

| Token | Valor |
|---|---|
| Radios | 4px default, 8px (lg), 12px (xl), full-round (nav/badges) |
| Sombra estándar de tarjeta | `0 4px 12px rgba(0,47,108,0.08)` — nunca bordes duros en tarjetas |
| Spacing scale | 4 / 8 / 16 / 24 / 32px |

## Componentes (patrón obligatorio)

- **Bottom nav (móvil):** 5 ítems máx, ítem activo con pill de fondo `#FED000`, íconos Material Symbols outlined
- **Card de ruta/bus:** barra de color lateral izquierda de 4px indicando línea, título + subtítulo con ícono `schedule`, ETA a la derecha en mono-eta 20px/700
- **Badge de severidad (alertas):** borde izquierdo de color (rojo/amarillo/azul), nunca relleno sólido completo
- **Barra de ocupación:** siempre con % + etiqueta de capacidad, nunca solo un color sin número (excepto en tier Free, que muestra 3 niveles en vez de %)

## Reglas negativas (guardrails)

- Nunca reemplaces una tarjeta con sombra por una con borde duro tipo Material default.
- Nunca uses el ColorScheme por defecto de Flutter/Material; todos los colores deben salir literalmente de este archivo.
- Nunca omitas el estado vacío o el estado de error de una pantalla aunque no se haya pedido explícitamente — cópialo del patrón de la pantalla de Alertas (tarjeta resuelta con check y texto tachado).
- Nunca uses Title Case en botones; siempre sentence case.
