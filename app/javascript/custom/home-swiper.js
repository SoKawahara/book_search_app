//これはswiperを実装するためのモジュール
//エクスポートして他のjsファイルで使用できるようにする
export let mySwiper = new Swiper('.swiper', {
    centeredSlides: true ,
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

