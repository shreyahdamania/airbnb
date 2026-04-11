import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["baseFare", "numberOfNights", "serviceFee", "totalAmount"]

  // Using values API for better state management
  static values = { perNightPriceCents: Number, serviceFeeRatio: Number  }

  // SERVICE_FEE  = 0.18;
  static CENTS_PER_UNIT = 100;

  connect() {
    this.updateDetails();
  }

  updateDetails(){

    const nights = this.numberOfNights();
    const base = (nights * this.perNightPriceCentsValue) / this.constructor.CENTS_PER_UNIT ;
    const fee = base * this.serviceFeeRatioValue;
    const total = base + fee;

    this.numberOfNightsTarget.textContent = nights;
    this.baseFareTarget.textContent = base.toFixed(2);
    this.serviceFeeTarget.textContent = fee.toFixed(2);
    this.totalAmountTarget.textContent = total.toFixed(2);
  }

  numberOfNights() {
    return 1;
  }

}