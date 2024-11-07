# Project Packager [Roblox Studio]

Project Packager is an open-source plugin designed to help Roblox developers manage and organize their assets more effectively within Roblox Studio. With features for packing and unpacking assets into structured folders, this tool aims to simplify asset management, improve project organization, and streamline your development workflow.

---

## Features

- **Pack and Unpack Assets**: Quickly group assets and folders into organized structures for easier project navigation.
- **Restore Original Structure**: Effortlessly unpack grouped folders to revert assets to their initial layout.
- **ChangeHistoryService**: Allows you to rollback unwanted changes or redo unwanted rollbacks.
- **Dynamic Merging**: When unpacking, assets are merged into existing folders if their names match, keeping your workspace tidy.

---

## Installation

You have two options for installation:

1. **Download the Repository**:
   - Clone or download the repository to your local system.
   - Open Roblox Studio, then insert the `.lua` files from the repository into Studio.
   - Convert `PackingLogic` from a regular Script to a ModuleScript.
   - **Set Up Folder Structure**: Ensure `PackingLogic` is parented under the `ProjectPackager` script in the Explorer. This structure is essential for the plugin to work as intended.

2. **Download from Releases**:
   - Alternatively, go to the [Releases](../../releases) section of this repository and download the provided `.rbxm` file.
   - Open the `.rbxm` file in Roblox Studio to load the plugin with the correct structure.

### Publishing as a Plugin

1. With the `ProjectPackager` plugin set up in Roblox Studio, go to the `Explorer` panel.
2. Right-click on `ProjectPackager` and select “Publish as Plugin.”
3. Follow the prompts to publish the plugin to your Roblox account.

---

## How to Use Project Packager

### Packing Assets

1. Select the assets or folders you want to organize in Roblox Studio.
2. Click the **Pack** button in the Project Packager toolbar.
3. A new folder containing the selected assets will be created within `ServerStorage`.

### Unpacking Assets

1. Select the folder you wish to unpack.
2. Click the **Unpack** button in the toolbar.
3. The assets are restored to their original locations, merging into existing folders if names match.

---

This plugin is designed to make project management within Roblox Studio more efficient and easy. I hope this plugin can make your development process smoother.
