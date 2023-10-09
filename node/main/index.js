// sysZ
const { ipcRenderer } = require("electron");
const { exec } = require("child_process");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const dialog = require("../modules/dialog.js");
const helper = require("../modules/helper.js");
const { group } = require("console");
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

function executeCommand(command, callback) {
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      console.error("stderr:", stderr);
      return;
    }
    console.log("Command executed successfully");
    console.log("stdout:", stdout);

    if (typeof callback === "function") {
      callback();
    }
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

  if (caArgs?.group) {
    if (caArgs.group.length > 0) {
      var groupDiv;
      if (document.getElementById(caArgs.group)) {
        // group already exists, add child
        groupDiv = document.getElementById(caArgs.group);
        groupDiv.appendChild(div);
      } else {
        // create group, attach child
        groupDiv = document.createElement("div");
        groupDiv.id = caArgs.group;
        groupDiv.style.borderColor = "red";
        groupDiv.style.border = "2px solid white";
        groupDiv.style.borderRadius = "16px";
        groupDiv.style.fontWeight = "bold";
        groupDiv.style.textAlign = "center";
        groupDiv.appendChild(document.createTextNode(caArgs.group));
        groupDiv.appendChild(div);
        document.getElementById(section).appendChild(groupDiv);
      }
    }
  }

  div.onclick = action;
  if (!caArgs?.group) {
    // not using group, so append default
    document.getElementById(section).appendChild(div);
  }

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
  createAction(
    "Change Appearance",
    "square-button",
    parent,
    function () {
      executeCommand(
        "i3-msg 'exec qt5ct; exec lxappearance; exec font-manager;'"
      );
    },
    {
      showTitle: true,
      group: "Appearance",
      useImg: true,
      imgSrc: "../images/colour.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Change Wallpaper",
    "square-button",
    parent,
    function () {
      /*
    executeCommandAndKeepTerminalOpen(
      `alacritty -e ${sysZ}/shell/pull.sh --cw`
    );
    */
      changeSection("section-wallpaper");
      setupWallpaperSelection("wallpaper");
    },
    {
      showTitle: true,
      group: "Appearance",
      useImg: true,
      imgSrc: "../images/wallpaper.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Change Live Wallpaper",
    "square-button",
    parent,
    function () {
      /*
      executeCommandAndKeepTerminalOpen(
        `alacritty -e ${sysZ}/shell/pull.sh --lw`
      );
      */
      changeSection("section-video");
      setupWallpaperSelection("video");
    },
    {
      showTitle: true,
      group: "Appearance",
      useImg: true,
      imgSrc: "../images/live-wallpaper.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "System Update",
    "square-button",
    parent,
    function () {
      executeCommandAndKeepTerminalOpen("alacritty -e " + "sudo pacman -Syu");
      showDialog({
        title: "Proceed in terminal",
        message: "A terminal window may have opened. Please proceed there.",
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
      showTitle: true,
      group: "System",
      useImg: true,
      imgSrc: "../images/update.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Update [sysZ]",
    "square-button",
    parent,
    function () {
      executeCommandAndKeepTerminalOpen(
        `alacritty -e ${sysZ}/shell/pull.sh -u`
      );
    },
    {
      showTitle: true,
      group: "sysZ",
      useImg: true,
      imgSrc: "../images/update.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Refresh [sysZ]",
    "square-button",
    parent,
    function () {
      executeCommand(`i3-msg 'exec ${sysZ}/shell/pull.sh -r;'`);
    },
    {
      showTitle: true,
      group: "sysZ",
      useImg: true,
      imgSrc: "../images/restart.png",
      imgAlt: "alt",
    }
  );

  // System
  createAction(
    "Lock",
    "square-button",
    parent,
    function () {
      executeCommand("i3-msg 'exec betterlockscreen -l dimblur;'");
    },
    {
      showTitle: true,
      group: "System",
      useImg: true,
      imgSrc: "../images/lock.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Logout",
    "square-button",
    parent,
    function () {
      executeCommand("i3-msg exit");
    },
    {
      showTitle: true,
      group: "System",
      useImg: true,
      imgSrc: "../images/logout.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Restart",
    "square-button",
    parent,
    function () {
      executeCommand("systemctl reboot");
    },
    {
      showTitle: true,
      group: "System",
      useImg: true,
      imgSrc: "../images/restart.png",
      imgAlt: "alt",
    }
  );
  createAction(
    "Shutdown",
    "square-button",
    parent,
    function () {
      executeCommand("systemctl poweroff");
    },
    {
      showTitle: true,
      group: "System",
      useImg: true,
      imgSrc: "../images/shutdown.png",
      imgAlt: "alt",
    }
  );

  createAction(
    "Open Terminal",
    "square-button",
    parent,
    function () {
      executeCommand("i3-msg 'exec alacritty;'");
    },
    {
      showTitle: true,
      group: "Other",
      useImg: true,
      imgSrc: "../images/terminal.png",
      imgAlt: "Help",
    }
  );

  createAction(
    "Autostart",
    "square-button",
    parent,
    function () {
      executeCommand("i3-msg 'exec gedit ~/.config/sysZ/autostart.sh;'");
    },
    {
      showTitle: true,
      group: "Other",
      useImg: true,
      imgSrc: "../images/autostart.png",
      imgAlt: "Help",
    }
  );
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

  if (document.getElementById("Appearance")) {
    document
      .getElementById("Appearance")
      .appendChild(document.getElementById("xscale"));
  }
  /*
  document
    .getElementById("section-control-panel-btns")
    .appendChild(document.getElementById("xscale"));
    */
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

  fs.readdir(path.join(__dirname, "../../docs/"), (err, files) => {
    if (err) {
      console.error(`Error reading folder: ${err}`);
      return;
    }
    files.forEach((file) => {
      const filePath = path.join(folderPath, file);
      console.log(filePath);
      createAction(file, "square-button", parent, function () {
        loadDoc(file);
      });
    });
  });
  /*
  createAction("Recommended Apps", "square-button", parent, function () {
    loadDoc("apps");
  });
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
  */
}

function page_change_log() {
  changeSection("section-change-log");
  fs.readFile(
    path.join(__dirname, "../change_log_history.txt"),
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
  const videos = [];
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
    // ==========| IMAGES |========== //
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
          const jsonObject = helper.getSettings();
          jsonObject["live_wallpaper"] = false;
          helper.writeSettings(jsonObject);
          executeCommand(`killall -9 mpv`);
          executeCommand(`feh --bg-fill ${filePath}`);
          executeCommand(`cp -v ${filePath} ${sysZ}/bg`);
        }
      });
    });
    // ==========| VIDEOS |========== //
    files.forEach((file) => {
      const filePath = path.join(folderPath, file);
      console.log(filePath);
      if (type == "video") {
        const videoElement = document.createElement("video");
        videoElement.id = filePath;
        videoElement.src = filePath;
        videoElement.muted = true;
        videoElement.controls = false;
        videoElement.classList.add("thumbnail");
        thumbnailsContainer.appendChild(videoElement);

        videoElement.addEventListener("loadeddata", () => {
          thumbnailsContainer.appendChild(videoElement);
          videos.push(videoElement);
          if (videos.length === files.length) {
            changeSection("section-video");
            console.log("All videos have been loaded");
          }
        });

        videoElement.addEventListener("click", () => {
          const jsonObject = helper.getSettings();
          jsonObject["live_wallpaper"] = true;
          helper.writeSettings(jsonObject);
          changeSection("section-load", caArgs);
          executeCommand(`cp -v "${filePath}" ${sysZ}/vid.mp4`, () => {
            console.log("copy successful");
            executeCommand(`killall -9 mpv`);
            executeCommand(`i3-msg 'exec ${sysZ}/shell/pull.sh --apply-live;'`);
            changeSection("section-video");
          });
          /*
          showDialog({
            title: "Success",
            message:
              "The live wallpaper has been changed \n Please refresh the wm to see the new live wallpaper",
            buttons: [
              {
                label: "Continue",
                action: () => {
                  //
                },
              },
            ],
          });
        */
        });
        videoElement.addEventListener("mouseenter", () => {
          if (videoElement.paused) {
            videoElement.play();
          }
        });

        videoElement.addEventListener("mouseleave", () => {
          if (!videoElement.paused) {
            videoElement.pause();
          }
        });
      }
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

  const update = () => {
    if (hintIndex >= hints.length) {
      hintIndex = 0;
      helper.shuffleArray(hints);
    }
    tipsElement.innerHTML = hints[hintIndex];
  };

  const restartInterval = () => {
    clearInterval(intervalId);
    intervalId = setInterval(() => {
      hintIndex++;
      update();
      if (hintIndex >= hints.length) {
        hintIndex = 0;
        helper.shuffleArray(hints);
      }
    }, 15 * 1000);
  };

  createAction("<", "mini-btn", "tips-nav", function () {
    hintIndex--;
    if (hintIndex < 0) {
      hintIndex = hints.length - 1;
    }
    update();
    restartInterval();
  });

  createAction(">", "mini-btn", "tips-nav", function () {
    hintIndex++;
    if (hintIndex >= hints.length) {
      hintIndex = 0;
    }
    update();
    restartInterval();
  });

  update();
  restartInterval();
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
    "use_autotiling",
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
    fs.readFile("./change_log_history.txt", "utf8", (err, data) => {
      if (err) {
        console.error("Error reading file:", err);
        return;
      }
      const firstLine = data.split("\n")[0];
      showDialog({
        title: "Change Log",
        message: firstLine,
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
