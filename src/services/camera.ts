/**
 * Camera service — handles live preview, frame capture, and image upload to Rust backend.
 * Works on both desktop (getUserMedia) and mobile browsers.
 */

import { invoke } from "@tauri-apps/api/core";

export interface CaptureInfo {
  filename: string;
  extension: string;
  size_bytes: number;
}

// ---------------------------------------------------------------------------
// Tauri IPC commands (defined in src-tauri/src/camera.rs)
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
// Live camera (browser getUserMedia)
// ---------------------------------------------------------------------------

/** Start a live camera stream on the given video element. */
export async function startCamera(
  videoEl: HTMLVideoElement,
  facingMode: "user" | "environment" = "environment",
): Promise<MediaStream> {
  const stream = await navigator.mediaDevices.getUserMedia({
    video: {
      facingMode,
      width: { ideal: 1920 },
      height: { ideal: 1080 },
    },
    audio: false,
  });
  videoEl.srcObject = stream;
  await videoEl.play();
  return stream;
}

/** Stop the active camera stream. */
export function stopCamera(stream: MediaStream): void {
  if (stream) {
    stream.getTracks().forEach((t) => t.stop());
  }
}

// ---------------------------------------------------------------------------
// Frame capture helpers
// ---------------------------------------------------------------------------

/** Capture a single frame from a video element to base64 JPEG string. */
export function captureFrame(
  videoEl: HTMLVideoElement,
  quality = 0.75,
): string {
  const canvas = document.createElement("canvas");
  canvas.width = videoEl.videoWidth;
  canvas.height = videoEl.videoHeight;
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(videoEl, 0, 0);
  return canvas.toDataURL("image/jpeg", quality);
}

/** Capture to a Blob for direct upload without base64 encoding. */
export function captureFrameBlob(
  videoEl: HTMLVideoElement,
  quality = 0.75,
): Promise<Blob> {
  const canvas = document.createElement("canvas");
  canvas.width = videoEl.videoWidth;
  canvas.height = videoEl.videoHeight;
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(videoEl, 0, 0);
  return new Promise((resolve) => {
    canvas.toBlob(
      (blob) => resolve(blob!),
      "image/jpeg",
      quality,
    );
  });
}
