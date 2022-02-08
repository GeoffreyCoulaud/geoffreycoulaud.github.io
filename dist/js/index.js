/**
 * Animer les cartes de la section "Développeur web"
 */
function animateCards(){

	function hideShown(){
		const current = document.querySelector("#developper .card.shown");
		if (!current) return;
		current.classList.remove("shown");
		current.classList.add("hiding");
	}

	// Afficher une carte au clic (et cacher la précédente affichée)
	const cards = document.querySelectorAll("#developper .card");
	for (let i = 0; i < cards.length; i++){
		const card = cards[i];
		card.addEventListener("click", function(event){
			// Ne rien faire si on n'est pas en vue éventail
			const elem = event.currentTarget;
			const css = window.getComputedStyle(elem);
			const transform = css.getPropertyValue("transform"); 
			if (transform === "none") return;
			// Sinon, afficher celui cliqué
			event.stopPropagation();
			hideShown();
			elem.classList.remove("hiding");
			elem.classList.add("shown");
		});
	}

	// Cacher la carte au clic n'importe où ailleurs
	document.addEventListener("click", function(event){
		hideShown();
	});

}

document.addEventListener("DOMContentLoaded", (event)=>{
	animateCards();
});