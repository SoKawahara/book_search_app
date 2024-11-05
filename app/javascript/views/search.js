//function.jsで定義した関数をimport
import { get_book_data } from "./function";
import { views } from "./function";
import { changeDisabledValue } from "./function";
import { makeDate } from "./function";
import { post } from "./function";
import { getBookInfo } from "./function";
import { getClickBookInfo } from "./function";

//APIをたたいて取得したデータを保存するための配列
export let api_result_array = [];
document.addEventListener("turbo:load", () => {
    const condition = document.querySelector("#searchCondition");
    const searchNumber = document.querySelector(".search-number");
    const searchWord = document.querySelector(".search-word");
    const searchBtn = document.querySelector(".search-btn");


    if (searchNumber) {
        searchNumber.addEventListener("input", () => {
            if ((Number(searchNumber.value) && (0 < searchNumber.value && searchNumber.value <= 40)) || searchNumber.value === "") {
                searchNumber.style.border = "5px solid grey";
            } else {
                searchNumber.style.border = "5px solid red"
            }
        });
    } else {
        console.log("読み込みに失敗しました");
    }

    if (searchWord) {
        searchWord.addEventListener("input", () => {
            if (searchWord.value.match("\u3000")) {
                searchWord.style.border = "5px solid red";
            } else {
                searchWord.style.border = "5px solid grey";
            }
        });
    }

    
    //検索ボタンを押した際に実際にAPIをたたく処理をする
    if (searchBtn) {
        searchBtn.addEventListener("click", (e) => {
            e.preventDefault();
            //APIをたたいてデータの取得を行う
            //async関数の戻り値はPromiseオブジェクトになるのでawait or thenで受けることで簡単にデータを取り出せる
            get_book_data({ type: condition.value , number: searchNumber.value , content: searchWord.value } , api_result_array) 
            .then(result => {
                api_result_array = result;

                //ここで日付データの整形を行う
                makeDate(api_result_array);

                //現在選択されている条件を取得
                const style = document.querySelector('input[name="view-style"]:checked');
                const condition = document.querySelector('input[name="view-condition"]:checked');
                const order = document.querySelector('input[name="view-order"]:checked');

                //取得したデータを表示する
                if (api_result_array.length > 0) {
                  views(api_result_array , style.value, condition.value, order.value);
                }

                //感想を投稿するという文字をクリックした際にそのクリックされた要素に対応する本の情報を取得する
                //addEventListenerは非同期処理を行うので非同期的に結果を受け取る
                getBookInfo().then(index => {
                    //本の情報を受け取ったらposts/newに対して本の情報と共にPOSTメソッドを送信する
                    post(api_result_array[index]);
                })
                .catch(error => {
                    console.log("本の情報を取得できませんでした");
                })
            })
            //検索結果を表示している場所までスクロールする
            document.querySelector(".result-h1").scrollIntoView({
                behavior: 'smooth', // スムーズにスクロール
                block: 'start' // 要素がビューポートの上端に合わせてスクロール
            });
        });
    }

    //表示方法の変更を行う処理
    const decisionBtn = document.querySelector("#decision-btn");
    decisionBtn.addEventListener("click" , () => {
        //現在選択されている条件を取得
        const style = document.querySelector('input[name="view-style"]:checked');
        const condition = document.querySelector('input[name="view-condition"]:checked');
        const order = document.querySelector('input[name="view-order"]:checked');
        
        //取得したデータを表示する
        if (api_result_array.length > 0) {
            views(api_result_array , style.value, condition.value, order.value);
        }
    });

    //表示方法についての処理
    const viewStyles = document.querySelectorAll('input[name="view-style"]');
    const viewConditions = document.querySelectorAll('input[name="view-condition"]');
    const viewOrder = document.querySelectorAll('input[name="view-order"]');
    viewStyles.forEach((item) => {
        item.addEventListener("click" , () => {
            changeDisabledValue(item.value , viewConditions , viewOrder);
        });
    });
    

});