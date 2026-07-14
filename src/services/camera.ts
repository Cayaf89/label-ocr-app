/**
 * Camera service — uses native mobile camera via HTML5 <input type="file" capture>.
 * Works on all platforms (mobile + desktop) without any Rust plugin.
 */

import { invoke } from "@tauri-apps/api/core";

export interface CaptureInfo {
  filename: string;
  extension: string;
  size_bytes: number;
}

// ---------------------------------------------------------------------------
// Tauri IPC commands — defined in src-tauri/src/camera.rs
// ---------------------------------------------------------------------------

/** Save base64 image data to disk via Rust backend. */
export async function saveImage(base64Data: string): Promise<string> {
  return await invoke("save_image", { base64Data });
}

/** List all captured images from the Rust backend. */
export async function listCaptures(): Promise<CaptureInfo[]> {
  return await invoke("list_captures");
}

/** Delete a captured image from disk. */
export async function deleteCapture(filename: string): Promise<boolean> {
  return await invoke("delete_capture", { filename });
}

// ---------------------------------------------------------------------------
// Native mobile camera capture via HTML5 file input with `capture` attribute.
// On Android, this opens the device's native camera app. On desktop, it opens a file picker.
// ---------------------------------------------------------------------------

/**
 * Open a hidden <input type="file" accept="image/*" capture="environment">
 * to trigger the native mobile camera on Android devices.
 * Returns a Blob of the captured image, or null if cancelled.
 */
export function takeNativePhoto(): Promise<Blob | null> {
  return new Promise((resolve) => {
    const input = document.createElement("input");
    input.type = "file";
    // `capture="environment"` tells Android to open the rear camera directly.
    input.capture = "environment";
    input.accept = "image/*";
    input.style.display = "none";
    document.body.appendChild(input);

    input.addEventListener("change", () => {
      const file = input.files?.[0] ?? null;
      resolve(file || null);
      if (document.body.contains(input)) {
        document.body.removeChild(input);
      }
    });

    // Fallback timeout — if user doesn't pick within 60s.
    setTimeout(() => {
      if (document.body.contains(input)) {
        input.value = "";
        document.body.removeChild(input);
      }
      resolve(null);
    }, 60_000);

    input.click();
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Convert a base64 string (with or without data URL prefix) to Uint8Array. */
export function base64ToArrayBuffer(base64: string): Uint8Array {
  const cleaned = base64.replace(/^data:image\/\w+;base64,/, "");
  const byteString = atob(cleaned);
  const bytes = new Uint8Array(byteString.length);
  for (let i = 0; i < byteString.length; i++) {
    bytes[i] = byteString.charCodeAt(i);
  }
  return bytes;
}

/** Convert a Blob to base64 data URL string. */
export function blobToBase64(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}
