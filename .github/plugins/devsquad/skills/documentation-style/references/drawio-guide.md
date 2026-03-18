# Draw.io Guide

## When to use

Use Draw.io for system architecture diagrams or more complex diagrams that do not fit in Mermaid.

## Creation

Create the diagram as a `.drawio` file using the `drawio/create_diagram` tool or directly via VS Code (Draw.io Integration extension).

Export as `.drawio.png` (preferred format) for versioning and inline markdown visualization.

## CLI Export

Requires draw.io desktop installed:

```bash
# Detect CLI

# macOS: DRAWIO_CLI="/Applications/draw.io.app/Contents/MacOS/draw.io"
# Linux: drawio or /usr/bin/drawio
# Windows: "C:\Program Files\draw.io\draw.io.exe"

# Export as .drawio.png (recommended format)
"$DRAWIO_CLI" --export \
  --format png \
  --border 20 \
  --scale 2 \
  --output diagram.drawio.png \
  diagram.drawio
```

- `--scale 2`: exports at 2x for good quality on retina displays
- `--border 20`: 20px margin to avoid clipping in viewers
- PNG is widely compatible with all markdown renderers (GitHub, Azure DevOps, etc.)

## Docker Export

Alternative without draw.io desktop:

```bash
# Usa rlespinasse/drawio-desktop-headless (draw.io headless com Xvfb)
docker run --rm -w /data -v "$(pwd)":/data \
  rlespinasse/drawio-desktop-headless \
  --export \
  --format png \
  --border 20 \
  --scale 2 \
  --output diagram.drawio.png \
  diagram.drawio
```

- Same parameters as local CLI, but runs in a container without needing a GUI
- Useful for CI/CD, Linux without desktop, or any environment without draw.io installed
- Ref: [docker-drawio-desktop-headless](https://github.com/rlespinasse/docker-drawio-desktop-headless)

## Recommended workflow

1. Generate the XML with `drawio/create_diagram` for quick preview
2. Save as `.drawio` temporarily
3. Export as `.drawio.png`:
   - **Option A**: Local CLI (`draw.io --export ...`) if draw.io desktop available
   - **Option B**: Docker (`docker run ... rlespinasse/drawio-desktop-headless --export ...`) if CLI unavailable
4. Keep the `.drawio` file in the repository for future editing
5. If no export option available: keep only the `.drawio` and guide the user to export manually

## Markdown reference

- Reference as image: `![Description](path/diagram.drawio.png)`
- Version both the `.drawio` (editable) and `.drawio.png` (viewable) in the repository
