import { Controller } from "@hotwired/stimulus"

// Debounced live search: submits the form a short moment after typing stops.
// The form targets the #notes_list Turbo Frame, so only the list refreshes and
// the input keeps focus.
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  submit() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
