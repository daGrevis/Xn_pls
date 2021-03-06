module Bot.Bot

where

import Text.Printf

import Control.Monad.Reader as R
import Control.Exception as E

import System.IO
import System.Time

import Network

import Bot.Config
import Bot.Messaging

--
-- Connect to the server and return the initial bot state
--
connect :: IO Bot
connect = notify $ do
    t <- getClockTime
    h <- connectTo server (PortNumber (fromIntegral port))
    hSetBuffering h NoBuffering
    return (Bot h t)
        where
            notify a = bracket_
                (printf "Connecting to %s ... " server >> hFlush stdout)
                (putStrLn "done.")
                a

--
-- We're in the Net monad now, so we've connected successfully
-- Join a channel, and start processing commands
--
run :: Net ()
run = do
    write "NICK" nick
    write "USER" (nick++" 0 * :tutorial bot")
    write "JOIN" chan
    asks socket >>= listen
