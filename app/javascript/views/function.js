import { api_result_array } from "./search";
//このファイル内では使用する関数を定義する
export async function get_book_data({ type, number, content }, array = []) {
    //sessionStorageにデータがあった場合にはクリアする
    if (localStorage.getItem("book_data")) {
        localStorage.removeItem("book_data");
    }
    //配列に要素がある場合には削除して配列を空にする
    if (array.length > 0) {
        array.length = 0;
    }
    //ここでRailsで指定したエンドポイントに対してリクエストを送信する
    //RailsではGET以外のリクエストにはCSRFの認証トークンを用いてリクエストの正当性を保証する
    //fetch関数を用いる時には明示的にこれをリクエストに含める必要がある
    //これはCSRFの認証トークンを取得している
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    try {
        const response = await fetch('/searches/index', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({
                type: type,
                number: number,
                content: content
            })
        });
        const data = await response.json();
        data.items.forEach((item) => {
            const tmp = {};
            // この下で表示する要素を取得する
            //タイトル取得のエラーハンドリング
            try {
                const title = item.volumeInfo.title;
                tmp.title = title === undefined ? "不明" : title
            } catch {
                console.log("タイトルの読み込みに失敗しました");
                tmp.title = "不明";
            }
            //著者取得のエラーハンドリング
            try {
                const author = item.volumeInfo.authors;
                tmp.author = author === undefined ? "不明" : author;
            } catch {
                console.log("著者の読み込みに失敗しました");
                tmp.author = "不明";
            }
            //画像リンク取得のエラーハンドリング
            try {
                const imageLink = item.volumeInfo.imageLinks.thumbnail.replace("&zoom=1", "&zoom=5");
                tmp.imageLink = imageLink === undefined ? "error.jpg" : imageLink;
            } catch {
                console.log("画像リンクの取得に失敗しました");
                tmp.imageLink = "不明";
            }
            //詳細文取得のエラーハンドリング
            try {
                const description = item.volumeInfo.description;
                tmp.description = description === undefined ? "不明" : description
            } catch {
                console.log("詳細文の取得に失敗しました");
                tmp.description = "不明";
            }
            //出版社取得のエラーハンドリング
            try {
                const publisher = item.volumeInfo.publisher;
                tmp.publisher = publisher === undefined ? "不明" : publisher;
            } catch {
                console.log("出版社の取得に失敗しました");
                tmp.publisher = "不明";
            }
            //出版日取得のエラーハンドリング
            try {
                const publishedDate = item.volumeInfo.publishedDate;
                tmp.publishedDate = publishedDate === undefined ? "不明" : publishedDate
            } catch {
                console.log("出版日の取得に失敗しました");
                tmp.publishedDate = "不明";
            }
            //ページ数取得のエラーハンドリング
            try {
                const pageCount = item.volumeInfo.pageCount;
                tmp.pageCount = pageCount === undefined ? "0" : pageCount
            } catch {
                console.log("ページ数の取得に失敗しました");
                tmp.pageCount = "0";
            }
            //購入リンク取得のエラーハンドリング
            try {
                const buyLink = item.saleInfo.buyLink;
                tmp.buyLink = buyLink === undefined ? "不明" : buyLink
            } catch {
                console.log("購入リンクの取得に失敗しました");
                tmp.buyLink = "不明";
            }
            //価格取得のエラーハンドリング
            try {
                const value = item.saleInfo.listPrice.amount;
                tmp.value = value === undefined ? "0" : value
            } catch {
                console.log("価格の読み込みに失敗しました。");
                tmp.value = "0";
            }
            array.push(tmp);
        });

        //本のデータを取得出来たら一時的にブラウザのsessionStorageに保存する。これはセッションごとにデータを管理する
        localStorage.setItem("book_data", JSON.stringify(array));
        return array;
    } catch (e) {
        return [];
    }
}

export function getBookInfo() {
    const resultContainers = document.querySelectorAll(".result-container .result-item");
    return new Promise((resolve) => {
        resultContainers.forEach((item, index) => {
            const post = item.querySelector(".post");
            post.addEventListener("click", () => {
                resolve(index)
            })
        })
    })
}

//マイ本棚へ追加するが押された際の処理を書く
export function add_myshelf() {
    const resultContainers = document.querySelectorAll(".result-container .result-item");
    return new Promise((resolve) => {
        resultContainers.forEach((item, index) => {
            item.querySelector(".my-shelf").addEventListener("click", (e) => {
                e.preventDefault();
                resolve(index);
            });
        });
    });
}

//マイ本棚へ追加を押された際に実際に本棚に本を追加するリクエストを送信する
export function post_my_shelf(book_info) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    try {
        fetch("/shelfs/create" , {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({ bookInfo: book_info })
        }).then(response => {
            if (response.ok) {
                alert("マイ本棚への追加が完了しました!");
            } else {
                alert("マイ本棚へ追加できませんでした");
            }
        });
    } catch (e) {
        console.error(e);
    }


}

//感想を投稿するを押されたら本の情報と共にPOSTメソッドを送信する処理
export function post(bookInfo) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    try {
        fetch("/posts/new", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({ bookInfo: bookInfo })
        })
            //レスポンスとして返ってきたHTMLファイルを文字列に変換する
            .then(response => response.text())
            .then(html => {
                //変換されたHTMLファイルを画面に描画する。その際に一度画面の内容をdocument.openでリセットする
                document.open();
                document.write(html);
                document.close();

                //検索結果に戻るが押されたらブラウザのsessionStorageにapi_result_arrayを保存する


            })
            .catch(error => console.error("Error:", error));
    } catch {
        console.log("送信に失敗しました");
    }
}

//データの配列からビューを構築する
export function views(api_result_array, style, condition, order) {
    //検索結果を入れるコンテナを取得して現在の要素を全て削除する
    const container = document.querySelector(".result-container");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }

    if (style === "縦方向一覧") {
        //指定された順番に並べ替える
        sort(condition, order, api_result_array);
        //縦方向一覧を表示するのでグリッドスタイルが適用されていたら外す
        container.classList.remove("grid");

        api_result_array.forEach((item) => {
            const templateVertical = document.querySelector("#vertical-publish-day");
            const template = templateVertical.content.cloneNode(true);

            template.querySelector(".title").textContent = `タイトル: ${item.title}`;
            template.querySelector(".author").textContent = `著者: ${item.author.toString().replace(/[\[\]"]/, "")}`;
            template.querySelector(".publisher").textContent = `出版社: ${item.publisher}`;
            template.querySelector(".page-count").textContent = (item.pageCount === ("0" || undefined)) ? `ページ数:0ページ` : `ページ数: ${item.pageCount}ページ`;
            template.querySelector(".value").textContent = (item.value === ("不明" || undefined)) ? `価格:${0}円` : `価格: ${item.value}円`;
            template.querySelector(".publish-day").textContent = `出版日: ${item.publishedDate}`;
            template.querySelector(".publish-day-img").src = `${item.imageLink}`;
            template.querySelector(".publish-day-description").textContent = `${item.description}`;


            container.append(template);
        });
    } else {
        container.classList.add("grid");
        api_result_array.forEach((item) => {
            //グリッドで表示するテンプレートを作成
            const template = document.querySelector("#grid-layout");
            const targetNewElement = template.content.cloneNode(true);
            const gridContainer = targetNewElement.querySelector(".grid-container");
            const { title, author, imageLink } = item
            gridContainer.querySelector(".grid-title").textContent = `${title}`;
            gridContainer.querySelector(".grid-author").textContent = `著者: ${author}`;
            gridContainer.querySelector(".grid-img").src = `${imageLink}`;
            container.append(gridContainer);
        });

        const modal = document.querySelector(".modal");
        const sections = container.querySelectorAll("section");
        sections.forEach((item, index) => {
            const gridAbout = item.querySelector(".grid-about");
            gridAbout.addEventListener("click", () => {
                const template = document.querySelector("#grid-modal");
                const targetNewElement = template.content.cloneNode(true);

                //モーダルとして表示するコンテナを作成
                const modalContainer = targetNewElement.querySelector(".modal-container");
                //クリックされた詳細ボタンに対応する要素の詳細情報を分割代入の方式でarray配列から取得
                const { publisher, pageCount, value, description, imageLink } = api_result_array[index];
                modalContainer.querySelector(".modal-publisher").textContent = `出版社: ${publisher}`;
                modalContainer.querySelector(".modal-page-count").textContent = `ページ数: ${pageCount}`;
                modalContainer.querySelector(".modal-value").textContent = `価格: ${value}円`;
                modalContainer.querySelector(".modal-description").textContent = `${description}`;
                modalContainer.querySelector(".modal-img").src = `${imageLink}`;


                modalContainer.classList.add("add-modal-container");
                container.append(modalContainer);

                modal.classList.remove("modal");
                modal.classList.add("add-modal");

                //感想を投稿するボタンが押された際に本の情報と共にPOSTメソッドを送信する
                const postModal = modalContainer.querySelector(".post");
                const eventIndex = new Promise((resolve) => {
                    postModal.addEventListener("click", () => {
                        resolve(index);
                    });
                });
                eventIndex.then((i) => {
                    post(api_result_array[i]);
                });

                const modalClose = modalContainer.querySelector(".modal-close");
                modalClose.addEventListener("click", () => {
                    modal.classList.add("modal");
                    modal.classList.remove("add-modal");
                    modalContainer.remove();
                })
            });
        });
    }
}

//要素の並べ替えを行う
export function sort(condition, order, api_result_array) {
    if (condition === "出版日") {
        (order === "昇順") ? api_result_array.sort(arrangeAscendingPublisher) : api_result_array.sort(arrangeDescendingPublisher);
    } else if (condition === "ページ数") {
        (order === "昇順") ? api_result_array.sort(arrangeAscendingPageCount) : api_result_array.sort(arrangeDescendingPageCount);
    } else {
        (order === "昇順") ? api_result_array.sort(arrangeAscendingValue) : api_result_array.sort(arrangeDescendingValue);
    }
}

//指定された要素のdisabled属性を変更する
export function changeDisabledValue(value, elements1, elements2) {
    elements1.forEach((item) => {
        item.disabled = (value === "縦方向一覧") ? false : true;
    });
    elements2.forEach((item) => {
        item.disabled = (value === "縦方向一覧") ? false : TextTrackCue;
    })
}

//出版日順に昇順に並べ替える
export function arrangeAscendingPublisher(val1, val2) {
    let tmpVal1 = val1.publishedDate;
    let tmpVal2 = val2.publishedDate;

    tmpVal1 = new Date(tmpVal1).getTime();
    tmpVal2 = new Date(tmpVal2).getTime();

    return tmpVal1 - tmpVal2;
}
//出版日順に降順に並べ替える
export function arrangeDescendingPublisher(val1, val2) {
    let tmpVal1 = val1.publishedDate;
    let tmpVal2 = val2.publishedDate;

    tmpVal1 = new Date(tmpVal1).getTime();
    tmpVal2 = new Date(tmpVal2).getTime();

    return tmpVal2 - tmpVal1;
}
//ページ数順に昇順に並べ替える
export function arrangeAscendingPageCount(val1, val2) {
    let tmpVal1 = val1.pageCount;
    let tmpVal2 = val2.pageCount;

    return tmpVal1 - tmpVal2;
}
//ページ数順に降順に並べ替える
export function arrangeDescendingPageCount(val1, val2) {
    let tmpVal1 = val1.pageCount;
    let tmpVal2 = val2.pageCount;

    return tmpVal2 - tmpVal1;
}
//価格順に昇順に並べ替える
export function arrangeAscendingValue(val1, val2) {
    let tmpVal1 = val1.value;
    let tmpVal2 = val2.value;

    return tmpVal1 - tmpVal2;
}
//価格順に降順に並べ替える
export function arrangeDescendingValue(val1, val2) {
    let tmpVal1 = val1.value;
    let tmpVal2 = val2.value;

    return tmpVal2 - tmpVal1;
}

//この下で配列を引数に受け取ってそれぞれの要素の日付を矯正するための関数
export function makeDate(array) {
    const regExp = /^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?$/;

    for (let item of array) {
        if (item.publishedDate === undefined) {
            item.publishedDate = "0000-00-00";
            continue;
        }
        //日付の文字列に対してmatchメソッドを適用した結果の配列をmatchという変数に格納する
        const match = item.publishedDate.match(regExp);
        //それぞれの要素に対して分割代入を行い,マッチしなかった箇所を年、月、日の順に取得する
        //第１引数は使用しないので_とする
        if (Array.isArray(match)) {
            const [_, year, month, day] = match;
            //欠損部分を格納するためのオブジェクトを作成する
            const missingParts = {
                year: year ? null : "year",
                month: month ? null : "month",
                day: day ? null : "day"
            };

            //filterメソッドを用いて欠損部分だけを格納した新しい配列を作成する
            const obj = Object.keys(missingParts).filter(key => missingParts[key] !== null);
            if (obj.length === 1) {
                //日が不足している
                item.publishedDate += "-01";
            } else if (obj.length === 2) {
                item.publishedDate += "-01-01";
            } else {
                item.publishedDate = item.publishedDate;
            }
        }

    }
    return array;
}


export function getClickBookInfo() {
    const targets = document.querySelectorAll(".posts-container .post-container");
    targets.forEach((item) => {
        console.log(item);
    })
}



