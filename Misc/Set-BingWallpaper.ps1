Function Set-WallPaper($value){
add-type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Wallpaper
{
   public enum Style : int
   {
       Tile, Center, Stretch, NoChange
   }


   public class Setter {
      public const int SetDesktopWallpaper = 20;
      public const int UpdateIniFile = 0x01;
      public const int SendWinIniChange = 0x02;

      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
      
      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
         SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
         
         RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
         switch( style )
         {
            case Style.Stretch :
               key.SetValue(@"WallpaperStyle", "2") ; 
               key.SetValue(@"TileWallpaper", "0") ;
               break;
            case Style.Center :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "0") ; 
               break;
            case Style.Tile :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "1") ;
               break;
            case Style.NoChange :
               break;
         }
         key.Close();
      }
   }
}
"@

[Wallpaper.Setter]::SetWallpaper("$env:userprofile\Pictures\Wallpaper\bingimage.jpg","Stretch")


}

If (!(Test-Path "$env:userprofile\Pictures\Wallpaper")) { New-Item -Path "$env:userprofile\Pictures\Wallpaper" -ItemType Directory }

$url = "http://www.bing.com/HPImageArchive.aspx?format=xml&idx=1&n=1&mkt=en-US"
$wc = New-Object net.webclient
$url = $xml.images.image.url

$savelocation = "$env:userprofile\Pictures\Wallpaper\bingimage.jpg"

$wc.DownloadFile("http://www.bing.com" + $url,$savelocation);
# Set-Wallpaper -value ""
Set-Wallpaper -value $savelocation
