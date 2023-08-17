import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.NoBorders (withBorder, noBorders, smartBorders)
import XMonad.Layout.Spacing
import XMonad.Layout.Renamed
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.Ungrab
import XMonad.Layout.IndependentScreens
--import XMonad.Layout.Magnifier
import XMonad.Layout.ThreeColumns
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.ShowText
import XMonad.Util.SpawnOnce
import XMonad.Util.SpawnNamedPipe
import XMonad.Config.Desktop
import XMonad.Actions.CycleWS -- for nextWS
import XMonad.Actions.TiledWindowDragging
import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8
--import XMonad.Config.Prime.Monadic hiding ((|||))
import XMonad.Hooks.SetWMName

main :: IO ()
main = xmonad 
     . ewmhFullscreen
     . ewmh
     . withSB (mySBL <> mySBR)  .docks $ myConfig


mySBL = statusBarPropTo "_XMONAD_LOG_1" "$XMONAD_DIR/xmobartop" $ pure myXmobarPP_top
mySBR = statusBarPropTo "_XMONAD_LOG_2" "$XMONAD_DIR/xmobarbottom" $ pure myXmobarPP_bottom

myConfig = def
    { modMask    = mod1Mask      -- Rebind Mod to the Super key
    , layoutHook = myLayoutHook      -- Use custom layouts
    , manageHook = myManageHook <+> manageDocks -- Match on certain windows
    , terminal   = myTerminal
    , handleEventHook = handleTimerEvent
    , startupHook = setWMName "xmonad"
    }
  `additionalKeysP`
    [ 
      ("M-S-=", unGrab *> spawn "scrot -s")
    , ("<XF86AudioMute>", spawn "amixer -c 1 set Master toggle")
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
    , ("M-S-r", spawn "stack ghc ~/.config/xmonad/xmonad.hs && xmonad --restart")
    , ("M-S-t", spawn "restartTop")
    , ("M-S-o", spawn "restartBottom")
    , ("M-q", spawn "~/.config/xmobar/test")
    , ("M-u", flashText def 1 "->" ) -- >> nextWS is also possible
    , ("M-S-<Space>", sendMessage $ Toggle NOBORDERS ) -- >> nextWS is also possible
    ]
myTerminal :: String
myTerminal = "kitty -o background_opacity=0.8"

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "virt-manager" --> doFloat
    , className =? "zoom" --> doFloat
    , className =? "test" --> doFloat
    , className =? "fontforge" --> doFloat
    , isDialog            --> doFloat
    ]
myLayoutHook = 
      master |||
      full |||
      threeRow |||
      threeCol
  where
    master    = 
      withBorder 1 $
      renamed [Replace "master"] $ 
      spacingWithEdge 8 $
      avoidStruts $ 
      noBorders $ 
      Tall nmaster delta ratio
    full =
      smartBorders $ 
      Full 
    threeRow = 
      renamed [Replace "rows"] $ 
      Mirror $
      noBorders $ 
      ThreeCol nmaster delta ratio
    threeCol = 
      renamed [Replace "columns"] $ 
      noBorders $ 
      ThreeCol nmaster delta ratio

    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes
myXmobarPP_top :: PP
myXmobarPP_top = def
    { ppSep             = magenta " "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap "" "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap "" ""
    , ppHiddenNoWindows = lowWhite . wrap "" ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30
    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""

myXmobarPP_bottom :: PP
myXmobarPP_bottom = def
    { ppSep             = magenta " "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap "" "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap "" ""
    , ppHiddenNoWindows = lowWhite . wrap "" ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where

    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30
    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""
