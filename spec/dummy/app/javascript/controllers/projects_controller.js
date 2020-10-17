import { Controller } from 'stimulus';
import Rails from '@rails/ujs';

export default class extends Controller {
  static targets = ['modal', 'imagePreview'];

  openModal() {
    this.modalTarget.classList.remove('opacity-0', 'pointer-events-none');
  }

  closeModal() {
    this.modalTarget.classList.add('opacity-0', 'pointer-events-none');
    this.clearErrors(this.modalTarget);
  }

  clearErrors(element) {
    element
      .querySelectorAll('.error')
      .forEach((item) => item.classList.remove('error'));

    element
      .querySelectorAll('.error-feedback')
      .forEach((item) => (item.innerText = ''));
  }

  imageChange(event) {
    event.target
      .closest('.image-inputs')
      .querySelector('input[type="file"]')
      .click();
  }

  imagePreview(event) {
    const reader = new FileReader();

    reader.onload = (e) => {
      this.imagePreviewTarget.src = e.target.result;
    };

    reader.readAsDataURL(event.target.files[0]);
  }

  validation(event) {
    const input = event.target;
    const form = new FormData();
    form.append(input.name, input.value);

    Rails.ajax({
      type: 'post',
      url: '/project_validation',
      data: form,
    });
  }
}
