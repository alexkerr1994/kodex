import { Controller } from "@hotwired/stimulus"

// A tag picker: focus/type to see existing tags (colored pills), click one to
// assign it, or create a new one — optionally choosing a colour. Submits to the
// tag create endpoint by name (+ optional color).
export default class extends Controller {
  static targets = ["form", "name", "color", "input", "menu", "create", "createLabel"]

  open() {
    clearTimeout(this.timer)
    this.menuTarget.hidden = false
    this.filter()
  }

  closeSoon() {
    this.timer = setTimeout(() => (this.menuTarget.hidden = true), 150)
  }

  filter() {
    const q = this.inputTarget.value.trim().toLowerCase()
    let exact = false
    this.options.forEach((opt) => {
      const name = opt.dataset.name.toLowerCase()
      opt.hidden = !name.includes(q)
      if (name === q) exact = true
    })
    const showCreate = q !== "" && !exact
    this.createTarget.hidden = !showCreate
    if (showCreate) this.createLabelTarget.textContent = this.inputTarget.value.trim()
  }

  keydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.commit(this.inputTarget.value.trim())
    } else if (event.key === "Escape") {
      this.menuTarget.hidden = true
    }
  }

  // mousedown (not click) so it fires before the input's blur closes the menu.
  pick(event) {
    event.preventDefault()
    this.commit(event.currentTarget.dataset.name)
  }

  createTyped(event) {
    event.preventDefault()
    this.commit(this.inputTarget.value.trim())
  }

  createWithColor(event) {
    event.preventDefault()
    this.commit(this.inputTarget.value.trim(), event.currentTarget.dataset.color)
  }

  commit(name, color = "") {
    if (!name) return
    this.nameTarget.value = name
    if (this.hasColorTarget) this.colorTarget.value = color
    this.formTarget.requestSubmit()
  }

  get options() {
    return Array.from(this.element.querySelectorAll(".tag-combo-option"))
  }
}
