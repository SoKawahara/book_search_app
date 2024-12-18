document.addEventListener("turbo:load", () => {

    //エピソード入力欄の文字数が1000文字を超えた際に警告を知らせる
    const episode = document.querySelector("#profile_info_episode");
    const wordCounter = document.querySelector("#word-counter");
    episode.addEventListener("input", () => {
        wordCounter.textContent = `[現在 ${episode.value.length}文字です]`;
        if (episode.value.length > 1000) {
            episode.style.border = "3px solid red";
            wordCounter.style.color = "red";
        } else {
            episode.style.border = "2px inset black";
            wordCounter.style.color = "black";
        }
    })
    
})