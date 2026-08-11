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

- **10 Scene Types:** Automatically generates up to 10 custom scene styles (e.g., LineArt, Shadows, Base Colors, Thick Lines, etc.).
- **PSD Export:** Combines generated scenes into layered PSD files for efficient post-processing.
- **Multi-Format Support:** Export directly to PNG, JPG, and other standard image formats.
- **Custom Dimensions:** Set custom image resolution (width × height) before exporting.
- **Transparent Background Option:** Supports transparent background rendering for empty space.
<table border="0">
  <tr>
    <td border="0"><img valign="top" width="40%" alt="menu" src="https://github.com/user-attachments/assets/09ffece8-2771-475d-b7a9-31551f146c03" /><img valign="top" width="60%" alt="window2.1.1" src="https://github.com/user-attachments/assets/5338dd20-38cb-4cf1-84b3-c96bbee7b207" /></td>
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
## Generated Image Types
<table border="0">
  <tr>
    <td valign="top" align="center"><img width="100%" alt="Line" src="https://github.com/user-attachments/assets/e7bdf1d1-aa36-43a6-b394-4b0718b146d8" />
<br><b>Line</b></td>
    <td valign="top" align="center"><img width="100%" alt="Profile" src="https://github.com/user-attachments/assets/acb04f40-616e-4fc2-aba9-7c2e03a30e38" />
<br><b>Profile</b></td>
    <td valign="top" align="center"><img width="100%" alt="Vibration" src="https://github.com/user-attachments/assets/a756efc3-c9c1-4e83-98ab-6c89684c999c" />
<br><b>Vibration</b></td>
    <td valign="top" align="center"><img width="100%" alt="Cley" src="https://github.com/user-attachments/assets/b3ea1249-1acb-441f-990b-ef72abf12d1b" />
<br><b>Cley</b></td>
    <td valign="top" align="center"><img width="100%" alt="Shadow" src="https://github.com/user-attachments/assets/d79a409e-9d2f-4ff0-9cb5-c329248bb753" />
<br><b>Shadow</b></td>
  </tr>
  <tr>
    <td valign="top" align="center"><img width="100%" alt="Texture" src="https://github.com/user-attachments/assets/d25682d7-dd4b-4ee5-8ea1-26aca6a5c681" />
<br><b>Texture</b></td>
    <td valign="top" align="center"><img width="100%" alt="Color" src="https://github.com/user-attachments/assets/d30d18d3-42a3-4b73-8a97-52267d7bb143" />
<br><b>Color</b></td>
    <td valign="top" align="center"><img width="100%" alt="Color_by_Layer" src="https://github.com/user-attachments/assets/4eed98c0-d3c2-4f22-a6e7-f4030bbf60eb" />
<br><b>Color_by_Layer</b></td>
    <td valign="top" align="center"><img width="100%" alt="Alpha" src="https://github.com/user-attachments/assets/e4524298-bbec-4a0b-b94e-55cb87677e57" />
<br><b>Alpha</b></td>
    <td valign="top" align="center"><img width="100%" alt="Zdepth" src="https://github.com/user-attachments/assets/d51b0d21-4a29-4aab-8edc-162277e5bae7" />
<br><b>Z-Depth</b></td>
  </tr>
</table>

---
## 📁 Output Directory

- The completion dialog will show the path to the output folder.
- By default, exported images are saved in the **same directory as the current SketchUp (`.skp`) model file**.

---
<p align="center">
  <a href="https://youtu.be/YhRqtDTq2CU" target="_blank" rel="noopener noreferrer">
    <img src="https://img.youtube.com/vi/YhRqtDTq2CU/maxresdefault.jpg" width="80%" alt="NDS-WIC Demo Video" />
  </a>
  <br>
  <sub><b>🎬 NDS-WIC Feature Demo (Click to watch on YouTube)</b></sub>
</p>
