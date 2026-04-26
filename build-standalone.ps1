$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$portableDir = Join-Path $root 'Gaming Sidekick Portable'
$buildDir = Join-Path $portableDir 'build'
$iconPath = Join-Path $buildDir 'controller.ico'
$sourcePath = Join-Path $buildDir 'GamingSidekickStandalone.cs'
$exePath = Join-Path $portableDir 'Gaming Sidekick Standalone.exe'
$indexPath = Join-Path $root 'index.html'
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

Add-Type -AssemblyName System.Drawing

$size = 256
$bitmap = New-Object System.Drawing.Bitmap $size, $size
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.Clear([System.Drawing.Color]::Transparent)

function New-RoundRectPath($x, $y, $w, $h, $r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

$graphics.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 13, 83, 99))), (New-RoundRectPath 16 16 224 224 22))
$padPath = New-RoundRectPath 54 88 148 76 28
$leftGrip = New-RoundRectPath 48 108 52 64 22
$rightGrip = New-RoundRectPath 156 108 52 64 22
$padBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 99, 71, 153))
$padOutline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 160, 117, 214)), 8
$graphics.FillPath($padBrush, $leftGrip)
$graphics.FillPath($padBrush, $rightGrip)
$graphics.FillPath($padBrush, $padPath)
$graphics.DrawPath($padOutline, $leftGrip)
$graphics.DrawPath($padOutline, $rightGrip)
$graphics.DrawPath($padOutline, $padPath)
$dpadBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 41, 46, 78))
$graphics.FillRectangle($dpadBrush, 78, 112, 42, 14)
$graphics.FillRectangle($dpadBrush, 92, 98, 14, 42)
$graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 0, 184, 230))), 156, 102, 18, 18)
$graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 92, 162))), 178, 118, 18, 18)
$graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 214, 91))), 140, 120, 14, 14)
$graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 56, 211, 139))), 162, 138, 14, 14)

$pngStream = New-Object System.IO.MemoryStream
$bitmap.Save($pngStream, [System.Drawing.Imaging.ImageFormat]::Png)
$pngBytes = $pngStream.ToArray()
$fs = [System.IO.File]::Create($iconPath)
$bw = New-Object System.IO.BinaryWriter $fs
$bw.Write([UInt16]0)
$bw.Write([UInt16]1)
$bw.Write([UInt16]1)
$bw.Write([Byte]0)
$bw.Write([Byte]0)
$bw.Write([Byte]0)
$bw.Write([Byte]0)
$bw.Write([UInt16]1)
$bw.Write([UInt16]32)
$bw.Write([UInt32]$pngBytes.Length)
$bw.Write([UInt32]22)
$bw.Write($pngBytes)
$bw.Close()
$fs.Close()
$graphics.Dispose()
$bitmap.Dispose()

@'
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace GamingSidekick
{
    internal static class Program
    {
        private const string EmbeddedIndexName = "GamingSidekick.index.html";

        private static void Main()
        {
            string appDir = AppDomain.CurrentDomain.BaseDirectory;
            string profileDir = Path.Combine(appDir, "Profile");
            string runtimeDir = Path.Combine(profileDir, "App");
            string appFile = Path.Combine(runtimeDir, "index.html");

            if (!WriteEmbeddedIndex(appFile)) return;

            string appUrl = new Uri(appFile).AbsoluteUri;

            if (TryLaunchBrowser(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86) + @"\Microsoft\Edge\Application\msedge.exe", appUrl, profileDir)) return;
            if (TryLaunchBrowser(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles) + @"\Microsoft\Edge\Application\msedge.exe", appUrl, profileDir)) return;
            if (TryLaunchBrowser(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles) + @"\Google\Chrome\Application\chrome.exe", appUrl, profileDir)) return;
            if (TryLaunchBrowser(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86) + @"\Google\Chrome\Application\chrome.exe", appUrl, profileDir)) return;

            Process.Start(new ProcessStartInfo { FileName = appFile, UseShellExecute = true });
        }

        private static bool WriteEmbeddedIndex(string appFile)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(appFile));
            Stream input = Assembly.GetExecutingAssembly().GetManifestResourceStream(EmbeddedIndexName);
            if (input == null) return false;
            using (input)
            using (FileStream output = File.Create(appFile))
            {
                input.CopyTo(output);
            }
            return true;
        }

        private static bool TryLaunchBrowser(string browserPath, string appUrl, string profileDir)
        {
            if (!File.Exists(browserPath)) return false;
            Directory.CreateDirectory(profileDir);
            Process.Start(new ProcessStartInfo
            {
                FileName = browserPath,
                Arguments = "--app=\"" + appUrl + "\" --user-data-dir=\"" + profileDir + "\"",
                UseShellExecute = false
            });
            return true;
        }
    }
}
'@ | Set-Content -LiteralPath $sourcePath -Encoding ASCII

if (!(Test-Path -LiteralPath $csc)) {
  throw "Could not find .NET Framework compiler at $csc"
}

& $csc @(
  '/nologo',
  '/target:winexe',
  "/win32icon:$iconPath",
  "/resource:$indexPath,GamingSidekick.index.html",
  "/out:$exePath",
  $sourcePath
)

Get-ChildItem -LiteralPath $portableDir -Filter 'CSC*.TMP' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $buildDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Built $exePath"
