//検索結果を入れる配列をimportする
import { api_result_array } from "./search";
document.addEventListener("turbo:load" , () => {
    const targets = document.querySelectorAll(".posts-container .post-container");
    targets.forEach((item , index) => {
        item.addEventListener("click" , (e) => {
            //data属性に含ませていた感想を取り出す
            const content = item.querySelector(".post-name");
        
            //モーダルの背景を表示する
            const modal = document.querySelector(".modal");
            modal.classList.remove("modal");
            modal.classList.add("add-modal");

            const modalContainer = document.querySelector("#modal-post").content.cloneNode(true);
            const container = modalContainer.querySelector(".modal-post-container");

            container.querySelector("#content").textContent = content.dataset.postContent;
            container.querySelector(".modal-a").href = `/posts/good_counter/${content.dataset.postId}`;
            if (container.querySelector(".modal-delete-btn")) {
                container.querySelector(".modal-delete-btn").href = `/posts/destroy/${content.dataset.postId}`;
            }
            container.classList.add("add-modal-post-container");

            const postsContainer = document.querySelector(".posts-container");
            postsContainer.append(container);

            document.querySelector(".modal-post-container img").addEventListener("click" , () => {
                modal.classList.remove("add-modal");
                modal.classList.add("modal");
                
                container.remove();

                console.log("押されました");
                
            })
        });
    })
    
})