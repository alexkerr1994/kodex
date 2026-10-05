import { Controller } from "@hotwired/stimulus"

// Month-grid day interactions: a plain click opens "New event" for that day,
// while clicking and dragging across days selects a range and opens the form
// preloaded as an all-day multi-day event. Both load into the #event_detail
// popover frame. Day numbers/empty space pass through to the day cells (the
// content layer is pointer-events:none); event chips keep their own clicks.
export default class extends Controller {
  static targets = ["day"]

  connect() {
    this.anchor = null
    this.current = null
    this.onUp = (e) => this.finish(e)
    document.addEventListener("mouseup", this.onUp)
  }

  disconnect() {
    document.removeEventListener("mouseup", this.onUp)
    this.clear()
  }

  start(event) {
    if (event.button !== 0) return // left click only
    this.anchor = event.currentTarget.dataset.date
    this.current = this.anchor
    event.preventDefault() // suppress text selection while dragging
    this.highlight()
  }

  over(event) {
    if (!this.anchor) return
    this.current = event.currentTarget.dataset.date
    this.highlight()
  }

  finish() {
    if (!this.anchor) return
    const [from, to] = [this.anchor, this.current].sort() // ISO dates sort chronologically
    const anchor = this.anchor
    this.anchor = null
    this.clear()

    const url = from === to
      ? this.dayUrl(anchor)
      : `/events/new?date=${from}&end_date=${to}`
    const frame = document.getElementById("event_detail")
    if (frame) frame.src = url
    else Turbo.visit(url)
  }

  dayUrl(date) {
    const cell = this.dayTargets.find((d) => d.dataset.date === date)
    return cell ? cell.dataset.newUrl : `/events/new?date=${date}`
  }

  highlight() {
    const [from, to] = [this.anchor, this.current].sort()
    this.dayTargets.forEach((d) => {
      const on = d.dataset.date >= from && d.dataset.date <= to
      d.classList.toggle("drag-selecting", on)
    })
  }

  clear() {
    this.dayTargets.forEach((d) => d.classList.remove("drag-selecting"))
  }
}
