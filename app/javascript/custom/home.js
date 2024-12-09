document.addEventListener("turbo:load", () => {
    const catchphrase = document.querySelector("#catchphrase");
    const text1 = document.querySelector("#text-1");
    const text2 = document.querySelector("#text-2");

    function showcatchphrase(entries, obs) {
        if (entries[0].isIntersecting) {
            text1.querySelectorAll("span").forEach((item, index) => {
                item.animate(
                    {
                        opacity: [0, 1],
                    },
                    {
                        duration: 1000,
                        delay: index * 300,
                        fill: "forwards"
                    }
                )
            });
            text2.querySelectorAll("span").forEach((item, index) => {
                item.animate(
                    {
                        opacity: [0, 1],
                    },
                    {
                        duration: 1000,
                        delay: 1200 + index * 300,
                        fill: "forwards"
                    }
                )
            });

            obs.unobserve(entries[0].target);
        }
    }

    const catchphraseObserver = new IntersectionObserver(showcatchphrase);
    catchphraseObserver.observe(catchphrase);
    //Aboutが押されたらAboutまで遷移する
    //Featureが押されたらFeatureまで遷移する
    const scrollAbout = document.querySelector("#scroll-about");
    const title = document.querySelector(".about-title");
    const aboutContainer = document.querySelector("#about-container");
    const aboutDiv = document.querySelector(".about-title div");

    const options = {
        duration: 1200,
        delay: 500,
        easing: "ease-out",
        fill: "forwards"
    }
    scrollAbout.addEventListener("click", (e) => {
        e.preventDefault();
        title.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    })

    function showAboutContainer(entries, obs) {
        //isIntersecting関数で指定した監視対象の要素が交差しているのか判別できる
        if (entries[0].isIntersecting) {
            //紹介文に対するスタイルを定義している
            aboutContainer.querySelector("p").animate([
                {
                    opacity: 0,
                    filter: "blur(4px)",
                    translate: "0 4rem",
                    fontSize: "18px",
                    offset: 0
                },
                {
                    opacity: 0.3,
                    filter: "blur(2px)",
                    translate: "0 2rem",
                    fontSize: "19px",
                    offset: 0.3
                },
                {
                    opacity: 0.8,
                    filter: "blur(2px)",
                    translate: "0 .5rem",
                    fontSize: "20px",
                    offset: 0.8
                },
                {
                    opacity: 1,
                    filter: "blur(0)",
                    translate: "0",
                    fontSize: "18px",
                    offset: 1
                }
            ],
                {
                    duration: 2000,
                    easing: "ease-out",
                    fill: "forwards"
                });
            //画像に対するスタイルを充てる
            aboutContainer.querySelector("img").animate([
                {
                    opacity: 0,
                    filter: "blur(6px)",
                    translate: "0 3.5rem",
                    boxShadow: '0px 0px 0px rgba(0, 0, 0, 0)',
                    offset: 0
                },
                {
                    opacity: 0.3,
                    filter: "blur(4.5px)",
                    translate: "0 2.8rem",
                    boxShadow: '-0.3rem 0.3rem 10px grey',
                    offset: 0.3
                },
                {
                    opacity: 0.7,
                    filter: "blur(2px)",
                    translate: "0 1.4rem",
                    boxShadow: '-0.8rem 0.8rem 7px grey',
                    offset: 0.7
                },
                {
                    opacity: 1,
                    filter: "blur(0)",
                    translate: "0",
                    boxShadow: '-1.1rem 1.1rem 4px grey',
                    offset: 1
                }
            ],
                {
                    duration: 1800,
                    easing: "ease-out",
                    fill: "forwards"
                })
            //Aboutの下の棒線のアニメーション
            aboutDiv.animate(
                {
                    opacity: [0, 1],
                    width: [0, '60%']
                }, options )
            obs.unobserve(entries[0].target);
        }
    }

    const aboutContainerObserver = new IntersectionObserver(showAboutContainer);
    aboutContainerObserver.observe(aboutContainer);

    const scrollFeature = document.querySelector("#scroll-feature");
    const featureContainer = document.querySelector("#feature-container");
    scrollFeature.addEventListener("click", (e) => {
        e.preventDefault();
        featureContainer.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        })
    })

    //ここから下ではfeature項目に対してのアニメーションを適用する
    function showFeatureContainer(entries, obj) {
        if (entries[0].isIntersecting) {
            const target = entries[0].target;
            const options = {
                duration: 1500,
                easing: "ease-out",
                fill: "forwards"
            }
            if (target.className === "feature2") {
                target.animate(
                    {
                        opacity: [0, 1],
                        translate: ["-5rem 0", 0],
                        scale: [1.1, 1.0],
                    }, options
                )
            } else {
                target.animate(
                    {
                        opacity: [0, 1],
                        translate: ["5rem 0", 0],
                        scale: [1.1, 1.0],
                    }, options
                )

            }
            obj.unobserve(entries[0].target);
        }
    }

    //featureContainerObserverはshowFeatureContainerの第２引数に渡される
    //これは監視対象を監視するロボットを作成したことになる
    const featureContainerObserver = new IntersectionObserver(showFeatureContainer);
    const featureContainerItems = featureContainer.querySelectorAll(".feature1 , .feature2 , .feature3");
    featureContainerItems.forEach(item => {
        featureContainerObserver.observe(item);
    });

    //ここではfeature-titleが画面内に入ってきた際にアニメーションする処理を加える
    const featureTitle = document.querySelector(".feature-title");

    function showFeatureTitle(entries, obs) {
        if (entries[0].isIntersecting) {
            featureTitle.querySelector("div").animate(
                {
                    opacity: [0, 1],
                    width: [0, '60%']
                }, options )
            obs.unobserve(entries[0].target);
        }
    }

    const featureTitleObserver = new IntersectionObserver(showFeatureTitle);
    featureTitleObserver.observe(featureTitle);

    const scrollFunction = document.querySelector("#scroll-function");
    const functionTitle = document.querySelector(".function-title");

    scrollFunction.addEventListener("click", () => {
        functionTitle.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        })
    });

    function showFunctionTitle(entries , obs) {
        if (entries[0].isIntersecting) {
            functionTitle.querySelector("div").animate(
                {
                    opacity: [0 , 1],
                    width: [0 , "60%"]
                }, options )
            obs.unobserve(entries[0].target);
        }
    }

    const functionTitleObserver = new IntersectionObserver(showFunctionTitle);
    functionTitleObserver.observe(functionTitle);


    

    //ここから下では画面が一定以上スクロールされた際にヘッダーを固定するための処理を考える
    const introNav = document.querySelector(".intro-nav");
    window.addEventListener("scroll", () => {
        //スクロール量が100px(ヘッダーの大きさ)を越えた段階でヘッダー固定のスタイルを適用する
        if (window.scrollY >= 100) {
            introNav.classList.add("fixed");
        } else {
            introNav.classList.remove("fixed");
        }
    })

    //ここから下では機能紹介画面で各機能が選択された際に中央で詳細表示する機能を実装する
    const viewMain = document.querySelector(".view-main");
    const episode = document.querySelector(".left-container #episode");
    const myShelf = document.querySelector(".left-container #my_shelf");
    const search = document.querySelector(".right-container #search");
    const post = document.querySelector(".right-container #post");
    
    viewEachFunction(viewMain , episode);
    viewEachFunction(viewMain , myShelf);
    viewEachFunction(viewMain , search);
    viewEachFunction(viewMain , post);

    //これは各機能が選択された際に中央で詳細表示をするための関数
    function viewEachFunction(viewMain , item) {
        //クリックされた際に中央で詳細表示する
        item.addEventListener("click" , () => {
            //現在選択されている要素を取得する
            const target = document.querySelector(".function-container #episode .add-item-click, .function-container #my_shelf .add-item-click , .function-container #search .add-item-click , .function-container #post .add-item-click");
            if (target) {
                target.classList.remove("add-item-click");
                target.style.display = "none";
            } 

            viewMain.querySelector("h3").textContent = item.querySelector("h4").textContent;
            viewMain.querySelector("img").src = item.querySelector("img").src;
            viewMain.querySelector("p").textContent = item.querySelector("p").textContent;

            const itemClick = item.querySelector(".item-click");
            itemClick.style.display = "block";
            itemClick.classList.add("add-item-click");
        });
    }
})


