// sysZ
const { ipcRenderer } = require("electron");
const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");

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
  createAction("Open Terminal", "square-button", parent, function () {
    //
  });
  createAction("Change Appearance", "square-button", parent, function () {
    executeCommand(
      "i3-msg 'exec qt5ct; exec lxappearance; exec font-manager;'"
    );
  });
  createAction("Change Wallpaper", "square-button", parent, function () {
    //
  });
  createAction("Arch PKG", "square-button", parent, function () {
    //
  });
  createAction("AUR PKG", "square-button", parent, function () {
    //
  });
  createAction("System Update", "square-button", parent, function () {
    //
  });
  createAction("Update [sysZ]", "square-button", parent, function () {
    //
  });
  createAction("Restart [sysZ]", "square-button", parent, function () {
    //
  });
  createAction("Lock", "square-button", parent, function () {
    //
  });
  createAction("Logout", "square-button", parent, function () {
    //
  });
  createAction("Restart", "square-button", parent, function () {
    //
  });
  createAction("Shutdown", "square-button", parent, function () {
    //
  });
}

function loadDoc(doc) {
  const textBox = document.getElementById("text-box");
  const filePath = path.join(__dirname, doc);
  fs.readFile(filePath, "utf8", (error, content) => {
    if (error) {
      console.error("Error reading file:", error);
      return;
    }
    textBox.value = content;
  });
}

function page_guide() {
  changeSection("section-guide");
  const parent = "section-guide-btns";
  createAction("Bluetooth", "square-button", parent, function () {
    loadDoc("./docs/bluetooth.txt");
  });
  createAction("Packages & Updates", "square-button", parent, function () {
    loadDoc("./docs/i3.txt");
  });
  createAction("Printing", "square-button", parent, function () {
    loadDoc("./docs/print.txt");
  });
  createAction("i3-wm Shortcuts", "square-button", parent, function () {
    loadDoc("./docs/tools.txt");
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
  page_home();
});
