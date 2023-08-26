// sysZ
const { ipcRenderer } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const dialog = require("../modules/dialog.js");
const helper = require("../modules/helper.js");
// const jSettings = fs.readFileSync(`${os.homedir()}/.config/sysZ/config.json`);
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

  if (caArgs?.showTitle) {
    div.appendChild(document.createTextNode(text));
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

function hideAllExceptCurrent(caArgs) {
  const sections = document.querySelectorAll("section");

  sections.forEach((section) => {
    if (section.tagName === "SECTION") {
      if (caArgs?.hide_all) {
        section.classList.add("hidden");
      } else {
        // default
        document.getElementById(currentSection).classList.remove("hidden");
        if (section.id === currentSection) {
          section.style.display = "block";
        } else {
          section.style.display = "none";
        }
      }
    }
  });
  caArgs = {};
}

function changeSection(newSection, caArgs) {
  document
    .querySelectorAll(".square-button, #xscale img")
    .forEach((element) => {
      element.remove();
    });
  document.getElementById("checkboxContainer").innerHTML = "";
  currentSection = newSection;
  hideAllExceptCurrent();
  if (!caArgs?.hide_nav) {
    build_nav();
  }
}

function showDialog(options) {
  dialog.showDialog(options);
}

function page_home() {
  changeSection("section-home");
  createAction(
    "Change Log",
    "square-button",
    "section-home-btns",
    function () {
      page_change_log();
    },
    {
      showTitle: true,
      useImg: true,
      imgSrc: "../images/change_log.png",
      imgAlt: "Help",
    }
  );
  createAction(
    "Guides",
    "square-button",
    "section-home-btns",
    function () {
      page_guide();
    },
    {
      showTitle: true,
      useImg: true,
      imgSrc: "../images/guide.png",
      imgAlt: "Help",
    }
  );
  createAction(
    "Control Panel",
    "square-button",
    "section-home-btns",
    function () {
      page_control_panel();
    },
    {
      showTitle: true,
      useImg: true,
      imgSrc: "../images/control.png",
      imgAlt: "Help",
    }
  );
  createAction(
    "Settings",
    "square-button",
    "section-home-btns",
    function () {
      dynamicSettings();
    },
    {
      showTitle: true,
      useImg: true,
      imgSrc: "../images/settings.png",
      imgAlt: "Help",
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
    /*
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --cw`
    );
    */
    changeSection("section-wallpaper");
    setupWallpaperSelection("wallpaper");
  });
  createAction("Change Live Wallpaper", "square-button", parent, function () {
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --lw`
    );
    /*
    changeSection("section-video");
    setupWallpaperSelection("video");
    */
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

  createAction("Autostart", "square-button", parent, function () {
    executeCommand("i3-msg 'exec gedit ~/.config/sysZ/autostart.sh;'");
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
  var folderPath;
  var thumbnailsContainer;
  const images = [];
  const caArgs = {
    hide_nav: true,
  };
  if (type == "wallpaper") {
    if (checkBoolean("wallpapers_setup_1")) {
      return;
    }
    changeSection("section-load", caArgs);
    saveBoolean("wallpapers_setup_1", true);
    folderPath = `${sysZ}/wallpapers`;
    thumbnailsContainer = document.getElementById("thumbnails-wallpaper");
  }
  if (type == "video") {
    if (checkBoolean("wallpapers_setup_2")) {
      return;
    }
    changeSection("section-load", caArgs);
    saveBoolean("wallpapers_setup_2", true);
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
      imgElement.addEventListener("load", () => {
        thumbnailsContainer.appendChild(imgElement);
        images.push(imgElement);
        if (images.length === files.length) {
          changeSection("section-wallpaper");
          console.log("All wallpapers have been loaded");
        }
      });
      imgElement.addEventListener("click", () => {
        const thumbnails = document.querySelectorAll(".thumbnail");
        thumbnails.forEach((thumbnail) => {
          thumbnail.classList.remove("selected");
        });
        imgElement.classList.add("selected");
        if (type == "wallpaper") {
          executeCommand(`feh --bg-fill ${filePath}`);
          executeCommand(`cp -v ${filePath} ${sysZ}/bg`);
        }
        if (type == "video") {
          executeCommand(`cp -v ${filePath} ${sysZ}/vid.mp4`);
        }
      });
    });
  });
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
let intervalId;
let hintIndex = 0;
var hints = [
  "Want to configure some things? Check out {Settings}\nThere are some values you can modify to your liking!",
  "Check out {Guides} to learn how to do some awesome stuff!",
  "New wallpaper? {Control Panel > Change Wallpaper}",
  "Unable to download apps? Check there is a valid internet connection and run {sudo pacman -Sy}",
  "Have a favourite app that you'd like to launch everytime the system starts? Head to {Control Panel > Autostart}",
];

function colorizeHints(arr, color) {
  if (checkBoolean("colorize")) {
    return arr;
  }
  saveBoolean("colorize", true);

  const coloredHints = arr.map((hint) => {
    return hint.replace(
      /\{([^}]+)\}/g,
      `<span style="color: ${color};">$1</span>`
    );
  });

  return coloredHints;
}

function home_hints() {
  const tipsElement = document.getElementById("tips");
  hints = colorizeHints(hints, "green");
  clearInterval(intervalId);
  /*
  if (hintIndex >= hints.length) {
    hintIndex = 0;
    helper.shuffleArray(hints);
  }
  tipsElement.innerHTML = hints[hintIndex];
  hintIndex++;
  */
  const update = () => {
    if (hintIndex >= hints.length) {
      hintIndex = 0;
      helper.shuffleArray(hints);
    }
    tipsElement.innerHTML = hints[hintIndex];
    hintIndex++;
  };

  update();

  intervalId = setInterval(() => {
    update();
  }, 15000);
}

function validateMissingKeys() {
  const keysToValidate = [
    "use_background_blur",
    "ignore_updates",
    "render_lockscreen",
    "show_change_log",
    "live_wallpaper",
    "developer_mode",
    "show_resources_monitor",
  ];
  // "dev_test_key"
  const jsonObject = helper.getSettings();
  console.log("validating json keys");
  keysToValidate.forEach((key) => {
    if (!(key in jsonObject)) {
      jsonObject[key] = false;
      helper.writeSettings(jsonObject);
    }
  });
  console.log("json validation success");
}

document.addEventListener("DOMContentLoaded", () => {
  /*
  var heading = document.getElementById("heading");
  heading.classList.add("scale-down");
  heading.addEventListener("transitionend", function (event) {
    heading.classList.add("resolve");
  });
  */
  /*
  caArgs = {
    hide_nav: true,
  };
  changeSection("section-load", caArgs);
  */
  try {
    validateMissingKeys();
  } catch (error) {
    showDialog({
      title: "Validation has failed!",
      message: `Please check if sysZ's config.json file exists and is not incorrect or corrupted.\n${error.message}`,
      buttons: [
        {
          label: "Terminate",
          action: () => {
            ipcRenderer.send("close-application");
          },
        },
      ],
    });
  }
  page_home();
  if (helper.readJSONValue("show_change_log") || notUsingLinux) {
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
  home_hints();
});
