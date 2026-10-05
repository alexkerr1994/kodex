import { Controller } from "@hotwired/stimulus"

// Submits the form as soon as a control changes (e.g. a select).
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
