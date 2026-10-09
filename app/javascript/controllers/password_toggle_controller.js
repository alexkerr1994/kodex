import { Controller } from "@hotwired/stimulus"

// Toggles a password field between masked and visible, swapping the eye icon
// and the accessible label.
export default class extends Controller {
  static targets = ["input", "show", "hide", "button"]

  toggle() {
    const reveal = this.inputTarget.type === "password"
    this.inputTarget.type = reveal ? "text" : "password"
    if (this.hasShowTarget) this.showTarget.hidden = reveal
    if (this.hasHideTarget) this.hideTarget.hidden = !reveal
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-label", reveal ? "Hide password" : "Show password")
      this.buttonTarget.setAttribute("aria-pressed", reveal ? "true" : "false")
    }
  }
}
