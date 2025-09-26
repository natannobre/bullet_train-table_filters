import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filterForm", "icon"]
  static values = { delay: Number }

  connect() {
    this.timeout = null
    this.filterFormTarget.style.display = 'none'
  }

  toggle() {
    if (this.filterFormTarget.style.display === 'none') {
      this.filterFormTarget.style.display = 'block'
      this.iconTarget.classList.add('text-blue-600')
    } else {
      this.filterFormTarget.style.display = 'none'
      this.iconTarget.classList.remove('text-blue-600')
    }
  }

  submitForm() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue || 300)
  }
}
