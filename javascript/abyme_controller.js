import { Controller } from 'stimulus';

export default class extends Controller {
  // static targets = ['template', 'associations', 'fields', 'newFields'];
  // Some applications don't compile correctly with the usual static syntax. 
  // Thus implementing targets with standard getters below

  static get targets() {
    return ['template', 'associations', 'fields', 'newFields'];
  } 

  connect() {
    console.log("Abyme Connected")

    if (this.count) {
      // If data-count is present,
      // add n default fields on page load

      this.add_default_associations();
    }
  }

  // return the value of the data-count attribute

  get count() {
    return this.element.dataset.minCount || 0;
  }
  
  // return the value of the data-position attribute
  // if there is no position specified set end as default

  get position() {
    return this.associationsTarget.dataset.abymePosition === 'end' ? 'beforeend' : 'afterbegin';
  }

  // ADD_ASSOCIATION

  // this function is call whenever a click occurs
  // on the element with the click->abyme#add_association
  // <button> element by default

  // if a data-count is present the add_association
  // will be call without an event so we have to check
  // this case

  // check for limit reached 
  // dispatch an event if the limit is reached

  // - call the function build_html that take care
  //   for building the correct html to be inserted in the DOM
  // - dispatch an event before insert
  // - insert html into the dom
  // - dispatch an event after insert

  add_association(event) {
    if (event) {
      event.preventDefault();
    }

    if (this.element.dataset.limit && this.limit_check()) {
      this.create_event('limit-reached')
      return false
    }

    const html = this.build_html();
    this.create_event('before-add');
    this.associationsTarget.insertAdjacentHTML(this.position, html);
    this.create_event('after-add');
  }

  // REMOVE_ASSOCIATION

  // this function is call whenever a click occurs
  // on the element with the click->abyme#remove_association
  // <button> element by default

  // - call the function mark_for_destroy that takes care
  //   of marking the element for destruction and hiding it
  // - dispatch an event before mark & hide
  // - mark for descrution + hide the element
  // - dispatch an event after mark and hide

  remove_association(event) {
    event.preventDefault();

    this.create_event('before-remove');
    this.mark_for_destroy(event);
    this.create_event('after-remove');
  }

  // LIFECYCLE EVENTS RELATED

  // CREATE_EVENT

  // take a stage (String) => before-add, after-add...
  // create a new custom event 
  // and dispatch at at the controller level

  create_event(stage, html = null) {
    const event = new CustomEvent(`abyme:${stage}`, { detail: {controller: this, content: html} });
    this.element.dispatchEvent(event);
    // WIP
    this.dispatch(event, stage);
  }

  // WIP : Trying to integrate event handling through controller inheritance
  dispatch(event, stage) {
    if (stage === 'before-add' && this.abymeBeforeAdd) this.abymeBeforeAdd(event);
    if (stage === 'after-add' && this.abymeAfterAdd) this.abymeAfterAdd(event);
    if (stage === 'before-remove' && this.abymeBeforeRemove) this.abymeBeforeAdd(event);
    if (stage === 'after-remove' && this.abymeAfterRemove) this.abymeAfterRemove(event);
  }

  abymeBeforeAdd(event) {
  }

  abymeAfterAdd(event) {
  }

  abymeBeforeRemove(event) {
  }

  abymeAfterRemove(event) {
  }

  // BUILD HTML

  // takes the html template and substitutes the sub-string
  // NEW_RECORD for a generated timestamp
  // then if there is a sub template in the html (multiple nested level)
  // set all the sub timestamps back as NEW_RECORD
  // finally returns the html  

  build_html() {
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

    return html;
  }
  
  // MARK_FOR_DESTROY

  // mark association for destruction
  // get the closest abyme--fields from the remove_association button
  // set the _destroy input value as 1
  // hide the element
  // add the class of abyme--marked-for-destroy to the element

  mark_for_destroy(event) {
    let item = event.target.closest('.abyme--fields');
    item.querySelector("input[name*='_destroy']").value = 1;
    item.style.display = 'none';
    item.classList.add('abyme--marked-for-destroy')
  }


  // LIMIT_CHECK

  // Check if associations limit is reached
  // based on newFieldsTargets only
  // persisted fields are ignored

  limit_check() {
    return (this.newFieldsTargets
                .filter(item => !item.classList.contains('abyme--marked-for-destroy'))).length 
                >= parseInt(this.element.dataset.limit)
  }

  // ADD_DEFAULT_ASSOCIATION

  // Add n default blank associations at page load
  // call sleep function to ensure uniqueness of timestamp

  async add_default_associations() {
    let i = 0
    while (i < this.count) {
      this.add_association()
      i++
      await this.sleep(1);
    }
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
