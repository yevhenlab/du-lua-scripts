# Dual Universe Lua Info

This folder is a community reference extract of Dual Universe's in-game F1 Knowledge Base, made for easier Lua development and icon discovery. It is not affiliated with, endorsed by, or an official publication of Novaquark.

## Rights and sharing

Dual Universe, its F1 documentation, and the SVG assets in `svg/` are game materials. Novaquark's published EULA says that rights and intellectual-property rights related to the Game belong to Novaquark or its licensors. This repository does not claim ownership of those materials and does not grant a license to them.

The files are shared only as a non-commercial compatibility and reference aid for the community. Keep the attribution and proprietary notices intact, do not present the materials as original work or as Novaquark-endorsed, and comply with the applicable Dual Universe terms and local law. Obtain permission from Novaquark before publishing if their terms or your intended use require it. This notice is not legal advice and cannot guarantee protection from a claim.

- `f1-lua-element-api-index.json` is the AI-friendly Lua API inventory. It separates linkable element APIs from global Lua namespaces, RenderScript, and reference topics. No local filesystem paths are included.
- `svg-index.json` is the AI-friendly SVG manifest. Search `key`, `title`, `tags`, and `usageTags`, then use the referenced standalone file from `svg/`. `usageTags` classify likely HUD/AR uses such as `navigation`, `combat`, `flight`, `industry`, `social`, `building`, and `interface`. `visualDescription`, `visualMotifs`, and `recommendedContexts` are editorial discovery hints added after visually reviewing rendered contact sheets; they are not official Novaquark classifications. Use `visualReviewConfidence` to decide when to inspect the SVG before use.
- `SVG-GALLERY.md` displays the SVG collection in the ordinary GitHub repository view.
- `f1-svg-gallery.html` provides an interactive local/GitHub Pages gallery. GitHub repository file views show HTML source rather than render it, so enable GitHub Pages if publishing the interactive gallery.

To rebuild this release from recovered F1 files:

```powershell
./build-community-release.ps1 -ApiIndexPath <path-to-f1-lua-element-api-index.json> -F1HtmlPath <path-to-f1-lua-element-api.html>
```
