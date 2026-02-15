import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]
  static classes = ["active"]
  static values = {
    active: Boolean,
    url: String
  }

  activeValueChanged(isActive) {
    this.element.setAttribute("aria-pressed", isActive)

    const icon = this.hasIconTarget ? this.iconTarget : this.element
    icon.classList.toggle(this.activeClass, isActive)
    icon.classList.toggle("fill-none", !isActive)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const previousValue = this.activeValue
    const willActivate = !previousValue
    const method = willActivate ? "POST" : "DELETE"

    // Optimistic UI: update immediately for snappy UX
    this.activeValue = willActivate

    fetch(this.urlValue, {
      method: method,
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      credentials: "same-origin"
    })
      .then(async (response) => {
        if (response.status === 401) {
          const data = await response.json().catch(() => ({}))
          if (data.redirect_url) {
            window.location = data.redirect_url
          }
          return null
        }

        if (!response.ok) {
          throw new Error(`Wishlist request failed with status ${response.status}`)
        }

        return response.json()
      })
      .then((data) => {
        if (!data) return
        // Server is source of truth; correct UI if needed
        this.activeValue = !!data.active
      })
      .catch((error) => {
        console.error("Wishlist toggle failed", error)
        // Revert optimistic change on hard failure
        this.activeValue = previousValue
      })
  }

  get csrfToken() {
    const element = document.querySelector('meta[name="csrf-token"]')
    return element ? element.getAttribute('content') || '' : ''
  }
}

