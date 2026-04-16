import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "checkin",
    "checkout",
    "checkinWrapper",
    "checkoutWrapper",
    "baseFare",
    "numberOfNights",
    "serviceFee",
    "totalAmount",
    "reserveButton",
  ]

  static values = {
    perNightPriceCents: Number,
    serviceFeeRatio:    Number,
    bookedDates:        Array,
  }

  static ACTIVE_RING   = ["ring-2", "ring-black", "ring-inset"]
  static INACTIVE_RING = ["ring-1", "ring-gray-400", "ring-inset"]
  static CENTS_PER_UNIT = 100

  connect() {
    this.#initCheckinPicker()
    this.#initCheckoutPicker()
    this.#updatePriceDisplay()
  }
   

  disconnect() {
    this.checkinPicker?.destroy()
    this.checkoutPicker?.destroy()
  }

  // ─── Private: initialise pickers ──────────────────────────────────────────

  #initCheckinPicker() {
    this.checkinPicker = flatpickr(this.checkinTarget, {
      dateFormat:    "Y-m-d",
      altInput:      true,
      altFormat:     "d-m-Y",
      allowInput:    false,
      minDate:       this.#tomorrow(),
      disable:       this.#disabledRanges(),
      disableMobile: true,
      defaultDate:   this.checkinTarget.value,

      onOpen: () => {
        this.#activateWrapper(this.checkinWrapperTarget)
      },

      onClose: () => {
        this.#clearWrapper(this.checkinWrapperTarget)
        // Drop focus so switching windows does not re-trigger onOpen
        this.checkinPicker.altInput?.blur()
      },

      onChange: ([selectedDate]) => {
        if (!selectedDate) return
        this.#onCheckinChange(selectedDate)
      },
    })
  }

  #initCheckoutPicker() {
    this.checkoutPicker = flatpickr(this.checkoutTarget, {
      dateFormat:    "Y-m-d",
      altInput:      true,
      altFormat:     "d-m-Y",
      allowInput:    false,
      minDate:       this.#addDays(this.#tomorrow(), 1),
      disable:       this.#disabledRanges(),
      disableMobile: true,
      defaultDate:   this.checkoutTarget.value,

      onOpen: () => {
        this.#activateWrapper(this.checkoutWrapperTarget)
      },

      onClose: () => {
        this.#clearWrapper(this.checkoutWrapperTarget)

        // After checkout is picked, move focus to the booking container element
        // so the browser has nothing date-picker-related to restore focus to
        // when the user switches windows and returns.
        this.element.focus({ preventScroll: true })

        if (this.checkinTarget.value && this.checkoutTarget.value) {
          this.#updatePriceDisplay()
        }
      },
    })
  }

  // ─── Private: date change logic ───────────────────────────────────────────

  #onCheckinChange(checkinDate) {
    const minCheckout = this.#addDays(checkinDate, 1)

    this.checkoutPicker.set("minDate", minCheckout)

    // Clear checkout if it is now on or before the new checkin date
    const existingCheckout = this.checkoutPicker.selectedDates[0]
    if (existingCheckout && existingCheckout <= checkinDate) {
      this.checkoutPicker.clear()
    }

    // Bug 3 fix: always recalculate price after checkin changes.
    // If checkout was cleared above, #numberOfNights() returns 0
    // and #updatePriceDisplay() calls #resetPriceDisplay() internally.
    // If checkout is still valid, the new correct night count is shown immediately.
    this.#updatePriceDisplay()

    // Open checkout picker — use .open() not .click(), works on mobile
    setTimeout(() => this.checkoutPicker.open(), 50)
  }

  // ─── Private: border management ───────────────────────────────────────────

  #activateWrapper(wrapperEl) {
    this.#clearWrapper(this.checkinWrapperTarget)
    this.#clearWrapper(this.checkoutWrapperTarget)
    wrapperEl.classList.remove(...this.constructor.INACTIVE_RING)
    wrapperEl.classList.add(...this.constructor.ACTIVE_RING)
  }

  #clearWrapper(wrapperEl) {
    wrapperEl.classList.remove(...this.constructor.ACTIVE_RING)
    wrapperEl.classList.add(...this.constructor.INACTIVE_RING)
  }

  // ─── Private: price display ───────────────────────────────────────────────

  #updatePriceDisplay() {
    const nights = this.#numberOfNights()
    if (nights <= 0) {
      this.#resetPriceDisplay()
      return
    }

    const baseCents  = nights * this.perNightPriceCentsValue
    const feeCents   = Math.round(baseCents * this.serviceFeeRatioValue)
    const totalCents = baseCents + feeCents

    this.numberOfNightsTarget.textContent = nights
    this.baseFareTarget.textContent       = (baseCents  / this.constructor.CENTS_PER_UNIT).toFixed(2)
    this.serviceFeeTarget.textContent     = (feeCents   / this.constructor.CENTS_PER_UNIT).toFixed(2)
    this.totalAmountTarget.textContent    = (totalCents / this.constructor.CENTS_PER_UNIT).toFixed(2)
  }

  #resetPriceDisplay() {
    this.numberOfNightsTarget.textContent = "—"
    this.baseFareTarget.textContent       = "—"
    this.serviceFeeTarget.textContent     = "—"
    this.totalAmountTarget.textContent    = "—"
  }

  // ─── Private: date utilities ──────────────────────────────────────────────

  #numberOfNights() {
    const checkin  = this.checkinPicker.selectedDates[0]
    const checkout = this.checkoutPicker.selectedDates[0]
    if (!checkin || !checkout) return 0
    return Math.round((checkout - checkin) / (1000 * 60 * 60 * 24))
  }

  #tomorrow() {
    const d = new Date()
    d.setHours(0, 0, 0, 0)
    d.setDate(d.getDate() + 1)
    return d
  }

  #addDays(date, n) {
    const d = new Date(date)
    d.setDate(d.getDate() + n)
    return d
  }

  #disabledRanges() {
    return (this.bookedDatesValue || []).map(({ from, to }) => ({ from, to }))
  }
}