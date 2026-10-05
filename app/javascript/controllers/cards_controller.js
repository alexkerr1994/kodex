import { Controller } from "@hotwired/stimulus"

// Moves the "active" highlight to the clicked note card. The detail pane swaps
// via Turbo Frame without reloading this list, so we update the selection here.
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.select)
  }

  disconnect() {
    this.element.removeEventListener("click", this.select)
  }

  select = (event) => {
    const card = event.target.closest(".n-card")
    if (!card || !this.element.contains(card)) return
    this.element.querySelectorAll(".n-card.active").forEach((c) => c.classList.remove("active"))
    card.classList.add("active")
  }
}
