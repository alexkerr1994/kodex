import { Controller } from "@hotwired/stimulus"

// Shows the event-details popover once its Turbo Frame has rendered content.
export default class extends Controller {
  static targets = ["backdrop", "frame"]

  connect() {
    this.onKey = (e) => { if (e.key === "Escape") this.close() }
  }

  open() {
    this.backdropTarget.hidden = false
    this.frameTarget.classList.add("is-open")
    document.addEventListener("keydown", this.onKey)
  }

  close() {
    this.backdropTarget.hidden = true
    this.frameTarget.classList.remove("is-open")
    // Reset so clicking the same event again reloads the frame.
    this.frameTarget.removeAttribute("src")
    this.frameTarget.removeAttribute("complete")
    this.frameTarget.innerHTML = ""
    document.removeEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey)
  }
}
