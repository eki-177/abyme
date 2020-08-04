import { Controller } from 'stimulus';

export default class extends Controller {
	connect() {
		console.log('Abyme Controller Connected');
	}

	add_association(event) {
		event.preventDefault();
		console.log('Add Association');
	}

	remove_association(event) {
		event.preventDefault();
		console.log('Remove Association');
	}
}
