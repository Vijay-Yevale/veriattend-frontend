Start-Sleep -Seconds 8

$proc = Get-Process | Where-Object {
    $_.MainWindowTitle -like "*Android Emulator*" -or $_.ProcessName -like "*qemu*"
} | Select-Object -First 1

Add-Type -Name Win32MoveWindow -Namespace Win32Functions -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
"@

if ($proc -and $proc.MainWindowHandle -ne 0) {
    [Win32Functions.Win32MoveWindow]::MoveWindow($proc.MainWindowHandle, 0, 0, 900, 700, $true)
    Write-Host "Repositioned emulator window."
} else {
    Write-Host "Window not found yet — bump Start-Sleep up a few seconds and rerun."
}