import { Controller } from "@hotwired/stimulus"

// Makes a native <details> behave like a menu: closes on outside click or Esc.
export default class extends Controller {
  connect() {
    this.onDoc = (e) => { if (!this.element.contains(e.target)) this.element.removeAttribute("open") }
    this.onKey = (e) => { if (e.key === "Escape") this.element.removeAttribute("open") }
    document.addEventListener("click", this.onDoc)
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("click", this.onDoc)
    document.removeEventListener("keydown", this.onKey)
  }
}
