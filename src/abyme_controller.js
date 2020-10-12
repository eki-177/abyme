import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['template', 'associations'];

  connect() {
    console.log('Abyme Connect');
  }

  get position() {
    return this.associationsTarget.dataset.abymePosition === 'end' ? 'beforeend' : 'afterbegin';
  }

  add_association(event) {
    event.preventDefault();

    let html = this.templateTarget.innerHTML.replace(
      /NEW_RECORD/g,
      new Date().getTime()
    );

    if (html.match(/<template[\s\S]+<\/template>/)) {
      const template = html
        .match(/<template[\s\S]+<\/template>/)[0]
        .replace(/(\[\d{12,}\])(\[[^\[\]]+\]"){1}/g, `[NEW_RECORD]$2`);

      html = html.replace(/<template[\s\S]+<\/template>/g, template);
    }

    this.associationsTarget.insertAdjacentHTML(this.position, html);
  }

  remove_association(event) {
    event.preventDefault();

    let wrapper = event.target.closest('.abyme--fields');
    wrapper.querySelector("input[name*='_destroy']").value = 1;
    wrapper.style.display = 'none';
  }
}
