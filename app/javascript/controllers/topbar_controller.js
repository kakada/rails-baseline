import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reloadPage() {
    window.location.reload()
  }
}
