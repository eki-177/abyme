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

    this.dispatch('abyme:before-add')
    this.associationsTarget.insertAdjacentHTML(this.position, html);
    this.dispatch('abyme:after-add')
  }

  remove_association(event) {
    event.preventDefault();

    this.dispatch('abyme:before-remove')
    let wrapper = event.target.closest('.abyme--fields');
    wrapper.querySelector("input[name*='_destroy']").value = 1;
    wrapper.style.display = 'none';
    this.dispatch('abyme:before-after')
  }

  dispatch(type) {
    const event = new CustomEvent(type, { detail: this })
    this.element.dispatchEvent(event)

    if (type === 'abyme:before-add') {
      if (this.beforeAdd) this.abymeBeforeAdd(event)
    } else if (type === 'abyme:after-add') {
      if (this.afterAdd) this.abymeAfterAdd(event)
    } else if (type === 'abyme:before-remove') {
      if (this.beforeRemove) this.abymeBeforeRemove(event)
    } else if (type === 'abyme:after-remove') {
      if (this.afterRemove) this.abymeAfterRemove(event)
    }
  }

  abymeBeforeAdd(event) {
    console.log(event)
  }

  abymeAfterAdd(event) {
    console.log(event)
  }

  abymeBeforeRevome(event) {
    console.log(event)
  }

  abymeAfterRemove(event) {
    console.log(event)
  }
}
