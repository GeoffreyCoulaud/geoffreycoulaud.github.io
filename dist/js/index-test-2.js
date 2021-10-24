document.addEventListener("DOMContentLoaded", onLoad);
if (document.readyState === "complete"){
	onLoad();
}

function onLoad(){
	// Do nothing
}

function wrapInTable(){
	// Wrap sections in TDs and remove them from the DOM
	const sections = document.querySelectorAll("body > section");
	const tds = [];
	for (let section of sections){
		const clone = section.cloneNode(true);
		const td = document.createElement("td");
		td.appendChild(clone);
		section.remove();
		tds.push(td);
	}

	// Add all TDs in a single TR
	const trElem = document.createElement("tr");
	for (let td of tds){
		trElem.appendChild(td);
	}

	// Build the table
	const tbodyElem = document.createElement("tbody");
	tbodyElem.appendChild(trElem);
	const tableElem = document.createElement("table");
	tableElem.appendChild(tbodyElem);

	// Add back the table to body 
	document.body.appendChild(tableElem);
}