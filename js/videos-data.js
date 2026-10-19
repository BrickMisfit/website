// Add new videos at the top of this list. Only edit this file for future videos.
// youtubeId is the part after youtu.be/ in the video URL.
const brickMisfitVideos = [
  {
    title: "NYC Skyline",
    series: "Misfit Builds",
    youtubeId: "gZXdW4KTTsY",
    description: "Building the New York City skyline, one brick at a time."
  },
  {
    title: "LEGO Technic Ducati Desmo450 MX",
    series: "Misfit Builds",
    youtubeId: "yt2I5BA4tKo",
    description: "Watch the Ducati Desmo450 MX build come together, from the first pieces to the final reveal."
  }
];

(function renderBrickMisfitVideos() {
  const library = document.getElementById("brickmisfitVideoLibrary");
  if (!library) return;

  const validId = /^[a-zA-Z0-9_-]{11}$/;
  const videos = brickMisfitVideos.filter(video => validId.test(video.youtubeId));

  videos.forEach((video, index) => {
    const article = document.createElement("article");
    article.className = "video-feature";
    if (index > 0) article.style.marginTop = "28px";

    const frame = document.createElement("div");
    frame.className = "video-frame";
    const iframe = document.createElement("iframe");
    iframe.src = `https://www.youtube-nocookie.com/embed/${video.youtubeId}`;
    iframe.title = video.title;
    iframe.loading = "lazy";
    iframe.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
    iframe.referrerPolicy = "strict-origin-when-cross-origin";
    iframe.allowFullscreen = true;
    frame.appendChild(iframe);

    const copy = document.createElement("div");
    copy.className = "video-copy";
    const pill = document.createElement("span");
    pill.className = index === 0 ? "pill yellow" : "pill";
    pill.textContent = index === 0 ? "LATEST VIDEO" : (video.series || "VIDEO").toUpperCase();
    const heading = document.createElement("h3");
    heading.textContent = video.title;
    const description = document.createElement("p");
    description.textContent = video.description || "";
    const link = document.createElement("a");
    link.href = `https://youtu.be/${video.youtubeId}`;
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    link.textContent = "Watch on YouTube →";
    copy.append(pill, heading, description, link);
    article.append(frame, copy);
    library.appendChild(article);
  });
})();
