// sysZ
const { ipcRenderer } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const helper = require("../modules/helper.js");

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
  const icon = document.getElementById("logo");
  const hint_frame = document.getElementById("hint-frame");
  const white_screen = document.getElementById("white-screen");

  hintElement.textContent = hints[randomIndex];
  icon.classList.add("spin");
  hint_frame.classList.add("animate-up");

  exec(`sh ${sysZ}/shell/pull.sh -r`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing script: ${error}`);
      return;
    }

    icon.classList.add("fast");
    white_screen.classList.add("shine");

    white_screen.addEventListener("transitionend", () => {
      if (helper.readJSONValue("show_resources_monitor")) {
        executeCommand("i3-msg 'exec conky -d &;'");
      }
      ipcRenderer.send("close-application");
    });

    console.log(`Script output:\n${stdout}`);
    console.error(`Script errors:\n${stderr}`);
    console.log("Script execution completed.");
  });
});
