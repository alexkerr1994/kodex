import { Controller } from "@hotwired/stimulus"

// Collapses the left sidebar to an icon-only rail. State is remembered in
// localStorage and re-applied on connect (survives Turbo navigations).
// Placed on the .app-shell element so the class can drive the grid columns.
export default class extends Controller {
  static values = { defaultCollapsed: Boolean }

  connect() {
    const stored = localStorage.getItem("sidebarCollapsed")
    // Respect the user's saved toggle; fall back to their profile default.
    const collapsed = stored === null ? this.defaultCollapsedValue : stored === "1"
    this.element.classList.toggle("sidebar-collapsed", collapsed)
  }

  toggle() {
    const collapsed = this.element.classList.toggle("sidebar-collapsed")
    localStorage.setItem("sidebarCollapsed", collapsed ? "1" : "0")
  }
}
