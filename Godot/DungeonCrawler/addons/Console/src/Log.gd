
extends Reference


enum TYPE \
{
  INFO,
  WARNING,
  ERROR,
  NONE
}


# @var  int
var logLevel = TYPE.WARNING setget setLogLevel


# @param  int  inlogLevel
func setLogLevel(inlogLevel = TYPE.INFO):  # void
  logLevel = inlogLevel


# @param  string  message
# @param  int     type
func log(message, type = TYPE.INFO):  # void
  match type:
    TYPE.INFO:    info(message)
    TYPE.WARNING: warn(message)
    TYPE.ERROR:   error(message)


# @param  string  message
# @param  string  debugInfo
func info(message, debugInfo = ''):  # void
  if logLevel <= TYPE.INFO:
    var write = '[color=blue][INFO][/color] '

    if Console.debugMode and debugInfo:
      write += str(debugInfo) + ': '

    Console.writeLine(write + str(message))


# @param  string  message
# @param  string  debugInfo
func warn(message, debugInfo = ''):  # void
  if logLevel <= TYPE.WARNING:
    var write = '[color=yellow][WARNING][/color] '

    if Console.debugMode and debugInfo:
      write += str(debugInfo) + ': '

    Console.writeLine(write + str(message))


# @param  string  message
# @param  string  debugInfo
func error(message, debugInfo = ''):  # void
  if logLevel <= TYPE.ERROR:
    var write = '[color=red][ERROR][/color] '

    if Console.debugMode and debugInfo:
      write += str(debugInfo) + ': '

    Console.writeLine(write + str(message))


# @param  string  message
# @param  string  debugInfo
func debug(message, debugInfo = ''):  # void
  if Console.debugMode:
    var write = '[color=green][DEBUG][/color] '

    if debugInfo:
      write += str(debugInfo) + ': '

    Console.writeLine(write + str(message))
