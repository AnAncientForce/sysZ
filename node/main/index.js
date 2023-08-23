// sysZ
const { ipcRenderer } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const dialog = require("../modules/dialog.js");
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

function createAction(text, optionalClass, section, action, caArgs) {
  actionIndexer++;
  const div = document.createElement("div");
  div.id = `action${actionIndexer}`;
  // div.classList.add("toggleable", "singleaction");
  if (optionalClass.length > 0) {
    div.classList.add(optionalClass);
  }
  // "animated-background"

  if (!caArgs?.useImg) {
    div.textContent = text;
  } else {
    const img = document.createElement("img");
    img.src = caArgs.imgSrc;
    img.alt = caArgs.imgAlt || "";
    img.classList.add("nav-img");
    div.appendChild(img);
  }
  div.onclick = action;
  document.getElementById(section).appendChild(div);
  // console.log("Appended", `action${actionIndexer}`, text);
  caArgs = {};
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
  document
    .querySelectorAll(".square-button, #xscale img")
    .forEach((element) => {
      element.remove();
    });
  document.getElementById("checkboxContainer").innerHTML = "";
  currentSection = newSection;
  hideAllExceptCurrent();
  build_nav();
}

function showDialog(options) {
  dialog.showDialog(options);
}

function page_home() {
  changeSection("section-home");
  createAction("Change Log", "square-button", "section-home-btns", function () {
    page_change_log();
  });
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
  createAction("Settings", "square-button", "section-home-btns", function () {
    dynamicSettings();
  });
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
    /*
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --cw`
    );
    */
    changeSection("section-wallpaper");
    setupWallpaperSelection();
  });
  createAction("Change Live Wallpaper", "square-button", parent, function () {
    /*
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --lw`
    );
    */
    changeSection("section-video");
    setupVideoSelection();
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

  createAction(
    "xscale",
    "",
    "xscale",
    function () {
      showDialog({
        title: "Xresources",
        message: "The scaling size for the applications",
        buttons: [
          {
            label: "Continue",
            action: () => {
              //
            },
          },
        ],
      });
    },
    {
      useImg: true,
      imgSrc: "../images/help.png",
      imgAlt: "Help",
    }
  );
}

function loadDoc(doc) {
  fs.readFile(
    path.join(__dirname, "../../docs/" + doc + ".txt"),
    "utf8",
    (error, content) => {
      if (error) {
        console.error("Error reading file:", error);
        return;
      }
      document.getElementById("text-box").value = content;
    }
  );
}

function page_guide() {
  changeSection("section-guide");
  const parent = "section-guide-btns";
  createAction("Bluetooth", "square-button", parent, function () {
    loadDoc("bluetooth");
  });
  createAction("Packages & Updates", "square-button", parent, function () {
    loadDoc("pkgs");
  });
  createAction("Printing", "square-button", parent, function () {
    loadDoc("print");
  });
  createAction("i3-wm Shortcuts", "square-button", parent, function () {
    loadDoc("i3");
  });
  createAction("Tools", "square-button", parent, function () {
    loadDoc("tools");
  });
}

function page_change_log() {
  changeSection("section-change-log");
  fs.readFile(
    path.join(__dirname, "../../change_log_history.txt"),
    "utf8",
    (error, content) => {
      if (error) {
        console.error("Error reading file:", error);
        return;
      }
      document.getElementById("section-change-log-text-box").textContent =
        content;
    }
  );
}

function build_nav() {
  createAction(
    "Home",
    "square-button",
    "nav",
    function () {
      page_home();
    },
    {
      useImg: true,
      imgSrc: "../images/house.png",
      imgAlt: "Home",
    }
  );
  createAction(
    "Exit",
    "square-button",
    "nav",
    function () {
      ipcRenderer.send("close-application");
    },
    {
      useImg: true,
      imgSrc: "../images/exit.png",
      imgAlt: "Exit",
    }
  );
}

function setupWallpaperSelection(type) {
  if (checkBoolean("wallpapers_setup")) {
    return;
  }
  var folderPath = `${sysZ}/wallpapers`;
  var thumbnailsContainer = null;
  if (type == "wallpaper") {
    folderPath = `${sysZ}/wallpapers`;
    thumbnailsContainer = document.getElementById("thumbnails-wallpaper");
  }
  if (type == "video") {
    folderPath = `${sysZ}/videos`;
    thumbnailsContainer = document.getElementById("thumbnails-video");
  }
  fs.readdir(folderPath, (err, files) => {
    if (err) {
      console.error(`Error reading folder: ${err}`);
      return;
    }
    files.forEach((file) => {
      const filePath = path.join(folderPath, file);
      console.log(filePath);

      const imgElement = document.createElement("img");
      imgElement.src = filePath;
      imgElement.alt = filePath;
      imgElement.classList.add("thumbnail");
      imgElement.addEventListener("click", () => {
        const thumbnails = document.querySelectorAll(".thumbnail");
        thumbnails.forEach((thumbnail) => {
          thumbnail.classList.remove("selected");
        });
        imgElement.classList.add("selected");

        const existingSettings = helper.getSettings();
        existingSettings.live_wallpaper_id = videoFile;
        fs.writeFileSync(jSettings, JSON.stringify(existingSettings));

        if (type == "wallpaper") {
          executeCommand(`cp ${filePath} ${sysZ}/bg`);
        }
        if (type == "video") {
          executeCommand(`cp ${filePath} ${sysZ}/vid.mp4`);
        }
      });
      thumbnailsContainer.appendChild(imgElement);
    });
  });
  saveBoolean("wallpapers_setup", true);
}

function dynamicSettings() {
  changeSection("section-settings");
  const jsonData = require(`${os.homedir()}/.config/sysZ/config.json`);
  const checkboxContainer = document.getElementById("checkboxContainer");

  for (const key in jsonData) {
    if (jsonData.hasOwnProperty(key)) {
      const checkboxLabel = document.createElement("label");
      checkboxLabel.classList.add("checkbox-label");

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.id = key;
      checkbox.checked = jsonData[key];

      const label = document.createTextNode(key);

      checkboxLabel.appendChild(checkbox);
      checkboxLabel.appendChild(label);

      checkboxContainer.appendChild(checkboxLabel);

      checkbox.addEventListener("change", function () {
        jsonData[key] = this.checked;
        fs.writeFileSync(
          `${os.homedir()}/.config/sysZ/config.json`,
          JSON.stringify(jsonData, null, 2)
        );
      });
    }
  }
}

/*
function showDialog(options) {
  const dialogOverlay = document.getElementById("dialog-overlay");
  const dialogBox = document.getElementById("dialog-box");
  const dialogTitle = document.getElementById("dialog-title");
  const dialogMessage = document.getElementById("dialog-message");
  const cancelButton = document.getElementById("cancel-button");
  const proceedButton = document.getElementById("proceed-button");

  if (options.title) {
    dialogTitle.textContent = options.title;
    dialogTitle.style.display = "block";
  } else {
    dialogTitle.style.display = "none";
  }

  if (options.message) {
    dialogMessage.innerHTML = options.message.replace(/\n/g, "<br>");
    dialogMessage.style.display = "block";
  } else {
    dialogMessage.style.display = "none";
  }

  if (options.btn0) {
    cancelButton.style.display = "block";
    cancelButton.textContent = options.btn0;
    cancelButton.onclick = () => {
      dialogOverlay.classList.remove("dialog-show"); // Remove the dialog-show class
      setTimeout(() => {
        dialogOverlay.style.display = "none";
        dialogBox.style.display = "none";
      }, 500);
      dialogOverlay.classList.remove("blur-background");
      dialogBox.classList.add("animate-up");
      options.onCancel && options.onCancel();
    };
  } else {
    cancelButton.style.display = "none";
  }

  if (options.btn1) {
    proceedButton.style.display = "block";
    proceedButton.textContent = options.btn1;
    proceedButton.onclick = () => {
      dialogOverlay.classList.remove("dialog-show"); // Remove the dialog-show class
      setTimeout(() => {
        dialogOverlay.style.display = "none";
        dialogBox.style.display = "none";
      }, 500);
      dialogOverlay.classList.remove("blur-background");
      dialogBox.classList.add("animate-up");
      options.onProceed && options.onProceed();
    };
  } else {
    proceedButton.style.display = "none";
  }

  dialogOverlay.style.display = "flex";
  dialogOverlay.classList.add("blur-background");
  dialogBox.style.display = "block";
}
*/

function readJSONValue(valueKey) {
  try {
    const rawData = fs.readFileSync(`${os.homedir()}/.config/sysZ/config.json`);
    const jsonData = JSON.parse(rawData);

    if (jsonData && jsonData.hasOwnProperty(valueKey)) {
      return jsonData[valueKey] === true;
    } else {
      console.log(`Value "${valueKey}" not found in JSON file.`);
      return null;
    }
  } catch (error) {
    console.error("Error reading JSON file:", error.message);
    return null;
  }
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
  if (readJSONValue("show_change_log") || notUsingLinux) {
    fs.readFile("../change_log.txt", "utf8", (err, data) => {
      if (err) {
        console.error("Error reading file:", err);
        return;
      }
      showDialog({
        title: "Change Log",
        message: data,
        buttons: [
          {
            label: "Dismiss",
            action: () => {
              //
            },
          },
          {
            label: "Shortcut",
            action: () => {
              page_change_log();
            },
          },
        ],
      });
    });
  }
  const xscale = document.getElementById("xresourcesScale");
  fs.readFile(`${os.homedir()}/.Xresources`, "utf8", (err, data) => {
    if (err) {
      console.error(`Error reading .Xresources file: ${err.message}`);
      return;
    }
    const xftDpiMatch = data.match(/\b\d+\b/);
    if (xftDpiMatch) {
      const xftDpiValue = parseInt(xftDpiMatch[0]);
      xscale.value = xftDpiValue;
    }
  });
  xscale.addEventListener("input", function () {
    const enteredValue = parseInt(xscale.value);
    if (!isNaN(enteredValue)) {
      if (enteredValue >= 96 && enteredValue <= 296) {
        executeCommand(
          `echo 'Xft.dpi: ${enteredValue}' > ${os.homedir()}/.Xresources`
        );
      } else {
        showDialog({
          title: "Warning",
          message: "The number must be > 56 or < 300",
          buttons: [
            {
              label: "Continue",
              action: () => {
                //
              },
            },
          ],
        });
      }
    }
  });
});
