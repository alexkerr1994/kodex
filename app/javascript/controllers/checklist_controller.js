import { Controller } from "@hotwired/stimulus"

// Makes rendered Markdown task-list checkboxes interactive. Ticking a box PATCHes
// notes#toggle_task with the box's document-order index; the server flips the
// matching source line and returns a Turbo Stream that re-renders preview + source.
export default class extends Controller {
  static values = { editable: Boolean, url: String }

  connect() {
    if (!this.editableValue) return

    this.element.querySelectorAll('input[type="checkbox"]').forEach((box, index) => {
      box.disabled = false
      box.dataset.index = index
      box.addEventListener("change", this.toggle)
    })
  }

  toggle = (event) => {
    const box = event.target
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ index: Number(box.dataset.index), checked: box.checked })
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html))
  }
}
