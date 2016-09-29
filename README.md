[![Bless](https://cdn.rawgit.com/LunaGao/BlessYourCodeTag/master/tags/ramen.svg)](http://lunagao.github.io/BlessYourCodeTag/)

![icon](/image/icon.png)

# Skport
Search port and kill it on macOS. using swift.

# Screen Shot
![screenshot](/image/1.png
)

# For what?
If we meet those errors:
> * socket.error: [Errno 48] Address already in use
> * Port already in use: 1099;
> * ···

Skport is (maybe) an easy way to solution to (most, not all) those errors.

#Theory
using `lsof -i:$port` to find PID, then using the `kill -9 $PID` to kill it.

# !!!
This app is designed for professionals, if you use this program to cause any loss, the developer will not be responsible for any.


