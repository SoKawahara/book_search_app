//ログインしているユーザのプロフィール画面で設定ボタンのトグルを管理する
document.addEventListener("turbo:load" , () => {
    const settingIcon = document.querySelector(".setting-icon");
    const settingContainer = document.querySelector(".setting-container");
    settingIcon.addEventListener("click" , () => {
        // settingContainer.classList.toggle("active-setting");
        settingContainer.animate(
            {
                opacity: [0 , 1],
                visibility: ["hidden" , "visible"],
                translate: ["3rem" , 0]
            },
            {
                duration: 1000,
                easing: "ease-out",
                fill: "forwards"
            }
        );
    });

    const closeIcon = document.querySelector(".setting-container .close-icon");
    console.log(closeIcon);
    closeIcon.addEventListener("click" , () => {
        settingContainer.animate(
            {
                opacity: [1 , 0],
                visibility: ["visible" , "hidden"]
            },
            {
                duration: 300,
                easing: "ease-in",
                fill: "forwards"
            }
        );
    });
});