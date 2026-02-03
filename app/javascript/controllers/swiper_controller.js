import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Swiper controller connected")

    this.swiper = new window.Swiper(this.element, {
      loop: true,
      navigation: {
        nextEl: this.element.querySelector(".swiper-button-next"),
        prevEl: this.element.querySelector(".swiper-button-prev"),
      },
    })
  }

  disconnect() {
    // Check if the swiper instance exists before trying to destroy it
    if (this.swiper) {
      this.swiper.destroy()
    }
  }
}
