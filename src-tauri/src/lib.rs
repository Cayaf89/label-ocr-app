// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
use rusqlite::Connection;
use std::sync::Mutex;

mod camera;
mod db;

/// Application state — holds the database connection behind a Mutex.
struct AppState {
    conn: Mutex<Connection>,
}

// ---------------------------------------------------------------------------
// Tauri commands
// ---------------------------------------------------------------------------

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

// Example command that demonstrates how to access the DB connection.
// Uncomment and adapt for your actual Tauri commands.
/*
#[tauri::command]
fn list_templates_cmd(app: tauri::AppHandle) -> Result<serde_json::Value, String> {
    let state = app.state::<AppState>();
    let conn = state.conn.lock().map_err(|e| format!("DB lock poisoned: {}", e))?;

    // Use the helper from db module:
    let templates = db::list_templates(&conn).map_err(|e| e.to_string())?;
    Ok(serde_json::to_value(templates).unwrap_or_default())
}
*/

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        // Resolve the app data directory and initialise the SQLite database.
        .setup(|app| {
            use tauri::Manager;
            let app_data_dir = app
                .path()
                .resolve("", tauri::path::BaseDirectory::AppData)
                .map_err(|e| format!("Failed to resolve AppData dir: {}", e))?;

            std::fs::create_dir_all(&app_data_dir).map_err(|e| {
                format!(
                    "Failed to create data directory at {}: {}",
                    app_data_dir.display(),
                    e
                )
            })?;

            let db_path = app_data_dir.join("label_ocr.db");
            println!("SQLite DB path: {}", db_path.display());

            let conn = Connection::open(&db_path)
                .map_err(|e| format!("Failed to open SQLite database: {}", e))?;

            // WAL mode + foreign keys.
            conn.execute_batch("PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;")
                .map_err(|e| format!("Failed to set pragmas: {}", e))?;

            // Create tables if they don't exist.
            conn.execute_batch(
                "CREATE TABLE IF NOT EXISTS templates (
                    id          INTEGER PRIMARY KEY AUTOINCREMENT,
                    name        TEXT    NOT NULL UNIQUE,
                    description TEXT,
                    icon        TEXT,
                    fieldsCount INTEGER,
                    image_path  TEXT,
                    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS scanned_texts (
                    id              INTEGER PRIMARY KEY AUTOINCREMENT,
                    template_id     INTEGER,
                    ocr_text        TEXT,
                    confidence      REAL,
                    metadata_json   TEXT,
                    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),

                    FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE SET NULL
                );

                CREATE TABLE IF NOT EXISTS template_fields (
                    id              INTEGER PRIMARY KEY AUTOINCREMENT,
                    template_id     INTEGER,
                    api_field       TEXT,
                    x               INTEGER,
                    y               INTEGER,
                    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),

                    FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE SET NULL
                );",
            )
            .map_err(|e| format!("Failed to create tables: {}", e))?;

            println!(
                "Database initialized at {} with tables: templates, scans.",
                db_path.display()
            );

            // Wrap in Mutex and store as app state.
            app.manage(AppState {
                conn: Mutex::new(conn),
            });

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            camera::save_image,
            camera::list_captures,
            camera::delete_capture
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
