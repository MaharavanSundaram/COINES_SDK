'Usage -  word_to_pdf.vbs <filename.docx>

Main

Sub Main()
    Dim colArgs, intCounter, objFSO, FilePath,FullFilePath
	Set objFSO = CreateObject("Scripting.FileSystemObject")
    FilePath = Wscript.Arguments(0)
    FullFilePath = objFSO.GetAbsolutePathName(FilePath)
    SaveWordAsPDF FullFilePath
End Sub

Sub SaveWordAsPDF(FullFilePath)
    Dim objWord, objDocument,objFSO
    Set objWord = CreateObject("Word.Application")
    Set objDocument = objWord.Documents.Open(FullFilePath)
	Set objFSO = CreateObject("Scripting.FileSystemObject")

    PathOfPDF = objFSO.GetParentFolderName(FullFilePath) & "\"
    PathOfPDF = PathOfPDF & Left(objFSO.GetFileName(FullFilePath), Len(objFSO.GetFileName(FullFilePath)) - Len(objFSO.GetExtensionName(FullFilePath)))
    PathOfPDF = PathOfPDF & "pdf"

    objDocument.SaveAs PathOfPDF, 17
    objDocument.Close FALSE
    objWord.Quit
End Sub