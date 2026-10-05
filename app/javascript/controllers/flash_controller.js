import { Controller } from "@hotwired/stimulus"

// Auto-dismisses a flash message after a delay; also dismissable by click.
export default class extends Controller {
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    clearTimeout(this.timeout)
    this.element.classList.add("flash-hide")
    setTimeout(() => this.element.remove(), 350)
  }
}
