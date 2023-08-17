{- Copyright : Altti Tammi
 - License   : BSD3 (See LICENSE)
 -}

{-# LANGUAGE BangPatterns #-}
import Control.Monad (forever)
import Control.Concurrent (threadDelay)
import Data.List (isPrefixOf)
import System.IO
import Data.IORef
import BrailleBar

meterChars   = 10 
meterDots    = 1*meterChars
--lowLength    = div meterChars 2
lowLength    = 4
--mediumLength = 4
mediumLength = 5
lowColor     = "#13ad2f"
mediumColor  = "#feb500"
highColor    = "#f5010a"
milliSecond  = 1000
delay        = 1000*milliSecond
-- 10248,2808,⠈
-- 10241,2801,⠁
-- 10264,2818,⠘
-- 10243,2803,⠃
-- 10296,2838,⠸
-- 10247,2807,⠇
-- 10311,2847,⡇
--
-- 10495,28ff,⣿
main = do
  mapM_ (flip hSetBuffering NoBuffering) [stdin, stdout]
  stat <- newIORef ([[]] :: [[Int]])
  !oldstat <- cpuData
  writeIORef stat oldstat
  let numCPUs    = length oldstat
  let numBars    = div (numCPUs + 3) 4
  let pohaDelimiter = ""
  let delimiters = map (\a -> [a]) $ if numCPUs <= 4
      then ["\10248\10241","\10264\10243","\10296\10247","\10424\10311"]!!(numCPUs - 1) 
      else ' '--'\10424' 
           : (replicate (max 0 (numBars - 2)) ' ') --'\10495'

      --     ++ (["\10495\10311","\10319\10241","\10335\10243","\10367\10247"]!!(mod numCPUs 4))
           ++ ([pohaDelimiter]!!(mod numCPUs 4))
  forever $ do
    threadDelay delay
    newstat <- cpuData
    oldstat <- readIORef stat
    let !load = zipWith coreLoad oldstat newstat
    writeIORef stat newstat
    let bars = map (brailleBar meterDots) $ chunksOf4 $ map (numDots meterDots) $ load
    let coloredBars = flip map bars $ (\bar -> 
                        let (lowstr, temp) = splitAt lowLength bar in
                        let (medstr, histr) = splitAt mediumLength temp in concat 
                        [ "<fc=", lowColor, ">", lowstr, "</fc>"
                        , "<fc=", mediumColor, ">", medstr, "</fc>"
                        , "<fc=", highColor, ">", histr, "</fc>"
                        ])
    putStr ""
    --mapM_ putStr $ interleave ["<fn=1>\x00b0\x2044\x2083</fn>","³⁄₇","⁸⁄₁₁","¹²⁄₁₅","¹⁶⁄₁₉"] coloredBars
    mapM_ putStr $ interleave ["<fn=2><fc=#dad7cd>\xf2db</fc></fn>"
                              ,"<fn=2><fc=#a3b18a>\xf2db</fc></fn>"
                              ,"<fn=2><fc=#588157>\xf2db</fc></fn>"
                              ,"<fn=2><fc=#3a5a40>\xf2db</fc></fn>"
                              ,"<fn=2><fc=#344e41>\xf2db</fc></fn>"
                              ] coloredBars
    putChar '\n'
    hFlush stdout

cpuData :: IO [[Int]]
cpuData = do
  f <- readFile "/proc/stat"
  return $ map (map read . take 4 . tail . words) . takeWhile ("cpu" `isPrefixOf`) . tail . lines $ f

coreLoad :: (Integral a, Fractional b) => [a] -> [a] -> b
coreLoad (a_user:a_nice:a_system:a_idle:_) (b_user:b_nice:b_system:b_idle:_) = (fromIntegral busy) / (fromIntegral $ busy + b_idle - a_idle)
  where busy = b_user + b_nice + b_system - a_user - a_nice - a_system

numDots :: Int -> Double -> Int
numDots totaldots i = round $ i*(fromIntegral $ totaldots)

chunksOf4 :: [Int] -> [[Int]]
chunksOf4 (a:b:c:d:ls) = [a,b,c,d] : chunksOf4 ls
chunksOf4 [] = []
chunksOf4 ls = [ls ++ (replicate (4 - (length ls)) 0)]

interleave [] _ = []
interleave (a:as) b = a : interleave b as
