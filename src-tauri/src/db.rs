use rusqlite::{params, Connection, Result};

// ---------------------------------------------------------------------------
// Template helpers — each takes a `&Connection` (provided by app state).
// ---------------------------------------------------------------------------

/// Insert a new template and return its row id.
pub fn create_template(conn: &Connection, name: &str, image_path: Option<&str>) -> Result<i64> {
    conn.execute(
        "INSERT INTO templates (name, image_path) VALUES (?1, ?2)",
        params![name, image_path],
    )?;
    Ok(conn.last_insert_rowid())
}

/// List all templates ordered by newest first.
pub fn list_templates(conn: &Connection) -> Result<Vec<(i64, String, Option<String>, String)>> {
    let mut stmt = conn.prepare(
        "SELECT id, name, image_path, created_at FROM templates ORDER BY created_at DESC",
    )?;

    let rows = stmt.query_map([], |row| {
        Ok((
            row.get::<_, i64>(0)?,
            row.get::<_, String>(1)?,
            row.get::<_, Option<String>>(2)?,
            row.get::<_, String>(3)?,
        ))
    })?;

    let mut results = Vec::new();
    for row in rows {
        results.push(row?);
    }
    Ok(results)
}

// ---------------------------------------------------------------------------
// Scan helpers
// ---------------------------------------------------------------------------

/// Insert a new scan and return its row id.
pub fn create_scan(
    conn: &Connection,
    template_id: Option<i64>,
    ocr_text: &str,
    confidence: f64,
    image_path: Option<&str>,
) -> Result<i64> {
    conn.execute(
        "INSERT INTO scans (template_id, ocr_text, confidence, image_path) VALUES (?1, ?2, ?3, ?4)",
        params![template_id, ocr_text, confidence, image_path],
    )?;
    Ok(conn.last_insert_rowid())
}

/// List scans, optionally filtered by template id.
pub fn list_scans(
    conn: &Connection,
    template_id: Option<i64>,
) -> Result<Vec<(i64, Option<i64>, String, f64, Option<String>, Option<String>, String)>> {
    let mut results = Vec::new();

    match template_id {
        Some(tid) => {
            let mut stmt = conn.prepare(
                "SELECT id, template_id, ocr_text, confidence, image_path, metadata_json, created_at \
                 FROM scans WHERE template_id = ?1 ORDER BY created_at DESC",
            )?;
            let rows = stmt.query_map(params![tid], |row| {
                Ok((
                    row.get::<_, i64>(0)?,
                    row.get::<_, Option<i64>>(1)?,
                    row.get::<_, String>(2)?,
                    row.get::<_, f64>(3)?,
                    row.get::<_, Option<String>>(4)?,
                    row.get::<_, Option<String>>(5)?,
                    row.get::<_, String>(6)?,
                ))
            })?;

            for r in rows {
                results.push(r?);
            }
        }
        None => {
            let mut stmt = conn.prepare(
                "SELECT id, template_id, ocr_text, confidence, image_path, metadata_json, created_at \
                 FROM scans ORDER BY created_at DESC",
            )?;
            let rows = stmt.query_map([], |row| {
                Ok((
                    row.get::<_, i64>(0)?,
                    row.get::<_, Option<i64>>(1)?,
                    row.get::<_, String>(2)?,
                    row.get::<_, f64>(3)?,
                    row.get::<_, Option<String>>(4)?,
                    row.get::<_, Option<String>>(5)?,
                    row.get::<_, String>(6)?,
                ))
            })?;

            for r in rows {
                results.push(r?);
            }
        }
    }

    Ok(results)
}
