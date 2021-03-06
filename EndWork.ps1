$url = "http://xxxxx"
$shell = New-Object -ComObject Shell.Application 
$ie = new-Object -ComObject InternetExplorer.Application
$id = "00000000"
$pw = "XXXXXXXX"

#現在時刻の取得
$now = Get-Date -format "HH:mm"

#メッセージの設定
$title = "確認"
$message = "
終業操作を実行しますか？
現在時刻は"+"$now"+"です
"
#ChoiceDescriptionオブジェクトの生成（第一引数でショートカットボタンの文字,第二文字列でヘルプ表示時の文字）
$Choice = "System.Management.Automation.Host.ChoiceDescription"
$Yes = New-Object $Choice ("&Yes","打刻操作を開始します")　　#選択肢番号0
$No  = New-Object $Choice ("&No","プログラムを終了します")　 #選択肢番号1

#ChoiceDescription型のコレクションを生成
$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes,$No)

#PromptForChoiceを実行（タイトル,メッセージ,選択肢のコレクション,デフォルトの選択肢番号）
$resultVal = $host.ui.PromptForChoice($title,$message,$Options,1)

#Noが押された場合にプログラムを終了する　-neは≠の意味 「not equal」の略？
if($resultVal -ne 0){
    exit
    }

#IE起動
$ie.Visible = $true

#打刻画面に遷移
$ie.Navigate($url)

#IEがビジーの間待つ
while($ie.Busy){
    Start-Sleep -milliseconds 100
    }

#doc生成
$doc = $ie.document

#user_idタグの値を$idにする
$idElements = $doc.getElementsByName("user_id")
@($idElements)[0].value = $id

#passwordタグの値を$pwにする
$passwdElements = $doc.getElementsByName("password")
@($passwdElements)[0].value = $pw

#全てのinputタグを格納する変数$inputElements
$inputElements = $doc.getElementsByTagName("input")
#値が”退　社”のinputElementを探し、見つけたらクリックする
#(何故か配列の添字指定でクリックできないためこういう書き方になっています)
Foreach($inputElement in $inputElements){
    if($inputElement.value -eq " 退 社 "){
        $inputElement.click()
        }
    }
    
#退社完了を待つ
Start-Sleep -milliseconds 100

#ie終了　お疲れ様でした
$ie.Quit()