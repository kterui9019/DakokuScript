#########################################出社自動化ツールVer1.1#####################################
#　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
#　　使い方　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
#　　①下の入力欄に社員番号とパスワードを入力してください。
#　　②Companyの打刻ページ、勤務入力ページのURLをソース内の"http://xxxxx"の場所に入力してください。　　　　　　　　　　　　　　　　　　　　　　　　　　　
#　　②保存して閉じます。　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 
#　　③出社したくなったらこのファイルを右クリック⇒「PowerShellで実行」をクリックしてください。   　
#　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
####################################################################################################

#2018/7/31 確認メッセージの表示を追加

#############入力欄#############
#""内に社員番号を入力
$id = "00000000"
#""内にCompanyパスワードを入力
$pw = "XXXXXXXX"
################################

#現在時刻の取得
$now = Get-Date -format "HH:mm"

#メッセージの設定
$title = "確認"
$message = "
始業操作を実行しますか？
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

#IEとシェルのCOMオブジェクト生成
$shell = New-Object -ComObject Shell.Application 
$ie = new-Object -ComObject InternetExplorer.Application

#IE起動
$ie.Visible = $true

#打刻ページ遷移
#　※アドレスは下記に入力
$ie.Navigate("http://xxxxx")

#IEがビジーじゃなくなるまで待機
while($ie.Busy){
    Start-Sleep -milliseconds 100
    }

#ie.documentを格納する変数
$doc = $ie.document

#user_idテキストボックスに社員番号を入力
$idElements = $doc.getElementsByName("user_id")
@($idElements)[0].value = $id

#passwordテキストボックスにパスワードを入力
$passwdElements = $doc.getElementsByName("password")
@($passwdElements)[0].value = $pw

#inputタグを取得し、値が"出 社"の場合クリックする
$inputElements = $doc.getElementsByTagName("input")
Foreach($inputElement in $inputElements){
    if($inputElement.value -eq " 出 社 "){
        $inputElement.click()
        }
    }
    
#IEがビジーじゃなくなるまで待機
while($ie.Busy){
Start-Sleep -milliseconds 100
}

#勤務入力画面に遷移
#　※アドレスは下記に入力
$ie.Navigate("http://xxxxx")

#IEがビジーじゃなくなるまで待機
while($ie.Busy){
    Start-Sleep -milliseconds 100
    }

#"uid"テキストボックスに社員番号を入力
$idElements = $doc.getElementsByName("uid")
@($idElements)[0].value = $id

#"pwd"テキストボックスにパスワードを入力
$passwdElements = $doc.getElementsByName("pwd")
@($passwdElements)[0].value = $pw

#inputタグを取得し、値が"ログイン"の場合クリックする
$loginElements = $doc.getElementsByTagName("input")
Foreach($loginElement in $loginElements){
    if($loginElement.value -eq "ログイン"){
        $loginElement.click()
        }
    }

#IEがビジーじゃなくなるまで待機
while($ie.Busy){
Start-Sleep -milliseconds 100
}
    
#就労管理をクリックする
$shurouKanri = $doc.getElementsByTagName("a")
Foreach($shuroukanri in $shurouKanri){
    if($shuroukanri.innerText -eq "就労管理"){
        $shuroukanri.click()
        }
    }

#IEがビジーじゃなくなるまで待機
while($ie.Busy){
Start-Sleep -milliseconds 100
}

$kinmuJissekibo = $doc.getElementsByTagName("a")
Foreach($kinmujissekibo in $kinmuJissekibo){
    if($kinmuJissekibo.innerText -eq "勤務実績整理簿入力"){
        $kinmujissekibo.click()
        }
    }
#################################################################################