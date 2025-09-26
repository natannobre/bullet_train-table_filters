import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static values = { delay: Number }

  connect() {
    this.timeout = null
  }

  submitForm() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue || 300)
  }
}
