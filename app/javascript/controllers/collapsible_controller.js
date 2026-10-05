import { Controller } from "@hotwired/stimulus"

// Toggles a section open/closed and remembers it in localStorage.
// Put data-controller="collapsible" data-collapsible-key-value="..." on a wrapper,
// mark the body with data-collapsible-target="body", and a header with
// data-action="collapsible#toggle".
export default class extends Controller {
  static values = { key: String, open: { type: Boolean, default: true } }
  static targets = ["body"]

  connect() {
    const stored = this.keyValue ? localStorage.getItem(this.keyValue) : null
    this.apply(stored === null ? this.openValue : stored === "1")
  }

  toggle() {
    this.apply(!this.open)
  }

  apply(open) {
    this.open = open
    if (this.hasBodyTarget) this.bodyTarget.hidden = !open
    this.element.classList.toggle("collapsed", !open)
    if (this.keyValue) localStorage.setItem(this.keyValue, open ? "1" : "0")
  }
}
