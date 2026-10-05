import { Controller } from "@hotwired/stimulus"

// Drag a note card between tag columns to re-tag it. On drop, PATCHes
// notes#move_tag (from-tag -> to-tag) and re-renders the board from the server.
export default class extends Controller {
  start(event) {
    this.card = event.target.closest(".board-card")
    this.fromTag = this.card.closest(".board-col").dataset.tagId || ""
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.card.dataset.noteId) // Firefox needs data set
    requestAnimationFrame(() => this.card.classList.add("dragging"))
  }

  end() {
    this.card?.classList.remove("dragging")
  }

  over(event) {
    event.preventDefault() // allow drop
    event.currentTarget.closest(".board-col").classList.add("drop-target")
  }

  leave(event) {
    event.currentTarget.closest(".board-col").classList.remove("drop-target")
  }

  drop(event) {
    event.preventDefault()
    const column = event.currentTarget.closest(".board-col")
    column.classList.remove("drop-target")
    if (!this.card) return

    const toTag = column.dataset.tagId || ""
    if (toTag === this.fromTag) return

    // Optimistic move for immediate feedback; the server re-render reconciles.
    const body = column.querySelector(".board-col-body")
    body.appendChild(this.card)

    const noteId = this.card.dataset.noteId
    this.card = null

    fetch(`/notes/${noteId}/move_tag`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ from: this.fromTag, to: toTag })
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html))
  }
}
