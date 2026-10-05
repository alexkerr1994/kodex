import { Controller } from "@hotwired/stimulus"

// Inline note editor: tabbed panes (Edit / Preview / Share) + debounced auto-save.
// The form submits as a Turbo Stream (see notes#update -> save.turbo_stream.erb),
// which refreshes the preview and the "Saved" status without a page reload.
//
// Tabs and panes are paired by a matching data-name attribute; switching tabs
// first flushes any pending edit so the other panes reflect the latest text.
export default class extends Controller {
  static targets = ["form", "input", "status", "pane", "tab", "tagInput"]

  connect() {
    this.timer = null
    this.dirty = false
  }

  // Called on every keystroke in the title/body fields.
  schedule() {
    this.dirty = true
    this.setStatus("Saving…")
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.save(), 800)
  }

  save() {
    clearTimeout(this.timer)
    if (!this.dirty) return
    this.dirty = false
    this.formTarget.requestSubmit()
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  // Toolbar tag button → focus the "Add tag" input.
  focusTags() {
    if (this.hasTagInputTarget) this.tagInputTarget.focus()
  }

  // Insert a Markdown snippet at the cursor. Params: before, after, placeholder, block.
  // Wraps the current selection with before/after (or inserts the placeholder).
  insert(event) {
    const ta = this.inputTarget
    if (!ta) return
    const { before = "", after = "", placeholder = "", block = false } = event.params

    const start = ta.selectionStart
    const end = ta.selectionEnd
    const selected = ta.value.slice(start, end) || placeholder
    let snippet = before + selected + after
    // Block snippets (headings, lists, tables) start on their own line.
    if (block && start > 0 && ta.value[start - 1] !== "\n") snippet = "\n" + snippet

    ta.focus()
    ta.setRangeText(snippet, start, end, "end")
    this.schedule()
  }

  // data-action="editor#show" data-editor-name-param="preview"
  show(event) {
    const name = event.params.name
    this.save() // flush pending edit so preview/share are current
    this.paneTargets.forEach((pane) => { pane.hidden = pane.dataset.name !== name })
    this.tabTargets.forEach((tab) => { tab.classList.toggle("active", tab.dataset.name === name) })
  }
}
