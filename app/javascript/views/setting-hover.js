document.addEventListener("turbo:load" , () => {
    const setting = document.querySelector(".account-info li:last-child");
    setting.querySelector("img").addEventListener("mouseover" , () => {
        setting.querySelector("p").style.opacity = 1;
    });
    setting.querySelector("img").addEventListener("mouseout" , () => {
        setting.querySelector("p").style.opacity = 0;
    })
})