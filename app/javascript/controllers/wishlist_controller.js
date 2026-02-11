import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]
  static classes = ["active"] // Decouples CSS from JS
  static values = { active: Boolean }

  // Logic: Automatically triggered by Stimulus on change
  activeValueChanged(isActive) {
    this.element.setAttribute("aria-pressed", isActive)

    const icon = this.hasIconTarget ? this.iconTarget : this.element
    icon.classList.toggle(this.activeClass, isActive)
    icon.classList.toggle("fill-none", !isActive)
  }

  // Action: Clean naming convention
  toggle(event) {
    event.preventDefault()
    event.stopPropagation() // Vital for property cards that are links
    this.activeValue = !this.activeValue
  }
}
