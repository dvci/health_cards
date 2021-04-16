import QrScanner from 'qr-scanner';
import QrScannerWorkerPath from '!!file-loader!../../..//node_modules/qr-scanner/qr-scanner-worker.min.js';
QrScanner.WORKER_PATH = QrScannerWorkerPath;

const healthCardPattern = /^shc:\/(?<multipleChunks>(?<chunkIndex>[0-9]+)\/(?<chunkCount>[0-9]+)\/)?[0-9]+$/;

let qrScanner;
let startButton;
let stopButton;
let successNotification;
let errorNotification;
let inputField;
let multiStatusContainer;

let scannedCodes = [];

const onLoad = () => {
  const videoElement = document.getElementById('preview');

  qrScanner = new QrScanner(videoElement, handleScan);

  startButton = document.getElementById('start');
  stopButton = document.getElementById('stop');
  successNotification = document.getElementById('success-notification');
  errorNotification = document.getElementById('error-notification');
  inputField = document.getElementById('qr-contents');
  multiStatusContainer = document.getElementById('multi-status-container');

  startButton.addEventListener('click', startScanning);
  stopButton.addEventListener('click', stopScanning);
};

document.addEventListener('DOMContentLoaded', onLoad);

const startScanning = () => {
  disableStartButton();
  hideSuccessNotification();
  hideErrorNotification();
  qrScanner.start();
};

const stopScanning = () => {
  enableStartButton();
  qrScanner.stop();
};

const disableStartButton = () => {
  startButton.setAttribute('disabled', true);
  stopButton.removeAttribute('disabled');
};

const enableStartButton = () => {
  stopButton.setAttribute('disabled', true);
  startButton.removeAttribute('disabled');
};

const hideSuccessNotification = () => {
  successNotification.setAttribute('hidden', true);
};

const showSuccessNotification = () => {
  hideErrorNotification();
  successNotification.removeAttribute('hidden');
};

const hideErrorNotification = () => {
  errorNotification.setAttribute('hidden', true);
};

const showErrorNotification = () => {
  hideSuccessNotification();
  errorNotification.removeAttribute('hidden');
};

const handleScan = result => {
  console.log(result);

  if (healthCardPattern.test(result)) {
    const match = result.match(healthCardPattern);
    if (match.groups.multipleChunks) {
      hideErrorNotification();
      const chunkCount = +match.groups.chunkCount;
      const currentChunkIndex = +match.groups.chunkIndex;
      if (scannedCodes.length !== chunkCount) {
        scannedCodes = new Array(chunkCount);
        scannedCodes.fill(null, 0, chunkCount);
      }
      scannedCodes[currentChunkIndex - 1] = result;
      multiStatusContainer.innerHTML = scannedCodes
        .map((code, index) => {
          return code
            ? multiPresentElement(index + 1, chunkCount)
            : multiMissingElement(index + 1, chunkCount);
        })
        .join('\n');

      if (scannedCodes.every(code => code)) {
        stopScanning();

        inputField.value = JSON.stringify(scannedCodes);
        showSuccessNotification();
      }
    } else {
      stopScanning();

      multiStatusContainer.innerHTML = '';
      inputField.value = JSON.stringify([result]);
      showSuccessNotification();
    }
  } else {
    stopScanning();

    showErrorNotification();
  }
};

const multiPresentElement = (current, max) => `
  <div class="level-item tag is-large is-success">
    <span class="icon">
      <i class="fa fa-check-circle"></i>
    </span>
    <span>${current}/${max}</span>
  </div>
`;

const multiMissingElement = (current, max) => `
  <div class="level-item tag is-large is-danger">
    <span class="icon">
      <i class="fa fa-times-circle"></i>
    </span>
    <span>${current}/${max}</span>
  </div>
`;
