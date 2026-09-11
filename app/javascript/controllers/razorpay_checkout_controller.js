import { Controller } from "@hotwired/stimulus"

// Loads Razorpay's checkout script on demand — it is theirs, hosted by them,
// and the one external script this app loads — then posts the result back
// so the server can verify the signature. The browser never decides "paid".
export default class extends Controller {
  static values = { options: Object, confirmUrl: String }
  static targets = ["form", "paymentId", "signature"]

  connect() {
    if (window.Razorpay) return this.open()
    const script = document.createElement("script")
    script.src = "https://checkout.razorpay.com/v1/checkout.js"
    script.onload = () => this.open()
    document.head.appendChild(script)
  }

  open() {
    if (!window.Razorpay) return
    const rzp = new window.Razorpay({
      ...this.optionsValue,
      key: this.optionsValue.key_id,
      handler: response => {
        this.paymentIdTarget.value = response.razorpay_payment_id
        this.signatureTarget.value = response.razorpay_signature
        this.formTarget.requestSubmit()
      }
    })
    rzp.open()
  }
}
