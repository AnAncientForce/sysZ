const os = require("os");
const fs = require("fs");
const path = require("path");

var jSettings = null;
try {
  jSettings = `${os.homedir()}/.config/sysZ/config.json`;
} catch (error) {
  console.error("Error reading JSON file:", error.message);
  return null;
}

function isUsingLinux() {
  try {
    if (process.getuid() === 0) {
      return true;
    }
  } catch (error) {
    return false;
  }
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

function getSettings() {
  return JSON.parse(fs.readFileSync(jSettings, "utf8"));
}
function writeSettings(data) {
  fs.writeFileSync(jSettings, JSON.stringify(data));
}

function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

module.exports = {
  readJSONValue: readJSONValue,
  getSettings: getSettings,
  writeSettings: writeSettings,
  isUsingLinux: isUsingLinux,
  shuffleArray: shuffleArray,
};
