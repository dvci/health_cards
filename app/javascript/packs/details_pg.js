if (document.readyState !== "loading") {
	onReady();
}	else {
	document.addEventListener("DOMContentLoaded", onReady);
}

function onReady() {
	let cardToggles = document.getElementsByClassName('card-toggle');
	for (let i = 0; i < cardToggles.length; i++) {
		cardToggles[i].addEventListener('click', e => {
			e.currentTarget.parentElement.parentElement.childNodes[3].classList.toggle('is-hidden');
		});
	}
}