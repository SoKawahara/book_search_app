document.addEventListener("turbo:load", () => {
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