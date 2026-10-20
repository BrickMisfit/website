// Upcoming Build card settings. Edit these values when you choose your next build.
// image: path relative to the website root, e.g. "images/builds/coming-soon.webp".
// Leave image empty to display the brick placeholder instead.
const upcomingBuild = {
  status: "UPCOMING",
  title: "Next Build Coming Soon",
  description: "Something new is on the way. Stay tuned for the next BrickMisfit build!",
  image: "images/builds/coming-soon.webp",
  imageAlt: "Upcoming BrickMisfit build"
};

// Card rendering. No changes needed below this line.
(() => {
  const card = document.getElementById("upcomingBuild");
  if (!card) return;
  document.getElementById("upcomingBuildStatus").textContent = upcomingBuild.status;
  document.getElementById("upcomingBuildTitle").textContent = upcomingBuild.title;
  document.getElementById("upcomingBuildDescription").textContent = upcomingBuild.description;
  if (upcomingBuild.image && upcomingBuild.image.trim()) {
    const media = document.getElementById("upcomingBuildMedia");
    const img = document.createElement("img");
    img.src = upcomingBuild.image;
    img.alt = upcomingBuild.imageAlt || upcomingBuild.title;
    img.loading = "lazy";
    img.onerror = () => { media.replaceChildren(); const placeholder = document.createElement("div"); placeholder.className = "brick-icon"; placeholder.textContent = "🧱"; media.appendChild(placeholder); };
    media.replaceChildren(img);
  }
})();
