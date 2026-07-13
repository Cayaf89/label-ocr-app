use tauri::{AppHandle, Manager};

/// Base64 standard engine for decoding image data.
const BASE64: base64::engine::general_purpose::GeneralPurpose =
    base64::engine::general_purpose::STANDARD;

/// Save a base64-encoded image to disk and return the file path.
#[tauri::command]
pub fn save_image(base64_data: &str, app: AppHandle) -> Result<String, String> {
    // Strip "data:image/xxx;base64," prefix if present.
    let data = if let Some(comma_idx) = base64_data.find(',') {
        base64_data[comma_idx + 1..].to_string()
    } else {
        base64_data.to_string()
    };

    let bytes = base64::Engine::decode(&BASE64, &data).map_err(|e| format!("Invalid base64: {}", e))?;

    // Determine file extension from mime prefix.
    let ext = if base64_data.starts_with("image/png") { "png" } else { "jpg" };
    let filename = format!("capture_{}.{}", timestamp(), ext);

    // Save into $AppData/captures/.
    let save_dir = resolve_captures_dir(&app)?;
    std::fs::write(save_dir.join(&filename), &bytes)
        .map_err(|e| format!("Failed to write image: {}", e))?;

    println!("Image saved: {} ({} bytes)", save_dir.display(), bytes.len());
    Ok(save_dir.join(&filename).to_string_lossy().to_string())
}

/// List all captured images from the captures directory.
#[tauri::command]
pub fn list_captures(app: AppHandle) -> Result<Vec<CaptureInfo>, String> {
    let save_dir = resolve_captures_dir(&app)?;
    if !save_dir.exists() {
        return Ok(Vec::new());
    }

    let mut captures = Vec::new();
    for entry in std::fs::read_dir(&save_dir).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let path = entry.path();
        if let Some(ext) = path.extension().and_then(|s| s.to_str()) {
            if matches!(ext, "jpg" | "jpeg" | "png") {
                captures.push(CaptureInfo {
                    filename: path.file_name()
                        .unwrap_or_default()
                        .to_string_lossy()
                        .to_string(),
                    extension: ext.to_string(),
                    size_bytes: entry.metadata().map(|m| m.len()).unwrap_or(0),
                });
            }
        }
    }

    captures.sort_by(|a, b| b.filename.cmp(&a.filename)); // newest first.
    Ok(captures)
}

/// Delete a captured image file.
#[tauri::command]
pub fn delete_capture(filename: &str, app: AppHandle) -> Result<bool, String> {
    let save_dir = resolve_captures_dir(&app)?;
    let file_path = save_dir.join(filename);
    if !file_path.exists() {
        return Err(format!("Capture not found: {}", filename));
    }
    std::fs::remove_file(&file_path).map_err(|e| format!("Failed to delete capture: {}", e))?;
    println!("Deleted capture: {}", file_path.display());
    Ok(true)
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#[derive(serde::Serialize)]
pub struct CaptureInfo {
    pub filename: String,
    pub extension: String,
    pub size_bytes: u64,
}

fn resolve_captures_dir(app: &AppHandle) -> Result<std::path::PathBuf, String> {
    let base = app
        .path()
        .resolve("", tauri::path::BaseDirectory::AppData)
        .map_err(|e| format!("Failed to resolve AppData dir: {}", e))?;
    let save_dir = base.join("captures");
    std::fs::create_dir_all(&save_dir).map_err(|e| {
        format!(
            "Failed to create captures directory at {}: {}",
            save_dir.display(),
            e
        )
    })?;
    Ok(save_dir)
}

/// Timestamp string like `20260713_145234567`.
fn timestamp() -> String {
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default();

    let secs = now.as_secs();
    let millis = now.subsec_millis();
    let days = secs / 86400;
    let tod = secs % 86400;

    let h = tod / 3600;
    let m = (tod % 3600) / 60;
    let s = tod % 60;

    // Compute year/month/day from days-since-epoch.
    let mut y: i32 = 1970;
    let mut remaining = days as i32;
    loop {
        let diy = if is_leap(y) { 366 } else { 365 };
        if remaining < diy { break; }
        remaining -= diy;
        y += 1;
    }

    let md: [u8; 12] = if is_leap(y) {
        [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    } else {
        [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    };

    let mut mo = 1u8;
    for &d in md.iter() {
        if remaining < d as i32 { break; }
        remaining -= d as i32;
        mo += 1;
    }
    let day = (remaining + 1) as u8;

    format!(
        "{}{:02}{:02}_{:02}{:02}{:02}{:03}",
        y, mo, day, h, m, s, millis
    )
}

fn is_leap(year: i32) -> bool {
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}
