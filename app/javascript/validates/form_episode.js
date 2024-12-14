//このファイルの中ではエピソード入力欄での文字数のバリデーションを定義している
document.addEventListener("turbo:load" , () => {
    //この下ではエピソードの入力欄に入力された文字数をカウントする
    const triggerArea = document.querySelector("#trigger-area");
    const changingArea = document.querySelector("#changing-area");
    const triggerCounter = document.querySelector(".trigger-counter span");
    const changingCounter = document.querySelector(".changing-counter span");

    inputCounter(triggerArea , triggerCounter);
    inputCounter(changingArea , changingCounter);
    function inputCounter (target , item) {
        target.addEventListener("input" , () => {
            if (target.value.length > 1000) {
                target.style.border = "4px solid red";
                item.style.color = "red";
            } else {
                target.style.border = "2px inset black";
                item.style.color = "black";
            }
            item.textContent = target.value.length;
        })
    }
})