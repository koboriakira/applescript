-- HEIC to JPEG Converter
-- HEICファイルをJPEGファイルに変換するAppleScript

on run
	-- ファイル選択ダイアログを表示
	set heicFiles to choose file with prompt "変換するHEICファイルを選択してください:" of type {"public.heic"} with multiple selections allowed
	
	-- 変換処理を実行
	repeat with heicFile in heicFiles
		convertHEICToJPEG(heicFile)
	end repeat
	
	display dialog "変換が完了しました！" buttons {"OK"} default button "OK"
end run

-- HEIC to JPEG変換ハンドラー
on convertHEICToJPEG(heicFile)
	try
		-- ファイルパスとファイル名を取得
		set filePath to POSIX path of heicFile
		set fileName to name of (info for heicFile)
		set baseName to text 1 thru ((offset of "." in fileName) - 1) of fileName
		
		-- 出力ファイルパスを生成（同じディレクトリに.jpegで保存）
		set parentFolder to POSIX path of (container of heicFile as alias)
		set outputPath to parentFolder & baseName & ".jpeg"
		
		-- sipsコマンドを使用してHEICをJPEGに変換
		set shellCommand to "sips -s format jpeg '" & filePath & "' --out '" & outputPath & "'"
		do shell script shellCommand
		
		log "変換完了: " & fileName & " -> " & baseName & ".jpeg"
		
	on error errorMessage
		display dialog "エラーが発生しました: " & errorMessage buttons {"OK"} default button "OK"
		log "変換エラー: " & errorMessage
	end try
end convertHEICToJPEG

-- ドラッグ&ドロップ対応
on open droppedFiles
	repeat with droppedFile in droppedFiles
		-- HEICファイルかどうかチェック
		set fileExtension to name extension of (info for droppedFile)
		if fileExtension is in {"heic", "HEIC"} then
			convertHEICToJPEG(droppedFile)
		end if
	end repeat
	
	display dialog "変換が完了しました！" buttons {"OK"} default button "OK"
end open