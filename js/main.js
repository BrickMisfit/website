const menu=document.querySelector('.menu'),nav=document.querySelector('nav');
if(menu) menu.addEventListener('click',()=>nav.classList.toggle('open'));
const year=document.querySelector('#year'); if(year) year.textContent=new Date().getFullYear();

async function loadCollection(){
  const host=document.querySelector('#collectionGrid'); if(!host) return;
  const data=window.BRICKMISFIT_COLLECTION||[];
  const search=document.querySelector('#search'), filterHost=document.querySelector('#categoryFilters');
  const categories=['All',...new Set(data.map(x=>x.category).filter(Boolean))].sort((a,b)=>a==='All'?-1:b==='All'?1:a.localeCompare(b));
  let active='All';

  filterHost.innerHTML=categories.map(c=>`<button class="filter${c==='All'?' active':''}" data-filter="${c}">${c}</button>`).join('');

  function render(){
    const q=(search?.value||'').toLowerCase();
    const rows=data.filter(x=>(active==='All'||x.category===active)&&(`${x.brand} ${x.number} ${x.name} ${x.category}`.toLowerCase().includes(q)));

    host.innerHTML=rows.map(x=>`<article class="set-card">
      <div class="set-thumb-wrap">
        ${x.image
          ? `<img class="set-thumb" src="${x.image}" alt="${x.name}" loading="lazy"
               onerror="this.style.display='none';if(this.nextElementSibling)this.nextElementSibling.style.display='flex'">
             <div class="set-thumb-fallback" style="display:none"><span>${x.brand||'BUILD'}</span><strong>${x.number}</strong></div>`
          : `<div class="set-thumb-fallback"><span>${x.brand||'BUILD'}</span><strong>${x.number||'—'}</strong></div>`}
      </div>
      <div class="set-card-content">
        <h3 class="set-name">${x.name}</h3>
        <dl class="set-details">
          <div><dt>Set number</dt><dd>${x.number||'—'}</dd></div>
          <div><dt>Category</dt><dd>${x.category||'—'}</dd></div>
          <div><dt>Pieces</dt><dd>${x.pieces?Number(x.pieces).toLocaleString():'—'}</dd></div>
          <div><dt>Price</dt><dd>${x.msrp!=null&&x.msrp!==''?'$'+Number(x.msrp).toFixed(2):'—'}</dd></div>
        </dl>
        ${x.url?`<a class="lego-link" href="${x.url}" target="_blank" rel="noopener">${x.linkLabel||'View product'} →</a>`:''}
      </div>
    </article>`).join('');

    document.querySelector('#count').textContent=rows.length;
  }

  filterHost.querySelectorAll('.filter').forEach(b=>b.addEventListener('click',()=>{
    filterHost.querySelectorAll('.filter').forEach(x=>x.classList.remove('active'));
    b.classList.add('active');
    active=b.dataset.filter;
    render();
  }));

  search?.addEventListener('input',render);
  render();
}

loadCollection();