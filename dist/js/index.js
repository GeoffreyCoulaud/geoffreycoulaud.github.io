/**
 * Vérifie si la vue actuelle est celle avec les cartes en éventail
 * @returns {boolean}
 */
function isFanView(){
	const elem = document.querySelector("#developper .card");
	const css = window.getComputedStyle(elem);
	const transform = css.getPropertyValue("transform"); 
	return transform !== "none";
}

/**
 * Animer les cartes de la section "Développeur web"
 */
function animateCards(){

	function hideShownCard(){
		const current = document.querySelector("#developper .card.shown");
		if (!current) return;
		current.classList.remove("shown");
		current.classList.add("hiding");
	}

	// Afficher une carte au clic et cacher celle précédement affichée
	const cards = document.querySelectorAll("#developper .card");
	for (let i = 0; i < cards.length; i++){
		const card = cards[i];
		card.addEventListener("click", function(event){
			if (!isFanView()) return;
			const elem = event.currentTarget; 
			event.stopPropagation();
			hideShownCard();
			elem.classList.remove("hiding");
			elem.classList.add("shown");
		});
	}

	// Cacher la carte affichée au clic en dehors d'une carte
	document.addEventListener("click", ()=>{
		if (!isFanView()) return;
		hideShownCard();
	});

}

document.addEventListener("DOMContentLoaded", ()=>{
	animateCards();
});