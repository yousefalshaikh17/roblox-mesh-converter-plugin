# Roblox Mesh Converter Plugin

**Roblox Mesh Converter Plugin** is a developer tool that allows easy conversion between `MeshPart` and `SpecialMesh` instances within your game. This plugin makes switching between mesh types fast and hassle-free, allowing you to focus on other tasks. This Mesh Converter was primarily used in Fate Forge's game, Kaizen's Origami, which I am a lead programmer for.

You are also free to use the standalone MeshConverter plugin for real-time mesh conversions in live games. Kaizen's Origami currently does this to convert MeshPart accessories to SpecialMesh accessories for recoloring capabilities.


## Features

- Convert **MeshParts** to **SpecialMesh** parts.
- Convert **SpecialMesh** parts to **MeshParts**.
- Supports **multi-selection**, allowing you to convert multiple objects at once.
- Compatible with **ChangeHistoryService**, so all changes are undoable.
- Lightweight and easy to integrate into any project (built with Rojo, but not required).


## Roblox Project Structure

```
MeshConverterPlugin (Script)
├── MeshConverter (ModuleScript)
```

- `MeshConverterPlugin`: Main plugin script.
- `MeshConverter`: Module containing core conversion logic.


## Usage

1. Install the plugin from the [Roblox Marketplace](https://create.roblox.com/store/asset/119397415504975/Mesh-Converter-Plugin) or import it manually.
2. In the **Explorer**, select one or more `MeshPart` or `SpecialMesh` (or `Part` with `SpecialMesh` child).
3. Click the appropriate **conversion button** in the plugin toolbar:
   - Convert `MeshPart` to `SpecialMesh`
   - Convert `SpecialMesh` to `MeshPart`

![image](https://github.com/user-attachments/assets/53be08d2-0454-4c1b-9b19-d076501133fa)

4. Done! Your mesh objects will be converted and changes will be recorded in the undo history.




## Notes

- Conversion maintains relevant physical size and properties such as `MeshId`, `TextureId`, etc. However, it does not maintain SpecialMesh `Offset` or `VertexColor`.
- Unlikely, but some manual tweaking may be needed depending on mesh asset differences.

## Tests

Unit tests for the MeshConverter module are completed and testing is successful. However, I have not been able to implement it for Rojo yet. I hope to properly add unit testing in the future.

## Requirements

- Roblox Studio


## Contributions

Pull requests and issues are welcome! If you have an idea for improving the plugin or find a bug, feel free to open an issue or PR.


## License

MIT License – feel free to use, modify, and distribute.
