
![20240809.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/a49cee53-a725-8aa4-4ffd-23525e624927.gif)
英語のドキュメントを読む時
**日本語訳で何となく読む->意味がわからないところや詳しく知りたいところは英語に戻して読む**
というのはよくやると思います
## Apple Scriptを用意
今回は[こちら](https://sttk3.com/blog/tips/toggle-translate.html)からステキなスクリプトを拝借します
``` AppleScript
(**
  * @file Chrome翻訳の言語を交互に切り替える
  * @version 2.2.0
  * @author sttk3.com
  * @copyright © 2022 sttk3.com
*)
 
on run
	set sleep_seconds to 0.3
	set key_search_window to "ページ内を検索" as text
	set key_translate_window1 to "このページを翻訳しますか？" as text
	set key_translate_window2 to "翻訳済み" as text
	
	tell application "Google Chrome" to activate
	delay sleep_seconds
	
	tell application "System Events"
		tell application process "Google Chrome"
			try
				-- 検索ウインドウが出ている場合，それを閉じる
				if (name of window 1 contains "ページ内を検索") then
					-- Escapeキーを押して検索ウインドウを閉じる
					key code 53
					delay sleep_seconds
				end if
				
				-- 翻訳ウインドウ（ポップアップ）を取得する
				set target_window to my get_popup_window(key_translate_window1)
				if (target_window is missing value) then
					set target_window to my get_popup_window(key_translate_window2)
				end if
				
				-- 翻訳ウインドウが出ていなければ［このページを翻訳］ボタンを見つけて押す
				if (target_window is missing value) then
					-- メインウインドウを見つける。なぜか空のウインドウに邪魔されるので，タイトルがあるものに限定する
					set main_window to item 1 of (every window whose title of it is not "")
					
					-- ［このページを翻訳］ボタンを見つける。なければ終了する
					set translate_buttons to every UI element of group 1 of toolbar 1 of group 1 of group 1 of group 1 of group 1 of main_window whose description of it contains "このページを翻訳"
					if (translate_buttons is {}) then return
					
					-- ［このページを翻訳］ボタンを押す
					click item 1 of translate_buttons
					delay sleep_seconds
				end if
				
				-- 翻訳ウインドウ（ポップアップ）を取得する。なければ終了する
				if (target_window is missing value) then
					set target_window to my get_popup_window(key_translate_window1)
					if (target_window is missing value) then
						set target_window to my get_popup_window(key_translate_window2)
					end if
				end if
				if (target_window is missing value) then return
				
				-- 切り替え先の言語を決める。不明なら終了する
				try
					set lang_buttons to every radio button of tab group 1 of group 1 of group 1 of group 1 of group 1 of target_window whose (name of it ends with "語") and (selected is false)
				on error
					set lang_buttons to every radio button of tab group 1 of group 1 of group 1 of group 1 of group 1 of group 1 of target_window whose (name of it ends with "語") and (selected is false)
				end try
				if (lang_buttons is not {}) then
					set dst_lang_button to item 1 of lang_buttons
				else
					return
				end if
				
				-- 言語を切り替える
				click dst_lang_button
				delay sleep_seconds
				
				-- Escapeキーを押して翻訳ウインドウを閉じる
				key code 53
				
				-- 通知する
				-- display notification dst_lang with title "現在の言語："
			on error error_message number error_number
				log (error_message as text)
				-- skip
			end try
		end tell
	end tell
end run
 
(**
  * 検索・翻訳などのウインドウを取得する
  * @param {text} key_name "検索" "翻訳先の言語"などウインドウの特徴を示す識別子
  * @return {window} 
*)
on get_popup_window(key_name)
	set res to missing value
	tell application "System Events"
		tell application process "Google Chrome"
			-- 検索ウインドウや翻訳ウインドウを見つける
			set nameless_windows to every window whose name of it is key_name
			
			-- 対象のウインドウが出ている場合，それを返す
			if (nameless_windows is not {}) then
				if (every UI element of group 1 of item 1 of nameless_windows is not {}) then
					set res to item 1 of nameless_windows
				end if
			end if
		end tell
	end tell
	
	return res
end get_popup_window
```
## Automatorにスクリプトを登録
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/789ae41a-8a47-fbff-221e-371efc9556f4.png)
このパッと見**釘バット**を持ってそうなアプリを起動します
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/e08d0671-fcac-000e-f29a-0262c5696299.png)
クイックアクション->検索欄で「AppleScript」->「AppleScriptを実行」を追加して先ほどのスクリプトを登録->適当な名前で保存します
(ワークフローが受け取る項目や検索対象はいじらなくて大丈夫だと思います)
![Pasted image 20240809120004.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/3aa23cfe-d49d-8483-6294-fa66084350fa.png)

## システム設定でショートカットキーを設定
システム設定->キーボード->キーボードショートカット->サービス->一般
に先ほど保存したワークフローがあるはず！
![Pasted image 20240809120158.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/4c0f110f-86b8-7868-3978-6144538e1806.png)
お好みのキーボードショートカットを設定してください
私は`control + T`にしました
## 権限を許可
:::note info
Chromeをアクティブにしてショートカットを押したらダイアログが出るはずなのでそっちから設定する方が楽です
(でもノート書くために後から再現しようと思ったけどなんか出なかった)
:::

再び システム設定->プライバシーとセキュリティ->アクセシビリティ
Chromeを追加して許可します
![Pasted image 20240809120847.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/22d22d6e-5a93-bc83-f30e-5b4643354337.png)
## 楽しめ！
翻訳が起動している状態(アドレスバーで確認できる)で設定したショートカットキーを入力！
![Pasted image 20240809120958.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3857288/27e45cec-43e8-497a-673a-29eedf89e19b.png)
## 参考

https://sttk3.com/blog/tips/toggle-translate.html

https://qiita.com/phibi-soon/items/0a79f894d6d68c356432
