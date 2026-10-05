import { Controller } from "@hotwired/stimulus"

// A small popup menu (e.g. the user-chip account dropdown): toggles its menu
// target, and closes on outside click or Escape.
export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.onDoc = (e) => { if (!this.element.contains(e.target)) this.close() }
    this.onKey = (e) => { if (e.key === "Escape") this.close() }
  }

  toggle() {
    this.menuTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.menuTarget.hidden = false
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.onDoc)
    document.addEventListener("keydown", this.onKey)
  }

  close() {
    this.menuTarget.hidden = true
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.onDoc)
    document.removeEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("click", this.onDoc)
    document.removeEventListener("keydown", this.onKey)
  }
}
