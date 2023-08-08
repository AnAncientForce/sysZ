// sysZ
const { ipcRenderer } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

var notUsingLinux = false;
let sysZ;
try {
  if (process.getuid() === 0) {
    sysZ = path.join("/home", process.env.SUDO_USER, "sysZ");
  } else {
    sysZ = path.join("/home", os.userInfo().username, "sysZ");
  }
} catch (error) {
  console.error("Not on Linux");
  notUsingLinux = true;
}

function executeCommand(command) {
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      return;
    }
    console.log("Command executed successfully");
    console.log("stdout:", stdout);
    console.log("stderr:", stderr);
  });
}

function executeCommandAndKeepTerminalOpen(command) {
  const [program, ...args] = command.split(" "); // Split the command into program and arguments
  const childProcess = spawn(program, args, {
    stdio: "inherit", // Inherit stdio streams to keep terminal open
    shell: true, // Use shell for executing the command
  });

  childProcess.on("error", (error) => {
    console.error(`Error executing command: ${error.message}`);
  });

  childProcess.on("exit", (code, signal) => {
    console.log(`Command exited with code ${code} and signal ${signal}`);
  });
}

function requestShellScriptExecution(scriptName, args) {
  ipcRenderer.send("execute-shell-script", { scriptName, args });
}

var actionIndexer = 0;
var booleanStorage = {};

function saveBoolean(key, value) {
  booleanStorage[key] = value;
}
function checkBoolean(key) {
  return booleanStorage[key];
}

document.addEventListener("DOMContentLoaded", () => {
  const hints = [
    "We're loading!",
    "Nearly there!",
    "Hold on tight!",
    "Prepare for launch!",
  ];
  const hintElement = document.getElementById("hint");
  const randomIndex = Math.floor(Math.random() * hints.length);
  hintElement.textContent = hints[randomIndex];

  const icon = document.getElementById("logo");
  const hint_frame = document.getElementById("hint-frame");
  const white_screen = document.getElementById("white-screen");

  icon.classList.add("spin");
  hint_frame.classList.add("animate-up");

  exec(`sh ${sysZ}/shell/pull.sh -r`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing script: ${error}`);
      return;
    }

    icon.classList.add("fast");
    white_screen.classList.add("shine");

    console.log(`Script output:\n${stdout}`);
    console.error(`Script errors:\n${stderr}`);
    console.log("Script execution completed.");
  });
});
