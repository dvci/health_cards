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

const current = window.location.href;
const url = current.includes('health_card') ? `${current}/chunks.json` : `${current}/health_card/chunks.json`;

fetch(url)
  .then(res => res.json())
  .then(chunks => {
    const qrCodes = addPrefixToQrCodes(chunks);
    const container = document.getElementById('qr-code');

    // Remove all children of qr-code container
    while (container.firstChild && !container.firstChild.remove());

    // Add each QR code to the qr-code container
    qrCodes.forEach(qrCode => {
      const canvas = document.createElement('canvas');
      options = {
        version: 22,
        errorCorrectionLevel: 'L'
      };
      QRCode.toDataURL(qrCode, options, function (err, url) {
        if (err) throw err
        var field = document.getElementById('qr-code-field')
        field.value = url
      })
      QRCode.toCanvas(canvas, qrCode, options);
      container.appendChild(canvas);
    });
  });
