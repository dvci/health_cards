const QRCode = require('qrcode');

function generateQrCodes(chunks) {
  const chunksLength = chunks.length;

  if (chunksLength === 1) {
    const segs = [
      { data: 'shc:/', mode: 'byte' },
      { data: chunks[0], mode: 'numeric' }
    ];

    return [QRCode.create(segs, { version: 22 })];
  }

  return chunks.map((chunk, index) => {
    const prefix = `shc:/${index + 1}/${chunksLength}/`;
    const segs = [
      { data: prefix, mode: 'byte' },
      { data: chunk, mode: 'numeric' }
    ]

    return QRCode.create(segs, { version: 22 });
  });
}
