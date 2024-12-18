document.addEventListener("turbo:load" , () => {
    const headerSearch = document.querySelector(".header-search-div");
    const headerEpisode = document.querySelector(".header-episode-div");
    const headerGood = document.querySelector(".header-good-div");
    const headerFeed = document.querySelector(".header-feed-div");
    const headerProfile = document.querySelector(".header-profile-div");

    headerHover(headerSearch);
    headerHover(headerEpisode);
    headerHover(headerGood);
    headerHover(headerFeed);
    headerHover(headerProfile);
    function headerHover (target) {
        target.querySelector("a").addEventListener("mouseover" , () => {
            target.querySelector("p").style.opacity = 1;
        });
        target.querySelector("a").addEventListener("mouseout" , () => {
            target.querySelector("p").style.opacity = 0;
        })
    }

})