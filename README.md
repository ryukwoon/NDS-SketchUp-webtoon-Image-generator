# NDS - SketchUp Webtoon Background Generator

A SketchUp Ruby extension designed to automate background image extraction for webtoons and comics. It creates standard webtoon rendering scenes and exports them into multi-layer PSD files or standard image formats like PNG and JPG.

> **Note:** Tested and verified on **SketchUp 2019**.

---

## 📥 Download & Installation

- Download the latest version from the [Releases](../../releases) section.
- **Format:** `.rbz` (SketchUp Extension / Ruby format).
- **Compatibility:** SketchUp 2016 or higher.
  *(Versions prior to 2016 have not been tested, but may still work.)*

---

## ✨ Features

- **11 Scene Types:** Automatically generates up to 11 custom scene styles (e.g., LineArt, Shadows, Base Colors, Thick Lines, etc.).
- **PSD Export:** Combines generated scenes into layered PSD files for efficient post-processing.
- **Multi-Format Support:** Export directly to PNG, JPG, and other standard image formats.
- **Custom Dimensions:** Set custom image resolution (width × height) before exporting.
- **Transparent Background Option:** Supports transparent background rendering for empty space.
<table border="0">
  <tr>
    <td border="0"><img valign="top" width="40%" alt="menu" src="https://github.com/user-attachments/assets/09ffece8-2771-475d-b7a9-31551f146c03" /><img valign="top" width="60%" alt="window" src="https://github.com/user-attachments/assets/21f21dd8-82a0-46a7-b796-ab0f6b553905" /></td>
  </tr>
</table>

---
## 🌐 Multi-Language Support

- **Supported Languages (8 Languages):** English, Korean, French, Spanish, Russian, Chinese, Japanese, and German.
- **Dynamic Language Loading:** Simply place `.json` language files into the `lang/` folder, and the app will automatically detect and load them.

## 🛠️ How to Use

1. **Install Extension:** Load the `.rbz` file into SketchUp via Extension Manager.
2. **Set Up Camera:** Open your SketchUp model and adjust the camera to your desired angle.
3. **Open Tool:** Launch **NDS-WIC** from the toolbar icon or the Extensions menu.
4. **Generate Scenes:** Select the scene types you want (e.g., LineArt, Shadow, Base Color, Thick Lines) and click **Create Scenes** (Scene generation).
5. **Select Scenes:** Check all the generated scenes you wish to export.
6. **Export Settings:**
   - Choose your target **File Type** (PSD, PNG, JPG, etc.).
   - Specify the image size (**Width × Height**).
7. **Export:** Click the **Export Webtoon Images** (Export Webtoon) button.
8. **Completion:** Wait for the export process to complete until the notification dialog appears.

---

## 📁 Output Directory

- The completion dialog will show the path to the output folder.
- By default, exported images are saved in the **same directory as the current SketchUp (`.skp`) model file**.
