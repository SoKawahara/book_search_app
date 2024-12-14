document.addEventListener("turbo:load", () => {
    //詳細を見るを押された際に具体的な文章を表示する処理を書く
    const trigger = document.querySelector("#trigger");
    const changing = document.querySelector("#changing");

    const triggerBtn = trigger.querySelector("a");
    triggerBtn.addEventListener("click", (e) => {
        e.preventDefault();//デフォルトのaタグの挙動を止める

        if (triggerBtn.textContent === "→詳細を見る") {
            trigger.querySelector("#trigger-about-content").style.display = "none";
            trigger.querySelector("#trigger-main-content").style.display = "block";
            triggerBtn.textContent = "閉じる←"
        } else {
            trigger.querySelector("#trigger-about-content").style.display = "block";
            trigger.querySelector("#trigger-main-content").style.display = "none";
            triggerBtn.textContent = "→詳細を見る"

        }

    });

    const changingBtn = changing.querySelector("a");
    changingBtn.addEventListener("click", (e) => {
        e.preventDefault();

        if (changingBtn.textContent === "→詳細を見る") {
            changing.querySelector("#changing-about-content").style.display = "none";
            changing.querySelector("#changing-main-content").style.display = "block";
            changingBtn.textContent = "閉じる←"
        } else {
            changing.querySelector("#changing-about-content").style.display = "block";
            changing.querySelector("#changing-main-content").style.display = "none";
            changingBtn.textContent = "→詳細を見る"
        }
    });
})