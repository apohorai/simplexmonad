import           Xmobar
import           System.Environment
import           PohaVars



baseConfig :: Config
baseConfig = defaultConfig
  { font             = "Source Code Pro 24"
  , additionalFonts  = [
                       "DejaVu Sans 24"
 --                      , "Source Code Pro 24"
                       ]
  , overrideRedirect = False
  , lowerOnStart     = True
 -- , bgColor          = "#00192A"
  , fgColor          = "#D8DEE9"
  , alpha            = 150
  , sepChar          = "%"
  , alignSep         = "}{"
  , iconRoot         = "~/.config/xmobar/"
  }

topBar :: Config
topBar = baseConfig
 { 

    commands = myCommands
  , position = OnScreen 0 (TopH 40)
  , template =
      "<fn=1>%_XMONAD_LOG_1%</fn>" <>
      "}" <>
      "{" <>
      "<fn=1>%cpubar%</fn>" <>
 --     "<fn=1>%netbar%</fn>" <>
        "<fn=1>%soundbar%</fn>" 
 --     "<fc=#13ad2f>aaa</fc>"
  }

myCommands :: [Runnable]
myCommands =
  [
    Run XMonadLog 
   ,  Run $ CommandReader "/home/apohorai/.scripts/haskell/xmobar/cpubar" "cpubar" 
-- ,  Run $ CommandReader "~/.scripts/haskell/xmobar/netbar wlp0s20f0u7" "netbar" 
   ,  Run $ Com "/usr/bin/bash" ["-c","/home/apohorai/.scripts/bash/xmobarVolumeBar.sh"] "soundbar" 10
-- ,  Run $ Com "sh" ["/home/apohorai/.scripts/bash/xmobarMemBar.sh"] "membar" 10
 , Run $ UnsafeXPropertyLog "_XMONAD_LOG_1"
  ]

foreground :: String -> String
foreground =  (<> ",#2E3440:0")

main :: IO ()
main = do
 --   greet
    xmobar topBar
