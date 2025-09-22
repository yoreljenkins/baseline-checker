# Baseline Checker - Neovim Plugin

A Neovim plugin for web developers that integrates with web.dev's baseline API to provide real-time feedback about CSS features and their browser compatibility status.

## Features

- **Real-time CSS Linting**: Automatically highlights unsupported or experimental CSS features with virtual text as you type
- **Manual Compatibility Checking**: Use `:CheckBaseline <property>` to get detailed browser support information
- **Web.dev API Integration**: Fetches live compatibility data from https://api.webstatus.dev/v1/features
- **Visual Feedback**: Different highlight colors for baseline (✓), limited (⚠), experimental (⚠), and unknown (?) properties
- **Browser Support Data**: Shows support information for Chrome, Firefox, Safari, and Edge
- **Toggle Functionality**: Enable/disable linting on demand
- **Dynamic Updates**: Fetch latest compatibility data from web.dev baseline API

## Installation

!todo: Leroy create package
1. Copy the `baseline-checker` directory to your Neovim lua path
2. Add the plugin to your plugin manager configuration
3. Call `require('baseline-checker').setup()` in your init.lua

## Usage

### Commands

- `:CheckBaseline [property]` - Check browser compatibility for a CSS property
  - Uses web.dev API to fetch real-time data
  - Example: `:CheckBaseline grid` fetches data from `https://api.webstatus.dev/v1/features?q=id:grid`

- `:BaselineList` - Show all known CSS properties with their support status

- `:BaselineStats` - Show feature statistics by baseline category (widely/newly/limited/experimental)

- `:BaselineToggle` - Toggle real-time linting on/off

- `:BaselineUpdate` - Update compatibility data from web.dev baseline API
  - Fetches ALL features from three endpoints:
    - `https://api.webstatus.dev/v1/features?q=baseline_status:widely`
    - `https://api.webstatus.dev/v1/features?q=baseline_status:newly` 
    - `https://api.webstatus.dev/v1/features?q=baseline_status:limited`
  - Saves data to local JSON file for offline use

- `:BaselineCache` - Show API cache statistics

### Key Bindings (Default)

- `<leader>cb` - Check baseline compatibility for current word or prompt for property
- `<leader>ct` - Toggle baseline linter
- `<leader>cu` - Update compatibility data from web.dev API

### Real-time Linting

The plugin automatically lints CSS files (`.css`, `.scss`, `.less`) and shows virtual text indicators for:

- **Supported (✓)**: Properties that are baseline (widely supported)
- **Limited (⚠)**: Properties with limited browser support
- **Experimental (⚠)**: Experimental features with minimal support
- **Unknown (?)**: Properties not in the compatibility database

### Data Management

- **Local JSON Storage**: All fetched features are saved to `features_data.json` for offline use
- **Automatic Loading**: Plugin loads from local JSON on startup, falls back to hardcoded data
- **Dynamic Updates**: `:BaselineUpdate` fetches latest data and updates local storage
- **Feature Categories**: Each property is tagged with its baseline category (widely/newly/limited)

### API Response Mapping

The plugin converts web.dev API responses to internal format:
- `widely_available` → `supported` (baseline)
- `newly_available` → `limited` 
- `limited_availability` → `limited`
- Other statuses → `experimental`

## Configuration

```lua
require('baseline-checker').setup({
  auto_lint = true,           -- Enable real-time linting
  show_virtual_text = true,   -- Show virtual text indicators
  keymaps = {
    check_baseline = '<leader>cb',
    toggle_linter = '<leader>ct',
    update_data = '<leader>cu'
  }
})
```

## Supported Properties

The plugin includes compatibility data for common CSS features so you can add your own locally and can fetch additional data via API:

- `grid` / `grid-template-columns` (Baseline - widely supported)
- `flex` / `flexbox` (Baseline - widely supported)
- `display` (Baseline - universally supported)
- `container-queries` / `container-type` (Limited support)
- `subgrid` (Experimental - limited browser support)
- `aspect-ratio` (Newly baseline)
- `backdrop-filter` (Limited support)

## Example CSS File

```css
.container {
  display: grid;                    /* ✓ Baseline */
  grid-template-columns: 1fr 2fr;   /* ✓ Baseline */
  container-type: inline-size;      /* ⚠ Limited */
}

.experimental {
  subgrid: true;                    /* ⚠ Experimental */
  backdrop-filter: blur(10px);      /* ⚠ Limited */
}
```

## Architecture

The plugin consists of four main modules:

1. **`init.lua`** - Main plugin entry point and user commands
2. **`compat_data.lua`** - Browser compatibility data management with dynamic API updates
3. **`linter.lua`** - Real-time CSS linting with virtual text
4. **`api.lua`** - Web.dev baseline API integration with HTTP requests and caching

## API Details

The API module provides:
- HTTP requests using curl
- JSON response parsing
- Caching with TTL (1 hour default)
- Fallback to local data when API is unavailable
- Automatic data conversion from web.dev format
