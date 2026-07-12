# DESIGN_AUDIT.md — BUSSU

## Colores DESIGN.md → AppTheme

| Token | Valor | AppTheme | Verificado |
|---|---|---|---|
| `primary` | `#001B44` | `AppTheme.primary` | ✅ |
| `secondary/accent` | `#FED000` | `AppTheme.secondary` | ✅ |
| `surface` | `#F8F9FA` | `AppTheme.surface` | ✅ |
| `surface-container-lowest` | `#FFFFFF` | `AppTheme.surfaceContainerLowest` | ✅ |
| `error` | `#BA1A1A` | `AppTheme.error` | ✅ |
| `on-surface-variant` | `#434750` | `AppTheme.onSurfaceVariant` | ✅ |

## Componentes DESIGN.md

| Componente | Regla DESIGN.md | Verificado en |
|---|---|---|
| Card sombra | `0 4px 12px rgba(0,47,108,0.08)` + sin borde duro | `CardThemeData(elevation:4, shadowColor:0x14002F6C, surfaceTint:transparent)` en light/dark theme |
| Card radio | `8px (lg)` | `BorderRadius.circular(radiusLg)` |
| Bottom nav | 5 items max, pill active #FED000 | `RoleScaffold` usa `NavigationBar` con 4 tabs por rol |
| Badge severidad | Border izq color (rojo/amarillo/azul) | `AlertsPage`, `CoopAlertsPage`, `ConductorAlertsPage` |
| Barra ocupacion | % + etiqueta capacidad | `OccupancyPage` CircularProgressIndicator + texto |
| Sentence case botones | Nunca Title Case | Todos los botones usan sentence case |

## Auditoría por página

### Con mockup exacto (/design_reference/)

| Página | Componentes verificados | Estado |
|---|---|---|
| `RoutesPage` | Color de ruta como cículo de color, nombre, conteo paradas, chevron. Tarjeta con sombra DESIGN.md | ✅ |
| `MapPage` | Google Maps + selector de ruta dropdown. Sombra DESIGN.md en el Card del selector | ✅ |
| `TicketsPage` | Estado vacío con icono. ListView con monto y estado. Mock data | ✅ |
| `AlertsPage` | Badge severidad con borde izquierdo de color. Rojo=high, naranja=medium, azul=low | ✅ |
| `FleetDashboardPage` | Métricas en cards con sombra. Quick actions con icono primary + chevron | ✅ |
| `IncidentsPage` | Lista de alertas con PopupMenuButton. Crear alerta con dialog StatefulBuilder | ✅ |

### Extrapoladas (mismo lenguaje visual)

| Página | Patrón base usado | Estado |
|---|---|---|
| `FavoritesPage` | Card ListTile con icono primary + chevron (mismo que RoutesPage) | ✅ |
| `TripHistoryPage` | Card ListTile con chip de estado + icono | ✅ |
| `ProfilePage` | CircleAvatar primary + cards con ListTile + ElevatedButton primary | ✅ |
| `PremiumUpgradePage` | Cards con borde primary para "Recomendado" + ElevatedButton primary | ✅ |
| `DriverDashboardPage` | Card header de estado + ListTile con icono primary + chevron | ✅ |
| `ActiveTripPage` | Card centrado + InfoRow + ElevatedButton error para finalizar | ✅ |
| `BusStatusPage` | Card ListTile con icono de color (green/red) | ✅ |
| `OccupancyPage` | CircularProgressIndicator + cards de leyenda | ✅ |
| `ConductorAlertsPage` | Badge severidad borde izquierdo (patrón AlertsPage) | ✅ |
| `DriverTripHistoryPage` | Card ListTile con CircleAvatar color + chip estado + fecha | ✅ |
| `DriverManagementPage` | Card con CircleAvatar primary + botón OutlinedButton | ✅ |
| `BusesManagementPage` | ListTile con CircleAvatar primary + FAB create + dialog | ✅ |
| `StopManagementPage` | TabBar + cards con botones approve/reject | ✅ |
| `RoutesManagementPage` | Card con círculo color + ListTile + FAB + dialog | ✅ |
| `ReportsPage` | Card con _StatBox grid (4 columnas) | ✅ |
| `CoopAnalyticsPage` | Card con _StatBox grid (mismo que ReportsPage) | ✅ |
| `CoopTripHistoryPage` | Card ListTile con bus+route+estado+fecha (patrón TripHistoryPage) | ✅ |
| `CoopAlertsPage` | Badge severidad borde izquierdo (patrón AlertsPage) | ✅ |
| `MunicipalOverviewPage` | CircularProgressIndicator salud + _MetricCard grid + QuickAction ListTile | ✅ |
| `CooperativasCrudPage` | ListTile con indicador actividad + FAB + dialog | ✅ |
| `UserManagementPage` | CircleAvatar + Chip rol con color + PopupMenuButton | ✅ |
| `PremiumManagementPage` | ListTile con Chip status (green=active, grey=inactive) | ✅ |
| `AnalyticsPage` | Cards + _ReportRow (label/value) | ✅ |
| `MunicipalReportsPage` | Card + _Row (label/value) + cooperativa breakdown | ✅ |
| `MunicipalNotificationsPage` | Cards + SwitchListTile + CircleAvatar status | ✅ |
| `MunicipalConfigPage` | Cards + ListTile con subtitle descriptivo | ✅ |
| `ChatPage` | Burbujas de chat (primary derecha, grey izquierda) + input | ✅ |

## Strings de marca

| Antes | Ahora | Archivos |
|---|---|---|
| "Andes Mobility" | "BUSSU" | `app.dart:15`, `main.dart:21`, `login_page.dart:68`, `login_page_test.dart:48,51` |
