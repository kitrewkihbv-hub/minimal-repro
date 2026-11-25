const { app, BrowserWindow, Tray, Menu, ipcMain, globalShortcut } = require('electron');
const path = require('path');
const fs = require('fs');
const os = require('os');
const { exec } = require('child_process');

let tray = null;
let controllerWindow = null;
let widgetSlots = {}; // slotId -> { window, config }
let nextSlotId = 1;

// Ensure Apple Silicon compatibility
app.commandLine.appendSwitch('disable-gpu-vsync');
app.disableHardwareAcceleration();

function createWindow() {
  // Menu Bar / Tray Controller
  controllerWindow = new BrowserWindow({
    width: 300,
    height: 400,
    frame: false,
    transparent: true,
    show: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  controllerWindow.loadFile('controller.html');

  // Tray icon
  const iconPath = path.join(__dirname, 'assets', 'tray.png');
  tray = new Tray(iconPath || path.join(__dirname, 'main.png'));
  const contextMenu = Menu.buildFromTemplate([
    { label: 'NeoWidget Controller', click: () => controllerWindow.show() },
    { label: 'Add Empty Widget Slot', click: addWidgetSlot },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() }
  ]);
  tray.setToolTip('NeoWidget Editor');
  tray.setContextMenu(contextMenu);

  ipcMain.on('add-slot', addWidgetSlot);
  ipcMain.on('update-slot', (event, { slotId, config }) => {
    if (widgetSlots[slotId]) {
      widgetSlots[slotId].config = config;
      widgetSlots[slotId].window.webContents.send('config-updated', config);
    }
  });
  ipcMain.on('export-neowidget', (event, { slotId, filePath }) => {
    if (widgetSlots[slotId]) {
      const data = JSON.stringify(widgetSlots[slotId].config, null, 2);
      fs.writeFileSync(filePath, data);
      event.reply('export-success', { slotId, filePath });
    }
  });
  ipcMain.on('import-neowidget', (event, { slotId, filePath }) => {
    if (fs.existsSync(filePath)) {
      const data = fs.readFileSync(filePath, 'utf8');
      const config = JSON.parse(data);
      if (widgetSlots[slotId]) {
        widgetSlots[slotId].config = config;
        widgetSlots[slotId].window.webContents.send('config-updated', config);
        event.reply('import-success', { slotId, config });
      }
    }
  });
}

function addWidgetSlot() {
  const slotId = `slot-${nextSlotId++}`;
  const win = new BrowserWindow({
    width: 400,
    height: 600,
    type: 'desktop',
    transparent: true,
    frame: false,
    hasShadow: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    resizable: true,
    movable: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  // macOS specific: setVisibleOnAllWorkspaces
  if (win.setVisibleOnAllWorkspaces) {
    win.setVisibleOnAllWorkspaces(true);
  }

  win.loadFile('widget.html');
  win.webContents.once('did-finish-load', () => {
    win.webContents.send('slot-initialized', { slotId });
  });

  // Click to edit flow
  win.webContents.on('dom-ready', () => {
    win.webContents.executeJavaScript(`
      document.body.addEventListener('click', () => {
        require('electron').ipcRenderer.send('slot-clicked', '${slotId}');
      });
    `);
  });

  widgetSlots[slotId] = { window: win, config: null };

  ipcMain.once(`slot-clicked-${slotId}`, () => {
    openStudioEditor(slotId);
  });

  ipcMain.on(`slot-clicked-${slotId}`, () => {
    openStudioEditor(slotId);
  });

  return slotId;
}

function openStudioEditor(slotId) {
  const editorWin = new BrowserWindow({
    width: 1000,
    height: 800,
    title: `NeoWidget Studio - Slot ${slotId}`,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  editorWin.loadFile('editor.html');
  editorWin.webContents.once('did-finish-load', () => {
    editorWin.webContents.send('editor-ready', { slotId, config: widgetSlots[slotId]?.config });
  });
}

app.whenReady().then(() => {
  createWindow();
  // Auto-start controller
  controllerWindow.show();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
