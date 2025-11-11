$drive = Get-Item 'C:\'

if ($drive.Attributes -band [IO.FileAttributes]::Compressed) {
    Write-Output "The disk is compressed."
} else {
    Write-Output "The disk is not compressed."
}
