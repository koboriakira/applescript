-- Downloads HEIC to JPEG Converter with Deletion
-- DownloadsフォルダのHEICファイルをJPEGに変換して元ファイルを削除するAppleScript

on run
	try
		-- Downloadsフォルダのパスを取得
		set downloadsPath to (path to downloads folder) as string

		-- HEICファイルを検索
		set heicFiles to findHEICFiles(downloadsPath)

		if (count of heicFiles) = 0 then
			display dialog "DownloadsフォルダにHEICファイルが見つかりませんでした。" buttons {"OK"} default button "OK"
			return
		end if

		-- 変換確認ダイアログ
		set fileCount to count of heicFiles
		set confirmMessage to (fileCount as string) & "個のHEICファイルが見つかりました。JPEGに変換して元ファイルを削除しますか？"
		set userChoice to display dialog confirmMessage buttons {"キャンセル", "変換実行"} default button "変換実行"

		if button returned of userChoice is "キャンセル" then
			return
		end if

		-- 変換処理を実行
		set successCount to 0
		repeat with heicFile in heicFiles
			if convertAndDeleteHEIC(heicFile) then
				set successCount to successCount + 1
			end if
		end repeat

		-- 結果を表示
		display dialog (successCount as string) & "個のファイルが正常に変換・削除されました。" buttons {"OK"} default button "OK"

	on error errorMessage
		display dialog "エラーが発生しました: " & errorMessage buttons {"OK"} default button "OK"
	end try
end run

-- DownloadsフォルダからHEICファイルを検索するハンドラー
on findHEICFiles(folderPath)
	set heicFiles to {}
	try
		tell application "Finder"
			set downloadsFolder to folder folderPath
			set allFiles to every file of downloadsFolder whose name extension is in {"heic", "HEIC"}
			repeat with aFile in allFiles
				set end of heicFiles to (aFile as alias)
			end repeat
		end tell
	on error
		-- エラーが発生した場合は空のリストを返す
	end try
	return heicFiles
end findHEICFiles

-- HEIC to JPEG変換と削除を行うハンドラー
on convertAndDeleteHEIC(heicFile)
	try
		-- heicFileを明示的にaliasに変換
		set heicFileAlias to heicFile as alias

		-- ファイルパスとファイル名を取得
		set filePath to POSIX path of heicFileAlias
		set fileName to name of (info for heicFileAlias)
		set baseName to text 1 thru ((offset of "." in fileName) - 1) of fileName

		-- 出力ファイルパス（同じDownloadsフォルダに.jpegで保存）
		-- ファイルパスから親フォルダのパスを取得
		set parentFolder to do shell script "dirname '" & filePath & "'"
		set outputPath to parentFolder & "/" & baseName & ".jpeg"

		-- sipsコマンドを使用してHEICをJPEGに変換
		set shellCommand to "sips -s format jpeg '" & filePath & "' --out '" & outputPath & "'"
		do shell script shellCommand

		-- 変換が成功したら元のHEICファイルを削除
		tell application "Finder"
			delete heicFileAlias
		end tell

		log "変換・削除完了: " & fileName & " -> " & baseName & ".jpeg"
		return true

	on error errorMessage
		display dialog "ファイル処理エラー (" & (name of (info for heicFileAlias)) & "): " & errorMessage buttons {"OK"} default button "OK"
		log "変換・削除エラー: " & errorMessage
		return false
	end try
end convertAndDeleteHEIC

-- ドラッグ&ドロップ対応（Downloadsフォルダのチェック付き）
on open droppedFiles
	try
		set processedCount to 0
		repeat with droppedFile in droppedFiles
			-- HEICファイルかどうかチェック
			set fileExtension to name extension of (info for droppedFile)
			if fileExtension is in {"heic", "HEIC"} then
				-- Downloadsフォルダ内かチェック
				set filePath to POSIX path of droppedFile
				set downloadsPath to POSIX path of (path to downloads folder)

				if filePath starts with downloadsPath then
					if convertAndDeleteHEIC(droppedFile) then
						set processedCount to processedCount + 1
					end if
				else
					display dialog "ドラッグされたファイルはDownloadsフォルダ内にありません: " & (name of (info for droppedFile)) buttons {"OK"} default button "OK"
				end if
			end if
		end repeat

		if processedCount > 0 then
			display dialog (processedCount as string) & "個のファイルが処理されました。" buttons {"OK"} default button "OK"
		else
			display dialog "処理できるHEICファイルがありませんでした。" buttons {"OK"} default button "OK"
		end if

	on error errorMessage
		display dialog "ドラッグ&ドロップ処理エラー: " & errorMessage buttons {"OK"} default button "OK"
	end try
end open
