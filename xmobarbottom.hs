import           Xmobar
import           System.Environment
import           PohaVars

baseConfig :: Config
baseConfig = defaultConfig
  { font             =
    "Source Code Pro 24"
  , additionalFonts = [
                     "DejaVu Sans 24"
                      ]
  , overrideRedirect = False
  , lowerOnStart     = True
  , bgColor          = "#00192A"
  , fgColor          = "#D8DEE9"
  , alpha            = 200
  , sepChar          = "%"
  , alignSep         = "}{"
  , iconRoot         = "~/.config/xmobar/"
  }

bottomBar :: Config
bottomBar = baseConfig 
 { 

    commands = myCommands
  , position = OnScreen 0 (BottomH 35)
  , template =
      "%_XMONAD_LOG_2%" <>
      "}" <>
      "<action=`kitty` button=1>\xe795</action>" <>
      "{" <>
      "%date%"
  }

myCommands :: [Runnable]
myCommands =
  [ 
    Run $ Date "%a %b %d|%H:%M" "date" 10
  , Run $ UnsafeXPropertyLog "_XMONAD_LOG_2"
  , Run $ Com "echo" ["-e","'\x2808'aa"] "echo" 0
  ]


foreground :: String -> String
foreground =  (<> ",#2E3440:0")

main :: IO ()
main = do
    xmobar bottomBar
