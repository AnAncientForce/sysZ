let keydownListenerAdded = false;

function showDialog(options) {
  const dialogOverlay = document.querySelector(".dialog-overlay"); // Use class selector
  const dialogBox = document.querySelector(".dialog-box"); // Use class selector
  const dialogTitle = document.querySelector(".dialog-title"); // Use class selector
  const dialogMessage = document.querySelector(".dialog-message"); // Use class selector
  const dialogButtons = document.querySelector(".dialog-buttons"); // Use class selector

  const closeDialog = () => {
    dialogOverlay.classList.remove("dialog-show");
    setTimeout(() => {
      dialogOverlay.style.display = "none";
      dialogBox.style.display = "none";
    }, 500);
    dialogOverlay.classList.remove("blur-background");
    dialogBox.classList.add("animate-up");
    removeKeydownListener();
  };

  const removeKeydownListener = () => {
    document.removeEventListener("keydown", keydownHandler);
    keydownListenerAdded = false;
  };

  const keydownHandler = (event) => {
    const keyPressed = event.key;
    if (/[1-9]/.test(keyPressed)) {
      const buttonIndex = parseInt(keyPressed) - 1;
      if (options.buttons && options.buttons[buttonIndex]) {
        options.buttons[buttonIndex].action &&
          options.buttons[buttonIndex].action();
        closeDialog();
      }
    }
  };

  dialogOverlay.onclick = () => {
    closeDialog();
  };

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

  if (options.buttons && Array.isArray(options.buttons)) {
    dialogButtons.innerHTML = ""; // Clear existing buttons
    options.buttons.forEach((button) => {
      const buttonElement = document.createElement("button");
      buttonElement.textContent = button.label;
      buttonElement.classList.add("dialog-button"); // Add your button class here
      buttonElement.onclick = () => {
        button.action && button.action();
        closeDialog();
      };
      dialogButtons.appendChild(buttonElement);
    });
    dialogButtons.style.display = "flex"; // Display the button container
  } else {
    dialogButtons.style.display = "none";
  }

  dialogOverlay.style.display = "flex";
  //dialogOverlay.style.pointerEvents = "auto"; // Set pointer-events to auto
  //dialogOverlay.classList.add("blur-background");
  dialogBox.style.display = "block";
  setTimeout(() => {
    dialogOverlay.classList.add("dialog-show");
    // dialogBox.classList.add("animate-down");
    dialogBox.classList.remove("animate-up");
  }, 10); // Triggering the dialog to appear with a slight delay for animation

  if (!keydownListenerAdded) {
    keydownListenerAdded = true;
    document.addEventListener("keydown", keydownHandler);
  }
}

module.exports = {
  showDialog: showDialog,
};
