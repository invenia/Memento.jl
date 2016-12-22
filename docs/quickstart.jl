# Copy and paste these line into a REPL and screen capture to produce the
# sample usage image.
using Lumberjack
basic_config("debug"; fmt="[{date} | {level} | {name}]: {msg}")
logger = get_logger(current_module())
debug(logger, "Something that won't get logged.")
info(logger, "Something you might want to know.")
notice(logger, "This is probably pretty important.")
warn(logger, "This might cause an error.")
warn(logger, ErrorException("A caught exception that we want to log as a warning."))
error(logger, "Something that should throw an error.")
critical(logger, "The world is exploding")
alert(logger, "Alert the sysadmin if they're still sleeping.")
emergency(logger, "The world has exploded and you probably brought down the server.")
