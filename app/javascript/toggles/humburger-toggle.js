document.addEventListener("turbo:load", () => {
    const humburger = document.querySelector("#humburger-image");
    const sideBar = document.querySelector(".sidebar");
    const closeIcon = document.querySelector("aside.sidebar img.close-icon");
    const sideBarItems = document.querySelectorAll(".sidebar ul li:not(:last-child)");
    const modal = document.querySelector(".modal");
    //ハンバーガーメニューが押された際にサイドバーを表示する
    humburger.addEventListener("click", () => {
        sideBar.animate(
            {
                opacity: [0, 1],
                visibility: ["hidden", "visible"],
                translate: ["100vw", 0]
            },
            {
                duration: 1180,
                easing: "ease-out",
                fill: "forwards"
            }
        );
        sideBarItems.forEach((item, index) => {
            item.animate(
                {
                    opacity: [0, 1],
                    visibility: ["hidden", "visible"],
                    translate: ["100vw", 0]
                },
                {
                    duration: 1500,
                    easing: "ease-out",
                    delay: 150 * index,
                    fill: "forwards"
                }
            );
        });
    });

    //サイドバーの閉じるボタンが押された際にサイドバーを閉じる
    closeIcon.addEventListener("click", () => {
        sideBar.animate(
            {
                opacity: [1, 0],
                visibility: ["visible", "hidden"],
                translate: [0 , "100vw"]
            },
            {
                duration: 300,
                easing: "ease-in",
                fill: "forwards"
            }
        );
    });

});


