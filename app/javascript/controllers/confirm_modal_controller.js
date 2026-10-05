import { Controller } from "@hotwired/stimulus"

// A custom confirmation modal that replaces the browser's window.confirm for all
// Turbo `data-turbo-confirm` actions (note/tag/account deletes, etc.).
export default class extends Controller {
  static targets = ["message"]

  connect() {
    if (window.Turbo) {
      window.Turbo.setConfirmMethod((message) => this.ask(message))
    }
    this.onKeydown = (e) => { if (e.key === "Escape") this.cancel() }
  }

  ask(message) {
    this.messageTarget.textContent = message
    this.element.hidden = false
    document.addEventListener("keydown", this.onKeydown)
    return new Promise((resolve) => { this.resolve = resolve })
  }

  confirm() { this.close(true) }
  cancel() { this.close(false) }

  close(result) {
    this.element.hidden = true
    document.removeEventListener("keydown", this.onKeydown)
    if (this.resolve) {
      this.resolve(result)
      this.resolve = null
    }
  }
}
