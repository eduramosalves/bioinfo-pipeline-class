# Slides

Two files:

- **`slide-outline.md`** — the planning outline (titles + bullets + speaker-note paragraphs). Edit
  this when you want to change *content*.
- **`deck.md`** — the renderable [Marp](https://marp.app/) deck built from the outline, themed with
  `theme/brand.css`. Edit this for *delivery*.
- **`theme/brand.css`** — Marp theme mirroring the brand system
  (`~/estudio/knowledge/brandbook.md` v1.0 + `~/estudio/templates/brand-tokens.css`): scientific
  dark, teal→violet, **Exo / Roboto Mono**, glass surfaces, and **SVG icons only — no emoji**. The
  recurring "skeleton" navigation slides carry an inline Lucide `workflow` icon (CSS mask).

## Build

Marp renders Markdown → HTML / PDF / PPTX. No global install needed via `npx`:

```bash
# from repo root
cd slides

# live preview while editing (opens a server, re-renders on save)
npx -y @marp-team/marp-cli@latest -s .

# one-off exports (fonts load from Google Fonts → needs network the first time)
npx -y @marp-team/marp-cli@latest deck.md --theme theme/brand.css -o deck.html
npx -y @marp-team/marp-cli@latest deck.md --theme theme/brand.css --pdf -o deck.pdf
npx -y @marp-team/marp-cli@latest deck.md --theme theme/brand.css --pptx -o deck.pptx
```

The VS Code **Marp for VS Code** extension gives the same preview inline — point it at
`theme/brand.css` in the extension settings (`markdown.marp.themes`).

## Conventions in `deck.md`

- Slides are separated by `---`.
- `<!-- _class: lead -->` → centered title / section slide.
- `<!-- _class: skeleton -->` → navigation slide; the heading gets the `workflow` SVG icon.
- `<p class="eyebrow">…</p>` → the mono uppercase teal kicker above a heading.
- Any other `<!-- … -->` comment is a **presenter note** (visible in Marp's presenter view / notes
  in the PPTX export).

## Brand alignment

Per `decisões-fixas.md`, slides must follow the brandbook. The theme already encodes the tokens; if
the brand system changes, update `theme/brand.css` to match `brand-tokens.css`. Keep it **dark mode,
no emoji, no extra type families** (brandbook §8 anti-patterns).
