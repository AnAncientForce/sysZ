// sysZ
const { ipcRenderer } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

let sysZ;
if (process.getuid() === 0) {
  sysZ = path.join("/home", process.env.SUDO_USER, "sysZ");
} else {
  sysZ = path.join("/home", os.userInfo().username, "sysZ");
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

function createAction(text, optionalClass, section, action) {
  actionIndexer++;
  const div = document.createElement("div");
  div.id = `action${actionIndexer}`;
  // div.classList.add("toggleable", "singleaction");
  if (optionalClass.length > 0) {
    div.classList.add(optionalClass);
  }
  // "animated-background"
  div.textContent = text;
  div.onclick = action;
  document.getElementById(section).appendChild(div);
  // console.log("Appended", `action${actionIndexer}`, text);
  return div;
}

function handleKeydown(event) {
  switch (event.key) {
    case "r":
      window.location.reload();
      window.scrollToDefault();
      break;
  }
}

function collapseLogic(x) {
  if (checkBoolean(x) == false) {
    saveBoolean(x, true);
    toggleDiv(x, true);
  } else if (checkBoolean(x) == true) {
    saveBoolean(x, false);
    toggleDiv(x, false);
  }
}

var currentSection = "";

function hideAllExceptCurrent() {
  const sections = document.querySelectorAll("section");

  sections.forEach((section) => {
    if (section.tagName === "SECTION") {
      if (section.id === currentSection) {
        section.style.display = "block";
      } else {
        section.style.display = "none";
      }
    }
  });
}

function changeSection(newSection) {
  const elementsToDelete = document.getElementsByClassName("square-button");
  const elementsArray = Array.from(elementsToDelete);
  elementsArray.forEach((element) => {
    element.remove();
  });
  currentSection = newSection;
  hideAllExceptCurrent();
  build_nav();
}

function page_home() {
  changeSection("section-home");
  createAction("Guides", "square-button", "section-home-btns", function () {
    page_guide();
  });
  createAction(
    "Control Panel",
    "square-button",
    "section-home-btns",
    function () {
      page_control_panel();
    }
  );
  // for (let i = 0; i < 16; i++) {}
  // requestShellScriptExecution("~/sysZ/shell/pull.sh -u");
}

function page_control_panel() {
  changeSection("section-control-panel");
  const parent = "section-control-panel-btns";

  // Actions
  createAction("Change Appearance", "square-button", parent, function () {
    executeCommand(
      "i3-msg 'exec qt5ct; exec lxappearance; exec font-manager;'"
    );
  });
  createAction("Change Wallpaper", "square-button", parent, function () {
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --cw`
    );
  });
  createAction("Change Live Wallpaper", "square-button", parent, function () {
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --lw`
    );
  });
  createAction("System Update", "square-button", parent, function () {
    executeCommandAndKeepTerminalOpen("alacritty -e " + "sudo pacman -Syu");
  });
  createAction("Update [sysZ]", "square-button", parent, function () {
    executeCommandAndKeepTerminalOpen(`alacritty -e ${sysZ}/shell/pull.sh -u`);
  });
  createAction("Restart [sysZ]", "square-button", parent, function () {
    executeCommand(`i3-msg 'exec ${sysZ}/shell/pull.sh -r;'`);
  });

  // System
  createAction("Open Terminal", "square-button", parent, function () {
    executeCommand("i3-msg 'exec alacritty;'");
  });
  createAction("Lock", "square-button", parent, function () {
    executeCommand("i3-msg 'exec betterlockscreen -l dimblur;'");
  });
  createAction("Logout", "square-button", parent, function () {
    executeCommand("i3-msg exit");
  });
  createAction("Restart", "square-button", parent, function () {
    executeCommand("systemctl reboot");
  });
  createAction("Shutdown", "square-button", parent, function () {
    executeCommand("systemctl poweroff");
  });
}

function loadDoc(doc) {
  fs.readFile(path.join(__dirname, doc), "utf8", (error, content) => {
    if (error) {
      console.error("Error reading file:", error);
      return;
    }
    document.getElementById("text-box").value = content;
  });
}

function page_guide() {
  changeSection("section-guide");
  const parent = "section-guide-btns";
  createAction("Bluetooth", "square-button", parent, function () {
    loadDoc("../docs/bluetooth.txt");
  });
  createAction("Packages & Updates", "square-button", parent, function () {
    loadDoc("../docs/i3.txt");
  });
  createAction("Printing", "square-button", parent, function () {
    loadDoc("../docs/print.txt");
  });
  createAction("i3-wm Shortcuts", "square-button", parent, function () {
    loadDoc("../docs/tools.txt");
  });
}

function build_nav() {
  createAction("Home", "square-button", "nav", function () {
    page_home();
  });
  createAction("Exit", "square-button", "nav", function () {
    ipcRenderer.send("close-application");
  });
}

document.addEventListener("DOMContentLoaded", () => {
  /*
  var heading = document.getElementById("heading");
  heading.classList.add("scale-down");
  heading.addEventListener("transitionend", function (event) {
    heading.classList.add("resolve");
  });
  */
  page_home();
});
