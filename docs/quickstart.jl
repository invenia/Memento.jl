# Copy and paste these line into a REPL and screen capture to produce the
# sample usage image.
using Memento
logger = basic_config("debug"; fmt="[{level} | {name}]: {msg}")
debug(logger, "Something to help you track down a bug.")
info(logger, "Something you might want to know.")
notice(logger, "This is probably pretty important.")
warn(logger, "This might cause an error.")
warn(logger, ErrorException("A caught exception that we want to log as a warning."))
error(logger, "Something that should throw an error.")
critical(logger, "The world is exploding")
alert(logger, "Alert the sysadmin if they're still sleeping.")
emergency(logger, "The world has exploded and you probably brought down the server.")
child_logger = get_logger("Foo.bar")
set_level(child_logger, "warn")
add_handler(child_logger, DefaultHandler(tempname(), DefaultFormatter("[{date} | {level} | {name}]: {msg}")))
debug(child_logger, "Something that should only be printed to STDOUT on the root_logger.")
warn(child_logger, "Warning to STDOUT and the log file.")
