import { Controller } from "@hotwired/stimulus"

// Show/hide a calendar's events in the grid via the sidebar checkboxes.
// Hidden calendar ids persist in localStorage.
export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.hidden = new Set(JSON.parse(localStorage.getItem("calHidden") || "[]"))
    this.apply()
  }

  toggle(event) {
    const id = event.target.value
    event.target.checked ? this.hidden.delete(id) : this.hidden.add(id)
    localStorage.setItem("calHidden", JSON.stringify([...this.hidden]))
    this.apply()
  }

  apply() {
    this.checkboxTargets.forEach((cb) => { cb.checked = !this.hidden.has(cb.value) })
    this.element.querySelectorAll("[data-calendar-id]").forEach((el) => {
      el.style.display = this.hidden.has(el.dataset.calendarId) ? "none" : ""
    })
  }
}
