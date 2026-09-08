const filterButtons = document.querySelectorAll('.filter-btn');
const productCards = document.querySelectorAll('.product-card');
const addButtons = document.querySelectorAll('.add-btn');
const cartCount = document.getElementById('cartCount');

let cartTotal = Number(cartCount.textContent || 0);

filterButtons.forEach((button) => {
  button.addEventListener('click', () => {
    const filter = button.dataset.filter;

    filterButtons.forEach((item) => item.classList.remove('is-active'));
    button.classList.add('is-active');

    productCards.forEach((card) => {
      const shouldHide = filter !== 'all' && card.dataset.category !== filter;
      card.classList.toggle('is-hidden', shouldHide);
    });
  });
});

addButtons.forEach((button) => {
  button.addEventListener('click', () => {
    cartTotal += 1;
    cartCount.textContent = cartTotal;
    button.textContent = 'Ajouté';
    button.disabled = true;

    setTimeout(() => {
      button.textContent = 'Ajouter';
      button.disabled = false;
    }, 1100);
  });
});

document.querySelector('.newsletter-form')?.addEventListener('submit', (event) => {
  event.preventDefault();
  const input = event.currentTarget.querySelector('input');

  if (input && input.value.trim()) {
    input.value = '';
    alert('Merci ! Tu es inscrit aux prochaines nouveautés Aurora.');
  }
});
