import { Controller } from "@hotwired/stimulus"

// Generic tab switcher: pairs [data-tabs-target="tab"] buttons with
// [data-tabs-target="pane"] panes by a matching data-name attribute.
// The initially-active tab comes from data-tabs-active-value.
export default class extends Controller {
  static targets = ["tab", "pane"]
  static values = { active: String }

  connect() {
    const start = this.activeValue || this.tabTargets[0]?.dataset.name
    if (start) this.activate(start)
  }

  select(event) {
    this.activate(event.params.name)
  }

  activate(name) {
    this.paneTargets.forEach((pane) => { pane.hidden = pane.dataset.name !== name })
    this.tabTargets.forEach((tab) => { tab.classList.toggle("active", tab.dataset.name === name) })
  }
}
