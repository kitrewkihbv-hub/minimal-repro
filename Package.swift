name: NeoWidget macOS Native
platforms:
  macOS: 14.0
products:
  - name: NeoWidget
    type: application
    targets:
      - NeoWidget
      - NeoWidgetExtension
targets:
  - name: NeoWidget
    platform: macOS
    product: application
    dependencies:
      - target: NeoWidgetExtension
    settings:
      CODE_SIGN_IDENTITY: ""
      CODE_SIGNING_ALLOWED: NO
      DEVELOPMENT_TEAM: ""
      SWIFT_VERSION: "5.9"
      BASE_SDK: "macosx14.0"
  - name: NeoWidgetExtension
    platform: macOS
    product: appExtension
    dependencies: []
    settings:
      CODE_SIGN_IDENTITY: ""
      CODE_SIGNING_ALLOWED: NO
      DEVELOPMENT_TEAM: ""
      BASE_SDK: "macosx14.0"
