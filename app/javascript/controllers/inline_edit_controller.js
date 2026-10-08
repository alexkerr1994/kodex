import { Controller } from "@hotwired/stimulus"

// Toggles a display element (e.g. a heading + edit button) into an inline edit
// form. The form submits normally; Escape or the cancel button reverts.
export default class extends Controller {
  static targets = ["display", "form", "input"]

  edit() {
    this.displayTarget.hidden = true
    this.formTarget.hidden = false
    if (this.hasInputTarget) {
      this.inputTarget.focus()
      this.inputTarget.select()
    }
  }

  cancel() {
    this.formTarget.hidden = true
    this.displayTarget.hidden = false
  }
}
