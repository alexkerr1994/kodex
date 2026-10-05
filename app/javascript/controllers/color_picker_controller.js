import { Controller } from "@hotwired/stimulus"

// Custom swatch color picker with a "custom" option (native picker + HEX input).
// Writes the chosen colour to a hidden field and updates the trigger button.
export default class extends Controller {
  static targets = ["input", "button", "popover", "hex", "native"]

  connect() {
    this.onDocClick = (e) => { if (!this.element.contains(e.target)) this.close() }
    document.addEventListener("click", this.onDocClick)
    const current = this.inputTarget.value
    if (this.hasHexTarget) this.hexTarget.value = current
    if (this.hasNativeTarget) this.nativeTarget.value = current
  }

  disconnect() {
    document.removeEventListener("click", this.onDocClick)
  }

  toggle(event) {
    event.preventDefault()
    this.popoverTarget.hidden = !this.popoverTarget.hidden
  }

  pick(event) {
    this.setColor(event.currentTarget.dataset.color)
    this.close()
  }

  useNative(event) { this.setColor(event.target.value) }

  useHex(event) {
    const value = event.target.value.trim()
    if (/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(value)) this.setColor(value)
  }

  setColor(color) {
    if (!color) return
    this.inputTarget.value = color
    this.buttonTarget.style.background = color
    if (this.hasHexTarget) this.hexTarget.value = color
    if (this.hasNativeTarget) this.nativeTarget.value = color
  }

  close() {
    this.popoverTarget.hidden = true
  }
}
