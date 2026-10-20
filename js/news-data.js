// BrickMisfit news feed. Add verified articles below, newest first.
// Example entry:
// { title: "Article title", category: "Set Reveals", date: "2026-10-20",
//   summary: "Short original summary.", url: "https://example.com/article", image: "" }
const brickMisfitNews = [];

(() => {
  const grid = document.getElementById("brickmisfitNews");
  if (!grid || !brickMisfitNews.length) return;
  grid.replaceChildren();
  brickMisfitNews.forEach(item => {
    if (!item.title || !item.url || !/^https:\/\//i.test(item.url)) return;
    const article = document.createElement("article");
    article.className = "card";
    if (item.image) {
      const media = document.createElement("div"); media.className = "card-media";
      const img = document.createElement("img"); img.src = item.image; img.alt = item.title; img.loading = "lazy";
      img.style.cssText = "width:100%;height:100%;object-fit:cover"; media.appendChild(img); article.appendChild(media);
    }
    const body = document.createElement("div"); body.className = "card-body";
    const category = document.createElement("span"); category.className = "pill yellow"; category.textContent = item.category || "NEWS";
    const title = document.createElement("h3"); title.textContent = item.title;
    const date = document.createElement("p"); date.className = "muted"; date.textContent = item.date || "";
    const summary = document.createElement("p"); summary.textContent = item.summary || "";
    const link = document.createElement("a"); link.href = item.url; link.target = "_blank"; link.rel = "noopener noreferrer"; link.textContent = "Read more →";
    body.append(category,title,date,summary,link); article.appendChild(body); grid.appendChild(article);
  });
})();
