import { Controller } from "@hotwired/stimulus"

// Clicking empty day/column space opens "New event" in the in-window popover
// (the #event_detail frame). Clicking an existing event is left to its own link.
// In week view, the clicked hour is derived from the vertical offset and passed
// along so the form preloads that time slot.
const WEEK_HOUR_PX = 44 // keep in sync with ApplicationHelper::WEEK_HOUR_PX

export default class extends Controller {
  open(event) {
    if (event.target.closest(".cal-event, .cal-wevent")) return
    const cell = event.target.closest("[data-new-url]")
    if (!cell) return

    let url = cell.dataset.newUrl
    if (cell.classList.contains("cal-week-col")) {
      const y = event.clientY - cell.getBoundingClientRect().top
      const hour = Math.min(23, Math.max(0, Math.floor(y / WEEK_HOUR_PX)))
      url += (url.includes("?") ? "&" : "?") + "hour=" + hour
    }

    const frame = document.getElementById("event_detail")
    if (frame) frame.src = url
    else Turbo.visit(url)
  }
}
