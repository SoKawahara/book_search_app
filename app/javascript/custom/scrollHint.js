//このファイルでは縦スクロール可能な要素に対してホバーした際にスクロールできることを表示するための処理を書く
document.addEventListener("turbo:load", () => {
    const pathname = window.location.pathname;
    //アクセスしている先が投稿を表示するためのエンドポイントに対してリクエストが送信されていた時
    //matchメソッドは文字列と正規表現が一致しなかった際にはnullが帰るようになっている
    //IntersectionObserverAPIを用いて感想が監視領域内に入ってきたらアニメーションを実行するように制御した
    if (pathname.match(/^\/posts\/\d+\/\d+$/)) {
        const scrollableHint = document.querySelector(".scrollable-hint");
        const content = document.querySelector(".post-main-content .content");

        function showScroll(entries, obs) {
            if (entries[0].isIntersecting) {
                const maxLength = 460;//maxLengthを越える文字数の感想ではスクロール可能のアニメーションを作成する
                if (content.textContent.length >= maxLength) {
                    //感想を表示しているコンテナに対してホバーした際の処理
                    scrollableHint.style.display = "block";
                    scrollableHint.classList.add("add-scroll-hint");

                    //スクロール可能であることを知らせるためのアニメーションを定義する
                    const scrollItem = scrollableHint.querySelector("div");
                    scrollItem.animate(
                        {
                            translate: [0, "0 -16rem"],
                        },
                        {
                            duration: 1500,
                            delay: 650,
                            easing: "ease-out",
                            fill: "forwards"
                        }
                    );
                    setTimeout(() => {
                        scrollableHint.style.display = "none";
                        scrollableHint.classList.remove("add-scroll-hint");
                    }, 2250);
                }
                obs.unobserve(entries[0].target);
            }
        }

        const scrollObserver = new IntersectionObserver(showScroll);
        scrollObserver.observe(content);
    }
})