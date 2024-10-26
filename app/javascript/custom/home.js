//aboutがクリックされたらその場所まで遷移する
document.addEventListener("turbo:load", () => {
    document.querySelector(".header-nav li:nth-child(1)").addEventListener("click", (e) => {
        e.preventDefault();
        document.querySelector("#about").scrollIntoView({
            behavior: 'smooth', // スムーズにスクロール
            block: 'center' // 要素がビューポートの上端に合わせてスクロール
        });
    });
    //featureがクリックされたらその場所まで遷移する
    document.querySelector(".header-nav li:nth-child(2)").addEventListener("click", (e) => {
        e.preventDefault();
        document.querySelector("#feature").scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    });
    //ここから下は表示でanimationを適応させる場所

    /*サブタイトルに対してアニメーションを加える*/
    const subTitle = document.querySelector(".sub-title");
    const headerH2 = document.querySelectorAll("#header-h2");
    function showsubTitle(entries, obs) {
        if (entries[0].isIntersecting) {
            for (let i = 0; i < headerH2.length; ++i) {
                headerH2[i].animate(
                    {
                        opacity: [0, 1],
                        scale: [0.5, 2.0]
                    },
                    {
                        duration: 2000,
                        delay: i * 300,
                        easing: "ease",
                        fill: "forwards"
                    }
                )
            }
            obs.unobserve(entries[0].target);
        }
    }

    const subTitleObserver = new IntersectionObserver(showsubTitle);
    subTitleObserver.observe(subTitle);

    /*Search Booksとはについてアニメーションを加える*/
    const aboutContainer = document.querySelector(".about-container");
    const aboutText = document.querySelector(".about-text");
    const aboutPicture = document.querySelector(".about-picture");

    function showAboutContainer(entries, obs) {
        const keyframes = {
            opacity: [0, 1],
            translate: ["0 10rem", 0],
            scale: [0.5, 1.0],
            filter: ["blur(25px)", "blur(0)"]
        };
        const options = {
            duration: 2600,
            easing: "ease",
            fill: "forwards"
        };

        if (entries[0].isIntersecting) {
            aboutText.animate(keyframes, options);
            aboutPicture.animate(keyframes, options);
            obs.unobserve(entries[0].target);
        }
    }
    const aboutContainerObserver = new IntersectionObserver(showAboutContainer);
    aboutContainerObserver.observe(aboutContainer);

    //ここから下には4つの特徴に対してアクションを加える
    const responseKeyframes = {
        translate: ["1rem 1rem", 0, "-1rem -1rem", 0, "0.6rem 0.6rem"],
    }
    const customKeyframes = {
        translate: ["-1.2rem 1.2rem", 0, "1.2rem -1.2rem", 0, "-0.8rem 0.8rem"],
    }
    const informationKeyframes = {
        translate: ["-1.1rem -1.1rem", 0, "1.1rem 1.1rem", 0, "-0.9rem -0.9rem"]
    }
    const intuitivenessKeyframes = {
        translate: ["0 0.6rem", 0, "0 -1.1rem", 0, "0 0.3rem"]
    }
    const options = {
        duration: 3000,
        iterations: "Infinity"
    };

    const response = document.querySelector(".response");
    response.animate(responseKeyframes, options);

    const custom = document.querySelector(".custom");
    custom.animate(customKeyframes, options);

    const information = document.querySelector(".information");
    information.animate(informationKeyframes, options);

    const intuitiveness = document.querySelector(".intuitiveness");
    intuitiveness.animate(intuitivenessKeyframes, options);

    //サービス開始ボタンに対してanimationを加える
    const appStartContainer = document.querySelector(".appStart-container");
    const appStartImg = document.querySelector(".appStart-img");
    function showappStart(entries, obs) {
        if (entries[0].isIntersecting) {
            appStartImg.animate(
                {
                    opacity: [0, 1],
                    translate: ["100vw 0", 0],
                    rotate: ["-180deg", 0]
                },
                {
                    duration: 1800,
                    easing: "ease",
                    fill: "forwards"
                }
            );
            obs.unobserve(entries[0].target);
        }
    }
    const appStartContainerObserver = new IntersectionObserver(showappStart);
    appStartContainerObserver.observe(appStartContainer);

    //この下では紹介ページからアプリへの遷移を書く
    const nextPage = document.querySelector("#next-page");
    nextPage.addEventListener("click", event => {
        //これでデフォルトのaタグの効果を打ち消す。
        //addEventListener関数に入ってくるeventオブジェクトのpreventDefaultメソッドではブラウザで指定されたメソッドの効果を打ち消す
        event.preventDefault();
        window.open("app-view.html", "_blank");
    });


});
