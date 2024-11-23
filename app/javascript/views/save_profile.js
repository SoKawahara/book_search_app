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
    const profileSaveBtn = document.querySelector(".profile-save-btn");
    profileSaveBtn.addEventListener("click", (e) => {
        e.preventDefault();
        const yearMonth = document.querySelector(".year-month").value;
        const favoriteGenre = document.querySelector(".favorite-genre").value;
        const birthday = document.querySelector(".birthday").value;
        const gender = document.querySelector("#gender").value;
        const occupations = document.querySelector(".occupations").value;
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        //ここで入力されたデータをsessionに保存するためにリクエストを送信する
        fetch("/users/profile_tmp_save", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({
                yearMonth: yearMonth,
                favoriteGenre: favoriteGenre,
                birthday: birthday,
                gender: gender,
                occupations: occupations,
                // episode: episode
            })
        })
            .then(response => {
                if (response.ok) {
                    profileSaveBtn.textContent = "入力内容を適用しました";
                } else {
                }
            })
    });
})