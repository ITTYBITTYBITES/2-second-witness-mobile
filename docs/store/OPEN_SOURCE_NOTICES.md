# Two Second Witness — Open-Source Notices

**Reviewed:** 2026-07-13
**App version:** 4.0.0

## Godot Engine

Two Second Witness is built with the Godot Engine.

Copyright © 2014-present Godot Engine contributors.
Copyright © 2007-2014 Juan Linietsky, Ariel Manzur.

Godot Engine is licensed under the MIT License:

> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Godot license information is also available at <https://godotengine.org/license/>.

## Project assets and content

The application artwork, interface layouts, challenge content, local audio cues, product copy, and branding in this project are original ITTYBITTYBITES project material unless a file states otherwise.

No external font file, stock-art package, stock-audio package, advertising SDK, account SDK, social SDK, or remote analytics SDK is declared by the production project.

## Android plugin review

Google Play Billing plugin scaffolding exists under the local Android project directory for possible future work. It is not enabled in either production export preset, no billing API is used by the application, and billing is outside the version 4.0.0 product scope.

Before release, inspect the final AAB dependency report and confirm that inactive plugin dependencies are absent. If billing or another third-party component is enabled later, add its required notices before shipping that version.

## Release responsibility

This inventory reflects the current source and export configuration. The publisher must repeat the dependency and asset-license review against the exact signed release artifact before store submission.
