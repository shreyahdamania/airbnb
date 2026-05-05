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
    // Parse booked dates once into JS Date objects at midnight local time.
    // Every method reads from this.reservations — never re-parses strings.
    // Shape: [{ from: Date, to: Date }, ...]
    this.reservations = (this.bookedDatesValue || []).map(({ from, to }) => ({
      from: this.#parseDate(from),
      to:   this.#parseDate(to),
    }))

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
      disableMobile: true,
      defaultDate:   this.checkinTarget.value,

      // A function is used instead of an array so the logic can be
      // conditional. flatpickr calls this for every date it renders.
      // Return true = date is blocked/greyed out.
      disable: [
        (date) => this.#isCheckinBlocked(date)
      ],

      onOpen: () => {
        this.#activateWrapper(this.checkinWrapperTarget)
      },

      onClose: () => {
        this.#clearWrapper(this.checkinWrapperTarget)
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
      disableMobile: true,
      defaultDate:   this.checkoutTarget.value,

      onOpen: () => {
        this.#activateWrapper(this.checkoutWrapperTarget)
      },

      onClose: () => {
        this.#clearWrapper(this.checkoutWrapperTarget)
        this.checkoutPicker.altInput?.blur()
        this.element.focus({ preventScroll: true })

        if (this.checkinTarget.value && this.checkoutTarget.value) {
          this.#updatePriceDisplay()
        }
      },
    })
  }

  // ─── Private: checkin blocked date logic ──────────────────────────────────

  // Returns true if the given date should be blocked in the checkin picker.
  // A date is blocked if:
  //   1. It is the `from` date of any existing reservation (someone is
  //      checking in that day — the property is taken from that point).
  //   2. It falls strictly between `from` and `to` of any reservation
  //      (the property is physically occupied that night).
  //
  // The `to` date is deliberately NOT blocked — a guest checking out that
  // morning means the property is free for a new checkin that same day.
  #isCheckinBlocked(date) {
    return this.reservations.some(({ from, to }) => {
      const isFromDate        = this.#isSameDay(date, from)
      const isOccupiedBetween = date > from && date < to
      return isFromDate || isOccupiedBetween
    })
  }

  reserveProperty(e) {
    e.preventDefault();

    const paramsData = {
      checkin_date: this.checkinTarget.value,
      checkout_date: this.checkoutTarget.value
    };

    const paramsURL = new URLSearchParams(paramsData).toString();
    const baseURL = e.currentTarget.dataset.reservePropertyUrl;

    Turbo.visit(`${baseURL}?${paramsURL}`);
  }

  // ─── Private: date change logic ───────────────────────────────────────────

  #onCheckinChange(checkinDate) {
    const minCheckout = this.#addDays(checkinDate, 1)
    this.checkoutPicker.set("minDate", minCheckout)

    // Find the maximum valid checkout: the `from` date of the first
    // reservation that starts strictly after the selected checkin.
    // Example: checkin Apr 18, reservations exist Apr 21–25 and Apr 28–30.
    // The first `from` after Apr 18 is Apr 21, so maxDate = Apr 21.
    // The guest can checkout Apr 19, 20, or 21 (Apr 21 is valid because
    // one guest checking out as another checks in is allowed).
    const nextReservation = this.#nextReservationAfter(checkinDate)

    if (nextReservation) {
      this.checkoutPicker.set("maxDate", nextReservation.from)
    } else {
      // No upcoming reservation — remove the upper bound entirely
      this.checkoutPicker.set("maxDate", null)
    }

    // Clear checkout if it is now outside the valid range
    const existingCheckout = this.checkoutPicker.selectedDates[0]
    if (existingCheckout) {
      const tooEarly = existingCheckout <= checkinDate
      const tooLate  = nextReservation && existingCheckout > nextReservation.from

      if (tooEarly || tooLate) {
        this.checkoutPicker.clear()
      }
    }

    // Always recalculate — if checkout was cleared this returns 0
    // and #resetPriceDisplay() runs. If checkout is still valid,
    // the new correct night count is shown immediately.
    this.#updatePriceDisplay()

    setTimeout(() => this.checkoutPicker.open(), 50)
  }

  // Returns the first reservation whose `from` date is strictly after
  // the given date, sorted chronologically so we get the nearest one.
  #nextReservationAfter(date) {
    return this.reservations
      .filter(({ from }) => from > date)
      .sort((a, b) => a.from - b.from)[0] || null
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

  // Parses "YYYY-MM-DD" strings from Rails into a JS Date at local midnight.
  // Using new Date("YYYY-MM-DD") directly parses as UTC midnight, which
  // causes an off-by-one day error in timezones behind UTC (e.g. US).
  // Splitting and constructing manually guarantees local midnight.
  #parseDate(str) {
    const [year, month, day] = str.split("-").map(Number)
    const d = new Date(year, month - 1, day)
    d.setHours(0, 0, 0, 0)
    return d
  }

  #isSameDay(a, b) {
    return (
      a.getFullYear() === b.getFullYear() &&
      a.getMonth()    === b.getMonth()    &&
      a.getDate()     === b.getDate()
    )
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
}