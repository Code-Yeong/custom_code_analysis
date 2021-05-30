# Usage
1.Add dependency to `pubspec.yaml`
```
dependencies:
  custom_code_analysis: ^1.2.2
```
2.Add configuration to `analysis_options.yaml`
```
analyzer:
  plugins:
    - custom_code_analysis

custom_code_analysis:
  exclude:
      - "test/**"
  rules:
    - clickable-widget-uuid-missing
    - avoid-using-show-bottom-modal-sheet
    - avoid-using-show-bottom-sheet
    - avoid-using-show-date-picker
    - avoid-using-show-date-range-picker
    - avoid-using-show-dialog
    - avoid-using-show-general-dialog
    - avoid-using-show-menu
    - avoid-using-show-search
    - avoid-using-show-time-picker
    - avoid-using-color
    - avoid-using-colors
    - override-hash-code-method
```

# Rules
- clickable-widget-id-missing
- avoid-using-show-bottom-modal-sheet
- avoid-using-show-bottom-sheet
- avoid-using-show-date-picker
- avoid-using-show-date-range-picker
- avoid-using-show-dialog
- avoid-using-show-general-dialog
- avoid-using-show-menu
- avoid-using-show-search
- avoid-using-show-time-picker
- avoid-using-color
- avoid-using-colors
- override-hash-code-method

# Command line tools
```
    dart pub run custom_code_analysis:analysis lib
```