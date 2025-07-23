import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "checkbox"]

  connect() {
    this.toggleInput()
  }

  toggleInput() {
    if (this.hasCheckboxTarget && this.hasInputTarget) {
      this.inputTarget.disabled = this.checkboxTarget.checked
      if (this.checkboxTarget.checked) {
        this.inputTarget.value = ''
      }
    }
  }
}
