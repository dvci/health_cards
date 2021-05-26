const QRCode = require('qrcode');

// Adds prefix and breaks QR code up into byte and numeric segments
function addPrefixToQrCodes(chunks) {
  const chunksLength = chunks.length;

  if (chunksLength === 1) {
    return [
      [
        { data: 'shc:/', mode: 'byte' },
        { data: chunks[0], mode: 'numeric' }
      ]
    ];
  }

  // Number the chunks so that it can be reconstructed if the codes are scanned out of order
  return chunks.map((chunk, index) => {
    const prefix = `shc:/${index + 1}/${chunksLength}/`;
    return [
      { data: prefix, mode: 'byte' },
      { data: chunk, mode: 'numeric' }
    ];
  });
}

fetch(`${window.location.href}/health_card/chunks.json`)
  .then(res => res.json())
  .then(chunks => {
    const qrCodes = addPrefixToQrCodes(chunks);
    const container = document.getElementById('qr-code');

    // Remove all children of qr-code container
    while (container.firstChild && !container.firstChild.remove());

    // Add each QR code to the qr-code container
    qrCodes.forEach(qrCode => {
      const canvas = document.createElement('canvas');
      QRCode.toCanvas(canvas, qrCode, {
        version: 22,
        errorCorrectionLevel: 'L'
      });
      container.appendChild(canvas);
    });
  });
