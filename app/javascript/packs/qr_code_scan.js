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

document.addEventListener('DOMContentLoaded', () => {
  const videoElement = document.getElementById('preview');

  qrScanner = new QrScanner(videoElement, handleScan);

  startButton = document.getElementById('start');
  stopButton = document.getElementById('stop');
  successNotification = document.getElementById('success-notification');
  errorNotification = document.getElementById('error-notification');
  inputField = document.getElementById('qr-contents');

  startButton.addEventListener('click', startScanning);
  stopButton.addEventListener('click', stopScanning);
});

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
  stopScanning();

  if(healthCardPattern.test(result)) {
    inputField.value = JSON.stringify([result]);
    showSuccessNotification();
  } else {
    showErrorNotification();
  }
};
