//これはswiperを実装するためのモジュール
//エクスポートして他のjsファイルで使用できるようにする
//getMySwiperという関数をexportする。関数の中ではPromiseオブジェクトを返す。この非同期処理ではTurboを用いた画面遷移が行われた際にmySwiperが返される
//このファイルが読み込まれた際に1度だけこの関数がexportされる
export const getMySwiper = () => {
    //関数の中ではPromiseオブジェクトを利用した非同期処理が行われている
    return new Promise((resolve) => {
        const mySwiper = new Swiper('.swiper', {
            centeredSlides: true,
            effect: "cards",
            // If we need pagination
            pagination: {
                el: '.swiper-pagination',
            },
            speed: 600,
            autoplay: {
                delay: 5000,
                desableOnInteraction: false
            },

            // Navigation arrows
            navigation: {
                nextEl: '.swiper-button-next',
                prevEl: '.swiper-button-prev',
            },

            // And if we need scrollbar
            scrollbar: {
                el: '.swiper-scrollbar',
            },
        });

        document.addEventListener("turbo:load", () => {
            resolve(mySwiper);
        })
    })
}