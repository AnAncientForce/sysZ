const { app, BrowserWindow, ipcMain, Menu } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const path = require("path");
const os = require("os");

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });
  mainWindow.webContents.openDevTools();
  mainWindow.loadFile("index.html");
  Menu.setApplicationMenu(null);
  mainWindow.setFullScreen(true);
  mainWindow.on("closed", () => {
    mainWindow = null;
  });
}

app.on("ready", createWindow);

ipcMain.on("close-application", () => {
  app.quit();
});

// Listen for the IPC message to execute the shell script with arguments
ipcMain.on("execute-shell-script", (event, { scriptName, args }) => {
  const scriptPath = path.join(__dirname, scriptName);
  const command = `sh ${scriptPath} ${args.join(" ")}`;
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing the shell script: ${error.message}`);
      // Send a response back to the renderer process indicating the error
      event.reply("shell-script-execution-failed", error.message);
      return;
    }

    console.log("Shell script executed successfully.");
    console.log("Output:");
    console.log(stdout);
    // Send a response back to the renderer process indicating success and passing the stdout
    event.reply("shell-script-execution-success", stdout);
  });
});
