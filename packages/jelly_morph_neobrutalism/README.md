# Jelly neobrutalism morph

The printed-hardware FartUI Instrument design language as a data-only morph for
`jelly_ui`. It changes palette, typography, geometry, state recipes, and static
transition tokens; it cannot replace Jelly interaction, accessibility, physics,
or scheduling behavior.

```dart
MaterialApp(
  theme: JellyTheme.material(
    base: ThemeData.light(),
    morph: JellyNeobrutalism.morph,
  ),
  home: const MyApp(),
)
```

The bundled Archivo and Public Sans variable fonts are licensed under SIL OFL
1.1. See `FONT_LICENSES.md`.
