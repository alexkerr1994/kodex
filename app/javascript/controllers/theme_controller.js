import { Controller } from "@hotwired/stimulus"

// Swaps the `data-theme` attribute on <html> and remembers the choice.
// The initial theme is applied by an inline script in the layout <head>
// (before first paint); this controller just keeps the <select> in sync
// and handles changes.
export default class extends Controller {
  static targets = ["select"]

  connect() {
    const current = document.documentElement.getAttribute("data-theme") || "clean"
    if (this.hasSelectTarget) this.selectTarget.value = current
  }

  change() {
    const theme = this.selectTarget.value
    document.documentElement.setAttribute("data-theme", theme)
    localStorage.setItem("theme", theme)
  }
}
