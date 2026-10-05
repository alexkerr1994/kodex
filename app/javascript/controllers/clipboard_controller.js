import { Controller } from "@hotwired/stimulus"

// Copies a value to the clipboard and briefly confirms on the button.
export default class extends Controller {
  static values = { text: String }
  static targets = ["button", "source"]

  copy() {
    const text = this.textValue || this.sourceTarget?.value
    navigator.clipboard.writeText(text).then(() => this.confirm())
  }

  confirm() {
    if (!this.hasButtonTarget) return
    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Copied!"
    setTimeout(() => { this.buttonTarget.textContent = original }, 1500)
  }
}
