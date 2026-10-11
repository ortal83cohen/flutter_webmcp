# webmcp_flutter example

This example demonstrates how to register MCP tools with `WebMcp`, observe a
page with `WebMcpPage`, and publish the tool registry to a Chrome browser tab
via `WebMcpNativePublisher`.

## Dependencies

The example depends on the root `webmcp_flutter` package and on the companion
packages `webmcp_flutter_annotations` and `webmcp_flutter_generator` through
**relative path references**. It must therefore be run from a clone of this
repository; the companion packages are not presented as published on pub.dev.

## Running the example

All commands must be run from the `example/` directory.

1. **Fetch dependencies**

   ```sh
   flutter pub get
   ```

2. **Run in Chrome**

   ```sh
   flutter run -d chrome
   ```
