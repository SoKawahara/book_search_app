document.addEventListener("turbo:load", function () {
    //新規会員登録用のフォームに対するバリデーションを適用する
    const userName = document.querySelector("#user_name");
    const userEmail = document.querySelector("#user_email");
    const userPassword = document.querySelector("#user_password");
    const userPasswordConfirmation = document.querySelector("#user_password_confirmation");
    const formBtn = document.querySelector(".new-btn");


    //氏名入力欄へのバリデーション
    userName.addEventListener("input", () => {
        if (userName.value.match(/(\u3000)/)) {
            userName.style.border = "3px solid red";
        } else {
            userName.style.border = "1px solid black";
        }
    });

    //メールアドレス欄へのバリデーション
    userEmail.addEventListener("input", () => {
        //メールアドレスを検証する正規表現
        const REGEXP = /^[\w+\-.]+@[a-z\d\-.]+\.[a-z]+$/i;
        userEmail.style.border = (userEmail.value !== "" && !userEmail.value.match(REGEXP)) ? "3px solid red" : "1px solid black";
    });

    //パスワード入力欄へのバリデーション
    userPassword.addEventListener("input", () => {
        userPassword.style.border = (userPassword.value.length >= 6 || userPassword.value === "") ? "1px solid black" : "3px solid red";
    });

    //パスワード確認欄へのバリデーション
    userPasswordConfirmation.addEventListener("input", () => {
        userPasswordConfirmation.style.border = ((userPassword.value === userPasswordConfirmation.value) || userPasswordConfirmation.value === "") ? "1px solid black" : "3px solid red";
    });

});


