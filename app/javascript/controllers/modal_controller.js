import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this._boundHandleKeydown = this._handleKeydown.bind(this)
  }

  disconnect() {
    this._restoreBody()
    document.removeEventListener("keydown", this._boundHandleKeydown)
  }

  open() {
    this._triggerElement = document.activeElement
    this.panelTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    document.addEventListener("keydown", this._boundHandleKeydown)
    this._focusFirstElement()
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this._restoreBody()
    document.removeEventListener("keydown", this._boundHandleKeydown)
    this._triggerElement?.focus()
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  dragStart(event) {
    this._dragStartY    = event.touches[0].clientY
    this._dragCurrentY  = 0
    this._isDragging    = true
    this._dragStartTime = Date.now()
    this.panelTarget.style.transition = "none"
  }

  drag(event) {
    if (!this._isDragging) return

    const delta = event.touches[0].clientY - this._dragStartY
    if (delta < 0) return

    this._dragCurrentY = delta
    this.panelTarget.style.transform = `translateY(${delta}px)`
  }

  dragEnd() {
    if (!this._isDragging) return
    this._isDragging = false

    const dragDistance = this._dragCurrentY
    const dragDuration = Date.now() - this._dragStartTime
    const velocity     = dragDistance / dragDuration

    const swipedFarEnough = dragDistance > 80
    const swipedFastEnough = velocity > 0.4

    this.panelTarget.style.transition = ""

    if (swipedFarEnough || swipedFastEnough) {
      this.close()
    } else {
      this.panelTarget.style.transform = ""
    }
  }

  _handleKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }

    if (event.key === "Tab") {
      this._trapFocus(event)
    }
  }

  _focusFirstElement() {
    const focusable = this._focusableElements()
    if (focusable.length > 0) focusable[0].focus()
  }

  _trapFocus(event) {
    const focusable = this._focusableElements()
    if (focusable.length === 0) return

    const first = focusable[0]
    const last  = focusable[focusable.length - 1]

    if (event.shiftKey) {
      if (document.activeElement === first) {
        event.preventDefault()
        last.focus()
      }
    } else {
      if (document.activeElement === last) {
        event.preventDefault()
        first.focus()
      }
    }
  }

  _focusableElements() {
    return Array.from(
      this.panelTarget.querySelectorAll(
        'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'
      )
    )
  }

  _restoreBody() {
    document.body.classList.remove("overflow-hidden")
    this.panelTarget.style.transform = ""
    this.panelTarget.style.transition = ""
  }
}