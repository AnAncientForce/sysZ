const fs = require("fs");
const path = require("path");
const os = require("os");

var jSettings = null;
try {
  jSettings = fs.readFileSync(`${os.homedir()}/.config/sysZ/config.json`);
} catch (error) {
  console.error("Error reading JSON file:", error.message);
  return null;
}

function readJSONValue(valueKey) {
  try {
    const rawData = fs.readFileSync(jSettings);
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

function getFiles(folderPath, ext) {
  const filesWithExtension = [];

  const scanFolder = (currentPath) => {
    const files = fs.readdirSync(currentPath);

    files.forEach((file) => {
      const filePath = path.join(currentPath, file);
      const stats = fs.statSync(filePath);

      if (stats.isFile() && path.extname(file).toLowerCase() === ext) {
        filesWithExtension.push(filePath);
      } else if (stats.isDirectory()) {
        scanFolder(filePath);
      }
    });
  };

  scanFolder(folderPath);
  return filesWithExtension;
}

function getSubFolders(folderPath) {
  const subFolders = [];

  const files = fs.readdirSync(folderPath);

  files.forEach((file) => {
    const filePath = path.join(folderPath, file);
    const stats = fs.statSync(filePath);

    if (stats.isDirectory()) {
      subFolders.push(filePath);
    }
  });

  return subFolders;
}

function findFile(rootFolderPath, file) {
  const queue = [rootFolderPath];

  while (queue.length > 0) {
    const currentFolderPath = queue.shift();
    const folderContents = fs.readdirSync(currentFolderPath);

    for (const item of folderContents) {
      const itemPath = path.join(currentFolderPath, item);

      if (fs.statSync(itemPath).isDirectory()) {
        queue.push(itemPath);
      } else if (item.toLowerCase() === file.toLowerCase()) {
        return itemPath;
      }
    }
  }

  return null;
}

function slideDiv(elementId, direction) {
  const element = document.getElementById(elementId);
  // element.style.display = "block"; // Ensure the element is visible before animating
  element.style.display = ""; // Ensure the element is visible before animating

  // Reset transform and opacity properties
  element.style.transform = "";
  element.style.opacity = "";

  // Trigger reflow before applying the animation class
  element.offsetWidth;

  if (direction === "in") {
    element.classList.remove("slide-out");
    element.classList.add("slide-in");
  } else if (direction === "out") {
    element.classList.remove("slide-in");
    element.classList.add("slide-out");
  }
}

function filesWith(directory, ext) {
  fs.readdir(directory, (err, files) => {
    if (err) {
      console.error(err);
      return;
    }

    files.forEach((file) => {
      const filePath = path.join(directory, file);

      fs.stat(filePath, (err, stats) => {
        if (err) {
          console.error(err);
          return;
        }

        if (stats.isFile() && path.extname(file) === ext) {
          console.log("AHK file found:", filePath);
        } else if (stats.isDirectory()) {
          searchForAHKFiles(filePath);
        }
      });
    });
  });
}

function getSettings() {
  return JSON.parse(fs.readFileSync(jSettings, "utf8"));
}
function writeSettings(data) {
  fs.writeFileSync(jSettings, JSON.stringify(data));
}

module.exports = {
  readJSONValue: readJSONValue,
  getSubFolders: getSubFolders,
  getFiles: getFiles,
  findFile: findFile,
  getSettings: getSettings,
  writeSettings: writeSettings,
  slideDiv: slideDiv,
  filesWith: filesWith,
};
