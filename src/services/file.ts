/**
 * Convert a single File (e.g. from `event.target.files[0]`) to a base64 data URL.
 */
export function fileToDataUrl(file: File | Blob): Promise<string> {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => {
            if (typeof reader.result === "string") {
                resolve(reader.result);
            } else {
                reject(new Error("FileReader did not produce a string result."));
            }
        };
        reader.onerror = () => {
            reject(reader.error ?? new Error("Failed to read file."));
        };
        reader.readAsDataURL(file);
    });
}

/**
 * Convert multiple Files to data URLs.
 */
export async function filesToDataUrls(files: FileList | Iterable<File | Blob>): Promise<string[]> {
    const entries = Array.from(files);
    return Promise.all(entries.map((f) => fileToDataUrl(f)));
}
