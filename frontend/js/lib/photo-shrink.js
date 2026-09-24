// photo-shrink — a phone photo (3–8 MB) down to a JPEG data: URL the
// backend will happily store (≈200–400 KB at 1600 px).  Used by #security
// (screens/security.js) and the public upload page LockupController
// serves at /api/security/tap.  Honours EXIF orientation where the
// browser can (createImageBitmap with imageOrientation), so a portrait
// shot of the gate stays upright.
window.shrinkPhoto = async function shrinkPhoto(file, maxPx = 1600, quality = 0.82) {
  let bitmap = null;
  try {
    bitmap = await createImageBitmap(file, { imageOrientation: 'from-image' });
  } catch (_) {
    bitmap = await new Promise((resolve, reject) => {
      const url = URL.createObjectURL(file);
      const img = new Image();
      img.onload = () => { URL.revokeObjectURL(url); resolve(img); };
      img.onerror = () => { URL.revokeObjectURL(url); reject(new Error('Could not read the photo')); };
      img.src = url;
    });
  }
  const w = bitmap.width, h = bitmap.height;
  const scale = Math.min(1, maxPx / Math.max(w, h));
  const canvas = document.createElement('canvas');
  canvas.width = Math.round(w * scale);
  canvas.height = Math.round(h * scale);
  canvas.getContext('2d').drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  if (bitmap.close) bitmap.close();
  return canvas.toDataURL('image/jpeg', quality);
};
