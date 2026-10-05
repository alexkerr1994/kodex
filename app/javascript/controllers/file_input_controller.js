import { Controller } from "@hotwired/stimulus"

// Backs a custom "Choose photo" button: shows the selected filename.
export default class extends Controller {
  static targets = ["name"]

  update(event) {
    const file = event.target.files[0]
    if (this.hasNameTarget) this.nameTarget.textContent = file ? file.name : "No file chosen"
  }
}
