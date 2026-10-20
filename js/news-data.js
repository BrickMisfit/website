// BrickMisfit News: curated, source-linked LEGO.com US snapshot.
// Add new entries to brickMisfitNews; use ISO dates and official URLs.
// The site is static: editing this file and publishing updates the news cards.
const brickMisfitNews = [
  {
    title: "Explore the latest LEGO sets",
    category: "New Releases",
    date: "2026-10-20",
    summary: "Browse LEGO's recently released sets, including new display models and building projects. The official listing is updated by LEGO.",
    url: "https://www.lego.com/en-us/categories/new-sets-and-products"
  },
  {
    title: "See which LEGO sets are coming soon",
    category: "Coming Soon",
    date: "2026-10-20",
    summary: "Preview upcoming sets and future releases directly from LEGO's Coming Soon collection.",
    url: "https://www.lego.com/en-us/categories/coming-soon"
  },
  {
    title: "LEGO sets retiring soon",
    category: "Retiring Soon",
    date: "2026-10-20",
    summary: "LEGO's official Last Chance to Buy selection highlights sets approaching retirement. Availability varies by set.",
    url: "https://www.lego.com/en-us/categories/last-chance-to-buy"
  },
  {
    title: "October LEGO gifts with purchase",
    category: "Promotions",
    date: "2026-10-20",
    summary: "LEGO lists a Fun Halloween Skeleton gift with qualifying $40+ purchases and a Luminous Ghost gift with qualifying $120+ purchases, October 20–27, while supplies last. Check full eligibility and terms.",
    url: "https://www.lego.com/en-us/page/lego-offers-promotions"
  },
  {
    title: "LEGO offers and sale items",
    category: "Promotions",
    date: "2026-10-20",
    summary: "See the official LEGO US offers page for current sale items, Insiders offers and other promotions. Discounts may change.",
    url: "https://www.lego.com/en-us/page/lego-offers-promotions"
  }
];

(() => {
  const grid = document.getElementById("brickmisfitNews");
  if (!grid) return;
  const filters = document.querySelectorAll("[data-news-filter]");
  const render = (selected = "All") => {
    grid.replaceChildren();
    const items = brickMisfitNews.filter(item => selected === "All" || item.category === selected);
    if (!items.length) { const empty = document.createElement("p"); empty.className = "muted"; empty.textContent = "No updates in this category yet."; grid.appendChild(empty); return; }
    items.forEach(item => {
      if (!item.title || !/^https:\/\//i.test(item.url || "")) return;
      const article = document.createElement("article"); article.className = "card";
      const body = document.createElement("div"); body.className = "card-body";
      const pill = document.createElement("span"); pill.className = "pill yellow"; pill.textContent = item.category || "NEWS";
      const title = document.createElement("h3"); title.textContent = item.title;
      const date = document.createElement("p"); date.className = "brick-news-meta"; date.textContent = item.date ? `Reviewed ${new Date(item.date + "T12:00:00").toLocaleDateString("en-US",{month:"short",day:"numeric",year:"numeric"})}` : "";
      const summary = document.createElement("p"); summary.textContent = item.summary || "";
      const link = document.createElement("a"); link.href = item.url; link.target = "_blank"; link.rel = "noopener noreferrer"; link.textContent = "Explore on LEGO.com →";
      body.append(pill,title,date,summary,link); article.appendChild(body); grid.appendChild(article);
    });
  };
  filters.forEach(button => button.addEventListener("click", () => {
    filters.forEach(b => { const active = b === button; b.classList.toggle("active",active); b.setAttribute("aria-pressed",String(active)); });
    render(button.dataset.newsFilter);
  }));
  render();
})();
