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

module.exports = {
  readJSONValue: readJSONValue,
  getSettings: getSettings,
  writeSettings: writeSettings,
};
