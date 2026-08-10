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

---

## 🛠️ How to Use

1. **Install Extension:** Load the `.rbz` file into SketchUp via Extension Manager.
2. **Set Up Camera:** Open your SketchUp model and adjust the camera to your desired angle.
3. **Open Tool:** Launch **NDS-WIC** from the toolbar icon or the Extensions menu.
4. **Generate Scenes:** Select the scene types you want (e.g., LineArt, Shadow, Base Color, Thick Lines) and click **Create Scenes** (장면생성).
5. **Select Scenes:** Check all the generated scenes you wish to export.
6. **Export Settings:**
   - Choose your target **File Type** (PSD, PNG, JPG, etc.).
   - Specify the image size (**Width × Height**).
7. **Export:** Click the **Export Webtoon Images** (웹툰내보내기) button.
8. **Completion:** Wait for the export process to complete until the notification dialog appears.

---

## 📁 Output Directory

- The completion dialog will show the path to the output folder.
- By default, exported images are saved in the **same directory as the current SketchUp (`.skp`) model file**.
